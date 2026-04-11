
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('--- OpenRouter Connection Test ---');
  
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String? apiKey;
  String? modelName;
  for (var line in lines) {
    if (line.startsWith('OPENROUTER_API_KEY=')) apiKey = line.split('=')[1].trim();
    if (line.startsWith('OPENROUTER_MODEL=')) modelName = line.split('=')[1].trim();
  }
  
  print('Model: $modelName');
  
  if (apiKey == null || apiKey == 'your_openrouter_key_here') {
    print('ERROR: OpenRouter API key not set in .env');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://eggy.app',
        'X-Title': 'Eggy App',
      },
      body: jsonEncode({
        'model': modelName,
        'messages': [
          {'role': 'user', 'content': 'Is it safe to eat a duck egg?'}
        ],
      }),
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('SUCCESS: ${data['choices'][0]['message']['content']}');
    } else {
      print('FAILED (${response.statusCode}): ${response.body}');
    }
  } catch (e) {
    print('ERROR: $e');
  }
}
