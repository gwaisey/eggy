
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('--- AI Connection Final Test ---');
  
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String? apiKey;
  String? modelName;
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) apiKey = line.split('=')[1].trim();
    if (line.startsWith('GEMINI_MODEL=')) modelName = line.split('=')[1].trim();
  }
  
  print('Model: $modelName');
  
  try {
    // Standard initialization with NO tools
    final model = GenerativeModel(model: modelName!, apiKey: apiKey!);
    final response = await model.generateContent([Content.text('Hi')]).timeout(Duration(seconds: 10));
    print('SUCCESS: ${response.text}');
  } catch (e) {
    print('FAILED: $e');
  }
}
