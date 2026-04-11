
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('--- Minimal Connection Test ---');
  
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
  
  // Test with NO tools and NO system prompt
  final modelName = 'gemini-1.5-flash';
  print('Testing model: $modelName (Minimal)');
  
  try {
    final model = GenerativeModel(model: modelName, apiKey: apiKey);
    final response = await model.generateContent([Content.text('Hi')]);
    print('SUCCESS: ${response.text}');
  } catch (e) {
    print('FAILED: $e');
  }
}
