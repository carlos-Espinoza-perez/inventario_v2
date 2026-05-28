import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/inventory_requests.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/features/inventory/data/repository/inventario_repository.dart';

final movimientoRepositoryProvider = Provider((ref) {
  final driftDb = ref.watch(driftDatabaseProvider);
  return MovimientoRepository(
    db: driftDb,
    inventarioRepository: InventarioRepository(driftDb),
  );
});

class MovimientoRepository {
  final AppDatabase _db;
  final InventarioRepository _inventarioRepository;

  MovimientoRepository({
    required AppDatabase db,
    required InventarioRepository inventarioRepository,
  }) : _db = db,
       _inventarioRepository = inventarioRepository;

  Future<void> guardarEntradaAlmacen({
    required String empresaId,
    required String usuarioId,
    required String bodegaId,
    required String descripcion,
    required List<Map<String, dynamic>> lineasOrden,
  }) async {
    await _inventarioRepository.registrarEntrada(
      InventoryEntryRequest(
        destinationWarehouseId: bodegaId,
        descripcion: descripcion,
        items: lineasOrden
            .map(
              (linea) => InventoryEntryItem(
                productId: linea['productId'] as String,
                productVariantId: linea['productVariantId'] as String?,
                cantidad: ((linea['items'] as List?)?.length ?? 0).toDouble(),
                costoProveedor: (linea['cost'] as num?)?.toDouble() ?? 0.0,
                costoUnitarioFinal: (linea['cost'] as num?)?.toDouble() ?? 0.0,
                precioVenta: (linea['price'] as num?)?.toDouble(),
                sku: linea['qr']?.toString(),
                talla: linea['size']?.toString(),
                color: linea['color']?.toString(),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> registrarTrasladoBodegas({
    required String empresaId,
    required String usuarioId,
    required String bodegaOrigenId,
    required String bodegaDestinoId,
    required String descripcion,
    required List<Map<String, dynamic>> items,
  }) async {
    await _inventarioRepository.registrarTraslado(
      TransferRequest(
        originWarehouseId: bodegaOrigenId,
        destinationWarehouseId: bodegaDestinoId,
        descripcion: descripcion,
        items: items
            .map(
              (item) => TransferItemRequest(
                productId: item['productId'] as String,
                productVariantId: item['productVariantId'] as String?,
                cantidad: (item['cantidad'] as num?)?.toDouble() ?? 0.0,
                costoProveedor: (item['cost'] as num?)?.toDouble() ?? 0.0,
                costoUnitarioFinal: (item['cost'] as num?)?.toDouble() ?? 0.0,
                precioVenta: (item['price'] as num?)?.toDouble(),
                sku: item['qr']?.toString(),
                size: item['size']?.toString(),
                color: item['color']?.toString(),
                availableStock: (item['availableStock'] as num?)?.toDouble(),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialProducto(
    String productoId, {
    String? bodegaId,
  }) {
    return _db.inventoryDao.getHistorialProducto(
      productoId,
      bodegaId: bodegaId,
    );
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialBodega(
    String bodegaId,
  ) async {
    final rows =
        await (_db.select(_db.detalleMovimientos).join([
                innerJoin(
                  _db.movimientos,
                  _db.movimientos.id.equalsExp(
                    _db.detalleMovimientos.movimientoId,
                  ),
                ),
                leftOuterJoin(
                  _db.usuarios,
                  _db.usuarios.id.equalsExp(_db.movimientos.usuarioRegistroId),
                ),
              ])
              ..where(
                _db.movimientos.bodegaOrigenId.equals(bodegaId) |
                    _db.movimientos.bodegaDestinoId.equals(bodegaId),
              )
              ..orderBy([OrderingTerm.desc(_db.movimientos.createdAt)]))
            .get();

    final grouped = <String, List<TypedResult>>{};
    for (final row in rows) {
      final movimiento = row.readTable(_db.movimientos);
      grouped.putIfAbsent(movimiento.id, () => []).add(row);
    }

    return grouped.entries.map((entry) {
      final first = entry.value.first;
      final movimiento = first.readTable(_db.movimientos);
      final usuario = first.readTableOrNull(_db.usuarios);
      final isEntrada =
          movimiento.bodegaDestinoId == bodegaId &&
          movimiento.bodegaOrigenId != bodegaId;
      final isSalida =
          movimiento.bodegaOrigenId == bodegaId &&
          movimiento.bodegaDestinoId != bodegaId;
      final direccion = isEntrada
          ? 'ENTRADA'
          : isSalida
          ? 'SALIDA'
          : 'TRASLADO';

      return {
        'id': movimiento.id,
        'tipo': movimiento.tipoMovimiento.toUpperCase(),
        'direccion': direccion,
        'estado': movimiento.estadoMovimiento.toUpperCase(),
        'fecha': movimiento.createdAt,
        'referencia': movimiento.descripcion ?? 'Movimiento sin descripcion',
        'usuario': usuario?.nombreCompleto ?? 'Sistema',
        'items': entry.value.length,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> obtenerDetalleMovimiento(
    String movimientoId,
  ) async {
    final destinoAlias = _db.bodegas.createAlias('bodega_destino');
    final rows =
        await (_db.select(_db.movimientos).join([
                leftOuterJoin(
                  _db.detalleMovimientos,
                  _db.detalleMovimientos.movimientoId.equalsExp(
                    _db.movimientos.id,
                  ),
                ),
                leftOuterJoin(
                  _db.productos,
                  _db.productos.id.equalsExp(_db.detalleMovimientos.productoId),
                ),
                leftOuterJoin(
                  _db.productoVariantes,
                  _db.productoVariantes.id.equalsExp(
                    _db.detalleMovimientos.productoVarianteId,
                  ),
                ),
                leftOuterJoin(
                  _db.bodegas,
                  _db.bodegas.id.equalsExp(_db.movimientos.bodegaOrigenId),
                  useColumns: true,
                ),
                leftOuterJoin(
                  destinoAlias,
                  destinoAlias.id.equalsExp(_db.movimientos.bodegaDestinoId),
                ),
              ])
              ..where(_db.movimientos.id.equals(movimientoId))
              ..limit(100))
            .get();

    if (rows.isEmpty) return null;

    final first = rows.first;
    final movimiento = first.readTable(_db.movimientos);
    final origen = first.readTableOrNull(_db.bodegas);

    final items = <Map<String, dynamic>>[];
    var costoProductos = 0.0;

    for (final row in rows) {
      final detalle = row.readTableOrNull(_db.detalleMovimientos);
      if (detalle == null) continue;
      final producto = row.readTableOrNull(_db.productos);
      final variante = row.readTableOrNull(_db.productoVariantes);
      final precioUnitario = detalle.costoUnitarioFinal;
      final subtotal = precioUnitario * detalle.cantidad;
      costoProductos += subtotal;
      final variantes = _enrichVariantes(
        variantes: _decodeVariantes(detalle.variantesJson),
        detalle: detalle,
        variante: variante,
      );
      items.add({
        'nombre': producto?.nombre ?? 'Producto',
        'sku':
            variante?.sku ??
            producto?.codigoPersonalizado ??
            producto?.id ??
            detalle.productoId,
        'cantidad': detalle.cantidad,
        'precio_unitario': precioUnitario,
        'precio_compra': precioUnitario,
        'subtotal': subtotal,
        'variantes': variantes,
      });
    }

    final destino = rows.first.readTableOrNull(destinoAlias);
    return {
      'id': movimiento.id,
      'tipo': movimiento.tipoMovimiento.toUpperCase(),
      'estado': movimiento.estadoMovimiento.toUpperCase(),
      'fecha': movimiento.createdAt,
      'origen': origen?.nombre ?? 'N/A',
      'destino': destino?.nombre ?? 'N/A',
      'cliente': null,
      'metodo_pago': null,
      'proveedor': null,
      'referencia_externa': movimiento.descripcion,
      'costo_productos': costoProductos,
      'costo_flete': 0.0,
      'items': items,
    };
  }

  List<Map<String, dynamic>> _decodeVariantes(String? value) {
    if (value == null || value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e, st) {
      // JSON malformado en DB: el detalle de movimiento sigue renderizando sin variantes
      AppLogger.error('_decodeVariantes: JSON inválido en variantesJson', e, st);
      return const [];
    }
  }

  List<Map<String, dynamic>> _enrichVariantes({
    required List<Map<String, dynamic>> variantes,
    required DetalleMovimiento detalle,
    required ProductoVariante? variante,
  }) {
    if (variante == null) return variantes;

    if (variantes.isEmpty) {
      return [
        {
          'sku': variante.sku,
          'talla': variante.talla,
          'color': variante.color,
          'cantidad': detalle.cantidad,
          'precio': detalle.costoUnitarioFinal,
        },
      ];
    }

    return variantes.map((item) {
      final next = Map<String, dynamic>.from(item);
      final sku =
          next['sku']?.toString().trim() ?? next['qr']?.toString().trim();
      final talla =
          next['talla']?.toString().trim() ?? next['size']?.toString().trim();
      final color = next['color']?.toString().trim();

      if (sku == null || sku.isEmpty) next['sku'] = variante.sku;
      if (talla == null || talla.isEmpty || talla.toLowerCase() == 'general') {
        next['talla'] = variante.talla;
      }
      if (color == null || color.isEmpty) next['color'] = variante.color;
      return next;
    }).toList();
  }
}
