# Plan 01 - Pantalla de chat MVP (flujo real)
**Origen:** `requerimiento/Add IA/01_asistente_texto_mvp.md`

---

## Objetivo

Reemplazar el mock de plan_00 con el flujo real: texto del usuario → `AssistantParser` → `AssistantContextBuilder` → `AssistantOrchestrator` → `AssistantQueryRepository` → respuesta en el chat.

Este plan conecta los módulos creados en planes 02, 03, 04 y 06. No implementa lógica propia; solo ensambla el flujo completo en el provider.

**Prerequisito:** Planes 00, 02, 03, 04 y 06 completados.

---

## Alcance

**Incluye:**
- 7 consultas de lectura operativas con datos reales de Drift
- Permisos bloqueados con mensaje claro
- "No encontrado" y "ambiguo" sin crash
- Chips de clarificación cuando hay ambigüedad

**No incluye:**
- Registrar ventas, entradas, salidas, abonos (plan_05)
- Voz / TTS (plan_07)
- Sesión acumulativa (plan_09)

---

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/features/assistant/presentation/providers/assistant_provider.dart` | Inyectar `AssistantContextBuilder` real; conectar orquestador completo |
| `lib/features/assistant/domain/services/assistant_orchestrator.dart` | Completar con parser, validación de permisos y delegación al repositorio |

---

## Paso 1 — Provider final ensamblado

```dart
// lib/features/assistant/presentation/providers/assistant_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import '../../domain/models/assistant_message.dart';
import '../../domain/models/assistant_draft.dart';
import '../../domain/services/assistant_orchestrator.dart';
import '../../domain/services/assistant_parser.dart';
import '../../data/assistant_context_builder.dart';
import '../../data/assistant_query_repository.dart';
import '../../data/entity_resolver.dart';

class AssistantState {
  final List<AssistantMessage> messages;
  final bool isLoading;
  final AssistantDraft? pendingDraft;

  const AssistantState({
    this.messages = const [],
    this.isLoading = false,
    this.pendingDraft,
  });

  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
    AssistantDraft? pendingDraft,
    bool clearDraft = false,
  }) =>
      AssistantState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        pendingDraft: clearDraft ? null : (pendingDraft ?? this.pendingDraft),
      );
}

class AssistantNotifier extends StateNotifier<AssistantState> {
  final AssistantOrchestrator _orchestrator;
  final AssistantContextBuilder _contextBuilder;
  static const _uuid = Uuid();

  AssistantNotifier(this._orchestrator, this._contextBuilder)
      : super(const AssistantState());

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
      final context = await _contextBuilder.build();
      final response = await _orchestrator.handle(text.trim(), context);

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

  void clearDraft() => state = state.copyWith(clearDraft: true);
}

// ── Providers ──────────────────────────────────────────────────────────────

final _entityResolverProvider = Provider<EntityResolver>((ref) {
  return EntityResolver(ref.watch(driftDatabaseProvider));
});

final _queryRepositoryProvider = Provider<AssistantQueryRepository>((ref) {
  return AssistantQueryRepository(
    ref.watch(driftDatabaseProvider),
    ref.watch(_entityResolverProvider),
  );
});

final assistantOrchestratorProvider = Provider<AssistantOrchestrator>((ref) {
  return AssistantOrchestrator(
    parser: AssistantParser(),
    queryRepository: ref.watch(_queryRepositoryProvider),
  );
});

final assistantProvider =
    StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
  return AssistantNotifier(
    ref.watch(assistantOrchestratorProvider),
    ref.watch(assistantContextBuilderProvider),
  );
});
```

> **Nota de arquitectura:** `AssistantQueryRepository` recibe `EntityResolver` por constructor para mantener la inyección explícita y facilitar tests.

---

## Paso 2 — Verificar que AssistantOrchestrator recibe el repositorio

El orquestador definido en plan_03 recibe `AssistantParser` y `AssistantQueryRepository`. Confirmar que el constructor coincide:

```dart
class AssistantOrchestrator {
  final AssistantParser _parser;
  final AssistantQueryRepository _queryRepository;

  const AssistantOrchestrator({
    required AssistantParser parser,
    required AssistantQueryRepository queryRepository,
  });

  Future<AssistantResponse> handle(
    String rawText,
    AssistantOperationalContext context,
  ) async { ... }
}
```

---

## Paso 3 — Verificar flujo completo manualmente

Antes de declarar la fase cerrada, probar estas 7 frases en el simulador/dispositivo:

| Frase | Intent esperado | Respuesta esperada |
|---|---|---|
| "cuanto stock tengo de [producto real]" | `queryStockProduct` | Stock numérico real |
| "cuanto cuesta [producto real]" | `queryPriceProduct` | Precio en C$ |
| "quien me debe" | `queryReceivablesSummary` | Total + cantidad de clientes |
| "cuanto debe [cliente real]" | `queryReceivableBalanceClient` | Saldo del cliente |
| "cuanto vendi hoy" | `querySalesSummary` | Total de ventas del día |
| "como va la caja" | `queryCashStatus` | Estado + montos de sesión |
| "ultima venta de [producto real]" | `queryLastSaleProduct` | Fecha + cantidad |

Si alguna falla con datos reales, el problema está en el DAO o en el mapping del resultado — no en el parser ni el orquestador.

---

## Criterio de cierre

- [ ] Las 7 consultas devuelven datos reales de Drift (no stubs, no mocks)
- [ ] Contexto se construye desde providers reales en cada mensaje
- [ ] Permisos insuficientes devuelven mensaje claro sin crash
- [ ] "Producto no encontrado" muestra texto amigable
- [ ] Ambigüedad muestra chips de opciones seleccionables
- [ ] Ninguna operación modifica datos
