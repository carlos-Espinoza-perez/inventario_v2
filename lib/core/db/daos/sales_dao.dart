import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import 'base_dao.dart';
import '../models/cash_models.dart';
import '../models/dashboard_models.dart';
import '../models/report_models.dart';
import '../exceptions/dao_exceptions.dart';
import '../models/sales_requests.dart';
import '../tables/auth_tables.dart';
import '../tables/cash_tables.dart';
import '../tables/inventory_tables.dart';
import '../tables/sales_tables.dart';
part 'sales_dao.g.dart';

@DriftAccessor(
  tables: [
    Clientes,
    Ventas,
    DetalleVentas,
    PagosVentas,
    CajaSesiones,
    Cajas,
    CajaMovimientosExtras,
    Usuarios,
    ProductoVariantes,
    Productos,
    Inventarios,
  ],
)
class SalesDao extends BaseDao with _$SalesDaoMixin {
  SalesDao(super.db);

  Expression<bool> _isPending(GeneratedColumn<String> column) {
    return column.equals('pending_insert') | column.equals('pending_update') | column.equals('sync_error');
  }

  Future<void> upsertCliente(ClientesCompanion cliente) {
    return into(clientes).insertOnConflictUpdate(cliente);
  }

  Future<Venta> createVentaBase(VentasCompanion venta) {
    return into(ventas).insertReturning(venta);
  }

  Future<DetalleVenta> createDetalleVenta(DetalleVentasCompanion detalle) {
    return into(detalleVentas).insertReturning(detalle);
  }

  Future<PagosVenta> createPagoVenta(PagosVentasCompanion pago) {
    return into(pagosVentas).insertReturning(pago);
  }

  Future<CajaSesione?> getCajaSesionActiva(String usuarioId) {
    return (select(cajaSesiones)
          ..where(
            (tbl) =>
                tbl.usuarioAperturaId.equals(usuarioId) &
                tbl.estadoSesion.equals('abierta'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaApertura)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<Venta>> watchVentasPorEmpresa([String? empresaId]) {
    return Stream.fromFuture(
      empresaId == null ? getRequiredEmpresaId() : Future.value(empresaId),
    ).asyncExpand((resolvedEmpresaId) {
      return (select(ventas)
            ..where((tbl) => tbl.empresaId.equals(resolvedEmpresaId))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaVenta)]))
          .watch();
    });
  }

  Future<VentaCompletaResult> registrarVentaCompleta(
    RegistrarVentaCompletaRequest request,
  ) async {
    final context = await getRequiredContext();
    final now = DateTime.now();
    final resolvedBodegaId = request.bodegaId ?? context.bodegaId;

    if (resolvedBodegaId == null || resolvedBodegaId.isEmpty) {
      throw const ContextoInvalidoException(
        'No se pudo resolver la bodega activa para registrar la venta.',
      );
    }

    return transaction(() async {
      final ventaCabecera = request.venta;
      final cajaSesionId = ventaCabecera.cajaSesionId.present
          ? ventaCabecera.cajaSesionId.value
          : null;

      if (cajaSesionId == null || cajaSesionId.isEmpty) {
        throw const CajaSesionNoActivaException(
          'La venta requiere una cajaSesionId activa.',
        );
      }

      final sesion =
          await (select(cajaSesiones)
                ..where((tbl) => tbl.id.equals(cajaSesionId))
                ..limit(1))
              .getSingleOrNull();

      if (sesion == null || sesion.estadoSesion != 'abierta') {
        throw const CajaSesionNoActivaException(
          'La sesión de caja no está abierta.',
        );
      }

      final caja =
          await (select(cajas)
                ..where((tbl) => tbl.id.equals(sesion.cajaId))
                ..limit(1))
              .getSingleOrNull();

      if (caja == null) {
        throw const CajaSesionNoActivaException(
          'La caja asociada a la sesión no existe.',
        );
      }

      final bodegaId = request.bodegaId ?? caja.bodegaId;
      if (bodegaId.isEmpty) {
        throw const ContextoInvalidoException(
          'No se pudo resolver la bodega de la sesion de caja.',
        );
      }
      final detallesInsertados = <DetalleVenta>[];

      for (final detalle in request.detalles) {
        final inventario =
            await (select(inventarios)
                  ..where(
                    (tbl) =>
                        tbl.bodegaId.equals(bodegaId) &
                        (detalle.productoVarianteId != null
                            ? tbl.productoVarianteId.equals(
                                detalle.productoVarianteId!,
                              )
                            : tbl.productoVarianteId.isInQuery(
                                selectOnly(productoVariantes)
                                  ..addColumns([productoVariantes.id])
                                  ..where(
                                    productoVariantes.productoId.equals(
                                      detalle.productoId,
                                    ),
                                  ),
                              )),
                  )
                  ..limit(1))
                .getSingleOrNull();

        if (inventario == null ||
            inventario.cantidadActual < detalle.cantidad) {
          throw StockInsuficienteException(
            'Stock insuficiente para el producto ${detalle.productoId}. Disponible: ${inventario?.cantidadActual ?? 0}, solicitado: ${detalle.cantidad}.',
          );
        }
      }

      if (request.cliente != null) {
        await into(clientes).insertOnConflictUpdate(request.cliente!);
      }

      final venta = await into(ventas).insertReturning(
        _ventaPendingInsert(
          ventaCabecera,
          empresaId: context.empresaId,
          usuarioId: context.usuarioId,
          cajaSesionId: cajaSesionId,
          now: now,
        ),
      );

      for (final detalle in request.detalles) {
        final inserted = await into(detalleVentas).insertReturning(
          DetalleVentasCompanion.insert(
            id: detalle.id,
            ventaId: venta.id,
            productoId: detalle.productoId,
            productoVarianteId: Value(detalle.productoVarianteId),
            cantidad: detalle.cantidad,
            precioUnitario: detalle.precioUnitario,
            descuento: Value(detalle.descuento),
            subTotal: Value(detalle.subTotal),
            costoHistoricoCompra: Value(detalle.costoHistoricoCompra),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value('pending_insert'),
          ),
        );
        detallesInsertados.add(inserted);

        final inventario =
            await (select(inventarios)
                  ..where(
                    (tbl) =>
                        tbl.bodegaId.equals(bodegaId) &
                        (detalle.productoVarianteId != null
                            ? tbl.productoVarianteId.equals(
                                detalle.productoVarianteId!,
                              )
                            : tbl.productoVarianteId.isInQuery(
                                selectOnly(productoVariantes)
                                  ..addColumns([productoVariantes.id])
                                  ..where(
                                    productoVariantes.productoId.equals(
                                      detalle.productoId,
                                    ),
                                  ),
                              )),
                  )
                  ..limit(1))
                .getSingle();

        await (update(
          inventarios,
        )..where((tbl) => tbl.id.equals(inventario.id))).write(
          InventariosCompanion(
            cantidadActual: Value(inventario.cantidadActual - detalle.cantidad),
            actualizadoPor: Value(context.usuarioId),
            updatedAt: Value(now),
            syncStatus: const Value('pending_update'),
          ),
        );
      }

      PagosVenta? pago;
      if (request.pago != null && request.pago!.montoPagado > 0) {
        pago = await into(pagosVentas).insertReturning(
          PagosVentasCompanion.insert(
            id: request.pago!.id,
            ventaId: venta.id,
            cajaSesionId: cajaSesionId,
            montoPagado: request.pago!.montoPagado,
            metodoPago: request.pago!.metodoPago,
            referencia: Value(request.pago!.referencia),
            usuarioRegistroId: Value(
              request.pago!.usuarioRegistroId ?? context.usuarioId,
            ),
            estado: const Value(true),
            fechaRegistro: request.pago!.fechaRegistro,
            createdAt: Value(request.pago!.fechaRegistro),
            updatedAt: Value(now),
            syncStatus: const Value('pending_insert'),
          ),
        );
      }

      return VentaCompletaResult(
        venta: venta,
        detalles: detallesInsertados,
        pago: pago,
      );
    });
  }

  VentasCompanion _ventaPendingInsert(
    VentasCompanion source, {
    required String empresaId,
    required String usuarioId,
    required String cajaSesionId,
    required DateTime now,
  }) {
    return VentasCompanion.insert(
      id: source.id.value,
      empresaId: empresaId,
      clienteId: source.clienteId.present ? source.clienteId.value : '',
      usuarioId: usuarioId,
      cajaSesionId: cajaSesionId,
      tipoVenta: source.tipoVenta.present ? source.tipoVenta.value : 'contado',
      estadoPago: source.estadoPago.present
          ? source.estadoPago.value
          : 'pagado',
      totalVenta: Value(
        source.totalVenta.present ? source.totalVenta.value : 0.0,
      ),
      totalPagado: Value(
        source.totalPagado.present ? source.totalPagado.value : 0.0,
      ),
      saldoPendiente: Value(
        source.saldoPendiente.present ? source.saldoPendiente.value : 0.0,
      ),
      fechaVenta: source.fechaVenta.present ? source.fechaVenta.value : now,
      fechaVencimiento: source.fechaVencimiento,
      estado: source.estado.present
          ? Value(source.estado.value)
          : const Value(true),
      createdAt: Value(source.createdAt.present ? source.createdAt.value : now),
      updatedAt: Value(now),
      syncStatus: const Value('pending_insert'),
      fechaEliminacion: source.fechaEliminacion,
    );
  }

  Future<List<Cliente>> getPendingClientes() {
    return (select(clientes)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Cliente>> searchClientes(String query, String empresaId) async {
    final pattern = '%$query%';
    return (select(clientes)
          ..where((tbl) =>
              tbl.nombre.like(pattern) &
              tbl.empresaId.equals(empresaId) &
              tbl.estado.equals(true) &
              tbl.fechaEliminacion.isNull())
          ..limit(10))
        .get();
  }

  Future<List<Caja>> getPendingCajas() {
    return (select(cajas)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<CajaSesione>> getPendingCajaSesiones() {
    return (select(
      cajaSesiones,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Venta>> getPendingVentas() {
    return (select(ventas)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<DetalleVenta>> getPendingDetalleVentas() {
    return (select(
      detalleVentas,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<PagosVenta>> getPendingPagosVentas() {
    return (select(
      pagosVentas,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<CajaMovimientosExtra>> getPendingCajaMovimientosExtras() {
    return (select(
      cajaMovimientosExtras,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<CajaSesione?> getCajaSesionActivaActual({Set<String>? bodegaIds}) async {
    if (bodegaIds != null && bodegaIds.isEmpty) return null;

    final context = await getRequiredContext();
    if (context.cajaSesionId == null) return null;
    
    final query = select(cajaSesiones).join([
      innerJoin(cajas, cajas.id.equalsExp(cajaSesiones.cajaId)),
    ])..where(cajaSesiones.id.equals(context.cajaSesionId!));

    if (bodegaIds != null) {
      query.where(cajas.bodegaId.isIn(bodegaIds.toList()));
    }

    query.limit(1);
    final row = await query.getSingleOrNull();
    return row?.readTable(cajaSesiones);
  }

  Future<Caja> _resolveOrCreateCajaActiva({
    required String empresaId,
    required String usuarioId,
    required String bodegaId,
  }) async {
    final existing =
        await (select(cajas)
              ..where(
                (tbl) =>
                    tbl.bodegaId.equals(bodegaId) & tbl.estado.equals(true),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return existing;

    final now = DateTime.now();
    final cajaId = const Uuid().v4();
    await into(cajas).insert(
      CajasCompanion.insert(
        id: cajaId,
        empresaId: empresaId,
        bodegaId: bodegaId,
        nombre: 'Caja principal',
        usuarioRegistroId: Value(usuarioId),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_insert'),
      ),
    );

    return (select(cajas)..where((tbl) => tbl.id.equals(cajaId))).getSingle();
  }

  Future<CajaSesione> abrirCajaActual({double montoInicial = 0}) async {
    final context = await getRequiredContext();
    String? bodegaId = context.bodegaId;

    if (bodegaId == null || bodegaId.isEmpty) {
      final validBodegas = await db.authDao.getValidBodegasIds();
      if (validBodegas.isNotEmpty) {
        bodegaId = validBodegas.first;
      }
    }

    if (bodegaId == null || bodegaId.isEmpty) {
      throw const ContextoInvalidoException(
        'No se pudo resolver la bodega activa para abrir caja. Asegúrate de tener al menos una bodega asignada.',
      );
    }

    final activa = await getCajaSesionActiva(context.usuarioId);
    if (activa != null) return activa;

    final String resolvedBodegaId = bodegaId;

    return transaction(() async {
      final caja = await _resolveOrCreateCajaActiva(
        empresaId: context.empresaId,
        usuarioId: context.usuarioId,
        bodegaId: resolvedBodegaId,
      );
      final now = DateTime.now();
      final sesionId = const Uuid().v4();
      await into(cajaSesiones).insert(
        CajaSesionesCompanion.insert(
          id: sesionId,
          cajaId: caja.id,
          usuarioAperturaId: context.usuarioId,
          fechaApertura: now,
          montoInicial: Value(montoInicial),
          totalVentasSistema: const Value(0),
          totalEfectivoReal: Value(montoInicial),
          diferencia: const Value(0),
          estadoSesion: 'abierta',
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending_insert'),
        ),
      );
      return (select(cajaSesiones)
            ..where((tbl) => tbl.id.equals(sesionId))
            ..limit(1))
          .getSingle();
    });
  }

  Future<CajaMovimientosExtra> registrarMovimientoExtraCaja({
    required String cajaSesionId,
    required String tipo,
    required double monto,
    String? motivo,
    String? referenciaVentaId,
  }) async {
    if (monto <= 0) {
      throw const ContextoInvalidoException(
        'El monto del movimiento de caja debe ser mayor que cero.',
      );
    }

    final context = await getRequiredContext();
    final sesion =
        await (select(cajaSesiones)
              ..where((tbl) => tbl.id.equals(cajaSesionId))
              ..limit(1))
            .getSingleOrNull();

    if (sesion == null || sesion.estadoSesion != 'abierta') {
      throw const CajaSesionNoActivaException(
        'La sesion de caja no esta abierta.',
      );
    }

    final now = DateTime.now();
    final id = const Uuid().v4();
    await into(cajaMovimientosExtras).insert(
      CajaMovimientosExtrasCompanion.insert(
        id: id,
        cajaSesionId: cajaSesionId,
        tipo: tipo,
        monto: Value(monto),
        motivo: Value(motivo),
        referenciaVentaId: Value(referenciaVentaId),
        usuarioRegistroId: Value(context.usuarioId),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_insert'),
      ),
    );

    return (select(
      cajaMovimientosExtras,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<List<CajaMovimientosExtra>> getMovimientosExtrasCaja(
    String cajaSesionId,
  ) {
    return (select(cajaMovimientosExtras)
          ..where((tbl) => tbl.cajaSesionId.equals(cajaSesionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  Future<double> getVentasEfectivoSesion(String cajaSesionId) async {
    final sumExp = pagosVentas.montoPagado.sum();
    final query = selectOnly(pagosVentas).join([
      innerJoin(ventas, ventas.id.equalsExp(pagosVentas.ventaId)),
    ])
      ..addColumns([sumExp])
      ..where(pagosVentas.cajaSesionId.equals(cajaSesionId))
      ..where(pagosVentas.estado.equals(true))
      ..where(ventas.estado.equals(true));
      
    final row = await query.getSingle();
    return row.read(sumExp) ?? 0;
  }

  Future<double> getVentasCreditoPendienteSesion(String cajaSesionId) async {
    final sumExp = ventas.saldoPendiente.sum();
    final row =
        await (selectOnly(ventas)
              ..addColumns([sumExp])
              ..where(ventas.cajaSesionId.equals(cajaSesionId))
              ..where(ventas.estado.equals(true))
              ..where(ventas.tipoVenta.equals('credito')))
            .getSingle();
    return row.read(sumExp) ?? 0;
  }

  Future<double> getGananciaSesion(String cajaSesionId) async {
    final rows =
        await (select(detalleVentas).join([
                innerJoin(ventas, ventas.id.equalsExp(detalleVentas.ventaId)),
              ])
              ..where(ventas.cajaSesionId.equals(cajaSesionId))
              ..where(ventas.estado.equals(true)))
            .get();

    var total = 0.0;
    for (final row in rows) {
      final detalle = row.readTable(detalleVentas);
      final venta = row.readTable(ventas);
      final costo = detalle.cantidad * detalle.costoHistoricoCompra;
      final ingreso = detalle.subTotal - detalle.descuento;
      if (venta.tipoVenta == 'credito') {
        final pct = venta.totalVenta > 0
            ? venta.totalPagado / venta.totalVenta
            : 0;
        total += (ingreso - costo) * pct;
      } else {
        total += ingreso - costo;
      }
    }
    return total;
  }

  Future<double> getCostoSesion(String cajaSesionId) async {
    final rows =
        await (select(detalleVentas).join([
                innerJoin(ventas, ventas.id.equalsExp(detalleVentas.ventaId)),
              ])
              ..where(ventas.cajaSesionId.equals(cajaSesionId))
              ..where(ventas.estado.equals(true)))
            .get();

    var totalCosto = 0.0;
    for (final row in rows) {
      final detalle = row.readTable(detalleVentas);
      final costo = detalle.cantidad * detalle.costoHistoricoCompra;
      totalCosto += costo;
    }
    return totalCosto;
  }

  Future<void> cerrarCaja({
    required String cajaSesionId,
    required String usuarioCierreId,
    double? efectivoContado,
  }) async {
    final sesion =
        await (select(cajaSesiones)
              ..where((tbl) => tbl.id.equals(cajaSesionId))
              ..limit(1))
            .getSingleOrNull();
    if (sesion == null || sesion.estadoSesion != 'abierta') {
      throw const CajaSesionNoActivaException(
        'La sesion de caja ya fue cerrada o no existe.',
      );
    }

    final ventasEfectivo = await getVentasEfectivoSesion(cajaSesionId);
    final movimientos = await getMovimientosExtrasCaja(cajaSesionId);
    final gastos = movimientos
        .where((m) => m.tipo == 'egreso' && m.estado)
        .fold<double>(0, (sum, m) => sum + m.monto);

    final ventasTotalExp = ventas.totalVenta.sum();
    final ventasTotalRow =
        await (selectOnly(ventas)
              ..addColumns([ventasTotalExp])
              ..where(ventas.cajaSesionId.equals(cajaSesionId))
              ..where(ventas.estado.equals(true)))
            .getSingle();
    final ventasSistema = ventasTotalRow.read(ventasTotalExp) ?? 0;
    final teorico = sesion.montoInicial + ventasEfectivo - gastos;
    final contado = efectivoContado ?? teorico;
    final diferencia = contado - teorico;
    final now = DateTime.now();

    await (update(
      cajaSesiones,
    )..where((tbl) => tbl.id.equals(cajaSesionId))).write(
      CajaSesionesCompanion(
        usuarioCierreId: Value(usuarioCierreId),
        fechaCierre: Value(now),
        totalVentasSistema: Value(ventasSistema),
        totalEfectivoReal: Value(contado),
        diferencia: Value(diferencia),
        estadoSesion: const Value('cerrada'),
        updatedAt: Value(now),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  Future<List<CajaSesione>> obtenerHistorialCajas() {
    return (select(
      cajaSesiones,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaApertura)])).get();
  }

  Future<CashSessionDetailDrift> getCajaSessionDetail(String sessionId) async {
    final sesion =
        await (select(cajaSesiones)
              ..where((tbl) => tbl.id.equals(sessionId))
              ..limit(1))
            .getSingle();
    final usuario =
        await (select(usuarios)
              ..where((tbl) => tbl.id.equals(sesion.usuarioAperturaId))
              ..limit(1))
            .getSingleOrNull();
    final movimientos = await getMovimientosExtrasCaja(sessionId);
    final gastosTotales = movimientos
        .where((m) => m.tipo == 'egreso' && m.estado)
        .fold<double>(0, (sum, m) => sum + m.monto);
    final ventasEfectivo = await getVentasEfectivoSesion(sessionId);
    final ventasCredito = await getVentasCreditoPendienteSesion(sessionId);
    final ganancia = await getGananciaSesion(sessionId);
    final ventasDetalle = await getSalesListBySession(sessionId);
    final efectivoEsperado =
        sesion.montoInicial + ventasEfectivo - gastosTotales;

    return CashSessionDetailDrift(
      sesion: sesion,
      cajeroNombre: usuario?.nombreCompleto ?? 'Cajero',
      ventasEfectivo: ventasEfectivo,
      ventasCreditoPendiente: ventasCredito,
      gastosTotales: gastosTotales,
      gananciaEstimada: ganancia,
      efectivoEsperado: efectivoEsperado,
      movimientos: movimientos
          .map(
            (m) => CashExtraMovementView(
              id: m.id,
              tipo: m.tipo,
              motivo: m.motivo,
              monto: m.monto,
              fecha: m.createdAt,
              referenciaVentaId: m.referenciaVentaId,
              usuarioRegistroId: m.usuarioRegistroId,
              syncStatus: m.syncStatus,
            ),
          )
          .toList(),
      ventas: ventasDetalle,
    );
  }

  Future<double> getVentasDelDia({Set<String>? bodegaIds}) async {
    if (bodegaIds != null && bodegaIds.isEmpty) return 0.0;
    
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final query = selectOnly(ventas)
      ..addColumns([ventas.totalVenta.sum()])
      ..where(ventas.estado.equals(true))
      ..where(ventas.fechaVenta.isBiggerOrEqualValue(start))
      ..where(ventas.fechaVenta.isSmallerThanValue(end));

    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      query.where(
        ventas.cajaSesionId.isInQuery(
          selectOnly(cajaSesiones)
            ..addColumns([cajaSesiones.id])
            ..where(
              cajaSesiones.cajaId.isInQuery(
                selectOnly(cajas)
                  ..addColumns([cajas.id])
                  ..where(cajas.bodegaId.isIn(bodegaIds.toList())),
              ),
            ),
        ),
      );
    }

    final row = await query.getSingle();
    return row.read(ventas.totalVenta.sum()) ?? 0;
  }

  Future<List<DashboardTopProduct>> getTopSellingProducts({
    Set<String>? bodegaIds,
    int limit = 5,
  }) async {
    final sql = StringBuffer('''
SELECT dv.producto_id AS producto_id,
       p.nombre AS nombre,
       SUM(dv.cantidad) AS cantidad_vendida,
       SUM(dv.sub_total) AS total_vendido
FROM detalle_ventas dv
INNER JOIN ventas v ON v.id = dv.venta_id
INNER JOIN productos p ON p.id = dv.producto_id
INNER JOIN caja_sesiones cs ON cs.id = v.caja_sesion_id
INNER JOIN cajas c ON c.id = cs.caja_id
WHERE v.estado = 1
''');

    final variables = <Variable<Object>>[];
    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      final placeholders = List.generate(
        bodegaIds.length,
        (_) => '?',
      ).join(', ');
      sql.write(' AND c.bodega_id IN ($placeholders)');
      for (final id in bodegaIds) {
        variables.add(Variable<String>(id));
      }
    }
    sql.write(
      ' GROUP BY dv.producto_id, p.nombre ORDER BY cantidad_vendida DESC LIMIT ?',
    );
    variables.add(Variable<int>(limit));

    final rows = await customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: {detalleVentas, ventas, productos, cajaSesiones, cajas},
    ).get();

    return rows
        .map(
          (row) => DashboardTopProduct(
            productoId: row.read<String>('producto_id'),
            nombre: row.read<String>('nombre'),
            cantidadVendida: row.read<double>('cantidad_vendida'),
            totalVendido: row.read<double>('total_vendido'),
          ),
        )
        .toList();
  }

  Future<List<RecentTransactionDrift>> getRecentTransactions({
    int limit = 10,
    Set<String>? bodegaIds,
  }) async {
    if (bodegaIds != null && bodegaIds.isEmpty) return [];

    // Ventas con cliente en un solo JOIN
    final query = select(ventas).join([
      leftOuterJoin(clientes, clientes.id.equalsExp(ventas.clienteId)),
      innerJoin(cajaSesiones, cajaSesiones.id.equalsExp(ventas.cajaSesionId)),
      innerJoin(cajas, cajas.id.equalsExp(cajaSesiones.cajaId)),
    ])
      ..where(ventas.estado.equals(true));
      
    if (bodegaIds != null) {
      query.where(cajas.bodegaId.isIn(bodegaIds));
    }
    
    query
      ..orderBy([OrderingTerm.desc(ventas.fechaVenta)])
      ..limit(limit);
      
    final ventasJoin = await query.get();

    // Pagos con venta y cliente en un solo JOIN
    final queryPagos = select(pagosVentas).join([
      innerJoin(ventas, ventas.id.equalsExp(pagosVentas.ventaId)),
      leftOuterJoin(clientes, clientes.id.equalsExp(ventas.clienteId)),
      innerJoin(cajaSesiones, cajaSesiones.id.equalsExp(ventas.cajaSesionId)),
      innerJoin(cajas, cajas.id.equalsExp(cajaSesiones.cajaId)),
    ])
      ..where(pagosVentas.estado.equals(true));

    if (bodegaIds != null) {
      queryPagos.where(cajas.bodegaId.isIn(bodegaIds));
    }

    queryPagos
      ..orderBy([OrderingTerm.desc(pagosVentas.fechaRegistro)])
      ..limit(limit);

    final pagosJoin = await queryPagos.get();

    final items = <RecentTransactionDrift>[];

    for (final row in ventasJoin) {
      final venta = row.readTable(ventas);
      final cliente = row.readTableOrNull(clientes);
      items.add(
        RecentTransactionDrift(
          title: venta.tipoVenta == 'credito'
              ? 'Venta a credito'
              : 'Venta de productos',
          subtitle: cliente?.nombre ?? 'Cliente',
          amount: venta.totalVenta,
          isIncome: true,
          date: venta.fechaVenta,
        ),
      );
    }

    for (final row in pagosJoin) {
      final pago = row.readTable(pagosVentas);
      final cliente = row.readTableOrNull(clientes);
      items.add(
        RecentTransactionDrift(
          title: 'Abono de cliente',
          subtitle: cliente?.nombre ?? 'Cliente',
          amount: pago.montoPagado,
          isIncome: true,
          date: pago.fechaRegistro,
        ),
      );
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(limit).toList();
  }

  Future<double> getMontoTotalFiados({required Set<String> bodegaIds}) async {
    if (bodegaIds.isEmpty) return 0.0;

    final row =
        await (selectOnly(ventas)
              ..addColumns([ventas.saldoPendiente.sum()])
              ..join([
                innerJoin(cajaSesiones, cajaSesiones.id.equalsExp(ventas.cajaSesionId)),
                innerJoin(cajas, cajas.id.equalsExp(cajaSesiones.cajaId)),
              ])
              ..where(ventas.tipoVenta.equals('credito'))
              ..where(ventas.estado.equals(true))
              ..where(ventas.estadoPago.isNotValue('pagado'))
              ..where(cajas.bodegaId.isIn(bodegaIds)))
            .getSingle();
    return row.read(ventas.saldoPendiente.sum()) ?? 0;
  }

  Future<SalesWeeklyReportData> getWeeklySalesReport({
    Set<String>? bodegaIds,
  }) async {
    if (bodegaIds != null && bodegaIds.isEmpty) {
      return SalesWeeklyReportData(
        ventasPorDia: List<double>.filled(7, 0),
        totalSemana: 0,
        ventasPorCategoria: {},
        gananciaPorProducto: [],
      );
    }

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);

    final variables = <Variable<Object>>[Variable<DateTime>(start)];
    final bodegaFilter = StringBuffer();
    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      bodegaFilter.write(
        ' AND ca.bodega_id IN (${List.filled(bodegaIds.length, '?').join(', ')})',
      );
      for (final id in bodegaIds) {
        variables.add(Variable<String>(id));
      }
    }

    // Una sola query: ventas + detalles + productos + categorías
    final rows = await customSelect(
      '''
SELECT v.fecha_venta      AS fecha_venta,
       v.total_venta      AS total_venta,
       v.tipo_venta       AS tipo_venta,
       v.total_pagado     AS total_pagado,
       dv.sub_total       AS sub_total,
       dv.descuento       AS descuento,
       dv.cantidad        AS cantidad,
       dv.costo_historico_compra AS costo,
       p.nombre           AS producto_nombre,
       COALESCE(cat.nombre, 'Sin categoria') AS categoria_nombre
FROM ventas v
INNER JOIN caja_sesiones cs ON cs.id = v.caja_sesion_id
INNER JOIN cajas ca ON ca.id = cs.caja_id
INNER JOIN detalle_ventas dv ON dv.venta_id = v.id
INNER JOIN productos p ON p.id = dv.producto_id
LEFT  JOIN categorias cat ON cat.id = p.categoria_id
WHERE v.estado = 1
  AND v.fecha_venta >= ?
$bodegaFilter
''',
      variables: variables,
      readsFrom: {ventas, detalleVentas, productos, cajaSesiones, cajas},
    ).get();

    final ventasDia = List<double>.filled(7, 0);
    var totalSemana = 0.0;
    final ventasPorCategoria = <String, double>{};
    final gananciasPorProducto = <String, double>{};
    // Acumula total_venta una sola vez por venta usando fecha como agrupación
    final ventasContadas = <String, bool>{};

    for (final row in rows) {
      final fechaVenta = row.read<DateTime>('fecha_venta');
      final totalVenta = row.read<double>('total_venta');
      final tipoVenta = row.read<String>('tipo_venta');
      final totalPagado = row.read<double>('total_pagado');
      final subTotal = row.read<double>('sub_total');
      final descuento = row.read<double>('descuento');
      final cantidad = row.read<double>('cantidad');
      final costo = row.read<double>('costo');
      final productoNombre = row.read<String>('producto_nombre');
      final categoriaNombre = row.read<String>('categoria_nombre');

      // Acumula ventas del día solo una vez por fila de venta (agrupado por fecha+total)
      final ventaKey = '${fechaVenta.millisecondsSinceEpoch}_$totalVenta';
      if (!ventasContadas.containsKey(ventaKey)) {
        ventasContadas[ventaKey] = true;
        final idx = fechaVenta.weekday - 1;
        if (idx >= 0 && idx < 7) {
          ventasDia[idx] += totalVenta;
          totalSemana += totalVenta;
        }
      }

      ventasPorCategoria[categoriaNombre] =
          (ventasPorCategoria[categoriaNombre] ?? 0) + subTotal;

      final ingreso = subTotal - descuento;
      final costoParcial = cantidad * costo;
      final pctPagado =
          tipoVenta == 'credito' && totalVenta > 0
              ? totalPagado / totalVenta
              : 1.0;
      gananciasPorProducto[productoNombre] =
          (gananciasPorProducto[productoNombre] ?? 0) +
          ((ingreso - costoParcial) * pctPagado);
    }

    final gananciasList =
        gananciasPorProducto.entries
            .map((e) => {'nombre': e.key, 'ganancia': e.value})
            .toList()
          ..sort(
            (a, b) =>
                (b['ganancia'] as double).compareTo(a['ganancia'] as double),
          );

    return SalesWeeklyReportData(
      ventasPorDia: ventasDia,
      totalSemana: totalSemana,
      ventasPorCategoria: ventasPorCategoria,
      gananciaPorProducto: gananciasList,
    );
  }

  Future<List<SalesListItemDrift>> getSalesList({Set<String>? bodegaIds}) async {
    return _getSalesListInternal(bodegaIds: bodegaIds);
  }

  Future<List<SalesListItemDrift>> getSalesListBySession(
    String sessionId,
  ) async {
    return _getSalesListInternal(sessionId: sessionId);
  }

  Future<List<SalesListItemDrift>> _getSalesListInternal({
    String? sessionId,
    Set<String>? bodegaIds,
  }) async {
    if (bodegaIds != null && bodegaIds.isEmpty) return [];

    // Trae ventas + cliente + conteo de detalles en una sola query SQL
    final whereClause = StringBuffer();
    final variables = <Variable<Object>>[];
    
    if (sessionId != null) {
      whereClause.write(' AND v.caja_sesion_id = ?');
      variables.add(Variable<String>(sessionId));
    }
    
    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      whereClause.write(
        ' AND ca.bodega_id IN (${List.filled(bodegaIds.length, '?').join(', ')})',
      );
      for (final id in bodegaIds) {
        variables.add(Variable<String>(id));
      }
    }

    final rows = await customSelect(
      '''
SELECT v.id              AS id,
       v.caja_sesion_id  AS caja_sesion_id,
       v.tipo_venta      AS tipo_venta,
       v.estado_pago     AS estado_pago,
       v.estado          AS estado,
       v.total_venta     AS total_venta,
       v.fecha_venta     AS fecha_venta,
       COALESCE(c.nombre, 'Cliente Desconocido') AS cliente_nombre,
       COUNT(dv.id)      AS items_count
FROM ventas v
INNER JOIN caja_sesiones cs ON cs.id = v.caja_sesion_id
INNER JOIN cajas ca ON ca.id = cs.caja_id
LEFT  JOIN clientes c ON c.id = v.cliente_id
LEFT  JOIN detalle_ventas dv ON dv.venta_id = v.id
WHERE 1=1 $whereClause
GROUP BY v.id, v.caja_sesion_id, v.tipo_venta, v.estado_pago,
         v.estado, v.total_venta, v.fecha_venta, c.nombre
ORDER BY v.fecha_venta DESC
''',
      variables: variables,
      readsFrom: {ventas, clientes, detalleVentas, cajaSesiones, cajas},
    ).get();

    return rows.map((row) {
      final id = row.read<String>('id');
      final estadoBool = row.read<int>('estado') == 1;
      final estadoPago = row.read<String>('estado_pago');
      final status = !estadoBool
          ? 'Anulado'
          : (estadoPago == 'pagado' ? 'Pagado' : 'Pendiente');

      return SalesListItemDrift(
        id: id.substring(0, 8).toUpperCase(),
        fullId: id,
        client: row.read<String>('cliente_nombre'),
        date: row.read<DateTime>('fecha_venta'),
        total: row.read<double>('total_venta'),
        status: status,
        itemsCount: row.read<int>('items_count'),
      );
    }).toList();
  }

  Future<SaleDetailDrift> getSaleDetail(String saleId) async {
    final venta =
        await (select(ventas)..where((tbl) => tbl.id.equals(saleId))).getSingleOrNull();
    if (venta == null) {
      throw Exception('Venta no encontrada');
    }

    final cliente =
        await (select(clientes)..where((tbl) => tbl.id.equals(venta.clienteId)))
            .getSingleOrNull();

    final detailRows =
        await (select(detalleVentas).join([
                leftOuterJoin(
                  productoVariantes,
                  productoVariantes.id.equalsExp(detalleVentas.productoVarianteId),
                ),
                innerJoin(productos, productos.id.equalsExp(detalleVentas.productoId)),
              ])
              ..where(detalleVentas.ventaId.equals(saleId))
              ..orderBy([OrderingTerm.asc(detalleVentas.createdAt)]))
            .get();

    final items = detailRows.map((row) {
      final detalle = row.readTable(detalleVentas);
      final producto = row.readTable(productos);
      final variante = row.readTableOrNull(productoVariantes);
      final variantLabel = [
        if ((variante?.talla ?? '').isNotEmpty) variante!.talla,
        if ((variante?.color ?? '').isNotEmpty) variante!.color,
      ].join(' / ');
      final nombre = variantLabel.isEmpty
          ? producto.nombre
          : '${producto.nombre} ($variantLabel)';
      return SaleDetailItemDrift(
        detalleId: detalle.id,
        productoId: detalle.productoId,
        productoVarianteId: detalle.productoVarianteId,
        nombre: nombre,
        sku: variante?.sku ?? '',
        talla: variante?.talla,
        color: variante?.color,
        cantidad: detalle.cantidad,
        precioUnitario: detalle.precioUnitario,
        descuento: detalle.descuento,
        subtotal: detalle.subTotal,
        costoHistoricoCompra: detalle.costoHistoricoCompra,
      );
    }).toList();

    final pagos =
        await (select(pagosVentas)
              ..where((tbl) => tbl.ventaId.equals(saleId))
              ..where((tbl) => tbl.estado.equals(true))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaRegistro)]))
            .get();

    return SaleDetailDrift(
      venta: venta,
      cliente: cliente,
      items: items,
      pagos: pagos
          .map(
            (p) => SalePaymentDrift(
              id: p.id,
              fecha: p.fechaRegistro,
              monto: p.montoPagado,
              metodoPago: p.metodoPago,
              referencia: p.referencia,
            ),
          )
          .toList(),
    );
  }

  Future<void> registrarAbonoVenta({
    required String ventaId,
    required double monto,
    String metodoPago = 'efectivo',
    String? referencia,
  }) async {
    if (monto <= 0) {
      throw const ContextoInvalidoException(
        'El abono debe ser mayor que cero.',
      );
    }

    final context = await getRequiredContext();
    final now = DateTime.now();

    await transaction(() async {
      final venta =
          await (select(ventas)..where((tbl) => tbl.id.equals(ventaId))).getSingleOrNull();
      if (venta == null) {
        throw Exception('Venta no encontrada');
      }
      if (monto > venta.saldoPendiente + 0.01) {
        throw const ContextoInvalidoException(
          'El abono no puede ser mayor al saldo pendiente.',
        );
      }

      final cajaActiva =
          await getCajaSesionActivaActual() ??
          await (select(cajaSesiones)
                ..where((tbl) => tbl.id.equals(venta.cajaSesionId))
                ..limit(1))
              .getSingleOrNull();

      if (cajaActiva == null || cajaActiva.estadoSesion != 'abierta') {
        throw const CajaSesionNoActivaException(
          'No hay una sesion de caja activa para registrar el abono.',
        );
      }

      await into(pagosVentas).insert(
        PagosVentasCompanion.insert(
          id: const Uuid().v4(),
          ventaId: ventaId,
          cajaSesionId: cajaActiva.id,
          montoPagado: monto,
          metodoPago: metodoPago,
          referencia: Value(referencia),
          usuarioRegistroId: Value(context.usuarioId),
          estado: const Value(true),
          fechaRegistro: now,
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending_insert'),
        ),
      );

      final nuevoTotalPagado = venta.totalPagado + monto;
      final nuevoSaldo = (venta.totalVenta - nuevoTotalPagado).clamp(
        0,
        double.infinity,
      ).toDouble();
      await (update(ventas)..where((tbl) => tbl.id.equals(ventaId))).write(
        VentasCompanion(
          totalPagado: Value(nuevoTotalPagado),
          saldoPendiente: Value(nuevoSaldo),
          estadoPago: Value(nuevoSaldo <= 0.01 ? 'pagado' : 'pendiente'),
          updatedAt: Value(now),
          syncStatus: const Value('pending_update'),
        ),
      );

      final cliente =
          await (select(clientes)
                ..where((tbl) => tbl.id.equals(venta.clienteId))
                ..limit(1))
              .getSingleOrNull();
      if (cliente != null) {
        await (update(clientes)..where((tbl) => tbl.id.equals(cliente.id))).write(
          ClientesCompanion(
            saldoDeudorActual: Value(
              (cliente.saldoDeudorActual - monto).clamp(0, double.infinity),
            ),
            updatedAt: Value(now),
            syncStatus: const Value('pending_update'),
          ),
        );
      }
    });
  }

  Future<List<ReceivableClientDrift>> getReceivablesReport({
    Set<String>? bodegaIds,
  }) async {
    final sql = StringBuffer('''
SELECT v.cliente_id AS client_id,
       COALESCE(c.nombre, 'Cliente Desconocido') AS client_name,
       SUM(v.total_venta - COALESCE(p.total_pagado, 0)) AS total_debt,
       MAX(p.last_payment_date) AS last_payment_date,
       COUNT(v.id) AS ventas_count
FROM ventas v
LEFT JOIN clientes c ON c.id = v.cliente_id
LEFT JOIN (
  SELECT venta_id,
         SUM(monto_pagado) AS total_pagado,
         MAX(fecha_registro) AS last_payment_date
  FROM pagos_ventas
  WHERE estado = 1
  GROUP BY venta_id
) p ON p.venta_id = v.id
LEFT JOIN caja_sesiones cs ON cs.id = v.caja_sesion_id
LEFT JOIN cajas ca ON ca.id = cs.caja_id
WHERE v.estado = 1
  AND v.tipo_venta = 'credito'
  AND (v.total_venta - COALESCE(p.total_pagado, 0)) > 0
''');

    final variables = <Variable<Object>>[];
    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      sql.write(
        ' AND ca.bodega_id IN (${List.filled(bodegaIds.length, '?').join(', ')})',
      );
      for (final id in bodegaIds) {
        variables.add(Variable<String>(id));
      }
    }
    sql.write(
      ' GROUP BY v.cliente_id, c.nombre ORDER BY total_debt DESC',
    );

    final rows = await customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: {ventas, clientes, pagosVentas, cajaSesiones, cajas},
    ).get();

    return rows
        .map(
          (row) => ReceivableClientDrift(
            clientId: row.read<String>('client_id'),
            name: row.read<String>('client_name'),
            totalDebt: row.read<double>('total_debt'),
            lastPaymentDate: row.readNullable<DateTime>('last_payment_date'),
            ventasCount: row.read<int>('ventas_count'),
          ),
        )
        .toList();
  }

  Future<FinancialReportDrift> getFinancialReport({
    required DateTime start,
    required DateTime end,
    Set<String>? bodegaIds,
  }) async {
    if (bodegaIds != null && bodegaIds.isEmpty) {
      return FinancialReportDrift(
        ingresos: 0,
        costoVenta: 0,
        gastosOperativos: 0,
      );
    }
    final variables = <Variable<Object>>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
    ];
    final bodegaFilter = StringBuffer();
    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      bodegaFilter.write(
        ' AND ca.bodega_id IN (${List.filled(bodegaIds.length, '?').join(', ')})',
      );
      for (final id in bodegaIds) {
        variables.add(Variable<String>(id));
      }
    }

    final ingresosRow = await customSelect(
      '''
SELECT COALESCE(SUM(v.total_venta), 0) AS total_ingresos,
       COALESCE(SUM(dv.costo_historico_compra * dv.cantidad), 0) AS total_costo
FROM ventas v
INNER JOIN detalle_ventas dv ON dv.venta_id = v.id
INNER JOIN caja_sesiones cs ON cs.id = v.caja_sesion_id
INNER JOIN cajas ca ON ca.id = cs.caja_id
WHERE v.estado = 1
  AND v.fecha_venta >= ?
  AND v.fecha_venta < ?
$bodegaFilter
''',
      variables: variables,
      readsFrom: {ventas, detalleVentas, cajaSesiones, cajas},
    ).getSingle();

    final expenseVariables = <Variable<Object>>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
    ];
    final expenseBodegaFilter = StringBuffer();
    if (bodegaIds != null && bodegaIds.isNotEmpty) {
      expenseBodegaFilter.write(
        ' AND ca.bodega_id IN (${List.filled(bodegaIds.length, '?').join(', ')})',
      );
      for (final id in bodegaIds) {
        expenseVariables.add(Variable<String>(id));
      }
    }
    final gastosRow = await customSelect(
      '''
SELECT COALESCE(SUM(cme.monto), 0) AS total_gastos
FROM caja_movimientos_extras cme
INNER JOIN caja_sesiones cs ON cs.id = cme.caja_sesion_id
INNER JOIN cajas ca ON ca.id = cs.caja_id
WHERE cme.estado = 1
  AND cme.tipo = 'egreso'
  AND cme.created_at >= ?
  AND cme.created_at < ?
$expenseBodegaFilter
''',
      variables: expenseVariables,
      readsFrom: {cajaMovimientosExtras, cajaSesiones, cajas},
    ).getSingle();

    return FinancialReportDrift(
      ingresos: ingresosRow.read<double>('total_ingresos'),
      costoVenta: ingresosRow.read<double>('total_costo'),
      gastosOperativos: gastosRow.read<double>('total_gastos'),
    );
  }

  Future<List<CashAuditDrift>> getCashAuditReport({int limit = 20}) async {
    final sessions =
        await (select(cajaSesiones)
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaApertura)])
              ..limit(limit))
            .get();

    return sessions
        .map(
          (s) => CashAuditDrift(
            sessionId: s.id,
            openedAt: s.fechaApertura,
            closedAt: s.fechaCierre,
            totalVentas: s.totalVentasSistema,
            totalEfectivo: s.totalEfectivoReal,
            diferencia: s.diferencia,
            estado: s.estadoSesion,
          ),
        )
        .toList();
  }

  Future<ReportDashboardStatsDrift> getTodayStats({
    Set<String>? bodegaIds,
  }) async {
    if (bodegaIds != null && bodegaIds.isEmpty) {
      return ReportDashboardStatsDrift(ventasHoy: 0, utilidadHoy: 0);
    }
    
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final report = await getFinancialReport(
      start: start,
      end: end,
      bodegaIds: bodegaIds,
    );
    return ReportDashboardStatsDrift(
      ventasHoy: report.ingresos,
      utilidadHoy: report.utilidadNeta,
    );
  }

}

class SalesWeeklyReportData {
  final List<double> ventasPorDia;
  final double totalSemana;
  final Map<String, double> ventasPorCategoria;
  final List<Map<String, dynamic>> gananciaPorProducto;

  const SalesWeeklyReportData({
    required this.ventasPorDia,
    required this.totalSemana,
    required this.ventasPorCategoria,
    required this.gananciaPorProducto,
  });
}
