import 'workflow_state.dart';
import 'paused_workflow.dart';

class ConversationState {
  final WorkflowState? activeWorkflow;
  final List<PausedWorkflow> pausedWorkflowStack;
  final Map<String, CollectedVariable> collectedData;
  final List<ConversationTurn> messageHistory;
  final List<NamedEntity> lastShownList;
  final Map<String, String> factMemory;

  const ConversationState({
    this.activeWorkflow,
    this.pausedWorkflowStack = const [],
    this.collectedData = const {},
    this.messageHistory = const [],
    this.lastShownList = const [],
    this.factMemory = const {},
  });

  factory ConversationState.initial() => const ConversationState();

  bool get hasActiveWorkflow => activeWorkflow != null;
  bool get hasPausedWorkflows => pausedWorkflowStack.isNotEmpty;

  ConversationState copyWith({
    WorkflowState? activeWorkflow,
    bool clearActiveWorkflow = false,
    List<PausedWorkflow>? pausedWorkflowStack,
    Map<String, CollectedVariable>? collectedData,
    List<ConversationTurn>? messageHistory,
    List<NamedEntity>? lastShownList,
    Map<String, String>? factMemory,
  }) =>
      ConversationState(
        activeWorkflow:
            clearActiveWorkflow ? null : (activeWorkflow ?? this.activeWorkflow),
        pausedWorkflowStack: pausedWorkflowStack ?? this.pausedWorkflowStack,
        collectedData: collectedData ?? this.collectedData,
        messageHistory: messageHistory ?? this.messageHistory,
        lastShownList: lastShownList ?? this.lastShownList,
        factMemory: factMemory ?? this.factMemory,
      );

  ConversationState addTurn(ConversationTurn turn, {int maxTurns = 12}) {
    final updated = [...messageHistory, turn];
    return copyWith(
      messageHistory: updated.length > maxTurns
          ? updated.sublist(updated.length - maxTurns)
          : updated,
    );
  }

  ConversationState applyDecay() {
    final decayed = collectedData.map(
      (key, variable) => MapEntry(key, variable.withReducedRelevance()),
    );
    final pruned = Map.fromEntries(
      decayed.entries.where((e) =>
          e.value.type == VariableType.permanent || e.value.relevance > 0.1),
    );
    return copyWith(collectedData: pruned);
  }
}

// ── Tipos auxiliares ────────────────────────────────────────────────────────

enum VariableType { transient, session, permanent }

class CollectedVariable {
  final dynamic value;
  final VariableType type;
  final double relevance;

  const CollectedVariable({
    required this.value,
    required this.type,
    this.relevance = 1.0,
  });

  CollectedVariable withReducedRelevance() => CollectedVariable(
        value: value,
        type: type,
        relevance: (relevance * 0.85).clamp(0.0, 1.0),
      );

  static VariableType inferType(String key) {
    if (key.startsWith('_temp') || key.startsWith('_search')) {
      return VariableType.transient;
    }
    if (key.endsWith('Id') || key.startsWith('selected')) {
      return VariableType.session;
    }
    return VariableType.session;
  }
}

class ConversationTurn {
  final String role;
  final String content;
  final DateTime timestamp;

  const ConversationTurn({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, String> toOpenAIMessage() => {'role': role, 'content': content};
}

class NamedEntity {
  final String id;
  final String displayName;
  final String type;

  const NamedEntity({
    required this.id,
    required this.displayName,
    required this.type,
  });
}
