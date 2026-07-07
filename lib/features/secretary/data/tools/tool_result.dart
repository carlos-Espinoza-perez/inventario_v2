enum ToolResultStatus { success, notFound, ambiguous, error, requiresUserInput }

class ToolResult {
  final ToolResultStatus status;
  final dynamic data;
  final String? errorMessage;
  final List<dynamic>? candidates;
  final String? userQuestion;

  const ToolResult({
    required this.status,
    this.data,
    this.errorMessage,
    this.candidates,
    this.userQuestion,
  });

  bool get isSuccess => status == ToolResultStatus.success;
  bool get isAmbiguous => status == ToolResultStatus.ambiguous;
  bool get needsUserInput => status == ToolResultStatus.requiresUserInput;

  factory ToolResult.success(dynamic data) =>
      ToolResult(status: ToolResultStatus.success, data: data);

  factory ToolResult.notFound([String? message]) =>
      ToolResult(status: ToolResultStatus.notFound, errorMessage: message);

  factory ToolResult.ambiguous(List<dynamic> candidates) =>
      ToolResult(status: ToolResultStatus.ambiguous, candidates: candidates);

  factory ToolResult.error(String message) =>
      ToolResult(status: ToolResultStatus.error, errorMessage: message);

  factory ToolResult.askUser(String question) =>
      ToolResult(status: ToolResultStatus.requiresUserInput, userQuestion: question);

  Map<String, dynamic> toContext() => {
        'status': status.name,
        if (data != null) 'data': _serialize(data),
        if (errorMessage != null) 'error': errorMessage,
        if (candidates != null)
          'candidates': candidates!.map(_serialize).toList(),
      };

  static dynamic _serialize(dynamic d) {
    if (d == null || d is String || d is num || d is bool) return d;
    if (d is Map) return d;
    if (d is List) return d.map(_serialize).toList();
    try {
      return (d as dynamic).toJson();
    } catch (_) {
      return d.toString();
    }
  }
}
