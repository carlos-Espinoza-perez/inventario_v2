import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/repositories/sync_cursor_store.dart';
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
  final int retryCount;
  final int pendingCount;

  const SyncState({
    this.isSyncing = false,
    this.isOnline = true,
    this.lastError,
    this.lastSync,
    this.retryCount = 0,
    this.pendingCount = 0,
  });

  SyncState copyWith({
    bool? isSyncing,
    bool? isOnline,
    String? lastError,
    DateTime? lastSync,
    int? retryCount,
    int? pendingCount,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      lastError: lastError,
      lastSync: lastSync ?? this.lastSync,
      retryCount: retryCount ?? this.retryCount,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  bool get hasPendingData => pendingCount > 0;
  bool get hasError => lastError != null;
  bool get isCritical => !isOnline && pendingCount > 0;
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
  Timer? _retryTimer;

  bool _isSyncing = false;
  int _syncRetryCount = 0;
  static const int _maxRetryCount = 8;
  static const Duration _baseDelay = Duration(seconds: 2);
  static const Duration _maxDelay = Duration(minutes: 5);

  /// Calcula delay exponencial con jitter para evitar thundering herd.
  Duration _backoffDelay() {
    if (_syncRetryCount == 0) return Duration.zero;
    final exp = _baseDelay * (1 << _syncRetryCount.clamp(0, 10));
    final capped = exp > _maxDelay ? _maxDelay : exp;
    final jitter = Duration(
      milliseconds: (capped.inMilliseconds * 0.25 * (_syncRetryCount % 7 / 7.0)).toInt(),
    );
    return capped + jitter;
  }

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
      _retryTimer?.cancel();
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
    // Check sincrónico primero — cierra la ventana de race condition
    if (_isSyncing) {
      AppLogger.debug('[AutoSync] Full Sync omitido: ya está en progreso.');
      return;
    }
    _isSyncing = true;

    final currentState = state.value;

    final db = ref.read(driftDatabaseProvider);
    final sesion = await db.authDao.getSesionActiva();
    if (sesion == null) {
      AppLogger.debug('[AutoSync] Full Sync omitido: no hay sesión activa.');
      _isSyncing = false;
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      AppLogger.warn('[AutoSync] Full Sync omitido: sin conexión a internet.');
      _isSyncing = false;
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
      final isFirstSync =
          await SyncCursorStore.getLastPullAt('ventas') == null;
      await repo.pullRemoteChanges(forceFull: isFirstSync);

      _syncRetryCount = 0;
      final pendingCount = await repo.countTotalPending();

      AppLogger.info('[AutoSync] === SINCRONIZACIÓN COMPLETA FINALIZADA CON ÉXITO ===');
      RemoteLogger.info(
        'Sincronización completa finalizada con éxito',
        module: 'sync',
        action: 'full_sync_success',
        userId: userId,
        empresaId: empresaId,
      );
      _isSyncing = false;
      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
          retryCount: 0,
          pendingCount: pendingCount,
        ),
      );
    } catch (e, st) {
      AppLogger.error('[AutoSync] Fallo en Full Sync (intento $_syncRetryCount)', e, st);
      RemoteLogger.error(
        'Fallo en sincronización completa',
        module: 'sync',
        action: 'full_sync_error',
        userId: userId,
        empresaId: empresaId,
        exception: e,
        stackTrace: st,
      );

      if (_syncRetryCount < _maxRetryCount) {
        _syncRetryCount++;
        final delay = _backoffDelay();
        AppLogger.info(
          '[AutoSync] Reintentando en ${delay.inSeconds}s (intento $_syncRetryCount/$_maxRetryCount)',
        );
        _retryTimer?.cancel();
        _retryTimer = Timer(delay, runFullSync);
      } else {
        AppLogger.warn(
          '[AutoSync] Máximo de reintentos alcanzado. Sync suspendido hasta próxima reconexión.',
        );
        _syncRetryCount = 0;
      }

      _isSyncing = false;
      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: false,
          lastError: e.toString(),
          retryCount: _syncRetryCount,
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
      _syncRetryCount = 0;
      // Jitter para desincronizar múltiples dispositivos que reconectan a la vez
      final jitter = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch % 3000);
      _retryTimer?.cancel();
      _retryTimer = Timer(jitter, () {
        runFullSync();
        RemoteLogger.flushPending();
      });
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
    // Check sincrónico primero — cierra la ventana de race condition
    if (_isSyncing) return;
    _isSyncing = true;

    final currentState = state.value;
    if (currentState == null) {
      _isSyncing = false;
      return;
    }

    final db = ref.read(driftDatabaseProvider);
    final sesion = await db.authDao.getSesionActiva();
    if (sesion == null) {
      _isSyncing = false;
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _isSyncing = false;
      return;
    }

    AppLogger.info('[AutoSync] === Disparando Push de Cambios Locales Inmediato ===');
    try {
      state = AsyncData(
        currentState.copyWith(isSyncing: true, lastError: null),
      );
      final repo = await ref.read(syncRepositoryProvider.future);
      await repo.pushCambiosLocales();
      final pendingCount = await repo.countTotalPending();
      AppLogger.info('[AutoSync] === Push Inmediato Finalizado con Éxito ===');
      _isSyncing = false;
      state = AsyncData(
        currentState.copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
          pendingCount: pendingCount,
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
      _isSyncing = false;
      state = AsyncData(
        currentState.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }
  }
}
