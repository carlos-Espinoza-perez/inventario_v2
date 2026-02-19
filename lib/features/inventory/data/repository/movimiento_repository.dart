import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/movimiento_producto_collection.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'package:inventario_v2/features/inventory/data/collections/detalle_movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';

final movimientoRepositoryProvider = FutureProvider((ref) async {
  final isar = ref.watch(isarDbProvider).value;
  return MovimientoRepository(isar as Isar);
});

class MovimientoRepository {
  final Isar _isar;
  MovimientoRepository(this._isar);

  Future<void> guardarEntradaAlmacen({
    required String empresaId,
    required String usuarioId,
    required String bodegaId,
    required String descripcion,
    required List<Map<String, dynamic>> lineasOrden,
  }) async {
    await _isar.writeTxn(() async {
      // 1. CREAR CABECERA (Movimiento)
      final movimientoId = const Uuid().v4();
      final nuevoMovimiento = MovimientoProductoCollection()
        ..serverId = movimientoId
        ..empresaId = empresaId
        ..tipoMovimiento = TipoMovimiento.compra
        ..bodegaDestinoId = bodegaId
        ..fechaRegistro = DateTime.now()
        ..estadoMovimiento = EstadoMovimiento.aprobado
        ..descripcion = descripcion
        ..usuarioRegistroId = usuarioId
        ..ultimaActualizacion = DateTime.now()
        ..pendienteSincronizacion = true;

      await _isar.movimientoProductoCollections.put(nuevoMovimiento);

      // 2. PROCESAR CADA LÍNEA DE PRODUCTO (Agrupado por producto)
      for (var linea in lineasOrden) {
        final String productoId = linea['productId'];
        final double nuevoCosto = (linea['cost'] as num).toDouble();

        // items = lista de mapas: [{'qr': '...', 'size': '...'}, ...]
        final List itemsEscaneados = linea['items'] as List;
        final double cantidadEntranteTotal = itemsEscaneados.length.toDouble();

        // A. Crear Detalle Movimiento (Registro histórico)
        final detalleId = const Uuid().v4();
        final detalle = DetalleMovimientoProductoCollection()
          ..serverId = detalleId
          ..movimientoProductoId = movimientoId
          ..productoId = productoId
          ..cantidad = cantidadEntranteTotal
          ..costoUnitarioFinal = nuevoCosto
          ..costoProveedor = nuevoCosto
          ..ultimaActualizacion = DateTime.now()
          ..fechaEliminacion = null; // null por defecto

        await _isar.detalleMovimientoProductoCollections.put(detalle);

        // B. Actualizar PRODUCTO (Último Costo)
        final producto = await _isar.productoCollections
            .filter()
            .serverIdEqualTo(productoId)
            .findFirst();

        if (producto != null) {
          producto.ultimoCosto = nuevoCosto;
          // Actualizar precio venta si vino en el formulario
          if (linea['price'] != null) {
            producto.precioBase = (linea['price'] as num).toDouble();
          }
          producto.ultimaActualizacion = DateTime.now();
          producto.pendienteSincronizacion = true;
          await _isar.productoCollections.put(producto);
        }

        // C. Actualizar INVENTARIO MACRO (Tabla InventarioProducto)
        InventarioCollection? inventarioMacro = await _isar
            .inventarioCollections
            .filter()
            .bodegaIdEqualTo(bodegaId)
            .productoIdEqualTo(productoId)
            .findFirst();

        inventarioMacro ??= InventarioCollection()
          ..serverId = const Uuid().v4()
          ..bodegaId = bodegaId
          ..productoId = productoId
          ..cantidadActual = 0
          ..costoPromedio = 0
          ..cantidadReservada = 0
          ..ultimaActualizacion = DateTime.now()
          ..pendienteSincronizacion = true;

        // Cálculo de Promedio Ponderado
        final costoTotalActual =
            inventarioMacro.cantidadActual * inventarioMacro.costoPromedio;
        final costoTotalEntrante = cantidadEntranteTotal * nuevoCosto;
        final nuevaCantidadTotal =
            inventarioMacro.cantidadActual + cantidadEntranteTotal;

        double nuevoCostoPromedio = 0;
        if (nuevaCantidadTotal > 0) {
          nuevoCostoPromedio =
              (costoTotalActual + costoTotalEntrante) / nuevaCantidadTotal;
        }

        inventarioMacro.cantidadActual = nuevaCantidadTotal;
        inventarioMacro.costoPromedio = nuevoCostoPromedio;
        inventarioMacro.actualizadoPor = usuarioId; // Campo visto en tu imagen
        inventarioMacro.ultimaActualizacion = DateTime.now();
        inventarioMacro.pendienteSincronizacion = true;

        await _isar.inventarioCollections.put(inventarioMacro);

        // D. PROCESAR CADA TALLA/CÓDIGO (Inventario Micro)
        for (var item in itemsEscaneados) {
          final String qr = item['qr'];
          final String talla = item['size'];

          // 1. Gestionar Identidad (Tabla CodigoProducto)
          CodigoProductoCollection? codigoIdentidad = await _isar
              .codigoProductoCollections
              .filter()
              .codigoSkuEqualTo(qr)
              .findFirst();

          if (codigoIdentidad == null) {
            codigoIdentidad = CodigoProductoCollection()
              ..serverId = const Uuid().v4()
              ..productoId = productoId
              ..talla = talla
              ..codigoSku = qr
              ..usuarioRegistroId = usuarioId
              ..fechaRegistro = DateTime.now()
              ..ultimaActualizacion = DateTime.now()
              ..pendienteSincronizacion = true;

            await _isar.codigoProductoCollections.put(codigoIdentidad);
          }

          // 2. Actualizar Stock por Talla (Tabla InventarioCodigoProducto)
          final invMicro = await _isar.inventarioCodigoProductoCollections
              .filter()
              .inventarioIdEqualTo(
                inventarioMacro.serverId,
              ) // Relación con Padre
              .codigoProductoIdEqualTo(
                codigoIdentidad.serverId,
              ) // Relación con SKU
              .findFirst();

          if (invMicro != null) {
            invMicro.cantidad += 1;
            invMicro.ultimaActualizacion = DateTime.now();
            invMicro.usuarioRegistroId = usuarioId;
            invMicro.pendienteSincronizacion = true;
            await _isar.inventarioCodigoProductoCollections.put(invMicro);
          } else {
            final nuevoInvMicro = InventarioCodigoProductoCollection()
              ..serverId = const Uuid().v4()
              ..inventarioId = inventarioMacro.serverId
              ..codigoProductoId = codigoIdentidad.serverId
              ..cantidad = 1
              ..usuarioRegistroId = usuarioId
              ..fechaRegistro = DateTime.now()
              ..ultimaActualizacion = DateTime.now()
              ..pendienteSincronizacion = true;

            await _isar.inventarioCodigoProductoCollections.put(nuevoInvMicro);
          }
        }
      }
    });
  }
}
