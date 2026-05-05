import 'package:drift/drift.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/sales_requests.dart';
import 'package:uuid/uuid.dart';

class SalesRepository {
  SalesRepository(this._db);

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
    final clienteId = clienteName.isNotEmpty
        ? const Uuid().v4()
        : 'final_consumer';
    final ventaId = const Uuid().v4();
    final totalPagado = saleType == 'Contado' ? total : depositAmount;
    final saldoPendiente = saleType == 'Contado'
        ? 0.0
        : (total - depositAmount);

    final cliente = clienteName.isEmpty
        ? null
        : ClientesCompanion.insert(
            id: clienteId,
            empresaId: currentUser.empresaId,
            nombre: clienteName,
            celular: const Value(''),
            usuarioRegistroId: Value(currentUser.serverId),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value('pending_insert'),
          );

    final detalles = <VentaDetalleInput>[];
    for (final item in cartItems) {
      final productoId = item['id'] as String;
      final cantidad = (item['qty'] as num).toDouble();
      final precio = (item['price'] as num).toDouble();

      final producto = await _db.inventoryDao.getProductoById(productoId);
      detalles.add(
        VentaDetalleInput(
          id: '${ventaId}_${productoId}_${DateTime.now().microsecondsSinceEpoch}',
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
        clienteId: clienteId,
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
      cliente: cliente,
      bodegaId: bodegaId,
    );

    return _db.salesDao.registrarVentaCompleta(request);
  }
}
