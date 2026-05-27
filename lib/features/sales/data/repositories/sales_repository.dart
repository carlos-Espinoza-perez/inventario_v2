import 'package:drift/drift.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/sales_requests.dart';
import 'package:uuid/uuid.dart';

class SalesRepository {
  SalesRepository(this._db);

  static const _finalConsumerName = 'Consumidor final';

  final AppDatabase _db;

  Future<VentaCompletaResult> registrarVentaDesdeCheckout({
    required String cajaSesionId,
    required String? nombreCliente,
    required String saleType,
    required double total,
    required double depositAmount,
    required String bodegaId,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    final sesion = await _db.authDao.getSesionActiva();
    if (sesion == null) {
      throw StateError('No hay una sesion activa para registrar la venta.');
    }

    final currentUser = sesion.userView;
    final now = DateTime.now();
    final clienteName = (nombreCliente ?? '').trim();
    final cliente = await _buildClienteForSale(
      clienteName: clienteName,
      empresaId: currentUser.empresaId,
      usuarioId: currentUser.serverId,
      now: now,
    );
    final ventaId = const Uuid().v4();
    final totalPagado = saleType == 'Contado' ? total : depositAmount;
    final saldoPendiente = saleType == 'Contado'
        ? 0.0
        : (total - depositAmount);

    final detalles = <VentaDetalleInput>[];
    for (final item in cartItems) {
      final productoId = item['id'] as String;
      final cantidad = (item['qty'] as num).toDouble();
      final precio = (item['price'] as num).toDouble();

      final producto = await _db.inventoryDao.getProductoById(productoId);
      detalles.add(
        VentaDetalleInput(
          id: const Uuid().v4(),
          productoId: productoId,
          productoVarianteId: item['variantId'] as String?,
          cantidad: cantidad,
          precioUnitario: precio,
          descuento: 0,
          subTotal: precio * cantidad,
          costoHistoricoCompra: producto?.ultimoCosto ?? 0,
        ),
      );
    }

    final pago = totalPagado > 0
        ? PagoVentaInput(
            id: const Uuid().v4(),
            montoPagado: totalPagado,
            metodoPago: MetodoPago.efectivo.name,
            fechaRegistro: now,
            usuarioRegistroId: currentUser.serverId,
          )
        : null;

    final request = RegistrarVentaCompletaRequest(
      venta: VentasCompanion.insert(
        id: ventaId,
        empresaId: currentUser.empresaId,
        clienteId: cliente.id,
        usuarioId: currentUser.serverId,
        cajaSesionId: cajaSesionId,
        tipoVenta: saleType == 'Contado'
            ? TipoVenta.contado.name
            : TipoVenta.credito.name,
        estadoPago: (saleType == 'Contado' || depositAmount >= total)
            ? EstadoPago.pagado.name
            : EstadoPago.pendiente.name,
        totalVenta: Value(total),
        totalPagado: Value(totalPagado),
        saldoPendiente: Value(saldoPendiente),
        fechaVenta: now,
        estado: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_insert'),
      ),
      detalles: detalles,
      pago: pago,
      cliente: cliente.companion,
      bodegaId: bodegaId,
    );

    return _db.salesDao.registrarVentaCompleta(request);
  }

  Future<({String id, ClientesCompanion? companion})> _buildClienteForSale({
    required String clienteName,
    required String empresaId,
    required String usuarioId,
    required DateTime now,
  }) async {
    if (clienteName.isNotEmpty) {
      final clienteId = const Uuid().v4();
      return (
        id: clienteId,
        companion: ClientesCompanion.insert(
          id: clienteId,
          empresaId: empresaId,
          nombre: clienteName,
          celular: const Value(''),
          usuarioRegistroId: Value(usuarioId),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending_insert'),
        ),
      );
    }

    final existing =
        await (_db.select(_db.clientes)
              ..where(
                (tbl) =>
                    tbl.empresaId.equals(empresaId) &
                    tbl.nombre.equals(_finalConsumerName),
              )
              ..limit(1))
            .getSingleOrNull();

    if (existing != null) {
      return (id: existing.id, companion: null);
    }

    final clienteId = const Uuid().v4();
    return (
      id: clienteId,
      companion: ClientesCompanion.insert(
        id: clienteId,
        empresaId: empresaId,
        nombre: _finalConsumerName,
        celular: const Value(''),
        usuarioRegistroId: Value(usuarioId),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_insert'),
      ),
    );
  }
}
