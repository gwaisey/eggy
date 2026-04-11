
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    // Manually load .env since we're in a script
    final envFile = File('.env');
    if (!envFile.existsSync()) {
      print('Error: .env file not found');
      return;
    }
    
    final lines = await envFile.readAsLines();
    final env = <String, String>{};
    for (var line in lines) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final parts = line.split('=');
      if (parts.length >= 2) {
        env[parts[0]] = parts.sublist(1).join('=');
      }
    }

    final apiKey = env['GEMINI_API_KEY'];
    final modelName = env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';

    if (apiKey == null || apiKey.isEmpty) {
      print('Error: GEMINI_API_KEY not found in .env');
      return;
    }

    print('Testing Gemini with model: $modelName');
    final model = GenerativeModel(model: modelName, apiKey: apiKey);
    final content = [Content.text('Say hello!')];
    final response = await model.generateContent(content);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error testing Gemini: $e');
  }
}
