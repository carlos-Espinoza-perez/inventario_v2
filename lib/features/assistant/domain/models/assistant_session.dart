import 'package:flutter/foundation.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'assistant_draft.dart';

enum AssistantSessionType {
  registerEntry,
  registerSale,
  registerOutputAdjustment,
}

enum AssistantSessionState {
  active,
  awaitingQuantity,
  awaitingConfirmation,
  cancelled,
}

@immutable
class AssistantSession {
  final String id;
  final AssistantSessionType type;
  final AssistantSessionState state;
  final AssistantDraft draft;
  final DateTime startedAt;
  final DateTime? lastInteractionAt;
  final Producto? pendingProduct;

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

  bool get hasItems => draft.items.isNotEmpty;

  DraftType get draftType => switch (type) {
        AssistantSessionType.registerEntry => DraftType.inventoryEntry,
        AssistantSessionType.registerSale => DraftType.sale,
        AssistantSessionType.registerOutputAdjustment => DraftType.inventoryEntry,
      };

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
        pendingProduct:
            clearPendingProduct ? null : (pendingProduct ?? this.pendingProduct),
      );
}
