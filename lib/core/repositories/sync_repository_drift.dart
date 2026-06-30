import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/core/services/image_sync_service.dart';
import 'package:inventario_v2/core/utils/uuid_validator.dart';
import 'package:inventario_v2/core/repositories/sync_cursor_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncRepository {
  SyncRepository(this._db, this._supabase);

  final AppDatabase _db;
  final SupabaseClient _supabase;
  final List<RealtimeChannel> _channels = [];

  Future<void> pushCambiosLocales() async {
    final pendingProductos = await _db.inventoryDao.getPendingProductos();

    await _push(
      'empresa',
      'empresas',
      await _db.authDao.getPendingEmpresas(),
      _empresaToJson,
    );
    await _push(
      'rol',
      'roles',
      await _db.authDao.getPendingRoles(),
      _rolToJson,
    );
    await _push(
      'acceso_rol',
      'accesos_rol',
      await _db.authDao.getPendingAccesosRol(),
      _accesoRolToJson,
    );
    await _push(
      'usuario',
      'usuarios',
      await _db.authDao.getPendingUsuarios(),
      _usuarioToJson,
    );
    await _push(
      'bodega',
      'bodegas',
      await _db.authDao.getPendingBodegas(),
      _bodegaToJson,
    );
    await _push(
      'bodega_usuario',
      'bodegas_usuarios',
      await _db.authDao.getPendingBodegasUsuarios(),
      _bodegaUsuarioToJson,
      onConflict: 'usuario_id, bodega_id',
    );
    await _push(
      'caja',
      'cajas',
      await _db.salesDao.getPendingCajas(),
      _cajaToJson,
    );
    await _push(
      'caja_sesion',
      'caja_sesiones',
      await _db.salesDao.getPendingCajaSesiones(),
      _cajaSesionToJson,
    );
    await _push(
      'caja_movimiento_extra',
      'caja_movimientos_extras',
      await _db.salesDao.getPendingCajaMovimientosExtras(),
      _cajaMovimientoExtraToJson,
    );
    await _push(
      'categoria',
      'categorias',
      await _db.inventoryDao.getPendingCategorias(),
      _categoriaToJson,
    );
    await _push('producto', 'productos', pendingProductos, _productoToJson);
    if (pendingProductos.isNotEmpty) {
      await ImageSyncService().preCacheImages(pendingProductos);
    }
    final pendingVariantes = await _db.inventoryDao.getPendingProductoVariantes();
    await _reconcileProductoVarianteUUIDs(pendingVariantes);
    await _push(
      'codigo_producto',
      'producto_variantes',
      pendingVariantes,
      _productoVarianteToJson,
    );
    final pendingInventarios = await _db.inventoryDao.getPendingInventarios();
    await _reconcileInventarioUUIDs(pendingInventarios);
    await _push(
      'inventario_producto',
      'inventarios',
      pendingInventarios,
      _inventarioToJson,
      onConflict: 'id',
    );
    await _push(
      'cliente',
      'clientes',
      await _db.salesDao.getPendingClientes(),
      _clienteToJson,
    );
    await _pushMovimientosCoordinado();
    await _pushVentasCoordinado();
    // Guard: no intentar subir pagos si la venta padre tiene sync_error.
    // La RLS de historial_pago valida via JOIN a venta_producto.empresa_id,
    // y si la venta no llegó al servidor la validación falla con 42501.
    final ventasError = await _db.salesDao.getVentasSyncError();
    final idsVentasError = ventasError.map((v) => v.id).toSet();
    final pagosPendientes = await _db.salesDao.getPendingPagosVentas();
    final pagosValidos = idsVentasError.isEmpty
        ? pagosPendientes
        : pagosPendientes
            .where((p) => !idsVentasError.contains(p.ventaId))
            .toList();
    await _push('historial_pago', 'pagos_ventas', pagosValidos, _pagoVentaToJson);
  }

  Future<void> _pushVentasCoordinado() async {
    final pendingVentas = await _db.salesDao.getPendingVentas();
    if (pendingVentas.isNotEmpty) {
      await _push('venta_producto', 'ventas', pendingVentas, _ventaToJson);
    }

    final pendingDetalles = await _db.salesDao.getPendingDetalleVentas();
    if (pendingDetalles.isEmpty) return;

    final detallesPorVenta = <String, List<DetalleVenta>>{};
    for (final d in pendingDetalles) {
      detallesPorVenta.putIfAbsent(d.ventaId, () => []).add(d);
    }

    for (final entry in detallesPorVenta.entries) {
      final ventaId = entry.key;
      final detalles = entry.value;
      try {
        final payloads = detalles.map(_detalleVentaToJson).toList();
        final response = await _supabase
            .from('detalle_venta')
            .upsert(payloads)
            .select('id, ultima_actualizacion');
        final serverTs = <String, String>{
          for (final r in response)
            if (r['id'] != null && r['ultima_actualizacion'] != null)
              r['id'].toString(): r['ultima_actualizacion'].toString()
        };
        await _markSyncedWithTimestamps('detalle_ventas', detalles.map((d) => d.id).toList(), serverTs);
      } catch (e) {
        AppLogger.warn(
          '[Sync] Detalles de venta $ventaId fallaron. Revirtiendo padre a pending_update.',
        );
        await _db.transaction(() async {
          await _db.customStatement(
            "UPDATE ventas SET sync_status = 'pending_update' WHERE id = ? AND sync_status = 'synced'",
            [ventaId],
          );
          await _markSyncError(
            'detalle_ventas',
            detalles.map((d) => d.id).toList(),
            e.toString(),
          );
        });
      }
    }
  }

  Future<void> _pushMovimientosCoordinado() async {
    final pendingMovimientos = await _db.inventoryDao.getPendingMovimientos();
    if (pendingMovimientos.isNotEmpty) {
      await _push(
        'movimiento_producto',
        'movimientos',
        pendingMovimientos,
        _movimientoToJson,
      );
    }

    final pendingDetalles =
        await _db.inventoryDao.getPendingDetalleMovimientos();
    if (pendingDetalles.isEmpty) return;

    final detallesPorMovimiento = <String, List<DetalleMovimiento>>{};
    for (final d in pendingDetalles) {
      detallesPorMovimiento.putIfAbsent(d.movimientoId, () => []).add(d);
    }

    for (final entry in detallesPorMovimiento.entries) {
      final movimientoId = entry.key;
      final detalles = entry.value;
      try {
        final payloads = detalles.map(_detalleMovimientoToJson).toList();
        final response = await _supabase
            .from('detalle_movimiento_producto')
            .upsert(payloads)
            .select('id, ultima_actualizacion');
        final serverTs = <String, String>{
          for (final r in response)
            if (r['id'] != null && r['ultima_actualizacion'] != null)
              r['id'].toString(): r['ultima_actualizacion'].toString()
        };
        await _markSyncedWithTimestamps(
          'detalle_movimientos',
          detalles.map((d) => d.id).toList(),
          serverTs,
        );
      } catch (e) {
        AppLogger.warn(
          '[Sync] Detalles de movimiento $movimientoId fallaron. Revirtiendo padre a pending_update.',
        );
        await _db.transaction(() async {
          await _db.customStatement(
            "UPDATE movimientos SET sync_status = 'pending_update' WHERE id = ? AND sync_status = 'synced'",
            [movimientoId],
          );
          await _markSyncError(
            'detalle_movimientos',
            detalles.map((d) => d.id).toList(),
            e.toString(),
          );
        });
      }
    }
  }

  void subscribeToRealtimeChanges() {
    if (_channels.isNotEmpty) return;
    _channels.addAll([
      _subscribe(
        'empresas',
        'empresa',
        (j) =>
            _db.into(_db.empresas).insertOnConflictUpdate(_empresaFromJson(j)),
      ),
      _subscribe(
        'roles',
        'rol',
        (j) => _db.into(_db.roles).insertOnConflictUpdate(_rolFromJson(j)),
      ),
      _subscribe(
        'accesos_rol',
        'acceso_rol',
        (j) => _db
            .into(_db.accesosRol)
            .insertOnConflictUpdate(_accesoRolFromJson(j)),
      ),
      _subscribe(
        'usuarios',
        'usuario',
        (j) =>
            _db.into(_db.usuarios).insertOnConflictUpdate(_usuarioFromJson(j)),
      ),
      _subscribe(
        'bodegas',
        'bodega',
        (j) => _db.into(_db.bodegas).insertOnConflictUpdate(_bodegaFromJson(j)),
      ),
      _subscribe(
        'bodegas_usuarios',
        'bodega_usuario',
        (j) => _db
            .into(_db.bodegasUsuarios)
            .insertOnConflictUpdate(_bodegaUsuarioFromJson(j)),
      ),
      _subscribe(
        'cajas',
        'caja',
        (j) => _db.into(_db.cajas).insertOnConflictUpdate(_cajaFromJson(j)),
      ),
      _subscribe(
        'caja_sesiones',
        'caja_sesion',
        (j) => _db
            .into(_db.cajaSesiones)
            .insertOnConflictUpdate(_cajaSesionFromJson(j)),
      ),
      _subscribe(
        'caja_movimientos_extras',
        'caja_movimiento_extra',
        (j) => _db
            .into(_db.cajaMovimientosExtras)
            .insertOnConflictUpdate(_cajaMovimientoExtraFromJson(j)),
      ),
      _subscribe(
        'categorias',
        'categoria',
        (j) => _db
            .into(_db.categorias)
            .insertOnConflictUpdate(_categoriaFromJson(j)),
      ),
      _subscribe('productos', 'producto', (j) async {
        final companion = _productoFromJson(j);
        await _db.into(_db.productos).insertOnConflictUpdate(companion);
        final producto = await (_db.select(
          _db.productos,
        )..where((t) => t.id.equals(companion.id.value))).getSingleOrNull();
        if (producto != null) {
          await ImageSyncService().preCacheImages([producto]);
        }
      }),
      _subscribe(
        'producto_variantes',
        'codigo_producto',
        (j) => _db
            .into(_db.productoVariantes)
            .insertOnConflictUpdate(_productoVarianteFromJson(j)),
      ),
      _subscribe(
        'inventarios',
        'inventario_producto',
        _upsertInventarioFromJson,
      ),
      _subscribe(
        'clientes',
        'cliente',
        (j) =>
            _db.into(_db.clientes).insertOnConflictUpdate(_clienteFromJson(j)),
      ),
      _subscribe(
        'movimientos',
        'movimiento_producto',
        (j) => _db
            .into(_db.movimientos)
            .insertOnConflictUpdate(_movimientoFromJson(j)),
      ),
      _subscribe(
        'detalle_movimientos',
        'detalle_movimiento_producto',
        (j) => _db
            .into(_db.detalleMovimientos)
            .insertOnConflictUpdate(_detalleMovimientoFromJson(j)),
      ),
      _subscribe(
        'ventas',
        'venta_producto',
        (j) => _db.into(_db.ventas).insertOnConflictUpdate(_ventaFromJson(j)),
      ),
      _subscribe(
        'detalle_ventas',
        'detalle_venta',
        (j) => _db
            .into(_db.detalleVentas)
            .insertOnConflictUpdate(_detalleVentaFromJson(j)),
      ),
      _subscribe(
        'pagos_ventas',
        'historial_pago',
        (j) => _db
            .into(_db.pagosVentas)
            .insertOnConflictUpdate(_pagoVentaFromJson(j)),
      ),
    ]);
  }

  Future<void> pullRemoteChanges({bool forceFull = false}) async {
    await _pull('empresas', 'empresa',
        (j) => _db.into(_db.empresas).insertOnConflictUpdate(_empresaFromJson(j)),
        forceFull: forceFull);
    await _pull('roles', 'rol',
        (j) => _db.into(_db.roles).insertOnConflictUpdate(_rolFromJson(j)),
        forceFull: forceFull);
    await _pull('accesos_rol', 'acceso_rol',
        (j) => _db.into(_db.accesosRol).insertOnConflictUpdate(_accesoRolFromJson(j)),
        forceFull: forceFull);
    await _pull('usuarios', 'usuario',
        (j) => _db.into(_db.usuarios).insertOnConflictUpdate(_usuarioFromJson(j)),
        forceFull: forceFull);
    await _pull('bodegas', 'bodega',
        (j) => _db.into(_db.bodegas).insertOnConflictUpdate(_bodegaFromJson(j)),
        forceFull: forceFull);
    await _pull('bodegas_usuarios', 'bodega_usuario',
        (j) => _db.into(_db.bodegasUsuarios).insertOnConflictUpdate(_bodegaUsuarioFromJson(j)),
        forceFull: forceFull);
    await _pull('cajas', 'caja',
        (j) => _db.into(_db.cajas).insertOnConflictUpdate(_cajaFromJson(j)),
        forceFull: forceFull);
    await _pull('caja_sesiones', 'caja_sesion',
        (j) => _db.into(_db.cajaSesiones).insertOnConflictUpdate(_cajaSesionFromJson(j)),
        forceFull: forceFull);
    await _pull('caja_movimientos_extras', 'caja_movimiento_extra',
        (j) => _db.into(_db.cajaMovimientosExtras).insertOnConflictUpdate(_cajaMovimientoExtraFromJson(j)),
        forceFull: forceFull);
    await _pull('categorias', 'categoria',
        (j) => _db.into(_db.categorias).insertOnConflictUpdate(_categoriaFromJson(j)),
        forceFull: forceFull);
    await _pull('productos', 'producto',
        (j) => _db.into(_db.productos).insertOnConflictUpdate(_productoFromJson(j)),
        forceFull: forceFull);
    await _pull('producto_variantes', 'codigo_producto',
        (j) => _db.into(_db.productoVariantes).insertOnConflictUpdate(_productoVarianteFromJson(j)),
        forceFull: forceFull);
    await _pull('inventarios', 'inventario_producto',
        _upsertInventarioFromJson,
        forceFull: forceFull);
    await _pull('clientes', 'cliente',
        (j) => _db.into(_db.clientes).insertOnConflictUpdate(_clienteFromJson(j)),
        forceFull: forceFull);
    await _pull('movimientos', 'movimiento_producto',
        (j) => _db.into(_db.movimientos).insertOnConflictUpdate(_movimientoFromJson(j)),
        forceFull: forceFull);
    await _pull('detalle_movimientos', 'detalle_movimiento_producto',
        (j) => _db.into(_db.detalleMovimientos).insertOnConflictUpdate(_detalleMovimientoFromJson(j)),
        forceFull: forceFull);
    await _pull('ventas', 'venta_producto',
        (j) => _db.into(_db.ventas).insertOnConflictUpdate(_ventaFromJson(j)),
        forceFull: forceFull);
    await _pull('detalle_ventas', 'detalle_venta',
        (j) => _db.into(_db.detalleVentas).insertOnConflictUpdate(_detalleVentaFromJson(j)),
        forceFull: forceFull);
    await _pull('pagos_ventas', 'historial_pago',
        (j) => _db.into(_db.pagosVentas).insertOnConflictUpdate(_pagoVentaFromJson(j)),
        forceFull: forceFull);
  }

  /// Expone reset de cursores para soporte/debug (próximo pull será completo).
  Future<void> resetSyncCursors() => SyncCursorStore.resetAll();

  Future<void> _upsertInventarioFromJson(Map<String, dynamic> j) async {
    final productoId = _text(j['producto_id']);
    if (productoId != null && j['producto_variante_id'] == null) {
      final variante =
          await (_db.select(_db.productoVariantes)
                ..where((t) => t.productoId.equals(productoId))
                ..limit(1))
              .getSingleOrNull();
      if (variante != null) {
        j['producto_variante_id'] = variante.id;
      }
    }
    await _db
        .into(_db.inventarios)
        .insertOnConflictUpdate(_inventarioFromJson(j));
  }

  Future<bool> _shouldUpdateLocal(
    String tableName,
    Map<String, dynamic> remoteJson,
  ) async {
    final id = remoteJson['id']?.toString();
    if (id == null || id.isEmpty) return true;

    final res = await _db
        .customSelect(
          "SELECT sync_status, updated_at FROM $tableName WHERE id = ? LIMIT 1",
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();

    if (res == null) return true;

    final syncStatus = res.read<String>('sync_status');
    if (syncStatus == 'synced') {
      return true;
    }

    // pending_insert, pending_update y sync_error: comparar timestamps.
    // sync_error tiene un cambio local que falló al subir; no se sobreescribe
    // automáticamente con el dato remoto (que puede ser la versión anterior).
    final localUpdatedAtStr = res.read<String>('updated_at');
    final localUpdatedAt =
        DateTime.tryParse(localUpdatedAtStr) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final remoteUpdatedAtStr =
        remoteJson['ultima_actualizacion']?.toString() ??
        remoteJson['fecha_registro']?.toString();
    final remoteUpdatedAt = remoteUpdatedAtStr != null
        ? DateTime.tryParse(remoteUpdatedAtStr) ??
              DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(0);

    if (localUpdatedAt.isAfter(remoteUpdatedAt) ||
        localUpdatedAt.isAtSameMomentAs(remoteUpdatedAt)) {
      AppLogger.debug(
        '[Sync] Preservando edicion local ($syncStatus) para $tableName ($id)',
      );
      return false;
    }

    if (syncStatus == 'sync_error') {
      AppLogger.warn(
        '[Sync] Sobrescribiendo sync_error con dato remoto más reciente en $tableName ($id)',
      );
    }

    return true;
  }

  /// Antes de enviar variantes pendientes, detecta SKUs que ya existen en
  /// Supabase con distinto UUID. Cuando ocurre, redirige todas las FKs locales
  /// al UUID remoto y marca la variante local duplicada como 'synced' para
  /// que no vuelva a intentarse (evita error 23505 y los 23503 en cascada).
  Future<void> _reconcileProductoVarianteUUIDs(
    List<ProductoVariante> pendingVariantes,
  ) async {
    if (pendingVariantes.isEmpty) return;

    final skus = pendingVariantes.map((v) => v.sku).where((s) => s.isNotEmpty).toList();
    if (skus.isEmpty) return;

    List<dynamic> remoteRows;
    try {
      remoteRows = await _supabase
          .from('codigo_producto')
          .select('id, codigo_sku')
          .inFilter('codigo_sku', skus);
    } catch (e) {
      AppLogger.warn('[Sync][Reconcile] No se pudo consultar codigo_producto remoto: $e');
      return;
    }

    // Mapa SKU → UUID remoto
    final remoteSkuToId = <String, String>{};
    for (final row in remoteRows) {
      final sku = row['codigo_sku']?.toString() ?? '';
      final remoteId = row['id']?.toString() ?? '';
      if (sku.isNotEmpty && remoteId.isNotEmpty) {
        remoteSkuToId[sku] = remoteId;
      }
    }

    for (final variante in pendingVariantes) {
      final remoteId = remoteSkuToId[variante.sku];
      if (remoteId == null || remoteId == variante.id) continue;

      final localId = variante.id;
      AppLogger.info(
        '[Sync][Reconcile] SKU ${variante.sku}: redirigiendo $localId → $remoteId',
      );

      // Primero verificar que el remoto existe antes de modificar BD local.
      // Si falla, saltamos este SKU sin tocar nada — evita FKs rotos.
      Map<String, dynamic> remoteVarianteData;
      try {
        remoteVarianteData = await _supabase
            .from('codigo_producto')
            .select()
            .eq('id', remoteId)
            .single();
      } catch (e) {
        AppLogger.warn('[Sync][Reconcile] No se pudo bajar variante $remoteId, saltando: $e');
        continue;
      }

      // Todos los cambios locales en una transacción atómica
      await _db.transaction(() async {
        await _db.customStatement(
          "UPDATE inventarios SET producto_variante_id = ?, sync_status = 'pending_update' WHERE producto_variante_id = ?",
          [remoteId, localId],
        );
        await _db.customStatement(
          "UPDATE detalle_movimientos SET producto_variante_id = ?, sync_status = 'pending_update' WHERE producto_variante_id = ?",
          [remoteId, localId],
        );
        await _db.customStatement(
          "UPDATE detalle_ventas SET producto_variante_id = ?, sync_status = 'pending_update' WHERE producto_variante_id = ?",
          [remoteId, localId],
        );
        await _db
            .into(_db.productoVariantes)
            .insertOnConflictUpdate(_productoVarianteFromJson(Map<String, dynamic>.from(remoteVarianteData)));
        await _db.customStatement(
          "UPDATE producto_variantes SET sync_status = 'synced' WHERE id = ?",
          [localId],
        );
      });
    }
  }

  /// Antes de enviar inventarios pendientes, detecta filas que ya existen en
  /// Supabase con la misma combinación (producto_variante_id, bodega_id) pero
  /// con distinto UUID. En ese caso redirige el UUID local al remoto y marca
  /// el duplicado como 'synced' para evitar el error 23505 "unique_inventario".
  Future<void> _reconcileInventarioUUIDs(List<Inventario> pendingInventarios) async {
    if (pendingInventarios.isEmpty) return;

    for (final inv in pendingInventarios) {
      List<dynamic> remoteRows;
      try {
        remoteRows = await _supabase
            .from('inventario_producto')
            .select('id')
            .eq('producto_variante_id', inv.productoVarianteId)
            .eq('bodega_id', inv.bodegaId)
            .neq('id', inv.id);
      } catch (e) {
        AppLogger.warn('[Sync][Reconcile] No se pudo consultar inventario_producto remoto: $e');
        continue;
      }

      if (remoteRows.isEmpty) continue;

      final remoteId = remoteRows.first['id']?.toString() ?? '';
      if (remoteId.isEmpty) continue;

      final localId = inv.id;
      AppLogger.info(
        '[Sync][Reconcile] inventario (variante=${inv.productoVarianteId}, bodega=${inv.bodegaId}): redirigiendo $localId → $remoteId',
      );

      // Si el UUID remoto ya existe localmente (bajado en un pull previo),
      // solo marcamos el duplicado como synced para que no se intente subir.
      // Si no existe aún, renombramos para enviarlo con el UUID correcto.
      final alreadyLocal = await _db
          .customSelect(
            "SELECT 1 FROM inventarios WHERE id = ? LIMIT 1",
            variables: [Variable.withString(remoteId)],
          )
          .getSingleOrNull();

      if (alreadyLocal != null) {
        await _db.customStatement(
          "UPDATE inventarios SET sync_status = 'synced' WHERE id = ?",
          [localId],
        );
      } else {
        await _db.customStatement(
          "UPDATE inventarios SET id = ?, sync_status = 'pending_update' WHERE id = ?",
          [remoteId, localId],
        );
      }
    }
  }

  Future<void> _push<T>(
    String remoteTable,
    String localTable,
    List<T> rows,
    FutureOr<Map<String, dynamic>> Function(T row) toJson, {
    String? onConflict,
  }) async {
    if (rows.isEmpty) return;
    AppLogger.info(
      '[Sync][Push] Iniciando subida para $remoteTable ($localTable): ${rows.length} registros pendientes',
    );

    final validPayloads = <Map<String, dynamic>>[];
    final validIds = <String>[];
    final invalidIds = <String>[];

    for (final row in rows) {
      final id = ((row as dynamic).id ?? '').toString();
      try {
        final json = await toJson(row);
        if (_isValidPayload(json)) {
          validPayloads.add(json);
          validIds.add(id);
        } else {
          invalidIds.add(id);
        }
      } catch (e) {
        AppLogger.error(
          '[Sync][Push] Error construyendo payload local $id para $remoteTable',
          e,
        );
        invalidIds.add(id);
      }
    }

    if (invalidIds.isNotEmpty) {
      AppLogger.warn(
        '[Sync][Push] Encontrados ${invalidIds.length} payloads o UUIDs invalidos en $localTable',
      );
      await _markSyncError(localTable, invalidIds, 'Payload o UUID invalido');
    }

    if (validPayloads.isEmpty) return;

    try {
      final response = await _supabase
          .from(remoteTable)
          .upsert(validPayloads, onConflict: onConflict)
          .select('id, ultima_actualizacion');
      final serverTimestamps = <String, String>{};
      for (final row in response) {
        final rid = row['id']?.toString() ?? '';
        final ts = row['ultima_actualizacion']?.toString() ?? '';
        if (rid.isNotEmpty && ts.isNotEmpty) serverTimestamps[rid] = ts;
      }
      await _markSyncedWithTimestamps(localTable, validIds, serverTimestamps);
      AppLogger.info(
        '[Sync][Push] Lote exitoso para $remoteTable: ${validIds.length} registros guardados',
      );
    } catch (batchError) {
      AppLogger.warn(
        '[Sync][Push] Fallo upsert en lote para $remoteTable: $batchError. Reintentando individualmente...',
      );
      for (var i = 0; i < validPayloads.length; i++) {
        final payload = validPayloads[i];
        final id = validIds[i];
        try {
          final itemResponse = await _supabase
              .from(remoteTable)
              .upsert(payload, onConflict: onConflict)
              .select('id, ultima_actualizacion');
          final ts = itemResponse.isNotEmpty
              ? itemResponse.first['ultima_actualizacion']?.toString() ?? ''
              : '';
          await _markSyncedWithTimestamps(localTable, [id], {if (ts.isNotEmpty) id: ts});
        } catch (itemError) {
          final errorStr = itemError.toString();
          // Si intentamos actualizar un usuario que ya fue borrado de auth.users (falla FK 23503)
          if (localTable == 'usuarios' &&
              errorStr.contains('23503') &&
              errorStr.contains('usuarios_id_fkey')) {
            AppLogger.info(
              '[Sync][Push] Ignorando push para usuario ya eliminado remotamente: $id',
            );
            await _markSynced(localTable, [id]);
          } else {
            AppLogger.error(
              '[Sync][Push] Error en registro individual $id en $remoteTable | payload: $payload',
              itemError,
            );
            await _markSyncError(localTable, [id], errorStr);
          }
        }
      }
    }
  }

  RealtimeChannel _subscribe(
    String localTableName,
    String remoteTableName,
    Future<void> Function(Map<String, dynamic>) onUpsert,
  ) {
    return _supabase
        .channel('public:$remoteTableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: remoteTableName,
          callback: (payload) async {
            if (payload.eventType == PostgresChangeEvent.insert ||
                payload.eventType == PostgresChangeEvent.update) {
              try {
                final map = payload.newRecord;
                if (await _shouldUpdateLocal(localTableName, map)) {
                  await onUpsert(map);
                  AppLogger.debug(
                    '[Sync][Realtime] Registro actualizado en $localTableName desde web',
                  );
                }
              } catch (e) {
                final errorStr = e.toString();
                if (errorStr.contains('FOREIGN KEY constraint failed') ||
                    errorStr.contains('code 787')) {
                  final map = payload.newRecord;
                  await _createGhostEntitiesIfMissing(map);
                  try {
                    await onUpsert(map);
                    AppLogger.debug(
                      '[Sync][Realtime] Registro actualizado tras crear fantasma',
                    );
                    return;
                  } catch (retryErr) {
                    AppLogger.error(
                      '[Sync][Realtime] Error retry en $remoteTableName',
                      retryErr,
                    );
                  }
                }
                AppLogger.error(
                  '[Sync][Realtime] Error en $remoteTableName',
                  e,
                );
              }
            }
          },
        )
        .subscribe();
  }

  Future<void> _pull(
    String localTableName,
    String remoteTableName,
    Future<void> Function(Map<String, dynamic>) onUpsert, {
    bool forceFull = false,
  }) async {
    AppLogger.info(
      '[Sync][Pull] Consultando $remoteTableName -> $localTableName',
    );
    try {
      final lastPullAt = forceFull
          ? null
          : await SyncCursorStore.getLastPullAt(localTableName);
      final pullStartTime = DateTime.now().toUtc();

      if (lastPullAt != null) {
        AppLogger.info(
          '[Sync][Pull] Incremental desde ${lastPullAt.toIso8601String()} en $localTableName',
        );
      } else {
        AppLogger.info('[Sync][Pull] Pull completo para $localTableName');
      }

      const pageSize = 500;
      int offset = 0;
      int totalSynced = 0;
      int failedRows = 0;
      bool hasMore = true;

      while (hasMore) {
        var query = _supabase
            .from(remoteTableName)
            .select()
            .order('ultima_actualizacion', ascending: true)
            .range(offset, offset + pageSize - 1);

        if (lastPullAt != null) {
          query = _supabase
              .from(remoteTableName)
              .select()
              .gte('ultima_actualizacion', lastPullAt.toIso8601String())
              .order('ultima_actualizacion', ascending: true)
              .range(offset, offset + pageSize - 1);
        }

        final page = await query;

        for (final row in page) {
          try {
            final map = Map<String, dynamic>.from(row);
            if (await _shouldUpdateLocal(localTableName, map)) {
              await onUpsert(map);
              totalSynced++;
            }
          } catch (itemErr) {
            final errorStr = itemErr.toString();
            if (errorStr.contains('FOREIGN KEY constraint failed') ||
                errorStr.contains('code 787')) {
              final map = Map<String, dynamic>.from(row);
              await _createGhostEntitiesIfMissing(map);
              try {
                await onUpsert(map);
                totalSynced++;
                continue;
              } catch (retryErr) {
                AppLogger.error(
                  '[Sync][Pull] Retry fallo al insertar fila en $localTableName: $row',
                  retryErr,
                );
              }
            } else {
              AppLogger.error(
                '[Sync][Pull] Fallo al insertar fila en $localTableName: $row',
                itemErr,
              );
            }
            failedRows++;
          }
        }

        hasMore = page.length == pageSize;
        offset += pageSize;
      }

      // Solo avanzar el cursor si no hubo filas fallidas individuales.
      // Si hubo fallos, el próximo pull las reintentará desde lastPullAt.
      if (failedRows == 0) {
        await SyncCursorStore.setLastPullAt(localTableName, pullStartTime);
      } else {
        AppLogger.warn(
          '[Sync][Pull] $failedRows filas fallaron en $localTableName. Cursor NO actualizado para reintentar.',
        );
      }
      AppLogger.info(
        '[Sync][Pull] $totalSynced filas sincronizadas en $localTableName',
      );
    } catch (e, st) {
      AppLogger.error(
        '[Sync][Pull] Fallo general al descargar de $remoteTableName',
        e,
        st,
      );
      // No actualizamos el cursor para que el próximo pull sea completo
    }
  }

  Future<void> _markSynced(String tableName, List<String> ids) async {
    if (ids.isEmpty) return;
    final questions = List.filled(ids.length, '?').join(',');
    await _db.customStatement(
      "UPDATE $tableName SET sync_status = 'synced', updated_at = CURRENT_TIMESTAMP WHERE id IN ($questions)",
      ids,
    );
  }

  /// Marca registros como sincronizados usando el timestamp confirmado por el
  /// servidor. Evita divergencia cuando el reloj del dispositivo está desfasado.
  Future<void> _markSyncedWithTimestamps(
    String tableName,
    List<String> ids,
    Map<String, String> serverTimestamps,
  ) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      final ts = serverTimestamps[id];
      if (ts != null && ts.isNotEmpty) {
        await _db.customStatement(
          "UPDATE $tableName SET sync_status = 'synced', updated_at = ? WHERE id = ?",
          [ts, id],
        );
      } else {
        await _db.customStatement(
          "UPDATE $tableName SET sync_status = 'synced' WHERE id = ?",
          [id],
        );
      }
    }
  }

  Future<void> _markSyncError(
    String tableName,
    List<String> ids,
    String errorMessage,
  ) async {
    if (ids.isEmpty) return;
    final questions = List.filled(ids.length, '?').join(',');
    await _db.customStatement(
      "UPDATE $tableName SET sync_status = 'sync_error', updated_at = CURRENT_TIMESTAMP WHERE id IN ($questions)",
      ids,
    );
  }

  Future<void> _createGhostUsersIfMissing(Map<String, dynamic> map) async {
    final possibleUserFields = [
      'usuario_registro_id',
      'usuario_id',
      'usuario_apertura_id',
      'usuario_cierre_id',
      'actualizado_por',
      'vendedor_id',
    ];
    String? empresaId = map['empresa_id']?.toString();

    // Si no hay empresa_id en el map, buscamos una empresa por defecto
    if (empresaId == null || empresaId.isEmpty) {
      final res = await _db
          .customSelect('SELECT id FROM empresas LIMIT 1')
          .getSingleOrNull();
      empresaId = res?.read<String>('id') ?? '';
    }

    if (empresaId.isEmpty) return; // No podemos crear el fantasma sin empresa

    for (final field in possibleUserFields) {
      final userId = map[field]?.toString();
      if (userId == null || userId.isEmpty) continue;
      if (!UuidValidator.isValidUUID(userId)) {
        AppLogger.warn('[Sync] Ghost: UUID inválido en campo $field: $userId');
        continue;
      }
      final exists = await _db
          .customSelect(
            'SELECT 1 FROM usuarios WHERE id = ? LIMIT 1',
            variables: [Variable.withString(userId)],
          )
          .getSingleOrNull();
      if (exists == null) {
        AppLogger.info(
          '[Sync] Creando usuario fantasma para resolver FK: $userId ($field)',
        );
        try {
          await _db.customStatement(
            "INSERT INTO usuarios (id, created_at, updated_at, sync_status, empresa_id, nombre_completo, correo, rol_id, estado, fecha_eliminacion) "
            "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'Usuario Eliminado', ?, NULL, 0, CURRENT_TIMESTAMP)",
            [userId, empresaId, 'eliminado_$userId@sistema.local'],
          );
        } catch (e) {
          AppLogger.warn(
            '[Sync] Error al crear usuario fantasma $userId: $e',
          );
        }
      }
    }
  }

  Future<void> _createGhostProductsIfMissing(Map<String, dynamic> map) async {
    String? empresaId = map['empresa_id']?.toString();
    if (empresaId == null || empresaId.isEmpty) {
      final res = await _db
          .customSelect('SELECT id FROM empresas LIMIT 1')
          .getSingleOrNull();
      empresaId = res?.read<String>('id') ?? '';
    }
    if (empresaId.isEmpty) return;

    final ventaId = map['venta_id']?.toString();
    if (ventaId != null && ventaId.isNotEmpty) {
      if (!UuidValidator.isValidUUID(ventaId)) {
        AppLogger.warn('[Sync] Ghost: UUID inválido en venta_id: $ventaId');
      } else {
        final exists = await _db
            .customSelect(
              'SELECT 1 FROM ventas WHERE id = ? LIMIT 1',
              variables: [Variable.withString(ventaId)],
            )
            .getSingleOrNull();
        if (exists == null) {
          AppLogger.info('[Sync] Creando venta fantasma para resolver FK: $ventaId');
          const dummyId = '00000000-0000-0000-0000-000000000000';
          try {
            await _db.customStatement(
              "INSERT OR IGNORE INTO roles (id, created_at, updated_at, sync_status, empresa_id, nombre, user_admin, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'Rol Eliminado', 0, NULL, 0, CURRENT_TIMESTAMP)",
              [dummyId, empresaId],
            );
            await _db.customStatement(
              "INSERT OR IGNORE INTO usuarios (id, created_at, updated_at, sync_status, empresa_id, rol_id, nombre_completo, correo, password_hash, pin_offline, usuario_registro_id, bodega_default_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, ?, 'Usuario Eliminado', NULL, NULL, NULL, NULL, NULL, 0, CURRENT_TIMESTAMP)",
              [dummyId, empresaId, dummyId],
            );
            await _db.customStatement(
              "INSERT OR IGNORE INTO bodegas (id, created_at, updated_at, sync_status, empresa_id, nombre, direccion, es_punto_venta, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'Bodega Eliminada', '', 0, NULL, 0, CURRENT_TIMESTAMP)",
              [dummyId, empresaId],
            );
            await _db.customStatement(
              "INSERT OR IGNORE INTO clientes (id, created_at, updated_at, sync_status, empresa_id, nombre, identificacion, celular, direccion, monto_credito_maximo, saldo_deudor_actual, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'Cliente Eliminado', NULL, NULL, NULL, 0, 0, NULL, 0, CURRENT_TIMESTAMP)",
              [dummyId, empresaId],
            );
            await _db.customStatement(
              "INSERT OR IGNORE INTO cajas (id, created_at, updated_at, sync_status, empresa_id, bodega_id, nombre, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, ?, 'Caja Eliminada', NULL, 0, CURRENT_TIMESTAMP)",
              [dummyId, empresaId, dummyId],
            );
            await _db.customStatement(
              "INSERT OR IGNORE INTO caja_sesiones (id, created_at, updated_at, sync_status, caja_id, usuario_apertura_id, usuario_cierre_id, fecha_apertura, fecha_cierre, monto_inicial, total_ventas_sistema, total_efectivo_real, diferencia, estado_sesion, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, ?, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, 0, 0, 0, 'cerrada', CURRENT_TIMESTAMP)",
              [dummyId, dummyId, dummyId],
            );
            await _db.customStatement(
              "INSERT OR IGNORE INTO ventas (id, created_at, updated_at, sync_status, empresa_id, cliente_id, usuario_id, caja_sesion_id, tipo_venta, estado_pago, total_venta, total_pagado, saldo_pendiente, fecha_venta, fecha_vencimiento, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, ?, ?, ?, 'EFECTIVO', 'PAGADO', 0, 0, 0, CURRENT_TIMESTAMP, NULL, 0, CURRENT_TIMESTAMP)",
              [ventaId, empresaId, dummyId, dummyId, dummyId],
            );
          } catch (e) {
            AppLogger.warn('[Sync] Error al crear venta fantasma $ventaId: $e');
          }
        }
      }
    }

    final categoriaId = map['categoria_id']?.toString();
    if (categoriaId != null && categoriaId.isNotEmpty) {
      if (!UuidValidator.isValidUUID(categoriaId)) {
        AppLogger.warn('[Sync] Ghost: UUID inválido en categoria_id: $categoriaId');
      } else {
        final exists = await _db
            .customSelect(
              'SELECT 1 FROM categorias WHERE id = ? LIMIT 1',
              variables: [Variable.withString(categoriaId)],
            )
            .getSingleOrNull();
        if (exists == null) {
          AppLogger.info('[Sync] Creando categoria fantasma para resolver FK: $categoriaId');
          try {
            await _db.customStatement(
              "INSERT INTO categorias (id, created_at, updated_at, sync_status, empresa_id, nombre, categoria_padre_id, especificacion_json, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'Categoria Eliminada', NULL, NULL, NULL, 0, CURRENT_TIMESTAMP)",
              [categoriaId, empresaId],
            );
          } catch (e) {
            AppLogger.warn('[Sync] Error al crear categoria fantasma $categoriaId: $e');
          }
        }
      }
    }

    final bodegaId = map['bodega_id']?.toString();
    if (bodegaId != null && bodegaId.isNotEmpty) {
      if (!UuidValidator.isValidUUID(bodegaId)) {
        AppLogger.warn('[Sync] Ghost: UUID inválido en bodega_id: $bodegaId');
      } else {
        final exists = await _db
            .customSelect(
              'SELECT 1 FROM bodegas WHERE id = ? LIMIT 1',
              variables: [Variable.withString(bodegaId)],
            )
            .getSingleOrNull();
        if (exists == null) {
          AppLogger.info('[Sync] Creando bodega fantasma para resolver FK: $bodegaId');
          try {
            await _db.customStatement(
              "INSERT INTO bodegas (id, created_at, updated_at, sync_status, empresa_id, nombre, direccion, es_punto_venta, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'Bodega Eliminada', '', 0, NULL, 0, CURRENT_TIMESTAMP)",
              [bodegaId, empresaId],
            );
          } catch (e) {
            AppLogger.warn('[Sync] Error al crear bodega fantasma $bodegaId: $e');
          }
        }
      }
    }

    final productoId = map['producto_id']?.toString();
    if (productoId != null && productoId.isNotEmpty) {
      if (!UuidValidator.isValidUUID(productoId)) {
        AppLogger.warn('[Sync] Ghost: UUID inválido en producto_id: $productoId');
      } else {
        final exists = await _db
            .customSelect(
              'SELECT 1 FROM productos WHERE id = ? LIMIT 1',
              variables: [Variable.withString(productoId)],
            )
            .getSingleOrNull();
        if (exists == null) {
          AppLogger.info('[Sync] Creando producto fantasma para resolver FK: $productoId');
          try {
            await _db.customStatement(
              "INSERT INTO productos (id, created_at, updated_at, sync_status, empresa_id, categoria_id, nombre, precio_base, ultimo_costo, ultimo_precio_venta, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, NULL, 'Producto Eliminado', 0, 0, 0, NULL, 0, CURRENT_TIMESTAMP)",
              [productoId, empresaId],
            );
          } catch (e) {
            AppLogger.warn('[Sync] Error al crear producto fantasma $productoId: $e');
          }
        }
      }
    }

    final varianteId = map['producto_variante_id']?.toString();
    if (varianteId != null && varianteId.isNotEmpty) {
      if (!UuidValidator.isValidUUID(varianteId)) {
        AppLogger.warn('[Sync] Ghost: UUID inválido en producto_variante_id: $varianteId');
      } else {
        final exists = await _db
            .customSelect(
              'SELECT 1 FROM producto_variantes WHERE id = ? LIMIT 1',
              variables: [Variable.withString(varianteId)],
            )
            .getSingleOrNull();
        if (exists == null) {
          AppLogger.info('[Sync] Creando variante fantasma para resolver FK: $varianteId');
          try {
            const dummyId = '00000000-0000-0000-0000-000000000000';
            final pIdForVar = (productoId != null && UuidValidator.isValidUUID(productoId))
                ? productoId
                : dummyId;
            if (pIdForVar == dummyId) {
              await _db.customStatement(
                "INSERT OR IGNORE INTO productos (id, created_at, updated_at, sync_status, empresa_id, categoria_id, nombre, precio_base, ultimo_costo, ultimo_precio_venta, usuario_registro_id, estado, fecha_eliminacion) "
                "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, NULL, 'Producto Eliminado', 0, 0, 0, NULL, 0, CURRENT_TIMESTAMP)",
                [dummyId, empresaId],
              );
            }
            await _db.customStatement(
              "INSERT INTO producto_variantes (id, created_at, updated_at, sync_status, producto_id, sku, talla, precio_especifico, costo_especifico, usuario_registro_id, estado, fecha_eliminacion) "
              "VALUES (?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'synced', ?, 'VARI-ELIMINADA', 'Variante Eliminada', 0, 0, NULL, 0, CURRENT_TIMESTAMP)",
              [varianteId, pIdForVar],
            );
          } catch (e) {
            AppLogger.warn('[Sync] Error al crear variante fantasma $varianteId: $e');
          }
        }
      }
    }
  }

  Future<void> _createGhostEntitiesIfMissing(Map<String, dynamic> map) async {
    await _createGhostUsersIfMissing(map);
    await _createGhostProductsIfMissing(map);
  }

  bool _isValidPayload(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    if (!UuidValidator.isValidUUID(id)) return false;
    for (final entry in json.entries) {
      // referencia_venta_id es opcional y puede contener referencias externas
      // no-UUID (ej: número de transacción bancaria), por eso se excluye.
      if (!entry.key.endsWith('_id') || entry.key == 'referencia_venta_id') {
        continue;
      }
      final value = entry.value?.toString();
      if (value != null &&
          value.isNotEmpty &&
          !UuidValidator.isValidUUID(value)) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> _syncMap(
    String id,
    DateTime createdAt,
    DateTime updatedAt,
    String status,
  ) => {
    'id': id,
    'fecha_registro': createdAt.toIso8601String(),
    'ultima_actualizacion': updatedAt.toIso8601String(),
  };

  DateTime _date(dynamic value) => value == null
      ? DateTime.now()
      : DateTime.tryParse(value.toString()) ?? DateTime.now();
  double _double(dynamic value, [double fallback = 0]) =>
      value == null ? fallback : (value as num).toDouble();
  bool _bool(dynamic value, [bool fallback = true]) => value is bool
      ? value
      : value is num
      ? value != 0
      : value is String
      ? value.toLowerCase() == 'true'
      : fallback;
  String? _text(dynamic value) => value?.toString();
  String? _json(dynamic value) => value == null
      ? null
      : value is String
      ? value
      : jsonEncode(value);

  Map<String, dynamic> _empresaToJson(Empresa r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'nombre': r.nombre,
    'nombre_comercial': r.nombreComercial,
    'ruc': r.ruc,
    'configuracion': r.configuracion,
    'estado': r.estado,
    'usuario_registro_id': r.usuarioRegistroId,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _rolToJson(Role r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'nombre': r.nombre,
    'user_admin': r.userAdmin,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _accesoRolToJson(AccesosRolData r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'rol_id': r.rolId,
    'codigo_acceso': r.codigoAcceso,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _usuarioToJson(Usuario r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'rol_id': r.rolId,
    'nombre_completo': r.nombreCompleto,
    'correo': r.correo,
    // password_hash no se sincroniza: Supabase Auth maneja la autenticación principal
    'pin_offline': r.pinOffline,
    'bodega_default_id': r.bodegaDefaultId,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _bodegaToJson(Bodega r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'nombre': r.nombre,
    'direccion': r.direccion,
    'descripcion': r.descripcion,
    'es_punto_venta': r.esPuntoVenta,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _bodegaUsuarioToJson(BodegasUsuario r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'usuario_id': r.usuarioId,
    'bodega_id': r.bodegaId,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _cajaToJson(Caja r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'bodega_id': r.bodegaId,
    'nombre': r.nombre,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _cajaSesionToJson(CajaSesione r) {
    final map = {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'caja_id': r.cajaId,
      'usuario_apertura_id': r.usuarioAperturaId,
      'usuario_cierre_id': r.usuarioCierreId,
      'fecha_apertura': r.fechaApertura.toIso8601String(),
      'fecha_cierre': r.fechaCierre?.toIso8601String(),
      'monto_inicial': r.montoInicial,
      'total_ventas_sistema': r.totalVentasSistema,
      'total_efectivo_real': r.totalEfectivoReal,
      'diferencia': r.diferencia,
      'estado_sesion': r.estadoSesion,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
    map.remove('fecha_registro');
    return map;
  }

  Map<String, dynamic> _cajaMovimientoExtraToJson(CajaMovimientosExtra r) {
    final map = {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'caja_sesion_id': r.cajaSesionId,
      'referencia_venta_id': r.referenciaVentaId,
      'tipo': r.tipo,
      'motivo': r.motivo,
      'monto': r.monto,
      'usuario_registro_id': r.usuarioRegistroId,
      'estado': r.estado,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
    map.remove('fecha_registro');
    return map;
  }
  Map<String, dynamic> _categoriaToJson(Categoria r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'nombre': r.nombre,
    'categoria_padre_id': r.categoriaPadreId,
    'especificacion': r.especificacionJson,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _productoToJson(Producto r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'categoria_id': r.categoriaId,
    'nombre': r.nombre,
    'codigo_personalizado': r.codigoPersonalizado,
    'descripcion': r.descripcion,
    'especificacion': r.especificacionJson,
    'precio_base': r.precioBase,
    'ultimo_costo': r.ultimoCosto,
    'ultimo_precio_venta': r.ultimoPrecioVenta,
    'imagen_url': r.imagenUrl,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _productoVarianteToJson(ProductoVariante r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'producto_id': r.productoId,
    'codigo_sku': r.sku,
    'talla': r.talla,
    'color': r.color,
    'precio_especifico': r.precioEspecifico,
    'costo_especifico': r.costoEspecifico,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Future<Map<String, dynamic>> _inventarioToJson(Inventario r) async {
    final variante =
        await (_db.select(_db.productoVariantes)
              ..where((tbl) => tbl.id.equals(r.productoVarianteId))
              ..limit(1))
            .getSingleOrNull();

    if (variante == null) {
      throw StateError(
        'No existe la variante local ${r.productoVarianteId} para inventario ${r.id}',
      );
    }

    final map = {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'producto_id': variante.productoId,
      'producto_variante_id': r.productoVarianteId,
      'bodega_id': r.bodegaId,
      'cantidad_actual': r.cantidadActual,
      'cantidad_reservada': r.cantidadReservada,
      'ubicacion_pasillo': r.ubicacionPasillo,
      'precio_venta': r.precioVenta,
      'costo_promedio': r.costoPromedio,
      'actualizado_por': r.actualizadoPor,
      'estado': r.estado,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
    return map;
  }

  Map<String, dynamic> _clienteToJson(Cliente r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'empresa_id': r.empresaId,
    'nombre': r.nombre,
    'identificacion': r.identificacion,
    'celular': r.celular,
    'direccion': r.direccion,
    'monto_credito_maximo': r.montoCreditoMaximo,
    'saldo_deudor_actual': r.saldoDeudorActual,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
  };
  Map<String, dynamic> _movimientoToJson(Movimiento r) {
    return {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'empresa_id': r.empresaId,
      'bodega_origen_id': r.bodegaOrigenId,
      'bodega_destino_id': r.bodegaDestinoId,
      'tipo_movimiento': _tipoMovimientoToRemote(r.tipoMovimiento),
      // Preserva el valor local exacto para recuperarlo en el pull sin pérdida
      'tipo_movimiento_local': r.tipoMovimiento,
      'estado_movimiento': r.estadoMovimiento,
      'descripcion': r.descripcion,
      'usuario_registro_id': r.usuarioRegistroId,
      'estado': r.estado,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
  }

  String _tipoMovimientoToRemote(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'entrada' => 'compra',
      'salida'  => 'ajuste',
      'traslado' => 'traslado',
      'ajuste'  => 'ajuste',
      'compra'  => 'compra',
      _ => () {
        // Valor no mapeado — puede fallar en Supabase si tiene CHECK constraint
        AppLogger.warn(
          '[Sync] tipo_movimiento desconocido en push: "$normalized". '
          'Actualizar _tipoMovimientoToRemote si el servidor acepta este valor.',
        );
        return normalized;
      }(),
    };
  }

  /// Prioriza el campo [localValue] (tipo_movimiento_local) guardado en Supabase
  /// para recuperar el valor original sin pérdida al hacer pull.
  String _tipoMovimientoFromRemote(String? remoteValue, {String? localValue}) {
    if (localValue != null && localValue.isNotEmpty) return localValue;
    final normalized = remoteValue?.trim().toLowerCase() ?? '';
    return switch (normalized) {
      'compra' => 'entrada',
      _ => normalized,
    };
  }

  Map<String, dynamic> _detalleMovimientoToJson(DetalleMovimiento r) {
    // cargos_adicionales en Supabase es JSONB, debemos enviar objeto parseado
    dynamic cargosValue;
    if (r.cargosAdicionalesJson != null) {
      try {
        cargosValue = jsonDecode(r.cargosAdicionalesJson!);
      } catch (_) {
        cargosValue = null;
      }
    }
    return {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'movimiento_producto_id': r.movimientoId,
      'producto_id': r.productoId,
      'producto_variante_id': r.productoVarianteId,
      'cantidad': r.cantidad,
      'costo_proveedor': r.costoProveedor,
      'costo_unitario_final': r.costoUnitarioFinal,
      'cargos_adicionales': cargosValue,
      'variantes_json': r.variantesJson,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
  }

  Map<String, dynamic> _ventaToJson(Venta r) {
    final map = {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'empresa_id': r.empresaId,
      'cliente_id': r.clienteId,
      'usuario_registro_id': r.usuarioId,
      'caja_sesion_id': r.cajaSesionId,
      'tipo_venta': r.tipoVenta,
      'estado_pago': r.estadoPago,
      'total_venta': r.totalVenta,
      'total_pagado': r.totalPagado,
      'saldo_pendiente': r.saldoPendiente,
      'fecha_venta': r.fechaVenta.toIso8601String(),
      'fecha_vencimiento': r.fechaVencimiento?.toIso8601String(),
      'estado': r.estado,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
    map.remove('fecha_registro');
    return map;
  }

  Map<String, dynamic> _detalleVentaToJson(DetalleVenta r) {
    return {
      ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
      'venta_id': r.ventaId,
      'producto_id': r.productoId,
      'producto_variante_id': r.productoVarianteId,
      'cantidad': r.cantidad,
      'precio_unitario': r.precioUnitario,
      'descuento': r.descuento,
      'sub_total': r.subTotal,
      'costo_historico_compra': r.costoHistoricoCompra,
      'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    };
  }

  Map<String, dynamic> _pagoVentaToJson(PagosVenta r) => {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    'venta_id': r.ventaId,
    'caja_sesion_id': r.cajaSesionId,
    'monto_pagado': r.montoPagado,
    'metodo_de_pago': r.metodoPago,
    'referencia': r.referencia,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    'fecha_registro_pago': r.fechaRegistro.toIso8601String(),
  };

  EmpresasCompanion _empresaFromJson(Map<String, dynamic> j) =>
      EmpresasCompanion.insert(
        id: _text(j['id']) ?? '',
        nombre: _text(j['nombre']) ?? 'Sin nombre',
        nombreComercial: Value(_text(j['nombre_comercial'])),
        ruc: Value(_text(j['ruc'])),
        configuracion: Value(_json(j['configuracion'])),
        estado: Value(_bool(j['estado'])),
        usuarioRegistroId: const Value(null),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  RolesCompanion _rolFromJson(Map<String, dynamic> j) => RolesCompanion.insert(
    id: _text(j['id']) ?? '',
    empresaId: _text(j['empresa_id']) ?? '',
    nombre: _text(j['nombre']) ?? 'Sin nombre',
    userAdmin: Value(_bool(j['user_admin'], false)),
    usuarioRegistroId: const Value(null),
    estado: Value(_bool(j['estado'])),
    createdAt: Value(_date(j['fecha_registro'])),
    updatedAt: Value(_date(j['ultima_actualizacion'])),
    fechaEliminacion: Value(
      j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
    ),
    syncStatus: const Value('synced'),
  );
  AccesosRolCompanion _accesoRolFromJson(Map<String, dynamic> j) =>
      AccesosRolCompanion.insert(
        id: _text(j['id']) ?? '',
        rolId: _text(j['rol_id']) ?? '',
        codigoAcceso: _text(j['codigo_acceso']) ?? '',
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  UsuariosCompanion _usuarioFromJson(Map<String, dynamic> j) =>
      UsuariosCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        rolId: _text(j['rol_id']) ?? '',
        nombreCompleto: _text(j['nombre_completo']) ?? 'Sin nombre',
        correo: Value(_text(j['correo'])),
        passwordHash: Value(_text(j['password_hash'])),
        pinOffline: Value(_text(j['pin_offline'])),
        usuarioRegistroId: const Value(null),
        bodegaDefaultId: Value(_text(j['bodega_default_id'])),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  BodegasCompanion _bodegaFromJson(Map<String, dynamic> j) =>
      BodegasCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        nombre: _text(j['nombre']) ?? 'Sin nombre',
        direccion: Value(_text(j['direccion'])),
        descripcion: Value(_text(j['descripcion'])),
        esPuntoVenta: Value(_bool(j['es_punto_venta'], false)),
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  BodegasUsuariosCompanion _bodegaUsuarioFromJson(Map<String, dynamic> j) =>
      BodegasUsuariosCompanion.insert(
        id: _text(j['id']) ?? '',
        usuarioId: _text(j['usuario_id']) ?? '',
        bodegaId: _text(j['bodega_id']) ?? '',
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  CajasCompanion _cajaFromJson(Map<String, dynamic> j) => CajasCompanion.insert(
    id: _text(j['id']) ?? '',
    empresaId: _text(j['empresa_id']) ?? '',
    bodegaId: _text(j['bodega_id']) ?? '',
    nombre: _text(j['nombre']) ?? 'Caja',
    usuarioRegistroId: const Value(null),
    estado: Value(_bool(j['estado'])),
    createdAt: Value(_date(j['fecha_registro'])),
    updatedAt: Value(_date(j['ultima_actualizacion'])),
    fechaEliminacion: Value(
      j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
    ),
    syncStatus: const Value('synced'),
  );
  CajaSesionesCompanion _cajaSesionFromJson(Map<String, dynamic> j) =>
      CajaSesionesCompanion.insert(
        id: _text(j['id']) ?? '',
        cajaId: _text(j['caja_id']) ?? '',
        usuarioAperturaId: _text(j['usuario_apertura_id']) ?? '',
        usuarioCierreId: const Value(null),
        fechaApertura: _date(j['fecha_apertura']),
        fechaCierre: Value(
          j['fecha_cierre'] == null ? null : _date(j['fecha_cierre']),
        ),
        montoInicial: Value(_double(j['monto_inicial'])),
        totalVentasSistema: Value(_double(j['total_ventas_sistema'])),
        totalEfectivoReal: Value(_double(j['total_efectivo_real'])),
        diferencia: Value(_double(j['diferencia'])),
        estadoSesion: _text(j['estado_sesion']) ?? 'abierta',
        createdAt: Value(_date(j['fecha_registro'] ?? j['fecha_apertura'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  CajaMovimientosExtrasCompanion _cajaMovimientoExtraFromJson(
    Map<String, dynamic> j,
  ) => CajaMovimientosExtrasCompanion.insert(
    id: _text(j['id']) ?? '',
    cajaSesionId: _text(j['caja_sesion_id']) ?? '',
    referenciaVentaId: Value(_text(j['referencia_venta_id'])),
    tipo: _text(j['tipo']) ?? 'egreso',
    motivo: Value(_text(j['motivo'])),
    monto: Value(_double(j['monto'])),
    usuarioRegistroId: const Value(null),
    estado: Value(_bool(j['estado'])),
    createdAt: Value(_date(j['fecha_registro'])),
    updatedAt: Value(_date(j['ultima_actualizacion'])),
    fechaEliminacion: Value(
      j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
    ),
    syncStatus: const Value('synced'),
  );
  CategoriasCompanion _categoriaFromJson(Map<String, dynamic> j) =>
      CategoriasCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        nombre: _text(j['nombre']) ?? 'Sin nombre',
        categoriaPadreId: Value(_text(j['categoria_padre_id'])),
        especificacionJson: Value(_json(j['especificacion'])),
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  ProductosCompanion _productoFromJson(Map<String, dynamic> j) =>
      ProductosCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        categoriaId: Value(_text(j['categoria_id'])),
        nombre: _text(j['nombre']) ?? 'Sin nombre',
        codigoPersonalizado: Value(_text(j['codigo_personalizado'])),
        descripcion: Value(_text(j['descripcion'])),
        especificacionJson: Value(_json(j['especificacion'])),
        precioBase: Value(
          j['precio_base'] == null ? null : _double(j['precio_base']),
        ),
        ultimoCosto: Value(_double(j['ultimo_costo'])),
        ultimoPrecioVenta: Value(_double(j['ultimo_precio_venta'])),
        imagenUrl: Value(_text(j['imagen_url'])),
        imagenLocal: Value(_text(j['imagen_local'])),
        embedding: Value(_text(j['embedding'])),
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  ProductoVariantesCompanion _productoVarianteFromJson(
    Map<String, dynamic> j,
  ) => ProductoVariantesCompanion.insert(
    id: _text(j['id']) ?? '',
    productoId: _text(j['producto_id']) ?? '',
    sku: _text(j['codigo_sku']) ?? _text(j['sku']) ?? '',
    talla: Value(_text(j['talla'])),
    color: Value(_text(j['color'])),
    precioEspecifico: Value(
      j['precio_especifico'] == null ? null : _double(j['precio_especifico']),
    ),
    costoEspecifico: Value(
      j['costo_especifico'] == null ? null : _double(j['costo_especifico']),
    ),
    usuarioRegistroId: const Value(null),
    estado: Value(_bool(j['estado'])),
    createdAt: Value(_date(j['fecha_registro'])),
    updatedAt: Value(_date(j['ultima_actualizacion'])),
    fechaEliminacion: Value(
      j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
    ),
    syncStatus: const Value('synced'),
  );
  InventariosCompanion _inventarioFromJson(Map<String, dynamic> j) =>
      InventariosCompanion.insert(
        id: _text(j['id']) ?? '',
        productoVarianteId: _text(j['producto_variante_id']) ?? '',
        bodegaId: _text(j['bodega_id']) ?? '',
        cantidadActual: Value(_double(j['cantidad_actual'])),
        cantidadReservada: Value(_double(j['cantidad_reservada'])),
        ubicacionPasillo: Value(_text(j['ubicacion_pasillo'])),
        precioVenta: Value(_double(j['precio_venta'])),
        costoPromedio: Value(_double(j['costo_promedio'])),
        actualizadoPor: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  ClientesCompanion _clienteFromJson(Map<String, dynamic> j) =>
      ClientesCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        nombre: _text(j['nombre']) ?? 'Consumidor final',
        identificacion: Value(_text(j['identificacion'])),
        celular: Value(_text(j['celular'])),
        direccion: Value(_text(j['direccion'])),
        montoCreditoMaximo: Value(_double(j['monto_credito_maximo'])),
        saldoDeudorActual: Value(_double(j['saldo_deudor_actual'])),
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  MovimientosCompanion _movimientoFromJson(Map<String, dynamic> j) =>
      MovimientosCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        tipoMovimiento: _tipoMovimientoFromRemote(
          _text(j['tipo_movimiento']),
          localValue: _text(j['tipo_movimiento_local']),
        ),
        estadoMovimiento: _text(j['estado_movimiento']) ?? 'aprobado',
        bodegaOrigenId: Value(_text(j['bodega_origen_id'])),
        bodegaDestinoId: Value(_text(j['bodega_destino_id'])),
        descripcion: Value(_text(j['descripcion'])),
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  DetalleMovimientosCompanion _detalleMovimientoFromJson(
    Map<String, dynamic> j,
  ) => DetalleMovimientosCompanion.insert(
    id: _text(j['id']) ?? '',
    movimientoId: _text(j['movimiento_producto_id']) ?? '',
    productoId: _text(j['producto_id']) ?? '',
    productoVarianteId: Value(_text(j['producto_variante_id'])),
    cantidad: _double(j['cantidad']),
    costoProveedor: Value(_double(j['costo_proveedor'])),
    cargosAdicionalesJson: Value(_json(j['cargos_adicionales'] ?? j['cargos_adicionales_json'])),
    costoUnitarioFinal: Value(_double(j['costo_unitario_final'])),
    variantesJson: Value(_json(j['variantes_json'])),
    createdAt: Value(_date(j['fecha_registro'])),
    updatedAt: Value(_date(j['ultima_actualizacion'])),
    fechaEliminacion: Value(
      j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
    ),
    syncStatus: const Value('synced'),
  );
  VentasCompanion _ventaFromJson(Map<String, dynamic> j) =>
      VentasCompanion.insert(
        id: _text(j['id']) ?? '',
        empresaId: _text(j['empresa_id']) ?? '',
        clienteId: _text(j['cliente_id']) ?? '',
        usuarioId: (_text(j['usuario_id']) ?? _text(j['usuario_registro_id']))!,
        cajaSesionId: _text(j['caja_sesion_id']) ?? '',
        tipoVenta: _text(j['tipo_venta']) ?? 'contado',
        estadoPago: _text(j['estado_pago']) ?? 'pendiente',
        totalVenta: Value(_double(j['total_venta'])),
        totalPagado: Value(_double(j['total_pagado'])),
        saldoPendiente: Value(_double(j['saldo_pendiente'])),
        fechaVenta: _date(j['fecha_venta']),
        fechaVencimiento: Value(
          j['fecha_vencimiento'] == null ? null : _date(j['fecha_vencimiento']),
        ),
        estado: Value(_bool(j['estado'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  DetalleVentasCompanion _detalleVentaFromJson(Map<String, dynamic> j) =>
      DetalleVentasCompanion.insert(
        id: _text(j['id']) ?? '',
        ventaId: _text(j['venta_id']) ?? '',
        productoId: _text(j['producto_id']) ?? '',
        productoVarianteId: Value(_text(j['producto_variante_id'])),
        cantidad: _double(j['cantidad']),
        precioUnitario: _double(j['precio_unitario']),
        descuento: Value(_double(j['descuento'])),
        subTotal: Value(_double(j['sub_total'])),
        costoHistoricoCompra: Value(_double(j['costo_historico_compra'])),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );
  PagosVentasCompanion _pagoVentaFromJson(Map<String, dynamic> j) =>
      PagosVentasCompanion.insert(
        id: _text(j['id']) ?? '',
        ventaId: _text(j['venta_id']) ?? '',
        cajaSesionId: _text(j['caja_sesion_id']) ?? '',
        montoPagado: _double(j['monto_pagado']),
        metodoPago:
            _text(j['metodo_de_pago']) ?? _text(j['metodo_pago']) ?? 'efectivo',
        referencia: Value(_text(j['referencia'])),
        usuarioRegistroId: const Value(null),
        estado: Value(_bool(j['estado'])),
        fechaRegistro: _date(j['fecha_registro_pago'] ?? j['fecha_registro']),
        createdAt: Value(_date(j['fecha_registro'])),
        updatedAt: Value(_date(j['ultima_actualizacion'])),
        fechaEliminacion: Value(
          j['fecha_eliminacion'] == null ? null : _date(j['fecha_eliminacion']),
        ),
        syncStatus: const Value('synced'),
      );

  /// Cuenta el total de registros pendientes o con error de sync en todas las tablas.
  Future<int> countTotalPending() async {
    const tables = [
      'empresas', 'roles', 'accesos_rol', 'usuarios', 'bodegas',
      'bodegas_usuarios', 'cajas', 'caja_sesiones', 'caja_movimientos_extras',
      'categorias', 'productos', 'producto_variantes', 'inventarios',
      'clientes', 'movimientos', 'detalle_movimientos',
      'ventas', 'detalle_ventas', 'pagos_ventas',
    ];
    int total = 0;
    for (final table in tables) {
      final res = await _db.customSelect(
        "SELECT COUNT(*) as cnt FROM $table "
        "WHERE sync_status IN ('pending_insert','pending_update','sync_error')",
      ).getSingleOrNull();
      total += res?.read<int>('cnt') ?? 0;
    }
    return total;
  }
}
