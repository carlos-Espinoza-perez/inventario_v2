# 05 - Acciones con borrador

## Objetivo

Permitir que el Secretario prepare ventas, entradas, salidas y abonos sin modificar Drift hasta que el usuario confirme.

Esta fase se implementa despues del MVP de consultas.

## Principio

Toda accion pasa por un borrador editable.

La IA prepara, el usuario confirma, los Use Cases ejecutan.

## Acciones previstas

### Venta

Intent:

- `action_register_sale`

Datos requeridos:

- items
- cantidad
- producto o variante resuelta
- tipo de venta: contado o credito
- cliente si es credito
- abono inicial si aplica
- metodo de pago si se define

Use Case:

- `RegistrarVentaUseCase`

Bloqueos:

- sin caja abierta
- sin bodega seleccionada
- sin permiso `sale.create`
- credito sin permiso `sale.credit`
- stock insuficiente

### Entrada

Intent:

- `action_register_entry`

Datos requeridos:

- bodega destino
- items
- cantidad
- costo
- precio venta opcional
- descripcion o referencia

Use Case:

- `RegistrarEntradaUseCase`

### Salida o ajuste

Intent:

- `action_register_output_adjustment`

Datos requeridos:

- bodega
- items
- cantidad
- motivo

Motivos sugeridos:

- merma
- consumo interno
- ajuste fisico
- perdida
- otro

Pendiente:

- crear o exponer un Use Case claro para salida/ajuste si no existe de forma directa.

### Abono

Intent:

- `action_register_receivable_payment`

Datos requeridos:

- cliente
- monto
- venta relacionada opcional

Pendiente:

- extraer flujo actual de abonos a un Use Case reutilizable.

## Modelo de borrador

```dart
enum AssistantDraftStatus {
  ready,
  needsReview,
  blocked,
}

class AssistantDraft {
  final String id;
  final AssistantIntentType type;
  final AssistantDraftStatus status;
  final List<AssistantDraftItem> items;
  final Map<String, dynamic> metadata;
  final List<String> warnings;
  final List<String> blockers;
}
```

## UI de confirmacion

No usar un AlertDialog simple para acciones importantes.

Usar una pantalla o bottom sheet de revision con:

- resumen de accion
- productos editables
- cantidades editables
- precio/costo editable cuando aplique
- cliente editable
- bodega visible
- advertencias
- boton confirmar
- boton cancelar

## Criterio para cerrar esta fase

- el asistente puede preparar al menos una entrada
- el usuario puede revisar antes de guardar
- se ejecuta mediante Use Case existente
- no se modifica Drift sin confirmacion explicita
