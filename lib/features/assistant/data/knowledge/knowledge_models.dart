class IntentCatalog {
  final List<IntentDefinition> intents;

  const IntentCatalog({required this.intents});

  factory IntentCatalog.fromRows(List<Map<String, dynamic>> rows) {
    return IntentCatalog(
      intents: rows.map((r) => IntentDefinition.fromJson(r)).toList(),
    );
  }

  String toRouterPromptBlock() {
    return intents
        .map((i) => '- ${i.id} -> ${i.workflowId}: "${i.description}"')
        .join('\n');
  }
}

class IntentDefinition {
  final String id;
  final String displayName;
  final String description;
  final String workflowId;
  final String category;
  final List<String> requiresPermissions;
  final bool requiresCashOpen;
  final bool requiresWarehouse;

  const IntentDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.workflowId,
    required this.category,
    required this.requiresPermissions,
    required this.requiresCashOpen,
    required this.requiresWarehouse,
  });

  factory IntentDefinition.fromJson(Map<String, dynamic> j) => IntentDefinition(
        id: j['id'] as String,
        displayName: j['display_name'] as String,
        description: j['description'] as String,
        workflowId: j['workflow_id'] as String,
        category: j['category'] as String,
        requiresPermissions: List<String>.from(j['requires_permissions'] ?? []),
        requiresCashOpen: j['requires_cash_open'] ?? false,
        requiresWarehouse: j['requires_warehouse'] ?? false,
      );
}

class WorkflowDefinition {
  final String id;
  final String nombre;
  final String type;
  final bool sessionAccumulates;
  final List<RequiredField> requiredFields;
  final List<WorkflowStep> steps;

  const WorkflowDefinition({
    required this.id,
    required this.nombre,
    required this.type,
    required this.sessionAccumulates,
    required this.requiredFields,
    required this.steps,
  });

  factory WorkflowDefinition.fromJson(Map<String, dynamic> j) =>
      WorkflowDefinition(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        type: j['type'] as String,
        sessionAccumulates: j['session_accumulates'] ?? false,
        requiredFields: (j['required_fields'] as List? ?? [])
            .map((f) => RequiredField.fromJson(f as Map<String, dynamic>))
            .toList(),
        steps: (j['steps'] as List? ?? [])
            .map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class WorkflowStep {
  final String id;
  final String tool;
  final Map<String, dynamic> params;
  final String? storeResultAs;
  final String? onAmbiguous;
  final String? onNotFound;
  final String? onSuccess;
  final String? onError;
  final String? loopUntil;

  const WorkflowStep({
    required this.id,
    required this.tool,
    required this.params,
    this.storeResultAs,
    this.onAmbiguous,
    this.onNotFound,
    this.onSuccess,
    this.onError,
    this.loopUntil,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> j) => WorkflowStep(
        id: j['id'] as String,
        tool: j['tool'] as String,
        params: Map<String, dynamic>.from(j['params'] ?? {}),
        storeResultAs: j['store_result_as'] as String?,
        onAmbiguous: j['on_ambiguous'] as String?,
        onNotFound: j['on_not_found'] as String?,
        onSuccess: j['on_success'] as String?,
        onError: j['on_error'] as String?,
        loopUntil: j['loop_until'] as String?,
      );
}

class RequiredField {
  final String name;
  final String question;
  final String type;

  const RequiredField({
    required this.name,
    required this.question,
    required this.type,
  });

  factory RequiredField.fromJson(Map<String, dynamic> j) => RequiredField(
        name: j['name'] as String,
        question: j['question'] as String,
        type: j['type'] as String,
      );
}

class ToolDefinition {
  final String id;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic> outputSchema;
  final String category;

  const ToolDefinition({
    required this.id,
    required this.description,
    required this.inputSchema,
    required this.outputSchema,
    required this.category,
  });

  factory ToolDefinition.fromJson(Map<String, dynamic> j) => ToolDefinition(
        id: j['id'] as String,
        description: j['description'] as String,
        inputSchema: Map<String, dynamic>.from(j['input_schema'] ?? {}),
        outputSchema: Map<String, dynamic>.from(j['output_schema'] ?? {}),
        category: j['category'] as String,
      );

  String toPromptEntry() => '- $id: $description\n  Input: $inputSchema';
}

class RouterResult {
  final String intent;
  final double score;
  final String workflowId;
  final String intentDescription;
  final Map<String, dynamic> entities;
  final String reasoning;
  final bool requiresWarehouse;

  const RouterResult({
    required this.intent,
    required this.score,
    required this.workflowId,
    required this.intentDescription,
    required this.entities,
    required this.reasoning,
    this.requiresWarehouse = false,
  });

  factory RouterResult.fromJson(Map<String, dynamic> j) => RouterResult(
        intent: j['intent'] as String,
        score: (j['score'] as num).toDouble(),
        workflowId: j['workflow_id'] as String? ?? 'wf_direct_answer',
        intentDescription: j['intent_description'] as String? ?? '',
        entities: Map<String, dynamic>.from(j['entities'] ?? {}),
        reasoning: j['reasoning'] as String? ?? '',
        requiresWarehouse: j['requires_warehouse'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'intent': intent,
        'score': score,
        'workflow_id': workflowId,
        'intent_description': intentDescription,
        'entities': entities,
        'reasoning': reasoning,
        'requires_warehouse': requiresWarehouse,
      };

  bool get shouldReject => score < 0.40;
  bool get needsMoreInfo => score >= 0.40 && score < 0.65;
  bool get needsConfirmation => score >= 0.65 && score < 0.85;
  bool get canExecuteDirectly => score >= 0.85;
}
