import 'package:isar/isar.dart';
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';

class InventarioDTO {
  final String productoId; // Nuevo campo
  final String nombre;
  final String sku;
  final String categoria;
  final double stock;
  final double precio;
  final double costo;
  final String? imagen;

  InventarioDTO({
    required this.productoId, // Requerido en constructor
    required this.nombre,
    required this.sku,
    required this.categoria,
    required this.stock,
    required this.precio,
    required this.costo,
    this.imagen,
  });
}
// ... (resto de Imports y Clase InventarioRepository)

class InventarioRepository {
  final Isar _isar;

  InventarioRepository(this._isar);

  Stream<List<InventarioDTO>> obtenerInventarioPorBodega(
    String bodegaId,
  ) async* {
    // Escuchamos los cambios en la colección de Inventario para esta bodega

    // El watcher nos notifica cuando algo cambia en la query
    final query = _isar.inventarioCollections
        .filter()
        .bodegaIdEqualTo(bodegaId)
        .build();

    // Emitimos el stream
    await for (final inventarios in query.watch(fireImmediately: true)) {
      if (inventarios.isEmpty) {
        yield [];
        continue;
      }

      final List<InventarioDTO> resultados = [];

      for (final inv in inventarios) {
        // 2. Buscar el producto asociado
        final producto = await _isar.productoCollections
            .filter()
            .serverIdEqualTo(inv.productoId)
            .findFirst();

        if (producto != null) {
          // 3. Buscar la categoría del producto
          String nombreCategoria = 'Sin Categoría';
          final categoria = await _isar.categoriaCollections
              .filter()
              .serverIdEqualTo(producto.categoriaId)
              .findFirst();

          if (categoria != null) {
            nombreCategoria = categoria.nombre;
          }

          // 4. Mapear a DTO
          resultados.add(
            InventarioDTO(
              productoId: producto.serverId, // Mapeo del ID
              nombre: producto.nombre,
              sku: producto.codigoPersonalizado ?? 'S/SKU',
              categoria: nombreCategoria,
              stock: inv.cantidadActual,
              // CORRECCIÓN: Usar precioVenta de la bodega, o precioBase como default
              precio: inv.precioVenta ?? producto.precioBase ?? 0.0,
              costo: inv.costoPromedio,
              imagen: producto.imagenUrl,
            ),
          );
        }
      }
      yield resultados;
    }
  }

  // Obtener variantes (tallas) de un producto con su stock total (suma de todas las bodegas)
  Future<List<Map<String, dynamic>>> obtenerVariantesProducto(
    String productId, {
    String? bodegaId,
  }) async {
    // 1. Obtener todas las definiciones de variantes (SKUs/Tallas) del producto
    final variantes = await _isar.codigoProductoCollections
        .filter()
        .productoIdEqualTo(productId)
        .findAll();

    List<Map<String, dynamic>> resultado = [];

    for (var v in variantes) {
      // 2. Sumar el stock de esta variante en TODAS las bodegas e inventarios de microinventario
      InventarioCollection? invMacro;
      if (bodegaId != null) {
        invMacro = await _isar.inventarioCollections
            .filter()
            .productoIdEqualTo(productId)
            .bodegaIdEqualTo(bodegaId)
            .findFirst();
      }

      double stockTotal = 0;
      if (bodegaId == null) {
        final inventariosMicro = await _isar.inventarioCodigoProductoCollections
            .filter()
            .codigoProductoIdEqualTo(v.serverId)
            .findAll();
        for (var inv in inventariosMicro) {
          stockTotal += inv.cantidad;
        }
      } else if (invMacro != null) {
        final invMicro = await _isar.inventarioCodigoProductoCollections
            .filter()
            .codigoProductoIdEqualTo(v.serverId)
            .inventarioIdEqualTo(invMacro.serverId)
            .findFirst();
        if (invMicro != null) stockTotal = invMicro.cantidad;
      }

      resultado.add({
        'talla': v.talla,
        'sku': v.codigoSku,
        'stock': stockTotal,
        'precio': v.precioEspecifico, // Puede ser null
      });
    }

    // Ordenar por talla (alfabético simple)
    resultado.sort(
      (a, b) => (a['talla'] as String).compareTo(b['talla'] as String),
    );

    return resultado;
  }
}
