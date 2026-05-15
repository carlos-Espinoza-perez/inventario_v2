# Casos de prueba - Secretario IA

Fecha de preparacion: 2026-05-10

## Objetivo

Validar que el modulo de IA responde consultas reales, prepara borradores antes de guardar y respeta el flujo operativo de inventario, ventas, caja, bodegas y permisos.

## Datos recomendados para probar

- Usuario con permisos de ventas, inventario y caja.
- Una caja abierta para probar registro de ventas.
- Al menos dos bodegas asignadas al usuario.
- Productos de prueba:
  - Cafe molido con stock disponible.
  - Azucar 1kg con stock disponible.
  - Arroz 1kg con variantes o nombres parecidos para desambiguacion.
- Un cliente de prueba llamado Maria o Carlos.

## Preguntas rapidas de consulta

| Caso | Prompt | Resultado esperado |
| --- | --- | --- |
| Stock por producto | Cuanto cafe molido hay en bodega principal? | Responde cantidad real sin inventar datos. |
| Precio | Cual es el precio del azucar 1kg? | Responde precio del sistema. |
| Historial de ventas | Mostrame las ultimas ventas | Lista hasta 5 ventas recientes o indica que no hay ventas. |
| Caja | Como esta la caja hoy? | Indica caja abierta/cerrada o pide abrir caja si aplica. |
| Bodega faltante | Cuanto arroz hay? | Si hay varias bodegas y ninguna seleccionada, pregunta en que bodega trabajar. |
| Cambio de bodega | Cambiar de bodega | Muestra opciones de bodegas permitidas. |
| Producto ambiguo | Cuanto arroz tengo? | Pide elegir entre productos coincidentes si hay varias opciones. |
| Pregunta no soportada | Hazme una factura fiscal compleja | Responde que no puede completar esa accion o pide especificar. |

## Proceso: registrar una venta por texto

1. Abrir caja si no hay turno activo.
2. Abrir el modulo Asistente IA.
3. Enviar: `Vendeme 2 cafe molido a Maria al contado`.
4. Verificar que el asistente no guarde directo y muestre un borrador.
5. Revisar:
   - Tipo: venta.
   - Cliente: Maria.
   - Items: Cafe molido x 2.
   - Total correcto.
6. Confirmar el borrador.
7. Resultado esperado: `Venta registrada correctamente.`
8. Revisar en ventas recientes que aparezca la venta.

## Proceso: registrar una venta fiada con abono

1. Enviar: `Vende 3 azucar 1kg a Carlos al fiado, me abona 100`.
2. Verificar borrador:
   - Tipo: venta.
   - Cliente: Carlos.
   - Tipo venta: Fiado.
   - Abono: 100.
3. Confirmar.
4. Resultado esperado:
   - Venta registrada.
   - Saldo pendiente correcto si el total es mayor que el abono.

## Proceso: registrar una entrada de inventario

1. Enviar: `Registra entrada de 5 cafe molido con costo 80 y precio 120 en bodega principal`.
2. Verificar que se muestre borrador de entrada.
3. Confirmar.
4. Resultado esperado:
   - Entrada registrada.
   - Stock incrementado en la bodega seleccionada.
5. Preguntar despues: `Cuanto cafe molido hay en bodega principal?`

## Proceso: registrar una salida o ajuste

> Nota de prueba: actualmente el flujo acumulativo interno usa borrador de inventario para salida/ajuste. Validar si la ejecucion final descuenta stock o si solo queda como pendiente de implementacion.

1. Enviar: `Registra una salida de 1 cafe molido por producto dañado`.
2. Resultado esperado ideal:
   - El asistente prepara un borrador de salida/ajuste, no una entrada.
   - Pide confirmacion antes de guardar.
   - Al confirmar, descuenta stock y registra motivo.
3. Si el borrador aparece como entrada, registrar como hallazgo funcional.

## Proceso: sesion acumulativa con scanner

1. Iniciar modo venta/entrada acumulativa desde la UI si esta disponible.
2. Escanear un producto.
3. Cuando pregunte cantidad, responder: `2`.
4. Escanear otro producto.
5. Responder: `3`.
6. Enviar: `que llevo`.
7. Resultado esperado: lista ambos items.
8. Enviar: `listo`.
9. Resultado esperado: muestra borrador para confirmar.
10. Cancelar y validar que no se guarda nada.

## Casos negativos

| Caso | Prompt | Resultado esperado |
| --- | --- | --- |
| Sin sesion | Usar asistente sin login | Indica que no hay sesion activa. |
| Sin bodega | Cuanto stock hay? | Pide seleccionar bodega. |
| Sin caja | Vendeme 1 cafe molido | Pide abrir caja antes de registrar venta. |
| Stock insuficiente | Vendeme 999999 cafe molido | Bloquea operacion por stock insuficiente. |
| Cantidad invalida | En sesion scanner responder `dos cajas` | Pide ingresar solo numero y mantiene producto pendiente. |
| Codigo inexistente | Escanear codigo desconocido | Indica que no encontro producto y no agrega item. |
| Cancelacion | cancelar | Cancela sesion/borrador sin guardar. |

## Criterios de aprobacion

- Ninguna accion de escritura se ejecuta sin borrador y confirmacion.
- Las consultas usan datos reales del sistema.
- El asistente pide datos faltantes con una sola pregunta clara.
- Las opciones de aclaracion se muestran cuando hay ambiguedad.
- Ventas requieren caja abierta.
- Operaciones de inventario requieren bodega valida.
- Las respuestas de error son entendibles para usuario operativo.
