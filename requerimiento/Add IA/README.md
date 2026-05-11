# Secretario IA v2

## Objetivo

Construir un asistente para el sistema de inventario que permita consultar datos y preparar acciones usando lenguaje natural.

El desarrollo se hara por fases. La primera version sera por texto, sin voz, para validar la utilidad real y conectar el asistente con Drift, permisos, bodegas, caja y casos de uso existentes. La voz se agregara despues sobre una base ya confiable.

## Principio central

La IA no debe tocar la base de datos directamente.

El asistente solo interpreta la solicitud, resuelve entidades y prepara una respuesta o un borrador. Las acciones finales se ejecutan usando los mismos Use Cases que usa la interfaz manual.

## Orden de implementacion

1. `01_asistente_texto_mvp.md`
   - Primera pantalla de asistente por texto.
   - Consultas exactas: stock, precio, ventas, deuda, caja.

2. `02_intents_y_contratos.md`
   - Catalogo de intenciones.
   - Estructuras internas que debe producir el parser.

3. `03_contexto_operativo.md`
   - Empresa, usuario, permisos, bodega, caja y pantalla actual.
   - Reglas para bloquear acciones no permitidas.

4. `04_consultas_deterministas.md`
   - Consultas con Drift y repositorios.
   - Respuestas exactas sin inventar datos.

5. `05_acciones_con_borrador.md`
   - Venta, entrada, salida/ajuste y abono.
   - Borrador temporal y confirmacion antes de guardar.

6. `06_resolucion_de_entidades.md`
   - Matching de productos, variantes, clientes y bodegas.
   - Desambiguacion cuando hay varias coincidencias.

7. `07_voz_y_audio.md`
   - Push-to-talk, transcripcion, TTS y feedback auditivo.
   - Se implementa despues de que texto funcione bien.

8. `08_roadmap_de_entregas.md`
   - Secuencia concreta de desarrollo y criterios de avance.

9. `09_sesion_acumulativa.md`
   - Sesion activa que acumula items en varios turnos.
   - Input mixto: voz, texto y scanner de codigos de barra en la misma sesion.
   - El usuario va agregando productos uno a uno y confirma al final.

## Decision importante

No iniciaremos con un overlay global ni con modo manos libres completo.

La primera entrega sera una pantalla dedicada de asistente por texto. Esto reduce riesgo, permite testear rapido y evita que una mala transcripcion de voz esconda errores de logica.
