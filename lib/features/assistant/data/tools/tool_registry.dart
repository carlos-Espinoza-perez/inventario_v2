import 'package:inventario_v2/core/db/app_database.dart';
import '../entity_resolver.dart';
import 'tool_result.dart';

typedef ToolFunction =
    Future<ToolResult> Function(
      Map<String, dynamic> params,
      Map<String, dynamic> context,
    );

class ToolRegistry {
  final AppDatabase _db;
  final EntityResolver _resolver;
  late final Map<String, ToolFunction> _tools;

  ToolRegistry(this._db, this._resolver) {
    _tools = _buildRegistry();
  }

  bool has(String toolId) => _tools.containsKey(toolId);

  Future<ToolResult> execute(
    String toolId,
    Map<String, dynamic> params,
    Map<String, dynamic> context,
  ) async {
    final fn = _tools[toolId];
    if (fn == null) {
      return ToolResult.error('Tool "$toolId" no registrada.');
    }
    try {
      return await fn(params, context);
    } catch (e) {
      return ToolResult.error('Error en "$toolId": $e');
    }
  }

  Map<String, ToolFunction> _buildRegistry() => {
    // ── Entity Resolver ───────────────────────────────────────────────────
    'entity_resolver.resolveProduct': (params, ctx) async {
      final query = params['query'] as String? ?? '';
      final empresaId =
          params['empresaId'] as String? ?? ctx['empresaId'] as String? ?? '';
      final result = await _resolver.resolveProduct(
        query,
        empresaId: empresaId,
      );
      if (result.isResolved) return ToolResult.success(result.selected);
      if (result.isAmbiguous) return ToolResult.ambiguous(result.candidates);
      return ToolResult.notFound(
        'No encontré un producto parecido a "$query".',
      );
    },

    'entity_resolver.resolveClient': (params, ctx) async {
      final query = params['query'] as String? ?? '';
      final empresaId =
          params['empresaId'] as String? ?? ctx['empresaId'] as String? ?? '';
      final result = await _resolver.resolveClient(query, empresaId: empresaId);
      if (result.isResolved) return ToolResult.success(result.selected);
      if (result.isAmbiguous) return ToolResult.ambiguous(result.candidates);
      return ToolResult.notFound('No encontré un cliente con nombre "$query".');
    },

    // ── Inventario ────────────────────────────────────────────────────────
    'inventory.getStockPorBodega': (params, ctx) async {
      final productoId = params['productoId'] as String? ?? '';
      final bodegaId =
          params['bodegaId'] as String? ??
          ctx['selectedWarehouseId'] as String?;
      if (bodegaId == null || bodegaId.isEmpty) {
        return ToolResult.askUser('¿En qué bodega querés consultar el stock?');
      }
      final stockList = await _db.inventoryDao.getStockRealPorBodega(bodegaId);
      if (productoId.isEmpty) {
        final grouped = <String, Map<String, dynamic>>{};
        for (final stock in stockList) {
          final current = grouped.putIfAbsent(
            stock.producto.id,
            () => {
              'productoId': stock.producto.id,
              'productoNombre': stock.producto.nombre,
              'cantidad': 0.0,
            },
          );
          current['cantidad'] =
              (current['cantidad'] as double) + stock.inventario.cantidadActual;
        }

        final productos =
            grouped.values.where((p) => (p['cantidad'] as double) > 0).toList()
              ..sort(
                (a, b) => (a['productoNombre'] as String).compareTo(
                  b['productoNombre'] as String,
                ),
              );

        return ToolResult.success({
          'tipo': 'listado_stock_bodega',
          'bodegaId': bodegaId,
          'totalProductos': productos.length,
          'productos': productos.take(20).toList(),
          'hayMas': productos.length > 20,
        });
      }
      final item = stockList.where((s) => s.producto.id == productoId).toList();
      final total = item.fold(
        0.0,
        (sum, s) => sum + s.inventario.cantidadActual,
      );
      return ToolResult.success({
        'tipo': 'stock_producto',
        'cantidad': total,
        'bodegaId': bodegaId,
        'productoId': productoId,
      });
    },

    'inventory.getPrecioProducto': (params, ctx) async {
      final productoId = params['productoId'] as String? ?? '';
      final bodegaId =
          params['bodegaId'] as String? ??
          ctx['selectedWarehouseId'] as String?;
      final producto = await _db.inventoryDao.getProductoById(productoId);
      if (producto == null) return ToolResult.notFound();

      double? precio;
      String fuente = 'precio base';

      if (bodegaId != null) {
        final precios = await _db.inventoryDao.getPreciosProductoPorBodega(
          productoId,
        );
        final enBodega = precios
            .where((p) => p['bodegaId'] == bodegaId)
            .firstOrNull;
        if (enBodega != null && (enBodega['precioVenta'] as num?) != null) {
          precio = (enBodega['precioVenta'] as num).toDouble();
          fuente = 'bodega';
        }
      }

      precio ??= (producto.precioBase != null && producto.precioBase! > 0)
          ? producto.precioBase
          : null;

      if (precio == null && producto.ultimoPrecioVenta > 0) {
        precio = producto.ultimoPrecioVenta;
        fuente = 'último precio de venta';
      }

      return ToolResult.success({
        'precio': precio ?? 0,
        'fuente': fuente,
        'productoNombre': producto.nombre,
      });
    },

    'inventory.getHistorialProducto': (params, ctx) async {
      final productoId = params['productoId'] as String? ?? '';
      final bodegaId = params['bodegaId'] as String?;
      final historial = await _db.inventoryDao.getHistorialProducto(
        productoId,
        bodegaId: bodegaId,
      );
      return ToolResult.success(historial);
    },

    // ── Ventas ────────────────────────────────────────────────────────────
    'sales.getVentasDelDia': (params, ctx) async {
      final bodegaIds = (params['bodegaIds'] as List?)?.cast<String>().toSet();
      final total = await _db.salesDao.getVentasDelDia(bodegaIds: bodegaIds);
      return ToolResult.success({'totalVentas': total});
    },

    'sales.getDeudaCliente': (params, ctx) async {
      final clienteId = params['clienteId'] as String? ?? '';
      final bodegaId = ctx['selectedWarehouseId'] as String?;
      final bodegaIds = bodegaId != null ? {bodegaId} : const <String>{};
      final reporte = await _db.salesDao.getReceivablesReport(bodegaIds: bodegaIds);
      final cliente = reporte.where((r) => r.clientId == clienteId).firstOrNull;
      if (cliente == null) {
        return ToolResult.notFound('Cliente sin deuda registrada.');
      }
      return ToolResult.success({
        'clienteId': cliente.clientId,
        'clienteNombre': cliente.name,
        'totalDeuda': cliente.totalDebt,
        'cantidadFacturas': cliente.ventasCount,
      });
    },

    'sales.getResumenDeudas': (params, ctx) async {
      final bodegaId = ctx['selectedWarehouseId'] as String?;
      final bodegaIds = bodegaId != null ? {bodegaId} : const <String>{};
      final reporte = await _db.salesDao.getReceivablesReport(bodegaIds: bodegaIds);
      final total = await _db.salesDao.getMontoTotalFiados(bodegaIds: bodegaIds);
      return ToolResult.success({
        'totalFiados': total,
        'cantidadClientes': reporte.length,
      });
    },

    'sales.getEstadoCaja': (params, ctx) async {
      final sesion = await _db.salesDao.getCajaSesionActivaActual();
      if (sesion == null) return ToolResult.success({'cajaAbierta': false});
      final efectivo = await _db.salesDao.getVentasEfectivoSesion(sesion.id);
      final credito = await _db.salesDao.getVentasCreditoPendienteSesion(
        sesion.id,
      );
      final ganancia = await _db.salesDao.getGananciaSesion(sesion.id);
      return ToolResult.success({
        'cajaAbierta': true,
        'sesionId': sesion.id,
        'ventasEfectivo': efectivo,
        'ventasCredito': credito,
        'ganancia': ganancia,
      });
    },

    // ── Use Cases (marcan borrador, no ejecutan) ──────────────────────────
    'usecase.registrarEntrada': (params, ctx) async {
      return ToolResult.success({
        '__requires_draft': true,
        '__draft_type': 'entry',
        'bodegaId': params['bodegaId'] ?? ctx['selectedWarehouseId'],
        'items': params['items'] ?? [],
      });
    },

    'usecase.registrarVenta': (params, ctx) async {
      return ToolResult.success({
        '__requires_draft': true,
        '__draft_type': 'sale',
        'cajaSesionId': ctx['openCashSessionId'],
        'bodegaId': ctx['selectedWarehouseId'],
        'clientName':
            params['clientName'] ??
            params['client_name'] ??
            params['clientQuery'] ??
            params['nombreCliente'],
        'saleType':
            params['saleType'] ?? params['sale_type'] ?? params['tipoVenta'],
        'depositAmount':
            params['depositAmount'] ??
            params['deposit_amount'] ??
            params['abono'] ??
            params['montoAbonado'],
        'items': params['items'] ?? [],
      });
    },
  };
}
