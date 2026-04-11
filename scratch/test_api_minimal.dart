import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = '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';
  final models = [
    'google/gemma-3-4b-it:free',        // Very new 2026 model
    'meta-llama/llama-3.3-70b-instruct:free',
    'deepseek/deepseek-chat:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'google/gemma-2-9b-it:free'
  ];
  
  final client = HttpClient();
  
  for (var model in models) {
    print('\n--- Testing Model: $model ---');
    try {
      final request = await client.postUrl(Uri.parse('https://openrouter.ai/api/v1/chat/completions'));
      request.headers.set('Authorization', 'Bearer $apiKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('HTTP-Referer', 'https://eggy.app');
      
      final body = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'Is the API working?'}
        ],
        'max_tokens': 5,
      });
      
      request.write(body);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Status Code: ${response.statusCode}');
      print('Response: $responseBody');
      
      if (response.statusCode == 200) {
        print('SUCCESS for $model');
      }
    } catch (e) {
      print('EXCEPTION for $model: $e');
    }
  }
  client.close();
}
