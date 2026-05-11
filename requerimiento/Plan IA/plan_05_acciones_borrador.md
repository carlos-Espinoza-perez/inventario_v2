# Plan 05 - Acciones con borrador
**Origen:** `requerimiento/Add IA/05_acciones_con_borrador.md`

---

## Objetivo

Implementar el ciclo de preparación y confirmación de acciones. El Secretario arma un borrador editable, el usuario lo revisa en un bottom sheet y confirma usando los Use Cases existentes. Sin escritura en Drift sin confirmación explícita.

**Prerequisito:** Planes 01–04 completados.

---

## Use Cases confirmados en el proyecto

| Acción | Use Case | Provider |
|---|---|---|
| Entrada de inventario | `RegistrarEntradaUseCase` | `registrarEntradaUseCaseProvider` |
| Venta | `RegistrarVentaUseCase` | `registrarVentaUseCaseProvider` |
| Salida / Ajuste | **No existe aún** — crear en este plan | — |
| Abono a crédito | `registrarAbonoVenta` en `SalesDao` — exponer como UseCase | — |

> **Entrega 8 del roadmap depende de esto:** Crear `RegistrarSalidaUseCase` y exponer el flujo de abono como Use Case antes de implementar esas acciones en el asistente.

---

## Archivos a crear

| Archivo | Propósito |
|---|---|
| `lib/features/assistant/domain/models/assistant_draft.dart` | Borrador con status |
| `lib/features/assistant/domain/models/assistant_draft_item.dart` | Ítem individual del borrador |
| `lib/features/assistant/domain/services/assistant_draft_builder.dart` | Construye borradores desde intents |
| `lib/features/assistant/presentation/widgets/assistant_draft_sheet.dart` | Bottom sheet de revisión y confirmación |

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/features/assistant/presentation/providers/assistant_provider.dart` | Agregar `pendingDraft` al estado y método `confirmDraft` |
| `lib/features/assistant/presentation/screens/assistant_screen.dart` | Mostrar bottom sheet cuando hay borrador pendiente |
| `lib/features/assistant/domain/services/assistant_orchestrator.dart` | Devolver borrador en respuesta a acciones (en lugar de "pronto disponible") |

---

## Paso 1 — Modelos de borrador

```dart
// lib/features/assistant/domain/models/assistant_draft_item.dart

class AssistantDraftItem {
  final String id;
  final String productoId;
  final String productoNombre;
  final String? varianteId;
  final String? varianteNombre;
  final double cantidad;
  final double? precio;
  final double? costo;
  final String? motivo;

  const AssistantDraftItem({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    this.varianteId,
    this.varianteNombre,
    required this.cantidad,
    this.precio,
    this.costo,
    this.motivo,
  });

  AssistantDraftItem copyWith({
    double? cantidad,
    double? precio,
    double? costo,
    String? motivo,
  }) =>
      AssistantDraftItem(
        id: id,
        productoId: productoId,
        productoNombre: productoNombre,
        varianteId: varianteId,
        varianteNombre: varianteNombre,
        cantidad: cantidad ?? this.cantidad,
        precio: precio ?? this.precio,
        costo: costo ?? this.costo,
        motivo: motivo ?? this.motivo,
      );
}
```

```dart
// lib/features/assistant/domain/models/assistant_draft.dart

import 'package:uuid/uuid.dart';
import 'assistant_intent.dart';
import 'assistant_draft_item.dart';

enum AssistantDraftStatus { ready, needsReview, blocked }

class AssistantDraft {
  final String id;
  final AssistantIntentType type;
  final AssistantDraftStatus status;
  final List<AssistantDraftItem> items;
  final Map<String, String> metadata; // tipado como String:String para evitar dynamic
  final List<String> warnings;
  final List<String> blockers;

  const AssistantDraft({
    required this.id,
    required this.type,
    required this.status,
    required this.items,
    this.metadata = const {},
    this.warnings = const [],
    this.blockers = const [],
  });

  bool get isReady => status == AssistantDraftStatus.ready;
  bool get isBlocked => status == AssistantDraftStatus.blocked;

  AssistantDraft copyWith({
    List<AssistantDraftItem>? items,
    AssistantDraftStatus? status,
    List<String>? warnings,
    List<String>? blockers,
    Map<String, String>? metadata,
  }) =>
      AssistantDraft(
        id: id,
        type: type,
        status: status ?? this.status,
        items: items ?? this.items,
        metadata: metadata ?? this.metadata,
        warnings: warnings ?? this.warnings,
        blockers: blockers ?? this.blockers,
      );

  factory AssistantDraft.blocked(AssistantIntentType type, String reason) =>
      AssistantDraft(
        id: const Uuid().v4(),
        type: type,
        status: AssistantDraftStatus.blocked,
        items: const [],
        blockers: [reason],
      );
}
```

> `metadata` usa `Map<String, String>` en lugar de `Map<String, dynamic>` para eliminar el riesgo de crash por cast incorrecto. Si se necesita guardar un ID de bodega: `metadata: {'bodegaId': bodega.id}`.

---

## Paso 2 — AssistantDraftBuilder

```dart
// lib/features/assistant/domain/services/assistant_draft_builder.dart

import 'package:uuid/uuid.dart';
import '../models/assistant_draft.dart';
import '../models/assistant_draft_item.dart';
import '../models/assistant_intent.dart';
import '../models/assistant_operational_context.dart';
import '../../data/entity_resolver.dart';
import '../../domain/models/entity_resolution.dart';
import 'package:inventario_v2/core/db/app_database.dart';

class AssistantDraftBuilder {
  final EntityResolver _resolver;

  const AssistantDraftBuilder(this._resolver);

  Future<AssistantDraft> build(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    switch (intent.type) {
      case AssistantIntentType.actionRegisterEntry:
        return _buildEntry(intent, context);
      case AssistantIntentType.actionRegisterSale:
        return _buildSale(intent, context);
      case AssistantIntentType.actionRegisterOutputAdjustment:
        return _buildOutput(intent, context);
      case AssistantIntentType.actionRegisterReceivablePayment:
        return _buildPayment(intent, context);
      default:
        return AssistantDraft.blocked(intent.type, 'Acción no soportada todavía.');
    }
  }

  Future<AssistantDraft> _buildEntry(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    if (!context.hasWarehouseSelected) {
      return AssistantDraft.blocked(
        intent.type,
        'Seleccioná una bodega antes de registrar una entrada.',
      );
    }
    if (!context.hasPermission('warehouse.update')) {
      return AssistantDraft.blocked(
        intent.type,
        'No tenés permiso para registrar entradas.',
      );
    }

    final draftItems = await _resolveItemsFromIntent(intent, context);
    return AssistantDraft(
      id: const Uuid().v4(),
      type: intent.type,
      status: draftItems.isNotEmpty
          ? AssistantDraftStatus.ready
          : AssistantDraftStatus.needsReview,
      items: draftItems,
      metadata: {'bodegaId': context.selectedWarehouseId!},
    );
  }

  Future<AssistantDraft> _buildSale(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    if (!context.hasCashOpen) {
      return AssistantDraft.blocked(
        intent.type,
        'Necesitás abrir caja antes de registrar una venta.',
      );
    }
    if (!context.hasPermission('sale.create')) {
      return AssistantDraft.blocked(
        intent.type,
        'No tenés permiso para registrar ventas.',
      );
    }

    final draftItems = await _resolveItemsFromIntent(intent, context);
    final metadata = <String, String>{
      if (context.selectedWarehouseId != null)
        'bodegaId': context.selectedWarehouseId!,
      if (context.openCashSessionId != null)
        'cajaSesionId': context.openCashSessionId!,
    };

    return AssistantDraft(
      id: const Uuid().v4(),
      type: intent.type,
      status: AssistantDraftStatus.needsReview,
      items: draftItems,
      metadata: metadata,
    );
  }

  Future<AssistantDraft> _buildOutput(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    if (!context.hasPermission('warehouse.update')) {
      return AssistantDraft.blocked(
        intent.type,
        'No tenés permiso para registrar salidas.',
      );
    }
    // RegistrarSalidaUseCase debe crearse antes de activar esta acción
    return AssistantDraft(
      id: const Uuid().v4(),
      type: intent.type,
      status: AssistantDraftStatus.needsReview,
      items: const [],
      warnings: ['Confirmá los ítems antes de guardar.'],
    );
  }

  Future<AssistantDraft> _buildPayment(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    final clientQuery = intent.entities['clientQuery'] as String? ?? '';
    final montoStr = intent.entities['depositAmount'] as String? ?? '0';
    return AssistantDraft(
      id: const Uuid().v4(),
      type: intent.type,
      status: AssistantDraftStatus.needsReview,
      items: const [],
      metadata: {
        'clientQuery': clientQuery,
        'monto': montoStr,
      },
    );
  }

  Future<List<AssistantDraftItem>> _resolveItemsFromIntent(
    AssistantIntent intent,
    AssistantOperationalContext context,
  ) async {
    final rawItems = (intent.entities['items'] as List<Map<String, dynamic>>?) ?? [];
    final result = <AssistantDraftItem>[];

    for (final raw in rawItems) {
      final productQuery = raw['productQuery'] as String? ?? '';
      final resolution = await _resolver.resolveProduct(
        productQuery,
        empresaId: context.empresaId,
      );
      if (resolution.isResolved) {
        final producto = resolution.selected! as Producto;
        result.add(AssistantDraftItem(
          id: const Uuid().v4(),
          productoId: producto.id,
          productoNombre: producto.nombre,
          cantidad: (raw['quantity'] as num?)?.toDouble() ?? 1,
          costo: (raw['cost'] as num?)?.toDouble(),
          precio: (raw['price'] as num?)?.toDouble(),
        ));
      }
    }
    return result;
  }
}
```

---

## Paso 3 — Bottom sheet de confirmación

```dart
// lib/features/assistant/presentation/widgets/assistant_draft_sheet.dart

import 'package:flutter/material.dart';
import '../../domain/models/assistant_draft.dart';
import '../../domain/models/assistant_draft_item.dart';
import '../../domain/models/assistant_intent.dart';

class AssistantDraftSheet extends StatefulWidget {
  final AssistantDraft draft;
  final Future<void> Function(AssistantDraft confirmed) onConfirm;
  final VoidCallback onCancel;

  const AssistantDraftSheet({
    super.key,
    required this.draft,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<AssistantDraftSheet> createState() => _AssistantDraftSheetState();
}

class _AssistantDraftSheetState extends State<AssistantDraftSheet> {
  late AssistantDraft _draft;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  String get _actionLabel => switch (_draft.type) {
    AssistantIntentType.actionRegisterEntry => 'Entrada de inventario',
    AssistantIntentType.actionRegisterSale => 'Venta',
    AssistantIntentType.actionRegisterOutputAdjustment => 'Salida / Ajuste',
    AssistantIntentType.actionRegisterReceivablePayment => 'Abono',
    _ => 'Confirmar acción',
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(_actionLabel,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
              ],
            ),
            // Blockers
            ..._draft.blockers.map((b) => _AlertTile(text: b, isError: true)),
            // Warnings
            ..._draft.warnings.map((w) => _AlertTile(text: w, isError: false)),
            const Divider(),
            // Items
            Expanded(
              child: _draft.items.isEmpty
                  ? const Center(
                      child: Text('Sin ítems. Agregá productos en el chat.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _draft.items.length,
                      itemBuilder: (_, i) => _DraftItemTile(
                        item: _draft.items[i],
                        showCosto: _draft.type ==
                            AssistantIntentType.actionRegisterEntry,
                        onChanged: (updated) => setState(() {
                          final items = List<AssistantDraftItem>.from(_draft.items);
                          items[i] = updated;
                          _draft = _draft.copyWith(items: items);
                        }),
                        onRemove: () => setState(() {
                          final items = List<AssistantDraftItem>.from(_draft.items)
                            ..removeAt(i);
                          _draft = _draft.copyWith(items: items);
                        }),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _draft.isBlocked || _draft.items.isEmpty || _confirming
                        ? null
                        : () async {
                            setState(() => _confirming = true);
                            await widget.onConfirm(_draft);
                          },
                    child: _confirming
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Confirmar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String text;
  final bool isError;
  const _AlertTile({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(
          isError ? Icons.block : Icons.warning_amber_rounded,
          color: isError ? Colors.red : Colors.orange,
          size: 20,
        ),
        title: Text(text, style: const TextStyle(fontSize: 14)),
        dense: true,
      );
}

class _DraftItemTile extends StatelessWidget {
  final AssistantDraftItem item;
  final bool showCosto;
  final ValueChanged<AssistantDraftItem> onChanged;
  final VoidCallback onRemove;

  const _DraftItemTile({
    required this.item,
    required this.showCosto,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.productoNombre),
      subtitle: item.varianteNombre != null ? Text(item.varianteNombre!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: TextFormField(
              initialValue: item.cantidad.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Cant.', isDense: true, border: OutlineInputBorder()),
              onChanged: (v) {
                final n = double.tryParse(v);
                if (n != null && n > 0) onChanged(item.copyWith(cantidad: n));
              },
            ),
          ),
          if (showCosto) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: TextFormField(
                initialValue: item.costo?.toStringAsFixed(2) ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Costo', isDense: true, border: OutlineInputBorder()),
                onChanged: (v) {
                  final n = double.tryParse(v);
                  if (n != null) onChanged(item.copyWith(costo: n));
                },
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
```

---

## Paso 4 — Conectar Use Cases en AssistantProvider

```dart
// Agregar al AssistantState:
final AssistantDraft? pendingDraft;

// Agregar al AssistantNotifier:
Future<void> confirmDraft(AssistantDraft draft) async {
  state = state.copyWith(isLoading: true);
  try {
    switch (draft.type) {
      case AssistantIntentType.actionRegisterEntry:
        await _ref.read(registrarEntradaUseCaseProvider).ejecutar(
          bodegaId: draft.metadata['bodegaId']!,
          descripcion: 'Entrada por Secretario IA',
          orderLines: draft.items.map((item) => OrderLine(
            productoId: item.productoId,
            varianteId: item.varianteId,
            cantidad: item.cantidad,
            costoUnitario: item.costo ?? 0,
          )).toList(),
        );
        break;
      case AssistantIntentType.actionRegisterSale:
        // Llamar a RegistrarVentaUseCase con cartItems del draft
        // Ver parámetros exactos: ejecutar({cartItems, nombreCliente, saleType, total, depositAmount})
        break;
      // Salida y abono: implementar cuando UseCase exista (Entrega 8)
      default:
        break;
    }

    final ok = AssistantMessage(
      id: const Uuid().v4(),
      role: MessageRole.assistant,
      text: 'Listo. La operación fue registrada correctamente.',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, ok],
      pendingDraft: null,
      isLoading: false,
    );
  } catch (e) {
    final errMsg = AssistantMessage(
      id: const Uuid().v4(),
      role: MessageRole.error,
      text: 'No se pudo completar la operación. Verificá los datos e intentá de nuevo.',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, errMsg],
      pendingDraft: null,
      isLoading: false,
    );
  }
}
```

---

## Paso 5 — Mostrar bottom sheet en AssistantScreen

```dart
// En AssistantScreen, después de los chips de clarificación:

if (state.pendingDraft != null)
  FilledButton.tonal(
    onPressed: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AssistantDraftSheet(
        draft: state.pendingDraft!,
        onConfirm: (confirmed) async {
          Navigator.pop(context);
          await ref.read(assistantProvider.notifier).confirmDraft(confirmed);
        },
        onCancel: () {
          Navigator.pop(context);
          ref.read(assistantProvider.notifier).clearDraft();
        },
      ),
    ),
    child: const Text('Revisar y confirmar'),
  ),
```

---

## Tarea previa a Entrega 8: crear RegistrarSalidaUseCase

Antes de implementar salidas en el Secretario, crear:

```text
lib/features/inventory/domain/use_cases/registrar_salida_use_case.dart
```

Patrón: igual que `RegistrarEntradaUseCase` pero con tipo de movimiento `'salida'` o `'ajuste'`.

---

## Criterio de cierre

- [ ] Borrador de entrada se construye correctamente con `bodegaId` en metadata (tipado)
- [ ] Bottom sheet muestra ítems editables (cantidad y costo)
- [ ] Confirmar llama a `RegistrarEntradaUseCase.ejecutar()`
- [ ] Cancelar descarta el borrador sin tocar Drift
- [ ] `metadata` usa `Map<String, String>` — sin `dynamic`
- [ ] Borrador bloqueado deshabilita el botón "Confirmar"
