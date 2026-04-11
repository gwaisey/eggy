
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('--- Listing Available Models ---');
  
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('ERROR: .env not found');
    return;
  }
  
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) apiKey = line.split('=')[1].trim();
  }
  
  if (apiKey == null || apiKey.isEmpty) {
    print('ERROR: API Key missing');
    return;
  }
  
  try {
    // Note: The public SDK might not have a direct listModels call exposed easily in the main model class
    // but we can try common ones.
    final models = ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro', 'gemini-1.0-pro'];
    for (var m in models) {
      try {
        final model = GenerativeModel(model: m, apiKey: apiKey);
        await model.generateContent([Content.text('Hi')]).timeout(Duration(seconds: 5));
        print('SUCCESS: $m is available');
      } catch (e) {
        print('FAILED: $m - $e');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
