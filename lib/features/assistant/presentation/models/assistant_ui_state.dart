import 'package:inventario_v2/features/assistant/domain/models/assistant_draft.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_session.dart';
import 'package:inventario_v2/features/assistant/presentation/widgets/assistant_voice_button.dart';
import 'chat_message.dart';

class AssistantUiState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final bool isConfirming;
  final AssistantDraft? pendingDraft;
  final List<String> pausedWorkflowNames;
  final String? error;

  final bool isOffline;
  final List<String> clarificationOptions;

  // Voz
  final VoiceButtonState voiceState;
  final bool isVoiceMode;
  final String liveTranscript; // texto en tiempo real mientras escucha

  // Sesión acumulativa
  final AssistantSession? activeSession;

  const AssistantUiState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.isConfirming = false,
    this.pendingDraft,
    this.pausedWorkflowNames = const [],
    this.isOffline = false,
    this.clarificationOptions = const [],
    this.error,
    this.voiceState = VoiceButtonState.idle,
    this.isVoiceMode = false,
    this.liveTranscript = '',
    this.activeSession,
  });

  bool get hasPendingDraft => pendingDraft != null;
  bool get hasPausedWorkflows => pausedWorkflowNames.isNotEmpty;
  bool get hasClarificationOptions => clarificationOptions.isNotEmpty;
  bool get hasActiveSession => activeSession != null && activeSession!.isActive;
  bool get isRecording => voiceState == VoiceButtonState.recording;
  bool get isSpeaking => voiceState == VoiceButtonState.speaking;

  AssistantUiState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    bool? isConfirming,
    AssistantDraft? pendingDraft,
    List<String>? pausedWorkflowNames,
    bool? isOffline,
    List<String>? clarificationOptions,
    String? error,
    VoiceButtonState? voiceState,
    bool? isVoiceMode,
    String? liveTranscript,
    AssistantSession? activeSession,
    bool clearError = false,
    bool clearStreaming = false,
    bool clearDraft = false,
    bool clearClarification = false,
    bool clearSession = false,
    bool clearLiveTranscript = false,
  }) {
    return AssistantUiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: clearStreaming ? false : (isStreaming ?? this.isStreaming),
      isConfirming: isConfirming ?? this.isConfirming,
      pendingDraft: clearDraft ? null : (pendingDraft ?? this.pendingDraft),
      pausedWorkflowNames: pausedWorkflowNames ?? this.pausedWorkflowNames,
      isOffline: isOffline ?? this.isOffline,
      clarificationOptions: clearClarification
          ? const []
          : (clarificationOptions ?? this.clarificationOptions),
      error: clearError ? null : (error ?? this.error),
      voiceState: voiceState ?? this.voiceState,
      isVoiceMode: isVoiceMode ?? this.isVoiceMode,
      liveTranscript: clearLiveTranscript
          ? ''
          : (liveTranscript ?? this.liveTranscript),
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
    );
  }
}
