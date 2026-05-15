import 'package:flutter/foundation.dart';

@immutable
class AssistantSuggestedCategory {
  final String id;
  final String name;
  final double score;

  const AssistantSuggestedCategory({
    required this.id,
    required this.name,
    required this.score,
  });
}

@immutable
class AssistantEntrySessionDraft {
  final String sessionId;
  final String bodegaId;
  final List<AssistantEntryDraftLine> lines;

  const AssistantEntrySessionDraft({
    required this.sessionId,
    required this.bodegaId,
    required this.lines,
  });

  bool get isEmpty => lines.isEmpty;
  bool get hasBlockingIssues => lines.any((line) => !line.isReady);
}

@immutable
class AssistantEntryDraftLine {
  final String id;
  final String? productId;
  final String proposedName;
  final String displayName;
  final String? categoryId;
  final String? categoryName;
  final double quantity;
  final double? unitCost;
  final double? unitPrice;
  final String status;
  final bool isNewProduct;
  final List<String> candidates;

  const AssistantEntryDraftLine({
    required this.id,
    required this.productId,
    required this.proposedName,
    required this.displayName,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.unitCost,
    required this.unitPrice,
    required this.status,
    required this.isNewProduct,
    this.candidates = const [],
  });

  bool get isReady =>
      quantity > 0 &&
      unitCost != null &&
      unitPrice != null &&
      categoryName != null &&
      categoryName!.trim().isNotEmpty &&
      status == 'ready';
}

class AssistantEntryWorkflowResult {
  final bool handled;
  final String responseText;
  final AssistantEntrySessionDraft? draft;
  final bool requiresConfirmation;
  final bool confirmed;
  final bool cancelled;

  const AssistantEntryWorkflowResult({
    required this.handled,
    required this.responseText,
    this.draft,
    this.requiresConfirmation = false,
    this.confirmed = false,
    this.cancelled = false,
  });

  const AssistantEntryWorkflowResult.notHandled()
    : handled = false,
      responseText = '',
      draft = null,
      requiresConfirmation = false,
      confirmed = false,
      cancelled = false;
}
