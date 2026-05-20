import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/data_context.dart';
import 'conversation_service.dart';

class ChatArchiveSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const ChatArchiveSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });
}

/// Service to handle persistence of chat history using SharedPreferences.
/// Professor Eggy uses this to maintain "Real-World Memory" across app restarts.
class PersistenceService {
  static const String _historyKey = 'eggy_professor_history';
  static const String _archiveKey = 'eggy_ai_chat_archive';
  static const int _maxWindowSize = 15;
  static const int _maxCharacterLimit = 10000;
  static const int _maxArchivedSessions = 30;

  /// Saves the last 15 messages to persistent storage.
  Future<void> saveHistory(List<ChatMessage> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // We only persist the last 15 messages to keep the window clean/fast.
      final windowStart =
          history.length > _maxWindowSize ? history.length - _maxWindowSize : 0;
      final window = history.sublist(windowStart);

      List<String> jsonList = window
          .where((msg) => msg.rawError == null) // Don't persist errors
          .map(_encodeMessage)
          .toList();

      // Performance Tuning: Prune if we exceed the 10,000 char "snappy" limit
      while (jsonList.join('').length > _maxCharacterLimit &&
          jsonList.length > 2) {
        jsonList.removeAt(0); // Prune oldest first
      }

      await prefs.setStringList(_historyKey, jsonList);
    } catch (e) {
      print('Eggy Error: History Persistence Failed: $e');
    }
  }

  /// Loads the saved chat history from disk.
  Future<List<ChatMessage>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_historyKey) ?? [];

      return jsonList.map(_decodeMessage).toList();
    } catch (e) {
      print('Eggy Error: History Load Failed: $e');
      return [];
    }
  }

  Future<void> archiveSession(List<ChatMessage> history) async {
    final cleanHistory = history.where((msg) => msg.rawError == null).toList();
    if (cleanHistory.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = prefs.getStringList(_archiveKey) ?? [];
      final createdAt = DateTime.now();
      final encodedMessages = cleanHistory.map(_encodeMessage).toList();

      final archiveEntry = jsonEncode({
        'id': createdAt.microsecondsSinceEpoch.toString(),
        'title': _titleFor(cleanHistory),
        'createdAt': createdAt.toIso8601String(),
        'messages': encodedMessages,
      });

      final updated = [archiveEntry, ...sessions];
      if (updated.length > _maxArchivedSessions) {
        updated.removeRange(_maxArchivedSessions, updated.length);
      }

      await prefs.setStringList(_archiveKey, updated);
    } catch (e) {
      print('Eggy Error: Session Archive Failed: $e');
    }
  }

  Future<List<ChatArchiveSession>> loadArchivedSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = prefs.getStringList(_archiveKey) ?? [];

      return sessions
          .map((jsonStr) {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final rawMessages = data['messages'] as List? ?? [];
            final messages =
                rawMessages.whereType<String>().map(_decodeMessage).toList();

            return ChatArchiveSession(
              id: data['id'] as String? ?? '',
              title: data['title'] as String? ?? 'Eggy chat',
              createdAt:
                  DateTime.tryParse(data['createdAt'] as String? ?? '') ??
                      DateTime.now(),
              messages: messages,
            );
          })
          .where((session) => session.messages.isNotEmpty)
          .toList();
    } catch (e) {
      print('Eggy Error: Archive Load Failed: $e');
      return [];
    }
  }

  /// Clears the saved memory.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  String _encodeMessage(ChatMessage msg) => jsonEncode({
        'role': msg.isUser ? 'user' : 'model',
        'text': msg.text,
        'alertLevel': msg.alertLevel.index,
        'timestamp': msg.timestamp.toIso8601String(),
        'contexts': msg.contexts?.map((c) => c.toJson()).toList(),
      });

  ChatMessage _decodeMessage(String jsonStr) {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final contextsRaw = data['contexts'] as List?;
    final contexts = contextsRaw?.map((c) => DataContext.fromJson(c)).toList();
    final alertIndex = data['alertLevel'] as int? ?? AlertLevel.standard.index;
    final safeAlertIndex = alertIndex.clamp(0, AlertLevel.values.length - 1);

    return ChatMessage(
      text: data['text'] as String? ?? '',
      isUser: data['role'] == 'user',
      alertLevel: AlertLevel.values[safeAlertIndex],
      contexts: contexts,
      timestamp: DateTime.tryParse(data['timestamp'] as String? ?? ''),
    );
  }

  String _titleFor(List<ChatMessage> messages) {
    final userMessages = messages
        .where((msg) => msg.isUser && msg.text.trim().isNotEmpty)
        .map((msg) => msg.text.trim().replaceAll(RegExp(r'\s+'), ' '));
    final firstUserMessage = userMessages.isEmpty ? null : userMessages.first;

    if (firstUserMessage == null) return 'Eggy chat';
    return firstUserMessage.length <= 44
        ? firstUserMessage
        : '${firstUserMessage.substring(0, 44)}...';
  }
}
