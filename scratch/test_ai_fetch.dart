import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

Future<void> main() async {
  // Load .env
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found');
    return;
  }
  
  final lines = envFile.readAsLinesSync();
  final env = <String, String>{};
  for (var line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      env[parts[0].trim()] = parts.sublist(1).join('=').trim();
    }
  }

  final apiKey = env['OPENROUTER_API_KEY'] ?? '';
  final model = env['OPENROUTER_MODEL'] ?? 'meta-llama/llama-3.3-70b-instruct:free';
  
  print('Testing Model: $model');
  print('API Key (partial): ${apiKey.substring(0, 10)}...');

  final baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://eggy.app',
        'X-Title': 'Eggy App Test',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'Hello, say "Eggy is online"'},
        ],
        'temperature': 0.7,
        'max_tokens': 50,
      }),
    ).timeout(const Duration(seconds: 15));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      print('SUCCESS! Response: $content');
    } else {
      print('FAILURE: Received status ${response.statusCode}');
    }
  } catch (e) {
    print('EXCEPTION: $e');
  }
}
