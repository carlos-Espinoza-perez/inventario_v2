# Plan 02 - Parser de intents por reglas
**Origen:** `requerimiento/Add IA/02_intents_y_contratos.md`

---

## Objetivo

Completar `AssistantIntentType`, `AssistantIntent` y `AssistantParser`. El parser detecta la intención a partir de texto libre usando reglas deterministas, normaliza usando `normalizeText()` del archivo compartido creado en plan_00, y extrae entidades básicas. Sin LLM, sin embeddings.

---

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/features/assistant/domain/models/assistant_intent.dart` | Reemplazar stub con enum y clase completos |
| `lib/features/assistant/domain/services/assistant_parser.dart` | Implementar lógica de reglas |

---

## Paso 1 — AssistantIntentType y AssistantIntent completos

```dart
// lib/features/assistant/domain/models/assistant_intent.dart

enum AssistantIntentType {
  // Consultas
  queryStockProduct,
  queryPriceProduct,
  queryReceivableBalanceClient,
  queryReceivablesSummary,
  querySalesSummary,
  queryCashStatus,
  queryLastSaleProduct,
  queryProductHistory,

  // Acciones (activas desde plan_05)
  actionRegisterSale,
  actionRegisterEntry,
  actionRegisterOutputAdjustment,
  actionRegisterTransfer,
  actionRegisterReceivablePayment,

  // Utilidad
  clarifyProduct,
  clarifyClient,
  askMissingData,
  unsupported,
}

class AssistantIntent {
  final AssistantIntentType type;
  final String rawText;
  final Map<String, dynamic> entities;
  final double confidence;

  const AssistantIntent({
    required this.type,
    required this.rawText,
    required this.entities,
    required this.confidence,
  });

  bool get isQuery => type.name.startsWith('query');
  bool get isAction => type.name.startsWith('action');
  bool get isUnsupported => type == AssistantIntentType.unsupported;
}
```

---

## Paso 2 — AssistantParser completo

Usa `normalizeText` del archivo compartido. El orden de detección importa: reglas más específicas primero.

```dart
// lib/features/assistant/domain/services/assistant_parser.dart

import '../models/assistant_intent.dart';
import '../utils/text_normalizer.dart';

class AssistantParser {
  AssistantIntent parse(String rawText) {
    final n = normalizeText(rawText);
    return _detect(n, rawText);
  }

  AssistantIntent _detect(String n, String rawText) {
    // ── Deuda de cliente (antes que resumen de deudas) ──────────────────────
    // "cuanto debe maria", "deuda de pedro", "saldo de cliente X"
    if (_any(n, ['cuanto debe ', 'deuda de ', 'saldo de '])) {
      final clientQuery = _after(n, ['cuanto debe ', 'deuda de ', 'saldo de ']);
      return AssistantIntent(
        type: AssistantIntentType.queryReceivableBalanceClient,
        rawText: rawText,
        entities: {'clientQuery': clientQuery},
        confidence: clientQuery.isNotEmpty ? 0.85 : 0.55,
      );
    }

    // ── Resumen de deudas ───────────────────────────────────────────────────
    // "quien me debe", "quienes deben", "lista de deudas", "deudas pendientes"
    if (_any(n, ['quien me debe', 'quienes deben', 'lista de deudas', 'deudas pendientes', 'deudas'])) {
      return AssistantIntent(
        type: AssistantIntentType.queryReceivablesSummary,
        rawText: rawText,
        entities: {},
        confidence: 0.9,
      );
    }

    // ── Ventas del día ──────────────────────────────────────────────────────
    // "cuanto vendi hoy", "ventas del dia", "ventas de hoy"
    if (_any(n, ['cuanto vendi', 'vendi hoy', 'ventas del dia', 'ventas de hoy', 'cuanto vendi hoy'])) {
      return AssistantIntent(
        type: AssistantIntentType.querySalesSummary,
        rawText: rawText,
        entities: {'dateRange': 'today'},
        confidence: 0.88,
      );
    }

    // ── Caja ────────────────────────────────────────────────────────────────
    // "como va la caja", "estado de caja", "arqueo", "como esta la caja"
    if (_any(n, ['como va la caja', 'estado de caja', 'arqueo', 'como esta la caja', 'caja abierta'])) {
      return AssistantIntent(
        type: AssistantIntentType.queryCashStatus,
        rawText: rawText,
        entities: {},
        confidence: 0.9,
      );
    }

    // ── Última venta de producto ────────────────────────────────────────────
    // "cuando se vendio X", "ultima venta de X", "ultima vez que se vendio X"
    if (_any(n, ['cuando se vendio', 'ultima venta de', 'ultima vez que se vendio'])) {
      final productQuery = _after(n, [
        'cuando se vendio ',
        'ultima venta de ',
        'ultima vez que se vendio ',
      ]);
      return AssistantIntent(
        type: AssistantIntentType.queryLastSaleProduct,
        rawText: rawText,
        entities: {'productQuery': productQuery},
        confidence: productQuery.isNotEmpty ? 0.85 : 0.5,
      );
    }

    // ── Historial de producto ───────────────────────────────────────────────
    // "historial de X", "movimientos de X"
    if (_any(n, ['historial de ', 'movimientos de '])) {
      final productQuery = _after(n, ['historial de ', 'movimientos de ']);
      return AssistantIntent(
        type: AssistantIntentType.queryProductHistory,
        rawText: rawText,
        entities: {'productQuery': productQuery},
        confidence: productQuery.isNotEmpty ? 0.82 : 0.5,
      );
    }

    // ── Precio de producto ──────────────────────────────────────────────────
    // "cuanto cuesta X", "precio de X", "a cuanto esta X", "cuanto vale X"
    if (_any(n, ['cuanto cuesta', 'precio de', 'a cuanto', 'cuanto vale', 'cuesta '])) {
      final productQuery = _after(n, [
        'cuanto cuesta ',
        'el precio de ',
        'precio de ',
        'a cuanto esta ',
        'a cuanto ',
        'cuanto vale ',
        'cuesta ',
      ]);
      return AssistantIntent(
        type: AssistantIntentType.queryPriceProduct,
        rawText: rawText,
        entities: {'productQuery': productQuery},
        confidence: productQuery.isNotEmpty ? 0.85 : 0.5,
      );
    }

    // ── Stock de producto ───────────────────────────────────────────────────
    // "cuanto stock de X", "cuanto hay de X", "cuantas unidades de X"
    if (_any(n, ['stock de', 'cuanto hay de', 'cuantas unidades de', 'cuanto tengo de', 'inventario de', 'cuanto stock'])) {
      final productQuery = _after(n, [
        'stock de ',
        'cuanto hay de ',
        'cuantas unidades de ',
        'cuanto tengo de ',
        'inventario de ',
        'cuanto stock de ',
        'cuanto stock tengo de ',
      ]);
      final warehouseHint = _extractWarehouseHint(n);
      return AssistantIntent(
        type: AssistantIntentType.queryStockProduct,
        rawText: rawText,
        entities: {
          'productQuery': productQuery,
          if (warehouseHint != null) 'warehouseQuery': warehouseHint,
          'includeVariants': n.contains('variante') || n.contains('talla') || n.contains('color'),
          'totalAllWarehouses': n.contains('total') || n.contains('todas las bodegas'),
        },
        confidence: productQuery.isNotEmpty ? 0.87 : 0.5,
      );
    }

    // ── Acciones (stub para plan_05) ────────────────────────────────────────
    if (_any(n, ['hacer una entrada', 'registrar entrada', 'entra mercaderia', 'recibir mercaderia'])) {
      return AssistantIntent(
        type: AssistantIntentType.actionRegisterEntry,
        rawText: rawText,
        entities: {},
        confidence: 0.75,
      );
    }

    if (_any(n, ['vender', 'hacer una venta', 'registrar venta', 'anotar venta'])) {
      return AssistantIntent(
        type: AssistantIntentType.actionRegisterSale,
        rawText: rawText,
        entities: {},
        confidence: 0.75,
      );
    }

    if (_any(n, ['salida de', 'ajuste de', 'dar de baja', 'merma', 'perdida de'])) {
      return AssistantIntent(
        type: AssistantIntentType.actionRegisterOutputAdjustment,
        rawText: rawText,
        entities: {},
        confidence: 0.72,
      );
    }

    if (_any(n, ['abono de', 'recibir pago de', 'pago de ', 'abonar a'])) {
      return AssistantIntent(
        type: AssistantIntentType.actionRegisterReceivablePayment,
        rawText: rawText,
        entities: {},
        confidence: 0.72,
      );
    }

    // ── Sin coincidencia ────────────────────────────────────────────────────
    return AssistantIntent(
      type: AssistantIntentType.unsupported,
      rawText: rawText,
      entities: {},
      confidence: 0.0,
    );
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  bool _any(String normalized, List<String> keywords) =>
      keywords.any((kw) => normalized.contains(kw));

  /// Extrae el texto que viene después del primer keyword encontrado
  String _after(String normalized, List<String> prefixes) {
    for (final prefix in prefixes) {
      final idx = normalized.indexOf(prefix);
      if (idx >= 0) {
        return normalized.substring(idx + prefix.length).trim();
      }
    }
    return '';
  }

  String? _extractWarehouseHint(String normalized) {
    const markers = ['en bodega ', 'bodega ', 'en almacen '];
    for (final m in markers) {
      final idx = normalized.indexOf(m);
      if (idx >= 0) {
        return normalized.substring(idx + m.length).trim();
      }
    }
    return null;
  }
}
```

---

## Paso 3 — Tests unitarios recomendados

Crear `test/features/assistant/domain/services/assistant_parser_test.dart`:

```dart
void main() {
  final parser = AssistantParser();

  group('queryStockProduct', () {
    test('detecta consulta de stock con producto', () {
      final i = parser.parse('cuanto stock tengo de camisa nike');
      expect(i.type, AssistantIntentType.queryStockProduct);
      expect(i.entities['productQuery'], 'camisa nike');
    });
    test('extrae hint de bodega', () {
      final i = parser.parse('cuanto hay de coca cola en bodega central');
      expect(i.type, AssistantIntentType.queryStockProduct);
      expect(i.entities['warehouseQuery'], 'central');
    });
  });

  group('queryPriceProduct', () {
    test('detecta "cuanto cuesta"', () {
      final i = parser.parse('cuanto cuesta la coca cola 500');
      expect(i.type, AssistantIntentType.queryPriceProduct);
      expect(i.entities['productQuery'], contains('coca cola'));
    });
  });

  group('queryCashStatus', () {
    test('detecta "como va la caja"', () {
      expect(parser.parse('como va la caja').type,
          AssistantIntentType.queryCashStatus);
    });
  });

  group('queryReceivableBalanceClient', () {
    test('detecta "cuanto debe maria"', () {
      final i = parser.parse('cuanto debe maria');
      expect(i.type, AssistantIntentType.queryReceivableBalanceClient);
      expect(i.entities['clientQuery'], 'maria');
    });
  });

  group('queryReceivablesSummary', () {
    test('detecta "quien me debe"', () {
      expect(parser.parse('quien me debe').type,
          AssistantIntentType.queryReceivablesSummary);
    });
  });

  group('unsupported', () {
    test('texto sin sentido devuelve unsupported', () {
      expect(parser.parse('abc xyz 123').type,
          AssistantIntentType.unsupported);
    });
    test('texto vacío devuelve unsupported', () {
      expect(parser.parse('').type, AssistantIntentType.unsupported);
    });
  });
}
```

---

## Nota de extensión futura

Cuando se migre a LLM el contrato `AssistantIntent` no cambia. Solo se reemplaza `AssistantParser` por una implementación que llama a un modelo de lenguaje pero devuelve el mismo tipo.

---

## Criterio de cierre

- [ ] `AssistantIntentType` cubre los 17 tipos del contrato
- [ ] Parser detecta correctamente los 7 intents de consulta MVP
- [ ] Texto sin sentido devuelve `unsupported`
- [ ] `productQuery` y `clientQuery` se extraen sin el prefijo de la frase
- [ ] `normalizeText` viene del archivo compartido (no duplicada)
- [ ] Tests unitarios pasan sin errores
