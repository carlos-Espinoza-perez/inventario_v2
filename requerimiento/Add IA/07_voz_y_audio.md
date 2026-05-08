# 07 - Voz y audio

## Objetivo

Agregar voz al Secretario despues de que el asistente por texto sea estable.

La voz debe ser una capa de entrada/salida, no el corazon de la logica.

## Orden recomendado

### Fase 1 - Push-to-talk

El usuario presiona un boton, habla y suelta para enviar.

Ventajas:

- menos errores por ruido
- mas facil de probar
- mejor para bodega
- evita VAD complejo al inicio

### Fase 2 - Transcripcion

Opciones:

- `speech_to_text` para comandos cortos y bajo costo
- Whisper API para mayor precision
- Whisper local solo si se valida rendimiento real

Decision recomendada:

- iniciar con texto MVP
- probar `speech_to_text` como entrada opcional
- si la precision no basta, pasar a Whisper API

### Fase 3 - Respuesta auditiva

Primero:

- sonidos cortos locales
- feedback visual claro

Despues:

- TTS para frases dinamicas
- cache de frases frecuentes

### Fase 4 - Modo manos libres

Agregar VAD automatico solo cuando ya existan datos reales de uso.

No implementarlo al inicio.

## Flujo futuro

```text
Audio -> transcripcion -> mismo parser de texto -> contexto -> consulta/borrador -> respuesta visual -> respuesta auditiva
```

## Reglas de seguridad

- si no hay internet, no guardar audios pendientes para ejecutar despues
- si la transcripcion es ambigua, pedir confirmacion
- las acciones siguen pasando por borrador
- la voz nunca ejecuta una accion irreversible sin confirmacion

## Dependencias futuras posibles

- `permission_handler`
- `record`
- `speech_to_text`
- `just_audio`
- cliente HTTP/OpenAI

No agregarlas hasta que toque implementar esta fase.
