# 03 - Contexto operativo

## Objetivo

El Secretario debe respetar el mismo contexto que la app manual.

No existe una respuesta correcta si el asistente no sabe empresa, usuario, permisos, bodega seleccionada y caja abierta cuando aplica.

## Datos minimos del contexto

```dart
class AssistantOperationalContext {
  final String empresaId;
  final String usuarioId;
  final Set<String> permissionCodes;
  final String? selectedWarehouseId;
  final List<String> allowedWarehouseIds;
  final String? openCashSessionId;
  final String currentRoute;

  const AssistantOperationalContext({
    required this.empresaId,
    required this.usuarioId,
    required this.permissionCodes,
    required this.selectedWarehouseId,
    required this.allowedWarehouseIds,
    required this.openCashSessionId,
    required this.currentRoute,
  });
}
```

## Fuentes actuales en el proyecto

- sesion activa: providers/repositorios de auth
- permisos: `authorization_provider.dart` y `permission_codes.dart`
- bodega seleccionada: `selectedBodegaProvider`
- caja abierta: `dashboardProvider`
- base local: `driftDatabaseProvider`

## Reglas de permisos

Consultas:

- stock/precio/producto: requiere `product.read` o `warehouse.read`
- reportes/ventas/deudas: requiere `report.read` o `sale.read`
- caja: requiere `sale.read`

Acciones futuras:

- registrar venta: requiere `sale.create`
- venta al credito: requiere `sale.credit`
- entrada/salida/traslado: requiere `warehouse.update`
- crear producto desde asistente: requiere `product.create`

## Reglas de bodega

Por defecto:

- stock se consulta en la bodega seleccionada
- si el usuario pide "total", se suma en bodegas permitidas
- si menciona una bodega, se valida que tenga acceso

Si no hay bodega seleccionada y la consulta requiere bodega:

- el asistente debe pedir seleccionar bodega
- no debe asumir una bodega cualquiera

## Reglas de caja

Para consultar estado de caja:

- si no hay caja abierta, responder que no hay caja activa

Para venta futura:

- si no hay caja abierta, bloquear la accion y pedir abrir caja

## Criterio de seguridad

Si falta contexto, el asistente debe pedir aclaracion o bloquear con una explicacion breve.

Nunca debe ejecutar una accion usando contexto vacio.
