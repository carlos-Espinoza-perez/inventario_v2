# Plan 10 - Modo Offline / Fallback sin LLM

---

## Objetivo

Implementar un modo de fallback que permite consultas básicas de inventario cuando no hay conexión a internet (o cuando la API de OpenAI está caída). El sistema detecta la ausencia de conectividad y usa Drift directamente para responder, sin pasar por el LLM.

---

## Principio

> No necesitamos LLM para responder "¿cuánto stock hay de coca cola?". La query es determinista. El LLM agrega inteligencia cuando el lenguaje es ambiguo — en modo offline simplificamos la interfaz.

---

## Qué funciona offline vs. qué requiere online

| Funcionalidad | Modo Offline | Requiere Online |
|---|---|---|
| Consultar stock de producto (búsqueda exacta) | ✅ Sí | — |
| Consultar precio de producto | ✅ Sí | — |
| Ver ventas del día | ✅ Sí | — |
| Estado de caja | ✅ Sí | — |
| Consultas con referencia ambigua ("ese", "el mismo") | ❌ No | LLM para desambiguación |
| Registrar entrada / venta | ❌ No | LLM para construir borrador |
| Consultas en lenguaje libre | ❌ No | SemanticRouter |

---

## Paso 1 — Detector de conectividad

```dart
// lib/features/assistant/data/connectivity/connectivity_checker.dart

import 'dart:io';

class ConnectivityChecker {
  // Intenta alcanzar la API de OpenAI con timeout corto
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('api.openai.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
```

---

## Paso 2 — OfflineQueryHandler

Responde consultas básicas usando solo Drift, sin LLM.

```dart
// lib/features/assistant/data/offline/offline_query_handler.dart

import 'package:inventario_v2/core/db/app_database.dart';
import '../../domain/models/assistant_operational_context.dart';

/// Resultados que puede dar el modo offline
enum OfflineQueryType { stock, precio, ventasDelDia, estadoCaja, notSupported }

class OfflineQueryHandler {
  final AppDatabase _db;

  static final _stockPatterns = [
    RegExp(r'stock|cuánto hay|cuántos hay|cuánto tengo|disponib|existe|quedan?', caseSensitive: false),
  ];

  static final _precioPatterns = [
    RegExp(r'precio|cuánto cuesta|cuánto vale|a cómo', caseSensitive: false),
  ];

  static final _ventasPatterns = [
    RegExp(r'ventas? del día|ventas? hoy|cuánto vend', caseSensitive: false),
  ];

  static final _cajaPatterns = [
    RegExp(r'caja|sesión|efectivo|estado de (la )?caja', caseSensitive: false),
  ];

  const OfflineQueryHandler(this._db);

  Future<String> handle(
    String message,
    AssistantOperationalContext context,
  ) async {
    final type = _classify(message);

    return switch (type) {
      OfflineQueryType.stock       => await _handleStock(message, context),
      OfflineQueryType.precio      => await _handlePrecio(message, context),
      OfflineQueryType.ventasDelDia => await _handleVentas(context),
      OfflineQueryType.estadoCaja  => await _handleCaja(context),
      OfflineQueryType.notSupported => _notSupportedMessage(),
    };
  }

  OfflineQueryType _classify(String message) {
    if (_stockPatterns.any((p) => p.hasMatch(message))) return OfflineQueryType.stock;
    if (_precioPatterns.any((p) => p.hasMatch(message))) return OfflineQueryType.precio;
    if (_ventasPatterns.any((p) => p.hasMatch(message))) return OfflineQueryType.ventasDelDia;
    if (_cajaPatterns.any((p) => p.hasMatch(message))) return OfflineQueryType.estadoCaja;
    return OfflineQueryType.notSupported;
  }

  Future<String> _handleStock(
    String message,
    AssistantOperationalContext context,
  ) async {
    final bodegaId = context.selectedWarehouseId;
    if (bodegaId == null) {
      return '⚠️ Sin conexión. Necesito que selecciones una bodega para consultar stock.';
    }

    // Extraer posible nombre de producto del mensaje
    final query = _extractProductQuery(message);
    if (query.isEmpty) {
      return '⚠️ Sin conexión. ¿De qué producto querés saber el stock?';
    }

    final productos = await _db.inventoryDao.searchProductoByCodeOrName(
      query,
      empresaId: context.empresaId,
    );

    if (productos.isEmpty) {
      return '⚠️ Sin conexión. No encontré ningún producto con "$query".';
    }

    if (productos.length > 3) {
      return '⚠️ Sin conexión. Encontré ${productos.length} productos con "$query". '
          'Sé más específico o volvé a intentar cuando haya conexión.';
    }

    final buffer = StringBuffer('⚠️ Modo sin conexión — respuesta básica:\n\n');
    for (final producto in productos) {
      final stockList = await _db.inventoryDao.getStockRealPorBodega(bodegaId);
      final item = stockList.where((s) => s.productoId == producto.id).toList();
      final total = item.fold(0.0, (sum, s) => sum + s.cantidadActual);
      buffer.writeln('• ${producto.nombre}: ${total.toStringAsFixed(0)} unidades');
    }

    return buffer.toString().trim();
  }

  Future<String> _handlePrecio(
    String message,
    AssistantOperationalContext context,
  ) async {
    final query = _extractProductQuery(message);
    if (query.isEmpty) {
      return '⚠️ Sin conexión. ¿De qué producto querés saber el precio?';
    }

    final productos = await _db.inventoryDao.searchProductoByCodeOrName(
      query,
      empresaId: context.empresaId,
    );

    if (productos.isEmpty) {
      return '⚠️ Sin conexión. No encontré "$query".';
    }

    final producto = productos.first;
    final precio = producto.precioBase ?? producto.ultimoPrecioVenta;

    if (precio == null || precio <= 0) {
      return '⚠️ Sin conexión. ${producto.nombre} no tiene precio configurado.';
    }

    return '⚠️ Modo sin conexión:\n${producto.nombre}: \$${precio.toStringAsFixed(2)}';
  }

  Future<String> _handleVentas(AssistantOperationalContext context) async {
    final bodegaIds = context.allowedWarehouseIds.toList();
    final stats = await _db.salesDao.getVentasDelDia(bodegaIds: bodegaIds);

    if (stats == null) {
      return '⚠️ Sin conexión. No hay datos de ventas disponibles.';
    }

    return '⚠️ Modo sin conexión:\n'
        'Ventas del día: \$${(stats['totalVentas'] as num? ?? 0).toStringAsFixed(2)}\n'
        'Cantidad: ${stats['cantidadVentas'] ?? 0} transacciones';
  }

  Future<String> _handleCaja(AssistantOperationalContext context) async {
    final sesion = await _db.salesDao.getCajaSesionActivaActual();
    if (sesion == null) {
      return '⚠️ Sin conexión. No hay caja abierta en este momento.';
    }

    final efectivo = await _db.salesDao.getVentasEfectivoSesion(sesion.id);
    return '⚠️ Modo sin conexión:\n'
        'Caja abierta. Efectivo en caja: \$${(efectivo as num? ?? 0).toStringAsFixed(2)}';
  }

  String _notSupportedMessage() =>
      '⚠️ Sin conexión a internet. Solo puedo responder consultas básicas de stock, '
      'precios y ventas en modo offline. Verificá tu conexión para usar el asistente completo.';

  String _extractProductQuery(String message) {
    // Eliminar palabras clave de la consulta para aislar el nombre del producto
    final stopWords = [
      'stock', 'precio', 'cuánto hay', 'cuántos hay', 'cuánto tengo',
      'de', 'el', 'la', 'los', 'las', 'hay', 'tengo', 'tienen',
      'disponible', 'existe', 'quedan', 'queda', 'cuesta', 'vale',
      'a cómo', 'cuánto', 'dime', 'dame',
    ];

    var query = message.toLowerCase();
    for (final word in stopWords) {
      query = query.replaceAll(word, ' ');
    }

    return query.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
```

---

## Paso 3 — Integración en TurnPipeline

```dart
// lib/features/assistant/core/turn_pipeline.dart
// Agregar al inicio de process():

Future<TurnResult> process({
  required String userMessage,
  required ConversationState conversationState,
  required AssistantOperationalContext operationalContext,
}) async {
  // Verificar conectividad
  final isOnline = await _connectivityChecker.isOnline();

  if (!isOnline) {
    return await _handleOffline(
      userMessage: userMessage,
      conversationState: conversationState,
      operationalContext: operationalContext,
    );
  }

  // ... resto del pipeline normal
}

Future<TurnResult> _handleOffline({
  required String userMessage,
  required ConversationState conversationState,
  required AssistantOperationalContext operationalContext,
}) async {
  final response = await _offlineQueryHandler.handle(
    userMessage,
    operationalContext,
  );

  return TurnResult(
    responseText: response,
    updatedState: conversationState,
  );
}
```

---

## Paso 4 — Indicador de modo offline en la UI

```dart
// lib/features/assistant/presentation/widgets/offline_banner.dart

import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.8),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Sin conexión — modo básico activo',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
```

Agregar a `AssistantUiState`:
```dart
final bool isOffline;
```

Mostrar en `AssistantScreen` encima del input cuando `state.isOffline`:
```dart
if (state.isOffline) const OfflineBanner(),
```

---

## Paso 5 — Cache de último resultado para reconexión

Cuando el usuario recupera conexión a mitad de una sesión, los datos del `CollectedData` ya están disponibles — el sistema puede reanudar sin repetir las queries.

No hay código adicional para esto: `CollectedData` con `VariableType.session` persiste durante la sesión independientemente de si hubo momentos offline.

---

## Limitaciones documentadas del modo offline

1. **Sin desambiguación semántica**: si hay 5 productos con "camisa" en el nombre, el sistema devuelve los primeros 3 o pide ser más específico.
2. **Sin acciones de escritura**: registrar entradas, ventas, ajustes requieren LLM para validar la intención antes de ejecutar.
3. **Sin referencias contextuales**: "el mismo producto de antes" no funciona offline.
4. **Respuestas literales**: sin el toque conversacional que da el LLM.

---

## Criterio de cierre

- [ ] `ConnectivityChecker.isOnline()` verifica conectividad real (no solo WiFi conectado)
- [ ] `OfflineQueryHandler` responde stock, precio, ventas del día y estado de caja
- [ ] `TurnPipeline` verifica conectividad antes de invocar el LLM
- [ ] Respuestas offline incluyen el prefijo `⚠️ Modo sin conexión` para que el usuario sepa
- [ ] `OfflineBanner` visible en la pantalla del asistente cuando no hay internet
- [ ] Reconexión transparente: el siguiente mensaje ya usa el LLM sin acción del usuario
