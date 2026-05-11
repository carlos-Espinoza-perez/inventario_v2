import 'conversation_state.dart';
import 'workflow_state.dart';

class PausedWorkflow {
  final WorkflowState state;
  final Map<String, CollectedVariable> collectedDataSnapshot;
  final DateTime pausedAt;
  final String pauseReason;

  const PausedWorkflow({
    required this.state,
    required this.collectedDataSnapshot,
    required this.pausedAt,
    required this.pauseReason,
  });
}
