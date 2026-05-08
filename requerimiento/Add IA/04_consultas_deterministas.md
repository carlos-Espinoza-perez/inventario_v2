# 04 - Consultas deterministas

## Objetivo

Responder preguntas de negocio usando datos reales de Drift, DAOs, repositorios y providers.

La IA no debe calcular ni inventar cifras. Solo debe ayudar a transformar lenguaje natural en una consulta concreta.

## Consultas del MVP

### Stock de producto

Intent:

- `query_stock_product`

Entrada:

- `productQuery`
- `warehouseId` opcional
- `includeVariants` opcional

Respuesta:

- nombre resuelto del producto
- bodega consultada
- stock disponible
- variantes si aplica

Regla:

- por defecto responder stock en bodega seleccionada
- si el usuario dice "total", sumar bodegas permitidas

### Precio de producto

Intent:

- `query_price_product`

Respuesta:

- precio de venta recomendado
- variante si aplica
- bodega si el precio depende del inventario

Regla pendiente de negocio:

- definir prioridad exacta entre `Inventarios.precioVenta`, `ProductoVariantes.precioEspecifico`, `Productos.precioBase` y `Productos.ultimoPrecioVenta`

Recomendacion inicial:

1. si hay variante e inventario con `precioVenta > 0`, usar ese precio
2. si variante tiene `precioEspecifico`, usarlo
3. si producto tiene `precioBase`, usarlo
4. si no, usar `ultimoPrecioVenta`

### Clientes con deuda

Intent:

- `query_receivables_summary`

Respuesta:

- total pendiente
- cantidad de clientes
- top clientes con mayor saldo

Regla:

- preferir calculo desde ventas a credito y abonos, no desde campos que puedan estar desactualizados

### Deuda de cliente

Intent:

- `query_receivable_balance_client`

Entrada:

- `clientQuery`

Respuesta:

- cliente resuelto
- saldo pendiente
- ventas pendientes principales

### Ventas del dia

Intent:

- `query_sales_summary`

Entrada:

- `dateRange`

Respuesta:

- total vendido
- efectivo/credito si esta disponible
- cantidad de ventas

### Estado de caja

Intent:

- `query_cash_status`

Respuesta:

- caja abierta o cerrada
- monto inicial
- ventas de la sesion
- gastos o diferencias si aplica

### Ultima venta de producto

Intent:

- `query_last_sale_product`

Entrada:

- `productQuery`

Respuesta:

- fecha de ultima venta
- cantidad
- precio
- cliente si aplica y si no es consumidor final

## Formato de respuesta

Las respuestas deben ser breves y utiles:

```text
Camisa Nike talla M tiene 12 unidades en Bodega Central. Precio sugerido: C$ 450.
```

Si hay ambiguedad:

```text
Encontre 3 productos parecidos: Coca Cola 500ml, Coca Cola 1L y Coca lata. Cual queres consultar?
```

Si no hay datos:

```text
No encontre un producto parecido a "coca zero grande".
```
