# 08 - Roadmap de entregas

## Entrega 1 - Base del modulo Secretario

Objetivo:

- crear modulo `features/assistant`
- crear pantalla de chat por texto
- crear provider de estado
- agregar ruta y acceso desde la app

Resultado:

- usuario puede escribir y recibir respuestas mock o basicas

## Entrega 2 - Parser por reglas

Objetivo:

- detectar intents de consulta
- extraer `productQuery`, `clientQuery` y `dateRange`
- manejar unsupported

Resultado:

- frases comunes se transforman en intents internos

## Entrega 3 - Contexto operativo

Objetivo:

- resolver empresa, usuario, permisos, bodega y caja
- bloquear consultas sin permisos
- preparar contexto para acciones futuras

Resultado:

- asistente respeta el estado real de la app

## Entrega 4 - Consultas de productos

Objetivo:

- consultar stock
- consultar precio
- resolver producto por nombre/SKU
- manejar ambiguedad

Resultado:

- "cuanto hay de X" y "cuanto cuesta X" funcionan con Drift

## Entrega 5 - Consultas comerciales

Objetivo:

- consultar clientes con deuda
- consultar deuda de cliente
- consultar ventas del dia
- consultar caja
- consultar ultima venta de producto

Resultado:

- el asistente ya es util para el negocio sin modificar datos

## Entrega 6 - Borrador de entrada

Objetivo:

- preparar entrada de inventario por texto
- revisar items
- confirmar con `RegistrarEntradaUseCase`

Resultado:

- primera accion real con confirmacion segura

## Entrega 7 - Borrador de venta

Objetivo:

- preparar venta por texto
- validar caja, bodega, permisos y stock
- confirmar con `RegistrarVentaUseCase`

Resultado:

- venta asistida sin duplicar logica del POS

## Entrega 8 - Salidas, ajustes y abonos

Objetivo:

- crear/exponer Use Cases faltantes
- preparar borradores para salida y abono

Resultado:

- el asistente cubre operaciones principales

## Entrega 9 - Voz push-to-talk

Objetivo:

- agregar boton de microfono
- convertir voz a texto
- reutilizar el mismo parser

Resultado:

- el asistente acepta texto y voz

## Entrega 10 - TTS y feedback auditivo

Objetivo:

- agregar sonidos locales
- agregar frases habladas
- cachear respuestas frecuentes

Resultado:

- experiencia tipo secretario, pero con logica ya probada

## Entrega 11 - Sesion acumulativa con input mixto

Objetivo:

- implementar estado de sesion activa en el asistente
- acumular items en borrador a lo largo de varios turnos
- conectar scanner de camara como canal de entrada dentro de la sesion
- mostrar items agregados en pantalla mientras la sesion esta activa
- cancelar sesion sin guardar nada
- confirmar y ejecutar Use Case al final

Resultado:

- el usuario puede registrar una entrada completa diciendo productos uno a uno
- puede alternar entre hablar, escribir y escanear en la misma sesion
- ver `09_sesion_acumulativa.md` para detalle completo

Prerequisito:

- Entregas 6, 7 y 8 completadas (borradores de entrada, venta y salida funcionando)
- Voz basica (Entrega 9) recomendada pero no obligatoria para empezar con texto

## Criterio para avanzar de fase

No avanzar a voz hasta que:

- las consultas por texto sean confiables
- la resolucion de productos funcione bien
- los permisos esten integrados
- el borrador de acciones no modifique datos sin confirmacion

No avanzar a sesion acumulativa hasta que:

- los borradores de entrada y venta funcionen en flujo de un solo turno
- el scanner ya este integrado en la app de forma estable
