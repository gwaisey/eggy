import '../models/chat_suggestion.dart';

/// Eggy Chat conversation interface.
abstract class IConversationService {
  /// Returns Eggy's cozy response to a user message
  Future<String> getResponse(String userMessage);

  /// Suggested quick-tap prompts shown in the chat home chips
  List<ChatSuggestion> getSuggestedPrompts({bool isProfessorMode = false});

  /// Whether this service is backed by a live AI (changes the "thinking" UI)
  bool get isAIBacked;
}
