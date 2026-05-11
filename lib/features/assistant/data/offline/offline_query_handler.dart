import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import '../../domain/models/assistant_operational_context.dart';

enum _OfflineQueryType { stock, precio, ventasDelDia, estadoCaja, notSupported }

class OfflineQueryHandler {
  final AppDatabase _db;

  static final _stockPatterns = RegExp(
    r'stock|cu[aá]nto hay|cu[aá]ntos hay|cu[aá]nto tengo|disponib|existe|quedan?',
    caseSensitive: false,
  );
  static final _precioPatterns = RegExp(
    r'precio|cu[aá]nto cuesta|cu[aá]nto vale|a c[oó]mo',
    caseSensitive: false,
  );
  static final _ventasPatterns = RegExp(
    r'ventas? del d[ií]a|ventas? hoy|cu[aá]nto vend',
    caseSensitive: false,
  );
  static final _cajaPatterns = RegExp(
    r'caja|sesi[oó]n|efectivo|estado de (la )?caja',
    caseSensitive: false,
  );

  const OfflineQueryHandler(this._db);

  Future<String> handle(
    String message,
    AssistantOperationalContext context,
  ) async {
    final type = _classify(message);
    return switch (type) {
      _OfflineQueryType.stock => await _handleStock(message, context),
      _OfflineQueryType.precio => await _handlePrecio(message, context),
      _OfflineQueryType.ventasDelDia => await _handleVentas(context),
      _OfflineQueryType.estadoCaja => await _handleCaja(),
      _OfflineQueryType.notSupported => _notSupportedMessage(),
    };
  }

  _OfflineQueryType _classify(String message) {
    if (_stockPatterns.hasMatch(message)) return _OfflineQueryType.stock;
    if (_precioPatterns.hasMatch(message)) return _OfflineQueryType.precio;
    if (_ventasPatterns.hasMatch(message)) return _OfflineQueryType.ventasDelDia;
    if (_cajaPatterns.hasMatch(message)) return _OfflineQueryType.estadoCaja;
    return _OfflineQueryType.notSupported;
  }

  Future<String> _handleStock(
    String message,
    AssistantOperationalContext context,
  ) async {
    final bodegaId = context.selectedWarehouseId;
    if (bodegaId == null) {
      return '⚠️ Sin conexión. Seleccioná una bodega para consultar stock.';
    }

    final query = _extractProductQuery(message);
    if (query.isEmpty) {
      return '⚠️ Sin conexión. ¿De qué producto querés saber el stock?';
    }

    final producto =
        await _db.inventoryDao.searchProductoByCodeOrName(query);

    if (producto == null) {
      return '⚠️ Sin conexión. No encontré ningún producto con "$query".';
    }

    final stockList = await _db.inventoryDao.getStockRealPorBodega(bodegaId);
    final items = stockList
        .where((s) => s.variante.productoId == producto.id)
        .toList();
    final total = items.fold(
      0.0,
      (sum, s) => sum + s.inventario.cantidadActual,
    );

    return '⚠️ Modo sin conexión:\n${producto.nombre}: ${total.toStringAsFixed(0)} unidades en bodega.';
  }

  Future<String> _handlePrecio(
    String message,
    AssistantOperationalContext context,
  ) async {
    final query = _extractProductQuery(message);
    if (query.isEmpty) {
      return '⚠️ Sin conexión. ¿De qué producto querés saber el precio?';
    }

    final producto =
        await _db.inventoryDao.searchProductoByCodeOrName(query);

    if (producto == null) {
      return '⚠️ Sin conexión. No encontré "$query".';
    }

    final precio = producto.ultimoPrecioVenta;
    if (precio <= 0) {
      return '⚠️ Sin conexión. ${producto.nombre} no tiene precio configurado.';
    }

    return '⚠️ Modo sin conexión:\n${producto.nombre}: \$${precio.toStringAsFixed(2)}';
  }

  Future<String> _handleVentas(AssistantOperationalContext context) async {
    try {
      final bodegaIds = context.selectedWarehouseId != null
          ? {context.selectedWarehouseId!}
          : null;
      final total = await _db.salesDao.getVentasDelDia(bodegaIds: bodegaIds);
      return '⚠️ Modo sin conexión:\nVentas del día: \$${total.toStringAsFixed(2)}';
    } catch (_) {
      return '⚠️ Sin conexión. No hay datos de ventas disponibles.';
    }
  }

  Future<String> _handleCaja() async {
    final sesion = await _db.salesDao.getCajaSesionActivaActual();
    if (sesion == null) {
      return '⚠️ Sin conexión. No hay caja abierta en este momento.';
    }
    final efectivo =
        await _db.salesDao.getVentasEfectivoSesion(sesion.id);
    return '⚠️ Modo sin conexión:\nCaja abierta. Efectivo: \$${efectivo.toStringAsFixed(2)}';
  }

  String _notSupportedMessage() =>
      '⚠️ Sin conexión a internet. En modo offline solo puedo responder '
      'consultas básicas de stock, precios y ventas. '
      'Verificá tu conexión para usar el asistente completo.';

  String _extractProductQuery(String message) {
    final stopWords = [
      'stock', 'precio', 'cu[aá]nto hay', 'cu[aá]ntos', 'cu[aá]nto tengo',
      'disponible', 'existe', 'quedan', 'queda', 'cuesta', 'vale',
      'a cómo', 'cuánto', 'dime', 'dame', r'\bde\b', r'\bel\b',
      r'\bla\b', r'\blos\b', r'\blas\b', r'\bhay\b',
    ];

    var q = message.toLowerCase();
    for (final word in stopWords) {
      q = q.replaceAll(RegExp(word, caseSensitive: false), ' ');
    }
    return q.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

final offlineQueryHandlerProvider = Provider<OfflineQueryHandler>((ref) {
  return OfflineQueryHandler(ref.watch(driftDatabaseProvider));
});
