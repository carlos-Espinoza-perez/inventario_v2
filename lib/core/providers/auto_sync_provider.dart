import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/repositories/sync_repository.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/core/services/remote_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_sync_provider.g.dart';

class SyncState {
  final bool isSyncing;
  final bool isOnline;
  final String? lastError;
  final DateTime? lastSync;

  const SyncState({
    this.isSyncing = false,
    this.isOnline = true,
    this.lastError,
    this.lastSync,
  });

  SyncState copyWith({
    bool? isSyncing,
    bool? isOnline,
    String? lastError,
    DateTime? lastSync,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      lastError: lastError,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}

@riverpod
Future<SyncRepository> syncRepository(Ref ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return SyncRepository(db, supabase);
}

@riverpod
class AutoSync extends _$AutoSync {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  final List<StreamSubscription> _tableSubscriptions = [];
  Timer? _debounceTimer;

  @override
  Future<SyncState> build() async {
    final db = ref.watch(driftDatabaseProvider);
    final supabase = ref.watch(supabaseClientProvider);
    final repo = await ref.watch(syncRepositoryProvider.future);

    await RemoteLogger.init(db, supabase);

    repo.subscribeToRealtimeChanges();
    _initConnectivity();
    _initDriftWatchers(db);

    ref.onDispose(() {
      _connectivitySub.cancel();
      _debounceTimer?.cancel();
      for (final sub in _tableSubscriptions) {
        sub.cancel();
      }
    });

    final sesion = await db.authDao.getSesionActiva();
    if (sesion != null) {
      Future.microtask(runFullSync);
    } else {
      AppLogger.info('[AutoSync] Inicializado en espera (sin sesión activa local).');
    }
    return const SyncState();
  }

  Future<void> runFullSync() async {
    final currentState = state.value;
    if (currentState?.isSyncing == true) {
      AppLogger.debug('[AutoSync] Full Sync omitido: ya está en progreso.');
      return;
    }

    final db = ref.read(driftDatabaseProvider);
    final sesion = await db.authDao.getSesionActiva();
    if (sesion == null) {
      AppLogger.debug('[AutoSync] Full Sync omitido: no hay sesión activa.');
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      AppLogger.warn('[AutoSync] Full Sync omitido: sin conexión a internet.');
      return;
    }

    AppLogger.info('[AutoSync] === INICIANDO SINCRONIZACIÓN COMPLETA ===');
    final userId = sesion.usuario.id;
    final empresaId = sesion.empresa.id;
    RemoteLogger.info(
      'Sincronización completa iniciada',
      module: 'sync',
      action: 'full_sync_start',
      userId: userId,
      empresaId: empresaId,
    );
    try {
      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: true,
          lastError: null,
        ),
      );

      final repo = await ref.read(syncRepositoryProvider.future);
      AppLogger.info('[AutoSync] 1. Subiendo cambios locales...');
      await repo.pushCambiosLocales();
      AppLogger.info('[AutoSync] 2. Descargando cambios remotos...');
      await repo.pullRemoteChanges();

      AppLogger.info('[AutoSync] === SINCRONIZACIÓN COMPLETA FINALIZADA CON ÉXITO ===');
      RemoteLogger.info(
        'Sincronización completa finalizada con éxito',
        module: 'sync',
        action: 'full_sync_success',
        userId: userId,
        empresaId: empresaId,
      );
      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
        ),
      );
    } catch (e, st) {
      AppLogger.error('[AutoSync] Fallo en Full Sync', e, st);
      RemoteLogger.error(
        'Fallo en sincronización completa',
        module: 'sync',
        action: 'full_sync_error',
        userId: userId,
        empresaId: empresaId,
        exception: e,
        stackTrace: st,
      );
      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: false,
          lastError: e.toString(),
        ),
      );
    }
  }

  void _initConnectivity() {
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = !results.contains(ConnectivityResult.none);
    final wasOffline = state.value?.isOnline == false;

    state = AsyncData(
      (state.value ?? const SyncState()).copyWith(isOnline: hasConnection),
    );

    if (hasConnection && wasOffline) {
      runFullSync();
      RemoteLogger.flushPending();
    }
  }

  void _initDriftWatchers(AppDatabase db) {
    final stream = db.customSelect('SELECT 1', readsFrom: db.allTables.cast<ResultSetImplementation>().toSet()).watch().skip(1);
    _tableSubscriptions.add(stream.listen((_) => _onLocalChange()));
  }

  void _onLocalChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), triggerSyncNow);
  }

  Future<void> triggerSyncNow() async {
    final currentState = state.value;
    if (currentState == null || currentState.isSyncing) return;

    final db = ref.read(driftDatabaseProvider);
    final sesion = await db.authDao.getSesionActiva();
    if (sesion == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    AppLogger.info('[AutoSync] === Disparando Push de Cambios Locales Inmediato ===');
    try {
      state = AsyncData(
        currentState.copyWith(isSyncing: true, lastError: null),
      );
      final repo = await ref.read(syncRepositoryProvider.future);
      await repo.pushCambiosLocales();
      AppLogger.info('[AutoSync] === Push Inmediato Finalizado con Éxito ===');
      state = AsyncData(
        currentState.copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
        ),
      );
    } catch (e, st) {
      AppLogger.error('[AutoSync] Error en push automático', e, st);
      RemoteLogger.error(
        'Error en push automático de cambios locales',
        module: 'sync',
        action: 'push_error',
        exception: e,
        stackTrace: st,
      );
      state = AsyncData(
        currentState.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }
  }
}
