import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/repositories/sync_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_sync_provider.g.dart';

class SyncState {
  final bool isSyncing;
  final bool isOnline;
  final String? lastError;
  final DateTime? lastSync;

  const SyncState({
    this.isSyncing = false,
    this.isOnline = false,
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
    final repo = await ref.watch(syncRepositoryProvider.future);

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

    Future.microtask(runFullSync);
    return const SyncState();
  }

  Future<void> runFullSync() async {
    final currentState = state.value;
    if (currentState?.isSyncing == true) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    try {
      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: true,
          lastError: null,
        ),
      );

      final repo = await ref.read(syncRepositoryProvider.future);
      await repo.pushCambiosLocales();
      await repo.pullRemoteChanges();

      state = AsyncData(
        (currentState ?? const SyncState()).copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('[AutoSync] Error en Full Sync: $e');
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
    }
  }

  void _initDriftWatchers(AppDatabase db) {
    final streams = [
      db.select(db.empresas).watch().skip(1),
      db.select(db.roles).watch().skip(1),
      db.select(db.accesosRol).watch().skip(1),
      db.select(db.usuarios).watch().skip(1),
      db.select(db.bodegas).watch().skip(1),
      db.select(db.bodegasUsuarios).watch().skip(1),
      db.select(db.cajas).watch().skip(1),
      db.select(db.cajaSesiones).watch().skip(1),
      db.select(db.cajaMovimientosExtras).watch().skip(1),
      db.select(db.categorias).watch().skip(1),
      db.select(db.productos).watch().skip(1),
      db.select(db.productoVariantes).watch().skip(1),
      db.select(db.inventarios).watch().skip(1),
      db.select(db.clientes).watch().skip(1),
      db.select(db.movimientos).watch().skip(1),
      db.select(db.detalleMovimientos).watch().skip(1),
      db.select(db.ventas).watch().skip(1),
      db.select(db.detalleVentas).watch().skip(1),
      db.select(db.pagosVentas).watch().skip(1),
    ];

    for (final stream in streams) {
      _tableSubscriptions.add(stream.listen((_) => _onLocalChange()));
    }
  }

  void _onLocalChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), triggerSyncNow);
  }

  Future<void> triggerSyncNow() async {
    final currentState = state.value;
    if (currentState == null || currentState.isSyncing) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    try {
      state = AsyncData(
        currentState.copyWith(isSyncing: true, lastError: null),
      );
      final repo = await ref.read(syncRepositoryProvider.future);
      await repo.pushCambiosLocales();
      state = AsyncData(
        currentState.copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('[AutoSync] Error en push automatico: $e');
      state = AsyncData(
        currentState.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }
  }
}
