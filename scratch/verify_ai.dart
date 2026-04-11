
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('--- AI Connection Verification ---');
  
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('ERROR: .env not found');
    return;
  }
  
  final lines = await envFile.readAsLines();
  String? apiKey;
  String? modelName;
  
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) apiKey = line.split('=')[1].trim();
    if (line.startsWith('GEMINI_MODEL=')) modelName = line.split('=')[1].trim();
  }
  
  print('Target Model: $modelName');
  
  if (apiKey == null || apiKey.isEmpty) {
    print('ERROR: API Key missing');
    return;
  }
  
  try {
    final model = GenerativeModel(model: modelName!, apiKey: apiKey);
    final response = await model.generateContent([Content.text('Verify AI connection. Respond with one word: SUCCESS')]);
    
    print('AI Response: ${response.text?.trim()}');
    if (response.text?.trim().contains('SUCCESS') ?? false) {
      print('VERIFICATION: PASSED');
    } else {
      print('VERIFICATION: FAILED (Unexpected response)');
    }
  } catch (e) {
    print('VERIFICATION: FAILED with error: $e');
  }
}
