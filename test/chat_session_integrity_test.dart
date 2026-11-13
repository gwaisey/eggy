import 'dart:async';

import 'package:eggy/core/interfaces/i_conversation_service.dart';
import 'package:eggy/core/models/chat_suggestion.dart';
import 'package:eggy/features/chat/conversation_service.dart';
import 'package:eggy/features/mascot/eggy_mascot_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('new chat isolates an in-flight response and archives its owner',
      () async {
    final response = Completer<String>();
    final ai = _TestConversationService((_) => response.future);
    final mascot = EggyMascotController();
    final viewModel = EggyChatViewModel(ai, ScriptedResponseService(), mascot);
    addTearDown(() {
      viewModel.dispose();
      mascot.dispose();
    });

    await viewModel.initialize();
    final send = viewModel.sendMessage('Question in chat A');
    await ai.requestStarted.future.timeout(const Duration(seconds: 5));
    final conversationAId = viewModel.activeConversationId;
    final draftAId = viewModel.draftId;

    viewModel.updateComposerText('unsent text');
    await viewModel.startNewSession();

    expect(viewModel.activeConversationId, isNull);
    expect(viewModel.draftId, isNot(draftAId));
    expect(viewModel.messages, isEmpty);
    expect(viewModel.composerText, isEmpty);
    expect(viewModel.draftStatus, ChatDraftStatus.empty);
    expect(viewModel.isPersisted, isFalse);

    response.complete('Response from chat A');
    await send;

    expect(viewModel.messages, isEmpty);
    expect(viewModel.activeConversationId, isNull);
    final archived = await viewModel.loadArchivedSessions();
    expect(archived, hasLength(1));
    expect(archived.single.id, conversationAId);
    expect(archived.single.messages.map((message) => message.text),
        ['Question in chat A']);
  });

  test('new submission gets a separate stable ID and restore keeps that ID',
      () async {
    final ai = _TestConversationService(
      (_) async => 'A response in the new chat',
    );
    final mascot = EggyMascotController();
    final viewModel = EggyChatViewModel(ai, ScriptedResponseService(), mascot);
    addTearDown(() {
      viewModel.dispose();
      mascot.dispose();
    });

    await viewModel.initialize();
    final draftId = viewModel.draftId;
    await viewModel.sendMessage('Question in chat B');

    final conversationBId = viewModel.activeConversationId;
    expect(conversationBId, isNotNull);
    expect(conversationBId, isNot(draftId));
    expect(viewModel.messages.map((message) => message.text),
        ['Question in chat B', 'A response in the new chat']);
    expect(viewModel.isPersisted, isTrue);

    await viewModel.startNewSession();
    final archived = await viewModel.loadArchivedSessions();
    final chatB =
        archived.singleWhere((session) => session.id == conversationBId);
    await viewModel.restoreArchivedSession(chatB);

    expect(viewModel.activeConversationId, conversationBId);
    expect(viewModel.messages.map((message) => message.text),
        ['Question in chat B', 'A response in the new chat']);
  });
}

class _TestConversationService implements IConversationService {
  _TestConversationService(this._respond);

  final Future<String> Function(String userMessage) _respond;
  final Completer<void> requestStarted = Completer<void>();

  @override
  bool get isAIBacked => true;

  @override
  Future<String> getResponse(String userMessage) {
    if (!requestStarted.isCompleted) requestStarted.complete();
    return _respond(userMessage);
  }

  @override
  List<ChatSuggestion> getSuggestedPrompts({bool isProfessorMode = false}) =>
      const [];
}
