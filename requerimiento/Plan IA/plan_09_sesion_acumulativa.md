# Plan 09 - Sesión acumulativa con input mixto
**Origen:** `requerimiento/Add IA/09_sesion_acumulativa.md`

---

## Objetivo

Implementar estado de sesión activa que acumula ítems a lo largo de varios turnos combinando texto, voz y scanner. El producto pendiente del scanner se guarda con tipo explícito — sin `dynamic` en el borrador.

**Prerequisito obligatorio:** Planes 05 (borradores), 06 (resolución de entidades) y 07 (voz Fase 1) completados.

---

## Archivos a crear

| Archivo | Propósito |
|---|---|
| `lib/features/assistant/domain/models/assistant_session.dart` | Sesión activa con estado tipado |
| `lib/features/assistant/domain/models/assistant_input_event.dart` | Eventos sellados: texto, voz, barcode |
| `lib/features/assistant/domain/services/assistant_session_manager.dart` | Ciclo de vida de la sesión |
| `lib/features/assistant/presentation/widgets/assistant_session_banner.dart` | Banner de modo activo |
| `lib/features/assistant/presentation/widgets/assistant_scanner_button.dart` | Botón para activar scanner |

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/features/assistant/presentation/providers/assistant_provider.dart` | Agregar `AssistantSession?` al estado |
| `lib/features/assistant/presentation/screens/assistant_screen.dart` | Mostrar banner de sesión activa |
| `lib/features/assistant/presentation/widgets/assistant_input_bar.dart` | Agregar botón de scanner |
| `lib/features/assistant/domain/services/assistant_orchestrator.dart` | Delegar al session manager cuando hay sesión activa |

---

## Paso 1 — Modelo de sesión con producto pendiente tipado

La sesión necesita recordar cuál producto resolvió el scanner mientras espera la cantidad. En lugar de guardar esto en un `Map<String, dynamic>`, se modela explícitamente:

```dart
// lib/features/assistant/domain/models/assistant_session.dart

import 'package:inventario_v2/core/db/app_database.dart';
import 'assistant_draft.dart';
import 'assistant_intent.dart';

enum AssistantSessionType {
  registerEntry,
  registerSale,
  registerOutputAdjustment,
}

enum AssistantSessionState {
  active,
  awaitingQuantity,   // scanner resolvió producto, esperando cantidad
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
  final Producto? pendingProduct; // producto resuelto por scanner, esperando cantidad

  const AssistantSession({
    required this.id,
    required this.type,
    required this.state,
    required this.draft,
    required this.startedAt,
    this.lastInteractionAt,
    this.pendingProduct,
  });

  bool get isActive =>
      state == AssistantSessionState.active ||
      state == AssistantSessionState.awaitingQuantity;

  AssistantSession copyWith({
    AssistantSessionState? state,
    AssistantDraft? draft,
    DateTime? lastInteractionAt,
    Producto? pendingProduct,
    bool clearPendingProduct = false,
  }) =>
      AssistantSession(
        id: id,
        type: type,
        state: state ?? this.state,
        draft: draft ?? this.draft,
        startedAt: startedAt,
        lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
        pendingProduct: clearPendingProduct ? null : (pendingProduct ?? this.pendingProduct),
      );

  AssistantIntentType get draftIntentType => switch (type) {
    AssistantSessionType.registerEntry =>
        AssistantIntentType.actionRegisterEntry,
    AssistantSessionType.registerSale =>
        AssistantIntentType.actionRegisterSale,
    AssistantSessionType.registerOutputAdjustment =>
        AssistantIntentType.actionRegisterOutputAdjustment,
  };
}
```

---

## Paso 2 — Eventos de entrada sellados

```dart
// lib/features/assistant/domain/models/assistant_input_event.dart

import 'package:inventario_v2/core/db/app_database.dart';
import 'assistant_intent.dart';

sealed class AssistantInputEvent {
  const AssistantInputEvent();
}

final class TextInputEvent extends AssistantInputEvent {
  final String text;
  final AssistantIntent intent;
  const TextInputEvent({required this.text, required this.intent});
}

final class VoiceInputEvent extends AssistantInputEvent {
  final String transcript;
  final AssistantIntent intent;
  const VoiceInputEvent({required this.transcript, required this.intent});
}

final class BarcodeInputEvent extends AssistantInputEvent {
  final String barcode;
  final Producto? resolvedProduct; // null si no se encontró
  const BarcodeInputEvent({required this.barcode, this.resolvedProduct});
}
```

---

## Paso 3 — AssistantSessionManager

```dart
// lib/features/assistant/domain/services/assistant_session_manager.dart

import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import '../models/assistant_draft.dart';
import '../models/assistant_draft_item.dart';
import '../models/assistant_input_event.dart';
import '../models/assistant_intent.dart';
import '../models/assistant_response.dart';
import '../models/assistant_session.dart';
import '../utils/text_normalizer.dart';

class SessionResult {
  final AssistantSession session;
  final AssistantResponse response;
  const SessionResult({required this.session, required this.response});
}

class AssistantSessionManager {
  const AssistantSessionManager();

  AssistantSession? tryStartSession(AssistantIntentType type, String bodegaId) {
    final sessionType = switch (type) {
      AssistantIntentType.actionRegisterEntry => AssistantSessionType.registerEntry,
      AssistantIntentType.actionRegisterSale => AssistantSessionType.registerSale,
      AssistantIntentType.actionRegisterOutputAdjustment =>
          AssistantSessionType.registerOutputAdjustment,
      _ => null,
    };
    if (sessionType == null) return null;

    return AssistantSession(
      id: const Uuid().v4(),
      type: sessionType,
      state: AssistantSessionState.active,
      draft: AssistantDraft(
        id: const Uuid().v4(),
        type: type,
        status: AssistantDraftStatus.needsReview,
        items: const [],
        metadata: {'bodegaId': bodegaId},
      ),
      startedAt: DateTime.now(),
    );
  }

  Future<SessionResult> processEvent(
    AssistantSession session,
    AssistantInputEvent event,
  ) async {
    final now = DateTime.now();

    // ── Comandos de control (texto y voz) ──────────────────────────────────
    final text = switch (event) {
      TextInputEvent(text: final t) => t,
      VoiceInputEvent(transcript: final t) => t,
      BarcodeInputEvent() => null,
    };

    if (text != null) {
      final n = normalizeText(text);

      if (_isCancel(n)) {
        return SessionResult(
          session: session.copyWith(state: AssistantSessionState.cancelled),
          response: AssistantResponse(text: 'Sesión cancelada. No se guardó nada.'),
        );
      }

      if (_isDone(n)) {
        if (session.draft.items.isEmpty) {
          return SessionResult(
            session: session,
            response: AssistantResponse(
              text: 'No hay ítems en el borrador. Agregá al menos uno antes de confirmar.',
            ),
          );
        }
        return SessionResult(
          session: session.copyWith(
            state: AssistantSessionState.awaitingConfirmation,
            lastInteractionAt: now,
          ),
          response: AssistantResponse(
            text: 'Tenés ${session.draft.items.length} ítem(s) en el borrador. '
                'Revisá y confirmá.',
          ),
        );
      }

      if (_isShowDraft(n)) {
        return SessionResult(
          session: session.copyWith(lastInteractionAt: now),
          response: _buildDraftSummary(session.draft),
        );
      }

      // Si hay producto pendiente del scanner, interpretar como cantidad
      if (session.state == AssistantSessionState.awaitingQuantity &&
          session.pendingProduct != null) {
        final cantidad = double.tryParse(text.trim());
        if (cantidad != null && cantidad > 0) {
          return _addItemToSession(session, session.pendingProduct!, cantidad, now);
        }
        return SessionResult(
          session: session,
          response: AssistantResponse(
            text: 'No entendí la cantidad. Ingresá solo el número (ej: 24).',
          ),
        );
      }

      // Interpretar como "producto X, N unidades" o solo producto
      return _parseProductAndQuantity(session, text, event, now);
    }

    // ── Evento de barcode ──────────────────────────────────────────────────
    if (event is BarcodeInputEvent) {
      return _handleBarcode(session, event, now);
    }

    return SessionResult(
      session: session,
      response: AssistantResponse(text: 'No entendí ese input.'),
    );
  }

  SessionResult _handleBarcode(
    AssistantSession session,
    BarcodeInputEvent event,
    DateTime now,
  ) {
    if (event.resolvedProduct == null) {
      return SessionResult(
        session: session.copyWith(lastInteractionAt: now),
        response: AssistantResponse(
          text: 'No encontré un producto con ese código. '
              'Podés buscarlo por nombre.',
        ),
      );
    }

    // Producto encontrado: esperar cantidad
    return SessionResult(
      session: session.copyWith(
        state: AssistantSessionState.awaitingQuantity,
        pendingProduct: event.resolvedProduct,
        lastInteractionAt: now,
      ),
      response: AssistantResponse(
        text: 'Encontré ${event.resolvedProduct!.nombre}. ¿Cuántas unidades?',
      ),
    );
  }

  SessionResult _addItemToSession(
    AssistantSession session,
    Producto producto,
    double cantidad,
    DateTime now,
  ) {
    final newItem = AssistantDraftItem(
      id: const Uuid().v4(),
      productoId: producto.id,
      productoNombre: producto.nombre,
      cantidad: cantidad,
    );

    final updatedDraft = session.draft.copyWith(
      items: [...session.draft.items, newItem],
    );

    return SessionResult(
      session: session.copyWith(
        state: AssistantSessionState.active,
        draft: updatedDraft,
        lastInteractionAt: now,
        clearPendingProduct: true,
      ),
      response: AssistantResponse(
        text: 'Anotado: ${producto.nombre} x${cantidad.toStringAsFixed(0)}. '
            '¿Siguiente producto?',
      ),
    );
  }

  SessionResult _parseProductAndQuantity(
    AssistantSession session,
    String text,
    AssistantInputEvent event,
    DateTime now,
  ) {
    // Patrón simple: "producto, N" o "N unidades de producto"
    // Esta lógica se expande en la implementación real
    return SessionResult(
      session: session.copyWith(lastInteractionAt: now),
      response: AssistantResponse(
        text: 'Decime el producto y la cantidad (ej: "coca cola 500, 24 unidades").',
      ),
    );
  }

  AssistantResponse _buildDraftSummary(AssistantDraft draft) {
    if (draft.items.isEmpty) {
      return AssistantResponse(text: 'El borrador está vacío.');
    }
    final lines = draft.items
        .map((i) => '• ${i.productoNombre} x${i.cantidad.toStringAsFixed(0)}')
        .join('\n');
    return AssistantResponse(
      text: 'Lo que llevás hasta ahora:\n$lines\n\n'
          'Decí "listo" para confirmar o seguí agregando.',
    );
  }

  bool _isCancel(String n) =>
      n.contains('cancel') ||
      n.contains('olvida') ||
      n.contains('descart') ||
      n == 'no';

  bool _isDone(String n) =>
      n == 'listo' ||
      n == 'eso es todo' ||
      n == 'confirmar' ||
      n == 'terminar' ||
      n.contains('ya termine');

  bool _isShowDraft(String n) =>
      n.contains('que llevo') ||
      n.contains('muestra lo que') ||
      n.contains('ver borrador') ||
      n.contains('cuanto llevo');
}
```

---

## Paso 4 — Banner de sesión activa

```dart
// lib/features/assistant/presentation/widgets/assistant_session_banner.dart

import 'package:flutter/material.dart';
import '../../domain/models/assistant_session.dart';

class AssistantSessionBanner extends StatelessWidget {
  final AssistantSession session;
  final VoidCallback onCancel;

  const AssistantSessionBanner({
    super.key,
    required this.session,
    required this.onCancel,
  });

  String get _modeLabel => switch (session.type) {
    AssistantSessionType.registerEntry => 'Entrada de inventario',
    AssistantSessionType.registerSale => 'Venta',
    AssistantSessionType.registerOutputAdjustment => 'Salida / Ajuste',
  };

  @override
  Widget build(BuildContext context) {
    final items = session.draft.items;
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.playlist_add_check, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Modo: $_modeLabel',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Cancelar'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red, padding: EdgeInsets.zero),
              ),
            ],
          ),
          if (session.state == AssistantSessionState.awaitingQuantity &&
              session.pendingProduct != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '⏳ Esperando cantidad para: ${session.pendingProduct!.nombre}',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...items.map((i) => Text(
                  '• ${i.productoNombre} x${i.cantidad.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                )),
          ],
        ],
      ),
    );
  }
}
```

---

## Paso 5 — Integrar banner en AssistantScreen

```dart
// En el Column principal de AssistantScreen, antes del Expanded(ListView):

if (state.activeSession != null && state.activeSession!.isActive)
  AssistantSessionBanner(
    session: state.activeSession!,
    onCancel: () => ref.read(assistantProvider.notifier).cancelSession(),
  ),
```

---

## Paso 6 — Botón de scanner en AssistantInputBar

El scanner ya existe en la app (`/barcode-scanner`). Dentro de la sesión, se puede activar navegando a esa pantalla y recibiendo el resultado como un `BarcodeInputEvent`:

```dart
// En _AssistantInputBarState — agregar botón de scanner solo cuando hay sesión activa
if (widget.sessionActive)
  IconButton(
    onPressed: widget.onScanBarcode,
    icon: const Icon(Icons.qr_code_scanner),
    tooltip: 'Escanear producto',
  ),
```

El callback `onScanBarcode` navega al scanner existente y devuelve el código:

```dart
// En AssistantScreen
onScanBarcode: () async {
  final barcode = await context.push<String>('/barcode-scanner');
  if (barcode != null && context.mounted) {
    await ref.read(assistantProvider.notifier).handleBarcode(barcode);
  }
},
```

---

## Criterio de cierre

- [ ] Usuario puede acumular 3+ ítems en la misma sesión
- [ ] Scanner resuelve producto con tipo explícito (`Producto?` en la sesión — sin `dynamic`)
- [ ] Estado `awaitingQuantity` muestra el producto pendiente en el banner
- [ ] "Cancela" descarta todo sin guardar nada en Drift
- [ ] "Listo" muestra el borrador de confirmación del plan_05
- [ ] La confirmación ejecuta el Use Case existente
- [ ] Botón de scanner solo aparece cuando hay sesión activa
