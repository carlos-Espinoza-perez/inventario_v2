class WorkflowState {
  final String workflowId;
  final String intentType;
  final int currentStepIndex;
  final String? pendingField;
  final List<Map<String, dynamic>> stepHistory;

  const WorkflowState({
    required this.workflowId,
    required this.intentType,
    this.currentStepIndex = 0,
    this.pendingField,
    this.stepHistory = const [],
  });

  bool get isAwaitingUser => pendingField != null;

  WorkflowState copyWith({
    int? currentStepIndex,
    String? pendingField,
    bool clearPendingField = false,
    List<Map<String, dynamic>>? stepHistory,
  }) =>
      WorkflowState(
        workflowId: workflowId,
        intentType: intentType,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        pendingField:
            clearPendingField ? null : (pendingField ?? this.pendingField),
        stepHistory: stepHistory ?? this.stepHistory,
      );
}
