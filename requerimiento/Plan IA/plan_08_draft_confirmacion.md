# Plan 08 - Borrador y Confirmación

---

## Objetivo

Implementar el flujo de borrador (draft) que se activa cuando el ReAct loop devuelve `show_draft` o cuando una tool retorna `__requires_draft: true`. El usuario ve un resumen de lo que se va a hacer, confirma o cancela, y recién entonces se ejecutan los Use Cases existentes.

---

## Principio

El Secretario **nunca ejecuta una acción de escritura sin confirmación explícita del usuario.** El borrador es la capa de seguridad entre la intención del usuario y la mutación de datos.

```
LLM decide "show_draft"
        │
        ▼
StepwiseOrchestrator devuelve TurnResult(
  requiresConfirmation: true,
  draft: { '__draft_type': 'entry', 'items': [...], 'bodegaId': '...' }
)
        │
        ▼
AssistantNotifier → state.hasDraft = true, state.draftData = {...}
        │
        ▼
DraftCard visible en pantalla
        │
        ├── Usuario confirma → sendMessage('confirmar')
        │         └─ TurnPipeline detecta pendingField == '_draft_confirmation'
        │                   └─ Ejecuta el Use Case real
        │
        └── Usuario cancela → sendMessage('cancelar')
                  └─ Limpia el workflow activo
```

---

## Paso 1 — Tipos de borrador

Cada tipo de borrador tiene un widget de presentación diferente.

```dart
// lib/features/assistant/domain/models/assistant_draft.dart

enum DraftType { entry, sale, adjustment, transfer, unknown }

class AssistantDraft {
  final DraftType type;
  final String bodegaId;
  final String? cajaSesionId;
  final List<DraftItem> items;
  final Map<String, dynamic> rawData; // datos originales del orchestrator

  const AssistantDraft({
    required this.type,
    required this.bodegaId,
    this.cajaSesionId,
    required this.items,
    required this.rawData,
  });

  factory AssistantDraft.fromMap(Map<String, dynamic> data) {
    final typeStr = data['__draft_type'] as String? ?? 'unknown';
    final type = switch (typeStr) {
      'entry'      => DraftType.entry,
      'sale'       => DraftType.sale,
      'adjustment' => DraftType.adjustment,
      'transfer'   => DraftType.transfer,
      _            => DraftType.unknown,
    };

    final rawItems = (data['items'] as List? ?? []);
    final items = rawItems
        .map((i) => DraftItem.fromMap(i as Map<String, dynamic>))
        .toList();

    return AssistantDraft(
      type: type,
      bodegaId: data['bodegaId'] as String? ?? '',
      cajaSesionId: data['cajaSesionId'] as String?,
      items: items,
      rawData: data,
    );
  }

  String get typeLabel => switch (type) {
        DraftType.entry      => 'Entrada de inventario',
        DraftType.sale       => 'Venta',
        DraftType.adjustment => 'Ajuste de inventario',
        DraftType.transfer   => 'Transferencia',
        DraftType.unknown    => 'Acción',
      };

  double get totalAmount =>
      items.fold(0, (sum, i) => sum + (i.precio ?? 0) * i.cantidad);
}

class DraftItem {
  final String productoId;
  final String productoNombre;
  final double cantidad;
  final String unidad;
  final double? precio;
  final double? costoUnitario;

  const DraftItem({
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.unidad,
    this.precio,
    this.costoUnitario,
  });

  factory DraftItem.fromMap(Map<String, dynamic> data) => DraftItem(
        productoId: data['productoId'] as String? ?? '',
        productoNombre: data['productoNombre'] as String? ?? data['productoId'] as String? ?? '',
        cantidad: (data['cantidad'] as num? ?? 0).toDouble(),
        unidad: data['unidad'] as String? ?? 'unidad',
        precio: (data['precio'] as num?)?.toDouble(),
        costoUnitario: (data['costoUnitario'] as num?)?.toDouble(),
      );
}
```

---

## Paso 2 — DraftCard widget

```dart
// lib/features/assistant/presentation/widgets/draft_card.dart

import 'package:flutter/material.dart';
import '../../domain/models/assistant_draft.dart';

class DraftCard extends StatelessWidget {
  final Map<String, dynamic> draftData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DraftCard({
    super.key,
    required this.draftData,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final draft = AssistantDraft.fromMap(draftData);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Borrador: ${draft.typeLabel}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Items
          if (draft.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...draft.items.map((item) => _DraftItemRow(item: item)),
                ],
              ),
            ),

          if (draft.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Sin items especificados',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          // Total (solo si aplica)
          if (draft.type == DraftType.sale && draft.totalAmount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Total: \$${draft.totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const Divider(height: 16, indent: 16, endIndent: 16),

          // Botones
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onConfirm,
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftItemRow extends StatelessWidget {
  final DraftItem item;

  const _DraftItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productoNombre,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.cantidad} ${item.unidad}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (item.precio != null) ...[
            const SizedBox(width: 8),
            Text(
              '\$${item.precio!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## Paso 3 — TurnPipeline: detectar confirmación

En `TurnPipeline`, cuando hay un workflow activo con `pendingField == '_draft_confirmation'`:

```dart
// Dentro de TurnPipeline.process()

// Caso especial: respuesta a confirmación de borrador
if (workflowState?.pendingField == '_draft_confirmation') {
  final confirmed = _isConfirmation(userMessage);
  if (confirmed) {
    return await _executeDraftAction(
      conversationState: conversationState,
      operationalContext: operationalContext,
    );
  } else {
    // Cancelación
    return TurnResult(
      responseText: 'Acción cancelada.',
      updatedState: conversationState.copyWith(clearActiveWorkflow: true),
    );
  }
}

bool _isConfirmation(String message) {
  final lower = message.toLowerCase().trim();
  return ['confirmar', 'si', 'sí', 'ok', 'dale', 'proceder', 'ejecutar', 'listo']
      .any((word) => lower.contains(word));
}
```

---

## Paso 4 — Ejecución del draft con Use Cases existentes

Cuando el usuario confirma, el TurnPipeline extrae los datos del draft del `CollectedData` y llama al Use Case correspondiente.

```dart
// lib/features/assistant/core/draft_executor.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/assistant_draft.dart';
import '../../domain/models/assistant_operational_context.dart';
import '../../domain/models/conversation_state.dart';
import '../../../inventory/domain/usecases/registrar_entrada_usecase.dart';
import '../../../sales/domain/usecases/registrar_venta_usecase.dart';
import '../../presentation/providers/assistant_provider.dart'; // TurnResult

class DraftExecutor {
  final RegistrarEntradaUseCase _registrarEntradaUseCase;
  final RegistrarVentaUseCase _registrarVentaUseCase;

  const DraftExecutor({
    required RegistrarEntradaUseCase registrarEntradaUseCase,
    required RegistrarVentaUseCase registrarVentaUseCase,
  });

  Future<TurnResult> execute({
    required Map<String, dynamic> draftData,
    required ConversationState conversationState,
    required AssistantOperationalContext operationalContext,
  }) async {
    final draft = AssistantDraft.fromMap(draftData);

    try {
      return switch (draft.type) {
        DraftType.entry  => await _executeEntry(draft, conversationState, operationalContext),
        DraftType.sale   => await _executeSale(draft, conversationState, operationalContext),
        _                => TurnResult(
            responseText: 'Tipo de acción no soportado todavía.',
            updatedState: conversationState.copyWith(clearActiveWorkflow: true),
          ),
      };
    } catch (e) {
      return TurnResult(
        responseText: 'Error al ejecutar la acción: $e',
        updatedState: conversationState.copyWith(clearActiveWorkflow: true),
      );
    }
  }

  Future<TurnResult> _executeEntry(
    AssistantDraft draft,
    ConversationState state,
    AssistantOperationalContext ctx,
  ) async {
    // Mapear DraftItem → EntradaItem (modelo del Use Case)
    final items = draft.items.map((i) => EntradaItem(
      productoId: i.productoId,
      cantidad: i.cantidad,
      costoUnitario: i.costoUnitario ?? 0,
    )).toList();

    await _registrarEntradaUseCase.execute(
      bodegaId: draft.bodegaId,
      items: items,
      usuarioId: ctx.usuarioId,
    );

    return TurnResult(
      responseText: 'Entrada registrada correctamente. '
          '${draft.items.length} producto(s) ingresados a bodega.',
      updatedState: state.copyWith(clearActiveWorkflow: true),
    );
  }

  Future<TurnResult> _executeSale(
    AssistantDraft draft,
    ConversationState state,
    AssistantOperationalContext ctx,
  ) async {
    if (draft.cajaSesionId == null) {
      return TurnResult(
        responseText: 'No hay caja abierta para registrar la venta.',
        updatedState: state.copyWith(clearActiveWorkflow: true),
      );
    }

    final items = draft.items.map((i) => VentaItem(
      productoId: i.productoId,
      cantidad: i.cantidad,
      precioUnitario: i.precio ?? 0,
    )).toList();

    await _registrarVentaUseCase.execute(
      cajaSesionId: draft.cajaSesionId!,
      items: items,
      usuarioId: ctx.usuarioId,
    );

    return TurnResult(
      responseText: 'Venta registrada. '
          'Total: \$${draft.totalAmount.toStringAsFixed(2)}',
      updatedState: state.copyWith(clearActiveWorkflow: true),
    );
  }
}
```

---

## Paso 5 — WorkflowState con pendingField para confirmación

Cuando el `StepwiseOrchestrator` devuelve `requiresConfirmation: true`, el `TurnPipeline` guarda el draft en `CollectedData` y pone el workflow en espera:

```dart
// En TurnPipeline, después de recibir TurnResult con requiresConfirmation=true:

final updatedState = conversationState.copyWith(
  collectedData: {
    ...conversationState.collectedData,
    '_pendingDraft': CollectedVariable(
      value: result.draft!,
      type: VariableType.transient,
    ),
  },
  activeWorkflow: workflowState?.copyWith(
    pendingField: '_draft_confirmation',
  ),
);

return TurnResult(
  responseText: 'Revisá el borrador antes de confirmar.',
  updatedState: updatedState,
  requiresConfirmation: true,
  draft: result.draft,
);
```

---

## Flujo completo: "vender 3 camisas a Juan"

```
1. Usuario: "vender 3 camisas a Juan"
2. TurnPipeline → SemanticRouter detecta intent: action_register_sale
3. StepwiseOrchestrator:
   Iter 1: use_tool → entity_resolver.resolveProduct("camisa") → success(Producto)
   Iter 2: use_tool → entity_resolver.resolveClient("Juan") → success(Cliente)
   Iter 3: use_tool → inventory.getPrecioProducto → success({precio: 15.00})
   Iter 4: show_draft → TurnResult(requiresConfirmation=true, draft={...})
4. AssistantNotifier → state.hasDraft=true, DraftCard aparece en pantalla
5. Usuario toca "Confirmar"
6. TurnPipeline detecta pendingField=='_draft_confirmation', confirmed=true
7. DraftExecutor._executeSale() → RegistrarVentaUseCase.execute()
8. Respuesta: "Venta registrada. Total: $45.00"
```

---

## Criterio de cierre

- [ ] `AssistantDraft.fromMap()` parsea todos los tipos de borrador
- [ ] `DraftCard` muestra items, cantidades, precios y total cuando aplica
- [ ] Confirmación con "confirmar", "si", "ok", "dale" (y variantes) activa la ejecución
- [ ] Cancelación con "cancelar" o "no" limpia el workflow sin ejecutar
- [ ] `DraftExecutor` llama a los Use Cases existentes sin modificarlos
- [ ] `TurnPipeline` guarda el draft en `CollectedData['_pendingDraft']` para acceso posterior
- [ ] Errores durante la ejecución se reportan al usuario sin crash
