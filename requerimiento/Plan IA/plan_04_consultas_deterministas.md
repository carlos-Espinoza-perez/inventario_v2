# Plan 04 - Consultas deterministas contra Drift
**Origen:** `requerimiento/Add IA/04_consultas_deterministas.md`

---

## Objetivo

Implementar `AssistantQueryRepository` que ejecuta las 7 consultas del MVP usando los métodos reales de los DAOs. Sin TODOs genéricos: los métodos ya existen en el proyecto.

---

## Métodos de DAO confirmados y disponibles

| Consulta | DAO | Método real |
|---|---|---|
| Stock de producto | `InventoryDao` | `searchProductoByCodeOrName(query)` + `getStockRealPorBodega(bodegaId)` |
| Precio de producto | `InventoryDao` | `getPreciosProductoPorBodega(productoId)` + `getProductoById(productoId)` |
| Clientes con deuda | `SalesDao` | `getReceivablesReport({bodegaIds?})` |
| Deuda de cliente | `SalesDao` | `getReceivablesReport` + filtrar por cliente |
| Ventas del día | `SalesDao` | `getVentasDelDia({bodegaIds?})` |
| Estado de caja | `SalesDao` | `getCajaSesionActivaActual()` + `getVentasEfectivoSesion` + `getVentasCreditoPendienteSesion` |
| Última venta de producto | `SalesDao` | `getSalesList()` o `getTopSellingProducts` — **revisar si hay método más directo** |

> **Nota sobre SKU:** En el proyecto, `sku` vive en `ProductoVariante`, no en `Producto`. La búsqueda de producto por texto usa `searchProductoByCodeOrName(query)` que ya maneja ambos casos internamente.

---

## Archivos a crear/modificar

| Archivo | Cambio |
|---|---|
| `lib/features/assistant/data/assistant_query_repository.dart` | Implementación real con DAOs |

---

## Paso 1 — Estructura del repositorio

```dart
// lib/features/assistant/data/assistant_query_repository.dart

import 'package:inventario_v2/core/db/app_database.dart';
import '../domain/models/assistant_intent.dart';
import '../domain/models/assistant_operational_context.dart';
import '../domain/models/assistant_response.dart';
import 'entity_resolver.dart';

class AssistantQueryRepository {
  final AppDatabase _db;
  late final EntityResolver _resolver;

  AssistantQueryRepository(this._db) {
    _resolver = EntityResolver(_db);
  }

  Future<AssistantResponse> execute(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    switch (intent.type) {
      case AssistantIntentType.queryStockProduct:
        return _queryStock(intent, context);
      case AssistantIntentType.queryPriceProduct:
        return _queryPrice(intent, context);
      case AssistantIntentType.queryReceivableBalanceClient:
        return _queryClientBalance(intent, context);
      case AssistantIntentType.queryReceivablesSummary:
        return _queryReceivablesSummary(context);
      case AssistantIntentType.querySalesSummary:
        return _querySalesSummary(context);
      case AssistantIntentType.queryCashStatus:
        return _queryCashStatus(context);
      case AssistantIntentType.queryLastSaleProduct:
        return _queryLastSale(intent, context);
      case AssistantIntentType.actionRegisterEntry:
      case AssistantIntentType.actionRegisterSale:
      case AssistantIntentType.actionRegisterOutputAdjustment:
      case AssistantIntentType.actionRegisterReceivablePayment:
      case AssistantIntentType.actionRegisterTransfer:
        return AssistantResponse(
          text: 'Esa acción estará disponible pronto. '
              'Por ahora puedo responder consultas.',
        );
      default:
        return AssistantResponse(text: 'No puedo responder esa consulta.');
    }
  }
```

---

## Paso 2 — Stock de producto

```dart
  Future<AssistantResponse> _queryStock(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    final productQuery = (intent.entities['productQuery'] as String?) ?? '';
    if (productQuery.isEmpty) {
      return AssistantResponse(
        text: '¿De qué producto querés saber el stock?',
        needsClarification: true,
      );
    }

    final resolution = await _resolver.resolveProduct(
      productQuery,
      empresaId: context.empresaId,
    );

    if (resolution.isNotFound) {
      return AssistantResponse(
        text: 'No encontré ningún producto parecido a "$productQuery".',
      );
    }
    if (resolution.isAmbiguous) {
      return AssistantResponse.clarify(
        'Encontré varios productos parecidos. ¿Cuál querés consultar?',
        resolution.candidates
            .map((p) => (p as Producto).nombre)
            .take(4)
            .toList(),
      );
    }

    final producto = resolution.selected! as Producto;
    final warehouseId = context.selectedWarehouseId!;
    final totalAllWarehouses = intent.entities['totalAllWarehouses'] == true;

    if (totalAllWarehouses) {
      // Sumar en todas las bodegas permitidas
      double total = 0;
      for (final bid in context.allowedWarehouseIds) {
        final stockList = await _db.inventoryDao.getStockRealPorBodega(bid);
        total += stockList
            .where((s) => s.productoId == producto.id)
            .fold(0.0, (sum, s) => sum + s.cantidadActual);
      }
      return AssistantResponse(
        text: '${producto.nombre} tiene ${total.toStringAsFixed(0)} unidades '
            'en total entre tus bodegas.',
      );
    }

    final stockList = await _db.inventoryDao.getStockRealPorBodega(warehouseId);
    final stockItem = stockList
        .where((s) => s.productoId == producto.id)
        .fold(0.0, (sum, s) => sum + s.cantidadActual);

    return AssistantResponse(
      text: '${producto.nombre} tiene ${stockItem.toStringAsFixed(0)} unidades disponibles.',
    );
  }
```

---

## Paso 3 — Precio de producto

Prioridad (del requerimiento):
1. Inventario en bodega con `precioVenta > 0`
2. `ProductoVariante.precioEspecifico`
3. `Producto.precioBase`
4. `Producto.ultimoPrecioVenta`

```dart
  Future<AssistantResponse> _queryPrice(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    final productQuery = (intent.entities['productQuery'] as String?) ?? '';
    final resolution = await _resolver.resolveProduct(
      productQuery,
      empresaId: context.empresaId,
    );

    if (resolution.isNotFound) {
      return AssistantResponse(text: 'No encontré "$productQuery".');
    }
    if (resolution.isAmbiguous) {
      return AssistantResponse.clarify(
        '¿Cuál producto querés consultar?',
        resolution.candidates
            .map((p) => (p as Producto).nombre)
            .take(4)
            .toList(),
      );
    }

    final producto = resolution.selected! as Producto;

    // Buscar precio en inventario por bodega
    final precios =
        await _db.inventoryDao.getPreciosProductoPorBodega(producto.id);

    double? precioFinal;
    String fuente = '';

    // 1. Precio en inventario de la bodega seleccionada
    if (context.selectedWarehouseId != null) {
      final enBodega = precios
          .where((p) =>
              p.bodegaId == context.selectedWarehouseId &&
              (p.precioVenta ?? 0) > 0)
          .firstOrNull;
      if (enBodega != null) {
        precioFinal = enBodega.precioVenta;
        fuente = 'precio en bodega';
      }
    }

    // 2. Precio base del producto
    precioFinal ??= (producto.precioBase != null && producto.precioBase! > 0)
        ? producto.precioBase
        : null;
    if (precioFinal == producto.precioBase) fuente = 'precio base';

    // 3. Último precio de venta
    if (precioFinal == null && producto.ultimoPrecioVenta > 0) {
      precioFinal = producto.ultimoPrecioVenta;
      fuente = 'último precio de venta';
    }

    if (precioFinal == null || precioFinal == 0) {
      return AssistantResponse(
        text: '${producto.nombre} no tiene precio registrado.',
      );
    }

    return AssistantResponse(
      text: '${producto.nombre}: C\$ ${precioFinal.toStringAsFixed(2)} ($fuente).',
    );
  }
```

---

## Paso 4 — Deuda de cliente

```dart
  Future<AssistantResponse> _queryClientBalance(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    final clientQuery = (intent.entities['clientQuery'] as String?) ?? '';
    final resolution = await _resolver.resolveClient(
      clientQuery,
      empresaId: context.empresaId,
    );

    if (resolution.isNotFound) {
      return AssistantResponse(
        text: 'No encontré un cliente con el nombre "$clientQuery".',
      );
    }
    if (resolution.isAmbiguous) {
      return AssistantResponse.clarify(
        '¿Cuál cliente querés consultar?',
        resolution.candidates
            .map((c) => (c as Cliente).nombre)
            .take(4)
            .toList(),
      );
    }

    final cliente = resolution.selected! as Cliente;

    // saldoDeudorActual es el campo desnormalizado del modelo Cliente.
    // Usar getReceivablesReport para obtener datos más precisos.
    final reporte = await _db.salesDao.getReceivablesReport(
      bodegaIds: context.allowedWarehouseIds.toList(),
    );

    final fila = reporte.clientDetails
        .where((d) => d.clienteId == cliente.id)
        .firstOrNull;

    if (fila == null || fila.saldoPendiente <= 0) {
      return AssistantResponse(
        text: '${cliente.nombre} no tiene deudas pendientes.',
      );
    }

    return AssistantResponse(
      text: '${cliente.nombre} debe C\$ ${fila.saldoPendiente.toStringAsFixed(2)}.',
    );
  }
```

> **Nota:** Los nombres exactos de campos en el resultado de `getReceivablesReport` deben verificarse leyendo el modelo de retorno del DAO antes de implementar. Ajustar `clientDetails`, `clienteId` y `saldoPendiente` según el tipo real.

---

## Paso 5 — Resumen de deudas

```dart
  Future<AssistantResponse> _queryReceivablesSummary(
    AssistantOperationalContext context,
  ) async {
    final reporte = await _db.salesDao.getReceivablesReport(
      bodegaIds: context.allowedWarehouseIds.toList(),
    );

    final total = await _db.salesDao.getMontoTotalFiados();
    final cantidadClientes = reporte.clientDetails
        .where((d) => d.saldoPendiente > 0)
        .length;

    return AssistantResponse(
      text: 'Total en cuentas por cobrar: C\$ ${total.toStringAsFixed(2)}. '
          '$cantidadClientes cliente(s) con saldo pendiente.',
    );
  }
```

---

## Paso 6 — Ventas del día

```dart
  Future<AssistantResponse> _querySalesSummary(
    AssistantOperationalContext context,
  ) async {
    final stats = await _db.salesDao.getVentasDelDia(
      bodegaIds: context.allowedWarehouseIds.toList(),
    );

    // getVentasDelDia devuelve un objeto — revisar tipo real antes de implementar
    // Los campos esperados: totalVentas, ventasEfectivo, ventasCredito, cantidadVentas
    return AssistantResponse(
      text: 'Hoy vendiste C\$ ${stats.totalVentas.toStringAsFixed(2)}. '
          '${stats.cantidadVentas} venta(s): '
          'C\$ ${stats.ventasEfectivo.toStringAsFixed(2)} en efectivo, '
          'C\$ ${stats.ventasCredito.toStringAsFixed(2)} a crédito.',
    );
  }
```

> **Nota:** Verificar el tipo de retorno de `getVentasDelDia` en el DAO antes de implementar y ajustar los nombres de campos.

---

## Paso 7 — Estado de caja

```dart
  Future<AssistantResponse> _queryCashStatus(
    AssistantOperationalContext context,
  ) async {
    // El contexto ya valida que hay caja abierta antes de llegar aquí
    final sesion = await _db.salesDao.getCajaSesionActivaActual();
    if (sesion == null) {
      return AssistantResponse(text: 'No hay caja abierta en este momento.');
    }

    final ventasEfectivo =
        await _db.salesDao.getVentasEfectivoSesion(sesion.id);
    final ventasCredito =
        await _db.salesDao.getVentasCreditoPendienteSesion(sesion.id);
    final ganancia = await _db.salesDao.getGananciaSesion(sesion.id);

    final totalVentas = ventasEfectivo + ventasCredito;

    return AssistantResponse(
      text: 'Caja abierta. '
          'Ventas de la sesión: C\$ ${totalVentas.toStringAsFixed(2)} '
          '(efectivo: C\$ ${ventasEfectivo.toStringAsFixed(2)}, '
          'crédito: C\$ ${ventasCredito.toStringAsFixed(2)}). '
          'Ganancia estimada: C\$ ${ganancia.toStringAsFixed(2)}.',
    );
  }
```

---

## Paso 8 — Última venta de producto

```dart
  Future<AssistantResponse> _queryLastSale(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    final productQuery = (intent.entities['productQuery'] as String?) ?? '';
    final resolution = await _resolver.resolveProduct(
      productQuery,
      empresaId: context.empresaId,
    );

    if (resolution.isNotFound) {
      return AssistantResponse(text: 'No encontré "$productQuery".');
    }
    if (resolution.isAmbiguous) {
      return AssistantResponse.clarify(
        '¿Cuál producto querés consultar?',
        resolution.candidates
            .map((p) => (p as Producto).nombre)
            .take(4)
            .toList(),
      );
    }

    final producto = resolution.selected! as Producto;
    final historial = await _db.inventoryDao.getHistorialProducto(
      producto.id,
      null, // null = todas las bodegas
    );

    // Filtrar por tipo 'venta' y tomar el más reciente
    final ventas = historial
        .where((m) => m.tipo == 'venta' || m.tipo == 'salida_venta')
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    if (ventas.isEmpty) {
      return AssistantResponse(
        text: '${producto.nombre} no tiene ventas registradas.',
      );
    }

    final ultima = ventas.first;
    final fechaStr = _formatDate(ultima.fecha);
    return AssistantResponse(
      text: 'Última venta de ${producto.nombre}: '
          '$fechaStr — ${ultima.cantidad.toStringAsFixed(0)} unidad(es).',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

## Notas de integración importantes

1. **`getStockRealPorBodega`** devuelve una lista de objetos con `productoId` y `cantidadActual`. Verificar el tipo exacto en `inventory_dao.dart` antes de implementar.

2. **`getReceivablesReport`** devuelve un modelo de reporte. Leer el tipo de retorno para mapear los campos correctos (`clientDetails`, `saldoPendiente`, etc.).

3. **`getVentasDelDia`** devuelve un modelo de stats. Verificar campos antes de acceder.

4. **`getHistorialProducto`** — verificar los valores del campo `tipo` (`'venta'`, `'salida_venta'`, etc.) en los datos reales.

5. **`getPreciosProductoPorBodega`** — verificar el tipo de retorno y si tiene campo `precioVenta` y `bodegaId`.

Estos 5 puntos son revisiones rápidas de lectura antes de implementar; no son cambios de arquitectura.

---

## Criterio de cierre

- [ ] Las 7 consultas devuelven datos reales de Drift
- [ ] `searchProductoByCodeOrName` se usa como punto de entrada del resolver (no `_fetchAllProducts` manual)
- [ ] Productos no encontrados responden con texto claro sin crash
- [ ] Productos ambiguos muestran chips con opciones
- [ ] Cálculos financieros (deudas, ventas) vienen del DAO, no de lógica propia
- [ ] Ningún método modifica datos
