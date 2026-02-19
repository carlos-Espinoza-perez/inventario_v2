import 'package:inventario_v2/core/services/image_sync_service.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================
// 1. IMPORTACIONES DE COLECCIONES
// ==========================================

// Auth & Org
import 'package:inventario_v2/features/auth/data/collections/empresa_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/rol_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/acceso_rol_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/usuario_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_usuario_colletion.dart';

// Inventory
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/detalle_movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/regla_costo_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/cargo_adicional_collection.dart';

// Sales & POS
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';

class SyncRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  SyncRepository(this._isar, this._supabase);

  /// ==============================================================================
  /// 1. PUSH: SUBIDA MASIVA (Local -> Nube)
  /// ==============================================================================
  Future<void> pushCambiosLocales() async {
    print("🚀 [Sync] Iniciando Push Masivo...");

    try {
      // NIVEL 0: Configuración y Entidades Raíz
      await _syncEmpresas();
      await _syncReglasCosto();
      await _syncCargosAdicionales();

      // NIVEL 1: Estructura Organizacional
      await _syncRoles();
      await _syncAccesosRol();
      await _syncUsuarios();
      await _syncBodegas();
      await _syncClientes();
      await _syncCategorias();

      // NIVEL 2: Dependencias de Nivel 1
      await _syncBodegaUsuarios();
      await _syncCajas();
      await _syncProductos();

      // NIVEL 3: Operaciones Principales
      await _syncInventario();
      await _syncMovimientos();
      await _syncCajaSesiones();

      // NIVEL 4: Detalles y Transacciones Complejas
      await _syncDetallesMovimientos();
      await _syncVentas();
      await _syncCajaMovimientosExtra();

      // NIVEL 5: Detalles Finales
      await _syncDetallesVentas();
      await _syncHistorialPagos();

      print("✅ [Sync] Push Masivo completado exitosamente.");
    } catch (e) {
      print("❌ [Sync] Error crítico en Push Masivo: $e");
    }
  }

  // ==============================================================================
  // 2. REALTIME: SUBSCRIPCIÓN A CAMBIOS (Nube -> Local)
  // ==============================================================================
  void subscribeToRealtimeChanges() {
    print("📡 [Realtime] Iniciando suscripción a TODAS las tablas...");

    // --- CONFIG ---
    _subscribeTable<EmpresaCollection>(
      tableName: 'empresa',
      collection: _isar.empresaCollections,
      fromJson: (json) => EmpresaCollection.fromJson(json),
    );

    _subscribeTable<ReglaCostoCollection>(
      tableName: 'regla_costo',
      collection: _isar.reglaCostoCollections,
      fromJson: (json) => ReglaCostoCollection.fromJson(json),
    );

    _subscribeTable<CargoAdicionalCollection>(
      tableName: 'cargo_adicional',
      collection: _isar.cargoAdicionalCollections,
      fromJson: (json) => CargoAdicionalCollection.fromJson(json),
    );

    // --- AUTH & ORG ---
    _subscribeTable<RolCollection>(
      tableName: 'rol',
      collection: _isar.rolCollections,
      fromJson: (json) => RolCollection.fromJson(json),
    );

    _subscribeTable<AccesoRolCollection>(
      tableName: 'acceso_rol',
      collection: _isar.accesoRolCollections,
      fromJson: (json) => AccesoRolCollection.fromJson(json),
    );

    _subscribeTable<UsuarioCollection>(
      tableName: 'usuario',
      collection: _isar.usuarioCollections,
      fromJson: (json) => UsuarioCollection.fromJson(json),
    );

    _subscribeTable<BodegaCollection>(
      tableName: 'bodega',
      collection: _isar.bodegaCollections,
      fromJson: (json) => BodegaCollection.fromJson(json),
    );

    _subscribeTable<BodegaUsuarioColletion>(
      tableName: 'bodega_usuario',
      collection: _isar.bodegaUsuarioColletions,
      fromJson: (json) => BodegaUsuarioColletion.fromJson(json),
    );

    // --- CATALOGO ---
    _subscribeTable<CategoriaCollection>(
      tableName: 'categoria',
      collection: _isar.categoriaCollections,
      fromJson: (json) => CategoriaCollection.fromJson(json),
    );

    _subscribeTable<ProductoCollection>(
      tableName: 'producto',
      collection: _isar.productoCollections,
      fromJson: (json) => ProductoCollection.fromJson(json),
    );

    // --- INVENTARIO ---
    _subscribeTable<InventarioCollection>(
      tableName: 'inventario_producto',
      collection: _isar.inventarioCollections,
      fromJson: (json) => InventarioCollection.fromJson(json),
    );

    _subscribeTable<MovimientoProductoCollection>(
      tableName: 'movimiento_producto',
      collection: _isar.movimientoProductoCollections,
      fromJson: (json) => MovimientoProductoCollection.fromJson(json),
    );

    _subscribeTable<DetalleMovimientoProductoCollection>(
      tableName: 'detalle_movimiento_producto',
      collection: _isar.detalleMovimientoProductoCollections,
      fromJson: (json) => DetalleMovimientoProductoCollection.fromJson(json),
    );

    // --- CAJA (POS) ---
    _subscribeTable<CajaCollection>(
      tableName: 'caja',
      collection: _isar.cajaCollections,
      fromJson: (json) => CajaCollection.fromJson(json),
    );

    _subscribeTable<CajaSesionCollection>(
      tableName: 'caja_sesion',
      collection: _isar.cajaSesionCollections,
      fromJson: (json) => CajaSesionCollection.fromJson(json),
    );

    _subscribeTable<CajaMovimientoExtraCollection>(
      tableName: 'caja_movimiento_extra',
      collection: _isar.cajaMovimientoExtraCollections,
      fromJson: (json) => CajaMovimientoExtraCollection.fromJson(json),
    );

    // --- VENTAS ---
    _subscribeTable<ClienteCollection>(
      tableName: 'cliente',
      collection: _isar.clienteCollections,
      fromJson: (json) => ClienteCollection.fromJson(json),
    );

    _subscribeTable<VentaCollection>(
      tableName: 'venta_producto',
      collection: _isar.ventaCollections,
      fromJson: (json) => VentaCollection.fromJson(json),
    );

    _subscribeTable<DetalleVentaCollection>(
      tableName: 'detalle_venta',
      collection: _isar.detalleVentaCollections,
      fromJson: (json) => DetalleVentaCollection.fromJson(json),
    );

    _subscribeTable<HistorialPagoCollection>(
      tableName: 'historial_pago',
      collection: _isar.historialPagoCollections,
      fromJson: (json) => HistorialPagoCollection.fromJson(json),
    );
  }

  /// Helper para escuchar una tabla específica
  void _subscribeTable<T>({
    required String tableName,
    required IsarCollection<T> collection,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    _supabase
        .channel('public:$tableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          callback: (payload) async {
            // print("🔔 [Realtime] Cambio en $tableName: ${payload.eventType}");

            await _isar.writeTxn(() async {
              // INSERT o UPDATE
              if (payload.eventType == PostgresChangeEvent.insert ||
                  payload.eventType == PostgresChangeEvent.update) {
                final newRecord = payload.newRecord;
                try {
                  // Convertir JSON a Objeto Isar
                  final item = fromJson(newRecord);

                  // EVITAR BUCLE INFINITO:
                  // Marcamos el objeto como "ya sincronizado" porque viene de la nube.
                  (item as dynamic).pendienteSincronizacion = false;

                  // Guardar en Isar (Si tiene ID único, actualiza; si no, inserta)
                  // Nota: Asegúrate de que tus colecciones tengan @Index(unique: true, replace: true) en serverId
                  await collection.put(item);
                } catch (e) {
                  print("   ❌ Error Realtime $tableName: $e");
                }
              }
              // DELETE (Opcional: Si usas Soft Delete, esto rara vez se llama)
              else if (payload.eventType == PostgresChangeEvent.delete) {
                // Si borras físicamente en Supabase, aquí deberías borrar en local.
                // print("   ⚠️ Delete físico recibido en $tableName");
              }
            });
          },
        )
        .subscribe();
  }

  // ==============================================================================
  // HELPER GENÉRICO PARA PUSH
  // ==============================================================================
  Future<void> _syncTable<T>({
    required String tableName,
    required List<T> items,
    required Map<String, dynamic> Function(T) toJson,
    required Future<void> Function(List<T>) onCleanup,
  }) async {
    if (items.isEmpty) return;

    try {
      final data = items.map((e) {
        final json = toJson(e);
        json.remove('pendienteSincronizacion');
        return json;
      }).toList();

      await _supabase.from(tableName).upsert(data);
      await onCleanup(items);

      print("⬆️ [Sync] $tableName: ${items.length} subidos.");
    } catch (e) {
      print("⚠️ [Sync] Falló tabla $tableName: $e");
      rethrow;
    }
  }

  // ==============================================================================
  // IMPLEMENTACIONES PUSH POR COLECCIÓN
  // ==============================================================================

  // --- CONFIG ---
  Future<void> _syncEmpresas() async {
    final items = await _isar.empresaCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'empresa',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.empresaCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncReglasCosto() async {
    final items = await _isar.reglaCostoCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'regla_costo',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.reglaCostoCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncCargosAdicionales() async {
    final items = await _isar.cargoAdicionalCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'cargo_adicional',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.cargoAdicionalCollections.put(i);
        }
      }),
    );
  }

  // --- AUTH & ORG ---
  Future<void> _syncRoles() async {
    final items = await _isar.rolCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'rol',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.rolCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncAccesosRol() async {
    final items = await _isar.accesoRolCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'acceso_rol',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.accesoRolCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncUsuarios() async {
    final items = await _isar.usuarioCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'usuario',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.usuarioCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncBodegas() async {
    final items = await _isar.bodegaCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'bodega',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.bodegaCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncBodegaUsuarios() async {
    final items = await _isar.bodegaUsuarioColletions
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'bodega_usuario',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.bodegaUsuarioColletions.put(i);
        }
      }),
    );
  }

  // --- CATALOGO ---
  Future<void> _syncCategorias() async {
    final items = await _isar.categoriaCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'categoria',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.categoriaCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncProductos() async {
    final items = await _isar.productoCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();

    await _syncTable(
      tableName: 'producto',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.productoCollections.put(i);
        }

        ImageSyncService().preCacheImages(list).then((_) {
          print("Imágenes listas para offline");
        });
      }),
    );
  }

  // --- INVENTARIO ---
  Future<void> _syncInventario() async {
    final items = await _isar.inventarioCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'inventario_producto',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.inventarioCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncMovimientos() async {
    final items = await _isar.movimientoProductoCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'movimiento_producto',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.movimientoProductoCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncDetallesMovimientos() async {
    final items = await _isar.detalleMovimientoProductoCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'detalle_movimiento_producto',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.detalleMovimientoProductoCollections.put(i);
        }
      }),
    );
  }

  // --- CAJA (POS) ---
  Future<void> _syncCajas() async {
    final items = await _isar.cajaCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'caja',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.cajaCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncCajaSesiones() async {
    final items = await _isar.cajaSesionCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'caja_sesion',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.cajaSesionCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncCajaMovimientosExtra() async {
    final items = await _isar.cajaMovimientoExtraCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'caja_movimiento_extra',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.cajaMovimientoExtraCollections.put(i);
        }
      }),
    );
  }

  // --- VENTAS ---
  Future<void> _syncClientes() async {
    final items = await _isar.clienteCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'cliente',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.clienteCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncVentas() async {
    final items = await _isar.ventaCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'venta_producto',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.ventaCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncDetallesVentas() async {
    final items = await _isar.detalleVentaCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'detalle_venta',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.detalleVentaCollections.put(i);
        }
      }),
    );
  }

  Future<void> _syncHistorialPagos() async {
    final items = await _isar.historialPagoCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
    await _syncTable(
      tableName: 'historial_pago',
      items: items,
      toJson: (i) => i.toJson(),
      onCleanup: (list) => _isar.writeTxn(() async {
        for (var i in list) {
          i.pendienteSincronizacion = false;
          await _isar.historialPagoCollections.put(i);
        }
      }),
    );
  }

  // ==============================================================================
  // 3. PULL: BAJADA MASIVA (Nube -> Local)
  // Ejecutar esto al iniciar la app para traer cambios ocurridos offline.
  // ==============================================================================
  Future<void> pullRemoteChanges() async {
    print("⬇️ [Sync] Iniciando Bajada Masiva (Pull)...");

    try {
      // El orden importa menos aquí que en el Push, pero es bueno mantener jerarquía

      // 1. Config & Auth
      await _pullTable(
        'empresa',
        _isar.empresaCollections,
        (j) => EmpresaCollection.fromJson(j),
      );
      await _pullTable(
        'regla_costo',
        _isar.reglaCostoCollections,
        (j) => ReglaCostoCollection.fromJson(j),
      );
      await _pullTable(
        'cargo_adicional',
        _isar.cargoAdicionalCollections,
        (j) => CargoAdicionalCollection.fromJson(j),
      );
      await _pullTable(
        'rol',
        _isar.rolCollections,
        (j) => RolCollection.fromJson(j),
      );
      await _pullTable(
        'acceso_rol',
        _isar.accesoRolCollections,
        (j) => AccesoRolCollection.fromJson(j),
      );
      await _pullTable(
        'usuario',
        _isar.usuarioCollections,
        (j) => UsuarioCollection.fromJson(j),
      );
      await _pullTable(
        'bodega',
        _isar.bodegaCollections,
        (j) => BodegaCollection.fromJson(j),
      );
      await _pullTable(
        'bodega_usuario',
        _isar.bodegaUsuarioColletions,
        (j) => BodegaUsuarioColletion.fromJson(j),
      );

      // 2. Catálogo & Inventario
      await _pullTable(
        'categoria',
        _isar.categoriaCollections,
        (j) => CategoriaCollection.fromJson(j),
      );
      await _pullTable(
        'producto',
        _isar.productoCollections,
        (j) => ProductoCollection.fromJson(j),
      );
      await _pullTable(
        'inventario_producto',
        _isar.inventarioCollections,
        (j) => InventarioCollection.fromJson(j),
      );
      await _pullTable(
        'movimiento_producto',
        _isar.movimientoProductoCollections,
        (j) => MovimientoProductoCollection.fromJson(j),
      );
      await _pullTable(
        'detalle_movimiento_producto',
        _isar.detalleMovimientoProductoCollections,
        (j) => DetalleMovimientoProductoCollection.fromJson(j),
      );

      // 3. Ventas & POS
      await _pullTable(
        'cliente',
        _isar.clienteCollections,
        (j) => ClienteCollection.fromJson(j),
      );
      await _pullTable(
        'caja',
        _isar.cajaCollections,
        (j) => CajaCollection.fromJson(j),
      );
      await _pullTable(
        'caja_sesion',
        _isar.cajaSesionCollections,
        (j) => CajaSesionCollection.fromJson(j),
      );
      await _pullTable(
        'caja_movimiento_extra',
        _isar.cajaMovimientoExtraCollections,
        (j) => CajaMovimientoExtraCollection.fromJson(j),
      );
      await _pullTable(
        'venta_producto',
        _isar.ventaCollections,
        (j) => VentaCollection.fromJson(j),
      );
      await _pullTable(
        'detalle_venta',
        _isar.detalleVentaCollections,
        (j) => DetalleVentaCollection.fromJson(j),
      );
      await _pullTable(
        'historial_pago',
        _isar.historialPagoCollections,
        (j) => HistorialPagoCollection.fromJson(j),
      );

      print("✅ [Sync] Bajada Masiva completada.");
    } catch (e) {
      print("❌ [Sync] Error en Bajada Masiva: $e");
    }
  }

  // Helper para traer datos de una tabla
  Future<void> _pullTable<T>(
    String tableName,
    IsarCollection<T> collection,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      // Traemos TODO. (Para optimizar a futuro: filtrar por 'ultima_actualizacion')
      final data = await _supabase.from(tableName).select();

      if (data.isNotEmpty) {
        final items = data.map((json) {
          final item = fromJson(json);
          // Vital: Marcar como NO pendiente de sincronización
          (item as dynamic).pendienteSincronizacion = false;
          return item;
        }).toList();

        await _isar.writeTxn(() async {
          // putAll inserta o actualiza si ya existe el ID (serverId indexado)
          await collection.putAll(items);
        });
        print("   ⬇️ $tableName: ${items.length} recibidos.");
      }
    } catch (e) {
      print("   ⚠️ Error bajando $tableName: $e");
    }
  }
}
