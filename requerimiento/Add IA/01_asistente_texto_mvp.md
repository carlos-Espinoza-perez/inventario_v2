# 01 - Asistente por texto MVP

## Objetivo

Crear una primera version del Secretario IA como una pantalla de texto dentro de la app.

Esta fase no usa microfono, Whisper, TTS ni modelos locales pesados. El objetivo es probar que el asistente entiende comandos utiles y responde usando datos reales del sistema.

## Experiencia esperada

El usuario abre una pantalla llamada "Secretario" y escribe frases como:

- "cuanto stock tengo de camisa nike"
- "cuanto cuesta coca cola 500"
- "quien me debe"
- "cuanto debe Maria"
- "cuanto vendi hoy"
- "como va la caja"
- "cuando se vendio por ultima vez este producto"

El asistente responde con texto claro y corto.

## Alcance del MVP

Solo consultas de lectura.

Incluye:

- consultar stock de producto
- consultar precio de producto
- consultar deuda de cliente
- consultar clientes con deuda
- consultar ventas del dia
- consultar estado de caja
- consultar ultima venta de un producto

No incluye todavia:

- registrar ventas
- registrar entradas
- registrar salidas
- registrar abonos
- voz
- TTS
- OpenAI
- embeddings

## Pantalla inicial

Crear una pantalla dedicada:

- ruta sugerida: `/assistant`
- modulo sugerido: `lib/features/assistant`
- nombre visible: `Secretario`

Componentes:

- lista de mensajes
- campo de texto
- boton enviar
- estado de carga
- mensajes de error amigables

## Arquitectura sugerida

Carpetas:

```text
lib/features/assistant/
  data/
    assistant_query_repository.dart
  domain/
    models/
      assistant_intent.dart
      assistant_response.dart
    services/
      assistant_parser.dart
      assistant_context_resolver.dart
      assistant_orchestrator.dart
  presentation/
    providers/
      assistant_provider.dart
    screens/
      assistant_screen.dart
    widgets/
      assistant_message_bubble.dart
      assistant_input_bar.dart
```

## Flujo tecnico

1. Usuario escribe texto.
2. `AssistantParser` detecta intencion y entidades basicas.
3. `AssistantContextResolver` obtiene contexto operativo.
4. `AssistantOrchestrator` valida permisos y contexto.
5. `AssistantQueryRepository` ejecuta consulta determinista contra Drift/DAO.
6. El asistente responde con texto.

## Criterio para cerrar esta fase

La fase esta completa cuando:

- existe pantalla funcional de asistente por texto
- responde al menos 5 consultas reales
- no rompe permisos existentes
- no modifica datos
- maneja "no encontre el producto/cliente" sin crashear
- todas las respuestas salen de datos reales, no de suposiciones
