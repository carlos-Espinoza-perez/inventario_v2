# 09 - Sesion acumulativa con input mixto

## Objetivo

Permitir que el Secretario construya un borrador de accion a lo largo de varios turnos,
combinando voz, texto y escaneo de codigos de barra en la misma sesion.

El usuario no necesita dictar todo de una sola vez. Puede ir agregando productos
uno a uno, alternar entre hablar y escanear, y confirmar cuando este listo.

## Caso de uso principal

Entrada de inventario paso a paso:

```
Usuario: "vamos a hacer una entrada"
Asistente: "Listo. Dime el primer producto o escanealo."

Usuario: "coca cola 500, 24 unidades"
Asistente: "Anotado: Coca Cola 500ml x24. ¿Siguiente producto?"

Usuario: [escanea codigo de barras]
Asistente: "Encontre Pepsi 1L. ¿Cuantas unidades?"

Usuario: "12"
Asistente: "Anotado: Pepsi 1L x12. ¿Siguiente producto?"

Usuario: "eso es todo"
Asistente: [muestra borrador con 2 items]

Usuario: [confirma]
Asistente: [ejecuta RegistrarEntradaUseCase]
```

## Concepto de sesion activa

Una sesion activa es un estado temporal en el que el asistente sabe que esta
en medio de una accion especifica y acumula items en un borrador.

Mientras la sesion esta activa:

- cada mensaje nuevo se interpreta en el contexto de esa accion
- el borrador crece con cada item confirmado
- el usuario puede cancelar en cualquier momento
- el usuario puede editar items ya agregados

Cuando la sesion termina:

- por confirmacion explicita del usuario
- por cancelacion
- por inactividad prolongada (timeout configurable)

## Modelo de sesion

```dart
enum AssistantSessionType {
  registerEntry,
  registerSale,
  registerOutputAdjustment,
  registerReceivablePayment,
}

enum AssistantSessionState {
  active,
  awaitingConfirmation,
  confirmed,
  cancelled,
}

class AssistantSession {
  final String id;
  final AssistantSessionType type;
  final AssistantSessionState state;
  final AssistantDraft draft;
  final DateTime startedAt;
  final DateTime? lastInteractionAt;
}
```

## Input mixto: voz + scanner

Dentro de la misma sesion el usuario puede usar cualquier canal:

| Canal | Que aporta |
|---|---|
| Voz | nombre del producto, cantidad, instruccion general |
| Texto escrito | lo mismo que voz |
| Scanner (camara) | codigo de barras o QR que resuelve el producto en DB |

El scanner no reemplaza la voz. Solo resuelve la entidad producto de forma exacta.
Despues el asistente sigue esperando la cantidad por voz o texto.

## Flujo tecnico del scanner dentro de la sesion

1. Usuario activa camara dentro de la pantalla del Secretario.
2. Scanner lee codigo de barras.
3. El codigo se pasa al mismo `EntityResolver` que usa el parser de voz.
4. Si encuentra producto: asistente confirma y pide cantidad.
5. Si no encuentra: asistente informa y sugiere buscarlo por nombre.
6. El flujo continua igual que si hubiera llegado por voz.

```dart
// El scanner emite el mismo evento que el parser de voz
AssistantInputEvent.fromBarcode(String barcode) -> EntityResolution<Producto>
AssistantInputEvent.fromVoice(String transcript) -> AssistantIntent
AssistantInputEvent.fromText(String text) -> AssistantIntent
```

## Reglas de la sesion activa

- el contexto de sesion tiene prioridad sobre intents generales
  - si la sesion es de entrada y el usuario dice "12", se interpreta como cantidad, no como consulta
- si el usuario pregunta algo durante la sesion (ej: "cuanto cuesta esto"), el asistente responde y vuelve al estado activo
- si el usuario dice "cancela" o "olvida todo", la sesion se descarta sin guardar
- si el usuario dice "muestra lo que llevo", se despliega el borrador parcial
- el borrador parcial no se guarda en Drift, solo en memoria mientras la sesion esta activa

## Acciones que aplican sesion acumulativa

- entrada de inventario: acumula items (producto + cantidad + costo)
- venta: acumula items (producto + cantidad + precio)
- salida o ajuste: acumula items (producto + cantidad + motivo)

El abono no aplica porque es una sola operacion por cliente.

## Estados de la pantalla durante sesion activa

```
[ Secretario ]
  Modo: Entrada de inventario  [cancelar]
  
  Items agregados:
    - Coca Cola 500ml x24
    - Pepsi 1L x12
  
  [chat de mensajes]
  [campo de texto / microfono / camara]
```

La pantalla debe mostrar siempre:
- el modo activo actual
- los items ya agregados
- opcion de cancelar visible

## Transicion al borrador de confirmacion

Cuando el usuario indica que termino, el asistente muestra el borrador completo
definido en `05_acciones_con_borrador.md`.

Desde ahi el usuario puede editar cantidades, precios o eliminar items antes de confirmar.

## Criterio para cerrar esta fase

- el usuario puede agregar al menos 3 items en la misma sesion
- el scanner puede resolver un producto dentro de la sesion activa
- el borrador acumulado se muestra correctamente
- cancelar en cualquier punto descarta todo sin guardar
- la confirmacion ejecuta el Use Case existente sin duplicar logica
