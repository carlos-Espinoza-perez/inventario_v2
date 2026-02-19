import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 1. Core Imports
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/repositories/sync_repository.dart';

// 2. Auth & Org Imports
import 'package:inventario_v2/features/auth/data/collections/empresa_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/usuario_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/rol_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/acceso_rol_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_usuario_colletion.dart';

// 3. Inventory Imports
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/detalle_movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/regla_costo_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/cargo_adicional_collection.dart';

// 4. Sales & POS Imports
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';

// Parte generada por Riverpod Generator
part 'auto_sync_provider.g.dart';

// =============================================================================
// 1. ESTADO DEL SYNC (Inmutable)
// =============================================================================
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

// =============================================================================
// 2. REPOSITORIO PROVIDER
// =============================================================================
@riverpod
Future<SyncRepository> syncRepository(SyncRepositoryRef ref) async {
  // Obtenemos las instancias de BD de forma asíncrona y segura
  final isar = await ref.watch(isarDbProvider.future);
  final supabase = ref.watch(supabaseClientProvider);
  return SyncRepository(isar, supabase);
}

// =============================================================================
// 3. AUTO SYNC NOTIFIER (Lógica Inteligente)
// =============================================================================
@riverpod
class AutoSync extends _$AutoSync {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  final List<StreamSubscription> _isarSubscriptions = [];
  Timer? _debounceTimer;

  @override
  Future<SyncState> build() async {
    final isar = await ref.watch(isarDbProvider.future);
    final repo = await ref.watch(syncRepositoryProvider.future);

    // 1. Activar Realtime
    repo.subscribeToRealtimeChanges();

    // 2. Listeners de Red y BD Local
    _initConnectivity();
    _initIsarWatchers(isar);

    ref.onDispose(() {
      _connectivitySub.cancel();
      _debounceTimer?.cancel();
      for (var sub in _isarSubscriptions) {
        sub.cancel();
      }
    });

    // 3. NUEVO: Ejecutar Sincronización Inicial (Push + Pull)
    // Usamos Future.microtask para no bloquear la construcción inicial del provider
    Future.microtask(() => runFullSync());

    return const SyncState();
  }

  Future<void> runFullSync() async {
    final currentState = state.value;
    if (currentState?.isSyncing == true) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    try {
      print("🔄 [AutoSync] Ejecutando Sincronización Completa (Inicio)...");
      state = AsyncData(
        currentState!.copyWith(isSyncing: true, lastError: null),
      );

      final repo = await ref.read(syncRepositoryProvider.future);

      // 1. PRIMERO: Subimos lo local (Push) para no perder trabajo offline
      await repo.pushCambiosLocales();

      // 2. SEGUNDO: Bajamos lo remoto (Pull) para actualizar
      await repo.pullRemoteChanges();

      state = AsyncData(
        currentState.copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
        ),
      );
      print("✅ [AutoSync] Sincronización Completa Finalizada.");
    } catch (e) {
      print("❌ [AutoSync] Error en Full Sync: $e");
      state = AsyncData(
        currentState!.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }
  }

  // --- A. ESCUCHA DE RED ---
  void _initConnectivity() {
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool hasConnection = !results.contains(ConnectivityResult.none);

    // Guardamos el estado anterior para comparar
    final wasOffline = state.value?.isOnline == false;

    // Actualizamos el estado visual
    state = AsyncData(
      state.value?.copyWith(isOnline: hasConnection) ?? const SyncState(),
    );

    // LÓGICA DE RECUPERACIÓN:
    // Si hay conexión Y antes estábamos desconectados (o es la primera carga)
    if (hasConnection && wasOffline) {
      print(
        "📡 [AutoSync] Internet detectado. Iniciando Sincronización Completa...",
      );

      runFullSync();
    }
  }

  // --- B. ESCUCHA DE ISAR (VIGILANCIA AUTOMÁTICA) ---
  void _initIsarWatchers(Isar isar) {
    print("👀 [AutoSync] Iniciando vigilancia de tablas locales...");

    // Lista maestra de colecciones a vigilar
    final streamsToWatch = [
      isar.empresaCollections.watchLazy(),
      isar.usuarioCollections.watchLazy(),
      isar.rolCollections.watchLazy(),
      isar.accesoRolCollections.watchLazy(),
      isar.bodegaCollections.watchLazy(),
      isar.bodegaUsuarioColletions.watchLazy(),
      isar.categoriaCollections.watchLazy(),
      isar.productoCollections.watchLazy(),
      isar.inventarioCollections.watchLazy(),
      isar.movimientoProductoCollections.watchLazy(),
      isar.detalleMovimientoProductoCollections.watchLazy(),
      isar.clienteCollections.watchLazy(),
      isar.ventaCollections.watchLazy(),
      isar.detalleVentaCollections.watchLazy(),
      isar.historialPagoCollections.watchLazy(),
      isar.cajaCollections.watchLazy(),
      isar.cajaSesionCollections.watchLazy(),
      isar.cajaMovimientoExtraCollections.watchLazy(),
      isar.reglaCostoCollections.watchLazy(),
      isar.cargoAdicionalCollections.watchLazy(),
    ];

    // Suscribirse a cada tabla
    for (var stream in streamsToWatch) {
      final sub = stream.listen((_) => _onLocalChange());
      _isarSubscriptions.add(sub);
    }
  }

  // --- C. LÓGICA DE DEBOUNCE (Eficiencia) ---
  void _onLocalChange() {
    // Se dispara con CUALQUIER cambio en Isar (Insert/Update/Delete)
    _triggerSyncDebounced();
  }

  void _triggerSyncDebounced() {
    // Reiniciamos el timer para evitar spam de peticiones
    _debounceTimer?.cancel();

    // Esperamos 2 segundos de inactividad antes de subir
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      await triggerSyncNow();
    });
  }

  // --- D. EJECUCIÓN DEL SYNC ---
  Future<void> triggerSyncNow() async {
    final currentState = state.value;
    // Si ya está sincronizando o el estado es nulo, abortamos
    if (currentState == null || currentState.isSyncing) return;

    // Verificar conexión real antes de intentar subir
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      print(
        "💾 [AutoSync] Cambios detectados y guardados localmente (Sin internet).",
      );
      return;
    }

    try {
      print("🚀 [AutoSync] Ejecutando subida automática...");
      // 1. Estado: Cargando
      state = AsyncData(
        currentState.copyWith(isSyncing: true, lastError: null),
      );

      // 2. Obtener repositorio y ejecutar push
      final repo = await ref.read(syncRepositoryProvider.future);
      await repo.pushCambiosLocales();

      // 3. Estado: Éxito
      state = AsyncData(
        currentState.copyWith(
          isSyncing: false,
          lastError: null,
          lastSync: DateTime.now(),
        ),
      );
      print("✅ [AutoSync] Sincronización completada.");
    } catch (e) {
      print("❌ [AutoSync] Error: $e");
      // 4. Estado: Error (pero mantenemos isOnline true porque tenemos red, solo falló el proceso)
      state = AsyncData(
        currentState.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }
  }
}
