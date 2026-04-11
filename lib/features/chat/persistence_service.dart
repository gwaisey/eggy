import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/data_context.dart';
import 'conversation_service.dart';

/// Service to handle persistence of chat history using SharedPreferences.
/// Professor Eggy uses this to maintain "Real-World Memory" across app restarts.
class PersistenceService {
  static const String _historyKey = 'eggy_professor_history';
  static const int _maxWindowSize = 15; 
  static const int _maxCharacterLimit = 10000;

  /// Saves the last 15 messages to persistent storage.
  Future<void> saveHistory(List<ChatMessage> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // We only persist the last 15 messages to keep the window clean/fast.
      final windowStart = history.length > _maxWindowSize ? history.length - _maxWindowSize : 0;
      final window = history.sublist(windowStart);

      List<String> jsonList = window
          .where((msg) => msg.rawError == null) // Don't persist errors
          .map((msg) => jsonEncode({
                'role': msg.isUser ? 'user' : 'model',
                'text': msg.text,
                'alertLevel': msg.alertLevel.index,
                'timestamp': msg.timestamp.toIso8601String(),
                'contexts': msg.contexts?.map((c) => c.toJson()).toList(),
              }))
          .toList();

      // Performance Tuning: Prune if we exceed the 10,000 char "snappy" limit
      while (jsonList.join('').length > _maxCharacterLimit && jsonList.length > 2) {
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

      return jsonList.map((jsonStr) {
        final data = jsonDecode(jsonStr);
        final contextsRaw = data['contexts'] as List?;
        final contexts = contextsRaw != null 
            ? contextsRaw.map((c) => DataContext.fromJson(c)).toList() 
            : null;

        return ChatMessage(
          text: data['text'],
          isUser: data['role'] == 'user',
          contexts: contexts,
          // alertLevel and timestamp are restored for UI consistency if needed
        );
      }).toList();
    } catch (e) {
      print('Eggy Error: History Load Failed: $e');
      return [];
    }
  }

  /// Clears the saved memory.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
