# Plan 00 - Arranque del módulo Secretario IA
**Origen:** `requerimiento/Add IA/README.md`

---

## Objetivo

Crear la estructura vacía del módulo `features/assistant`, registrar la ruta `/assistant` dentro del `ShellRoute` existente y conectar el botón "IA" que ya existe en `BottomAppBarDashboard`. La pantalla responde con mocks; ninguna lógica real se implementa aquí.

---

## Hallazgo importante

`BottomAppBarDashboard` **ya tiene el botón "IA"** con `onTap: () {}` vacío (línea 99–103 de `bottom_app_bar_dashboard.dart`). Solo hay que conectarlo con `context.push('/assistant')`. No se agrega ningún botón nuevo.

---

## Archivos a crear

```text
lib/features/assistant/
  data/
    assistant_query_repository.dart       ← stub
  domain/
    models/
      assistant_message.dart
      assistant_intent.dart               ← stub (se llena en plan_02)
      assistant_response.dart
    services/
      assistant_parser.dart               ← stub (se llena en plan_02)
      assistant_orchestrator.dart         ← stub (se llena en plan_01)
    utils/
      text_normalizer.dart                ← función _normalize compartida
  presentation/
    providers/
      assistant_provider.dart
    screens/
      assistant_screen.dart
    widgets/
      assistant_message_bubble.dart
      assistant_input_bar.dart
```

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/core/router/app_router.dart` | Agregar `/assistant` dentro del `ShellRoute` |
| `lib/features/dashboard/presentation/widgets/bottom_app_bar_dashboard.dart` | Conectar `onTap` del botón "IA" |

---

## Paso 1 — Utilidad de normalización compartida

Este archivo lo usarán `AssistantParser`, `EntityResolver` y `AssistantSessionManager`. Se crea primero para evitar duplicación.

```dart
// lib/features/assistant/domain/utils/text_normalizer.dart

String normalizeText(String text) {
  const accents = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'ü': 'u', 'ñ': 'n',
    'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
    'Ü': 'u', 'Ñ': 'n',
  };
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().characters) {
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString().trim();
}
```

---

## Paso 2 — AssistantMessage

```dart
// lib/features/assistant/domain/models/assistant_message.dart

enum MessageRole { user, assistant, error }

class AssistantMessage {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;
  final List<String> clarificationOptions;

  const AssistantMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.clarificationOptions = const [],
  });
}
```

---

## Paso 3 — AssistantResponse (stub extensible)

```dart
// lib/features/assistant/domain/models/assistant_response.dart

class AssistantResponse {
  final String text;
  final bool isError;
  final bool needsClarification;
  final List<String> clarificationOptions;

  const AssistantResponse({
    required this.text,
    this.isError = false,
    this.needsClarification = false,
    this.clarificationOptions = const [],
  });

  factory AssistantResponse.error(String message) =>
      AssistantResponse(text: message, isError: true);

  factory AssistantResponse.clarify(String question, List<String> options) =>
      AssistantResponse(
        text: question,
        needsClarification: true,
        clarificationOptions: options,
      );
}
```

---

## Paso 4 — Stubs del dominio

```dart
// lib/features/assistant/domain/models/assistant_intent.dart
// Stub mínimo — se completa en plan_02

enum AssistantIntentType { unsupported }

class AssistantIntent {
  final AssistantIntentType type;
  final String rawText;
  final Map<String, dynamic> entities;
  final double confidence;

  const AssistantIntent({
    required this.type,
    required this.rawText,
    required this.entities,
    required this.confidence,
  });
}
```

```dart
// lib/features/assistant/domain/services/assistant_parser.dart
// Stub — se implementa en plan_02

import '../models/assistant_intent.dart';

class AssistantParser {
  AssistantIntent parse(String rawText) {
    return AssistantIntent(
      type: AssistantIntentType.unsupported,
      rawText: rawText,
      entities: {},
      confidence: 0.0,
    );
  }
}
```

```dart
// lib/features/assistant/domain/services/assistant_orchestrator.dart
// Stub — se implementa en plan_01

import '../models/assistant_response.dart';

class AssistantOrchestrator {
  Future<AssistantResponse> handle(String rawText) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AssistantResponse(
      text: 'Entendido: "$rawText" — lógica pendiente.',
    );
  }
}
```

```dart
// lib/features/assistant/data/assistant_query_repository.dart
// Stub — se implementa en plan_04

import '../domain/models/assistant_intent.dart';
import '../domain/models/assistant_response.dart';

class AssistantQueryRepository {
  Future<AssistantResponse> execute(AssistantIntent intent) async {
    return AssistantResponse(text: 'Consulta pendiente de implementar.');
  }
}
```

---

## Paso 5 — Provider de estado (con orquestador stub)

```dart
// lib/features/assistant/presentation/providers/assistant_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/assistant_message.dart';
import '../../domain/services/assistant_orchestrator.dart';

class AssistantState {
  final List<AssistantMessage> messages;
  final bool isLoading;

  const AssistantState({this.messages = const [], this.isLoading = false});

  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
  }) =>
      AssistantState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AssistantNotifier extends StateNotifier<AssistantState> {
  final AssistantOrchestrator _orchestrator;
  static const _uuid = Uuid();

  AssistantNotifier(this._orchestrator) : super(const AssistantState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AssistantMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final response = await _orchestrator.handle(text.trim());

      final reply = AssistantMessage(
        id: _uuid.v4(),
        role: response.isError ? MessageRole.error : MessageRole.assistant,
        text: response.text,
        timestamp: DateTime.now(),
        clarificationOptions: response.clarificationOptions,
      );

      state = state.copyWith(
        messages: [...state.messages, reply],
        isLoading: false,
      );
    } catch (_) {
      final errMsg = AssistantMessage(
        id: _uuid.v4(),
        role: MessageRole.error,
        text: 'Ocurrió un error inesperado. Intentá de nuevo.',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errMsg],
        isLoading: false,
      );
    }
  }
}

final assistantOrchestratorProvider = Provider<AssistantOrchestrator>(
  (_) => AssistantOrchestrator(),
);

final assistantProvider =
    StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
  return AssistantNotifier(ref.watch(assistantOrchestratorProvider));
});
```

---

## Paso 6 — Widgets de UI

```dart
// lib/features/assistant/presentation/widgets/assistant_message_bubble.dart

import 'package:flutter/material.dart';
import '../../domain/models/assistant_message.dart';

class AssistantMessageBubble extends StatelessWidget {
  final AssistantMessage message;

  const AssistantMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isError = message.role == MessageRole.error;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.shade100
              : isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
```

```dart
// lib/features/assistant/presentation/widgets/assistant_input_bar.dart

import 'package:flutter/material.dart';

class AssistantInputBar extends StatefulWidget {
  final void Function(String text) onSend;

  const AssistantInputBar({super.key, required this.onSend});

  @override
  State<AssistantInputBar> createState() => _AssistantInputBarState();
}

class _AssistantInputBarState extends State<AssistantInputBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Escribe una consulta...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _submit,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Paso 7 — AssistantScreen

```dart
// lib/features/assistant/presentation/screens/assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/assistant_provider.dart';
import '../widgets/assistant_message_bubble.dart';
import '../widgets/assistant_input_bar.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);
    ref.listen(assistantProvider, (_, __) => _scrollToBottom());

    final lastMessage = state.messages.isNotEmpty ? state.messages.last : null;

    return Column(
      children: [
        Expanded(
          child: state.messages.isEmpty
              ? const Center(
                  child: Text(
                    'Escribe una consulta para empezar.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: state.messages.length,
                  itemBuilder: (_, i) =>
                      AssistantMessageBubble(message: state.messages[i]),
                ),
        ),
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        // Chips de clarificación
        if (lastMessage != null &&
            lastMessage.clarificationOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: lastMessage.clarificationOptions
                  .map((opt) => ActionChip(
                        label: Text(opt),
                        onPressed: () => ref
                            .read(assistantProvider.notifier)
                            .sendMessage(opt),
                      ))
                  .toList(),
            ),
          ),
        AssistantInputBar(
          onSend: (text) =>
              ref.read(assistantProvider.notifier).sendMessage(text),
        ),
      ],
    );
  }
}
```

> **Nota:** La pantalla es un `Column` sin `Scaffold` propio porque `MainLayout` (el `ShellRoute`) ya provee el `Scaffold`, `AppBar` y `BottomAppBar`.

---

## Paso 8 — Registrar ruta DENTRO del ShellRoute

En `lib/core/router/app_router.dart`, agregar dentro del bloque `routes:` del `ShellRoute` (junto a `/dashboard`, `/profile`, etc.):

```dart
// Importar al inicio del archivo
import 'package:inventario_v2/features/assistant/presentation/screens/assistant_screen.dart';

// Dentro de ShellRoute > routes:
GoRoute(
  path: '/assistant',
  builder: (context, state) => const AssistantScreen(),
),
```

---

## Paso 9 — Conectar botón "IA" existente

En `lib/features/dashboard/presentation/widgets/bottom_app_bar_dashboard.dart`, el botón ya existe en la línea 99. Solo cambiar el `onTap`:

```dart
// ANTES (línea ~99):
_MenuButton(
  icon: Icons.chat_bubble_outline,
  text: 'IA',
  onTap: () {},   // ← vacío
),

// DESPUÉS:
_MenuButton(
  icon: Icons.chat_bubble_outline,
  text: 'IA',
  onTap: () => context.push('/assistant'),
),
```

---

## Criterio de cierre

- [ ] Compilación sin errores
- [ ] Pantalla visible al tocar el botón "IA" en la barra inferior
- [ ] La pantalla usa el `MainLayout` del `ShellRoute` (tiene AppBar y BottomBar)
- [ ] Usuario puede escribir y recibir respuesta mock
- [ ] Sin modificaciones de datos
