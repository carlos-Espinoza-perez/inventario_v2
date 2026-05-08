# 02 - Intents y contratos

## Objetivo

Definir que puede entender el Secretario y que estructura interna debe producir antes de consultar o preparar una accion.

En la primera fase, el parser puede ser por reglas. Mas adelante se puede reemplazar o complementar con un LLM, pero el contrato interno debe mantenerse estable.

## Tipos de intent

### Consultas

- `query_stock_product`
- `query_price_product`
- `query_receivable_balance_client`
- `query_receivables_summary`
- `query_sales_summary`
- `query_cash_status`
- `query_last_sale_product`
- `query_product_history`

### Acciones futuras

- `action_register_sale`
- `action_register_entry`
- `action_register_output_adjustment`
- `action_register_transfer`
- `action_register_receivable_payment`

### Utilidad

- `clarify_product`
- `clarify_client`
- `ask_missing_data`
- `unsupported`

## Contrato base

```dart
enum AssistantIntentType {
  queryStockProduct,
  queryPriceProduct,
  queryReceivableBalanceClient,
  queryReceivablesSummary,
  querySalesSummary,
  queryCashStatus,
  queryLastSaleProduct,
  queryProductHistory,
  actionRegisterSale,
  actionRegisterEntry,
  actionRegisterOutputAdjustment,
  actionRegisterTransfer,
  actionRegisterReceivablePayment,
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
}
```

## Entidades iniciales

Para consultas:

- `productQuery`
- `clientQuery`
- `warehouseQuery`
- `dateRange`
- `includeVariants`

Para acciones futuras:

- `items`
- `quantity`
- `price`
- `cost`
- `paymentType`
- `depositAmount`
- `reason`

## Reglas para el MVP por texto

El parser debe:

- normalizar texto a minusculas
- quitar tildes para comparacion
- detectar palabras clave
- extraer el resto como busqueda de producto o cliente
- devolver `unsupported` si no entiende

No debe:

- ejecutar acciones
- inventar IDs
- asumir producto si hay ambiguedad fuerte
- responder datos financieros sin consultar Drift

## Ejemplos

Texto:

```text
cuanto stock tengo de coca cola 500
```

Intent:

```json
{
  "type": "query_stock_product",
  "entities": {
    "productQuery": "coca cola 500"
  },
  "confidence": 0.8
}
```

Texto:

```text
quien me debe
```

Intent:

```json
{
  "type": "query_receivables_summary",
  "entities": {},
  "confidence": 0.9
}
```
