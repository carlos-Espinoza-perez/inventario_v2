# Plan 07 - Voz y audio
**Origen:** `requerimiento/Add IA/07_voz_y_audio.md`

---

## Objetivo

Agregar voz al Secretario como capa de entrada/salida sobre la lógica de texto ya funcional. La voz nunca ejecuta acciones directamente; solo alimenta el mismo parser que ya usa el texto.

**Prerequisito obligatorio:** Planes 01–04 completados y las consultas por texto deben ser confiables antes de iniciar este plan.

---

## Fases de implementación

### Fase 1 — Push-to-talk (entrada)

### Fase 2 — Transcripción

### Fase 3 — Respuesta auditiva (TTS)

### Fase 4 — Modo manos libres con VAD

> No implementar Fase 4 sin datos reales de uso.

---

## Archivos a crear (Fase 1 + 2)

| Archivo | Propósito |
|---|---|
| `lib/features/assistant/domain/services/speech_transcriber.dart` | Interfaz de transcripción (abstrae el paquete) |
| `lib/features/assistant/data/speech_to_text_transcriber.dart` | Implementación con `speech_to_text` |
| `lib/features/assistant/presentation/widgets/assistant_voice_button.dart` | Botón de push-to-talk |

## Archivos a modificar (Fase 1 + 2)

| Archivo | Cambio |
|---|---|
| `pubspec.yaml` | Agregar `speech_to_text` y `permission_handler` al llegar a esta fase |
| `lib/features/assistant/presentation/widgets/assistant_input_bar.dart` | Agregar botón de micrófono junto al campo de texto |
| `lib/features/assistant/presentation/providers/assistant_provider.dart` | Agregar estado de grabación |

---

## Fase 1 — Push-to-talk

### Dependencias (agregar solo cuando toque)

```yaml
# pubspec.yaml
speech_to_text: ^7.0.0      # o la versión más reciente
permission_handler: ^11.0.0
```

### Interfaz abstracta del transcriptor

```dart
// lib/features/assistant/domain/services/speech_transcriber.dart

abstract class SpeechTranscriber {
  Future<bool> initialize();
  Future<String?> transcribe();
  void dispose();
}
```

### Implementación con speech_to_text

```dart
// lib/features/assistant/data/speech_to_text_transcriber.dart

import 'package:speech_to_text/speech_to_text.dart';
import '../domain/services/speech_transcriber.dart';

class SpeechToTextTranscriber implements SpeechTranscriber {
  final SpeechToText _stt = SpeechToText();

  @override
  Future<bool> initialize() => _stt.initialize();

  @override
  Future<String?> transcribe() async {
    final completer = Completer<String?>();

    _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          completer.complete(result.recognizedWords.isNotEmpty
              ? result.recognizedWords
              : null);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      localeId: 'es_ES',
    );

    return completer.future;
  }

  @override
  void dispose() => _stt.cancel();
}
```

### Botón de voz

```dart
// lib/features/assistant/presentation/widgets/assistant_voice_button.dart

import 'package:flutter/material.dart';

enum VoiceButtonState { idle, recording, processing }

class AssistantVoiceButton extends StatelessWidget {
  final VoiceButtonState state;
  final VoidCallback onTap;

  const AssistantVoiceButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      VoiceButtonState.idle => Theme.of(context).colorScheme.primary,
      VoiceButtonState.recording => Colors.red,
      VoiceButtonState.processing => Colors.orange,
    };

    final icon = switch (state) {
      VoiceButtonState.idle => Icons.mic_none,
      VoiceButtonState.recording => Icons.mic,
      VoiceButtonState.processing => Icons.hourglass_empty,
    };

    return IconButton(
      onPressed: state == VoiceButtonState.processing ? null : onTap,
      icon: Icon(icon, color: color),
      tooltip: switch (state) {
        VoiceButtonState.idle => 'Mantener para hablar',
        VoiceButtonState.recording => 'Grabando...',
        VoiceButtonState.processing => 'Procesando...',
      },
    );
  }
}
```

### Estado de grabación en AssistantProvider

Agregar al `AssistantState`:

```dart
final VoiceButtonState voiceState;
```

Agregar método en `AssistantNotifier`:

```dart
Future<void> startVoiceInput() async {
  state = state.copyWith(voiceState: VoiceButtonState.recording);
  try {
    final transcript = await _transcriber.transcribe();
    state = state.copyWith(voiceState: VoiceButtonState.processing);
    if (transcript != null && transcript.isNotEmpty) {
      await sendMessage(transcript);
    } else {
      // Transcripción vacía: silencio o error
      state = state.copyWith(voiceState: VoiceButtonState.idle);
    }
  } catch (_) {
    state = state.copyWith(voiceState: VoiceButtonState.idle);
  }
}
```

---

## Fase 2 — Transcripción alternativa: Whisper API

Si `speech_to_text` no tiene precisión suficiente para el español latinoamericano, migrar a Whisper API:

```dart
// lib/features/assistant/data/whisper_transcriber.dart

class WhisperTranscriber implements SpeechTranscriber {
  final String _apiKey;
  WhisperTranscriber(this._apiKey);

  @override
  Future<String?> transcribe() async {
    // 1. Grabar audio con el paquete `record`
    // 2. Enviar a https://api.openai.com/v1/audio/transcriptions
    // 3. Retornar texto transcrito
    throw UnimplementedError('Implementar cuando sea necesario');
  }
  // ...
}
```

Elegir implementación via provider:

```dart
final speechTranscriberProvider = Provider<SpeechTranscriber>((ref) {
  // Cambiar a WhisperTranscriber si se valida que speech_to_text no es suficiente
  return SpeechToTextTranscriber();
});
```

---

## Fase 3 — Respuesta auditiva (TTS)

Agregar solo cuando las fases anteriores sean estables.

```yaml
# pubspec.yaml (agregar solo en esta fase)
just_audio: ^0.10.0
flutter_tts: ^4.0.0
```

```dart
// lib/features/assistant/domain/services/tts_service.dart

abstract class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
}
```

Estrategia para esta fase:
1. Primero: sonidos locales cortos para confirmar/error
2. Luego: `flutter_tts` para frases dinámicas
3. Cachear respuestas de frases frecuentes para evitar delay

---

## Reglas de seguridad (todas las fases)

- No guardar audios en disco para ejecutar después sin conexión
- Si transcripción es ambigua (baja confianza), mostrar texto y pedir confirmación
- Las acciones siempre pasan por borrador, aunque vengan de voz
- La voz nunca ejecuta operaciones irreversibles sin confirmación visual

---

## Flujo completo (Fase 1 + 2 implementadas)

```
Toque botón mic → grabar audio → transcribir → AssistantParser.parse()
→ AssistantOrchestrator.handle() → AssistantResponse → mostrar en chat
→ [opcional] TtsService.speak(response.text)
```

---

## Criterio de cierre (Fase 1 + 2)

- [ ] Botón de micrófono visible en `AssistantInputBar`
- [ ] Push-to-talk funciona en Android e iOS
- [ ] Transcripción llega correctamente al parser
- [ ] Texto transcrito visible en burbuja de usuario igual que texto escrito
- [ ] No se agrega ruido o texto vacío al chat
- [ ] Las acciones siguen pasando por borrador aunque vengan de voz
