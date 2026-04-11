
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('--- Listing OpenRouter Free Models ---');
  
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('OPENROUTER_API_KEY=')) apiKey = line.split('=')[1].trim();
  }
  
  try {
    final response = await http.get(
      Uri.parse('https://openrouter.ai/api/v1/models'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> models = data['data'];
      final freeModels = models.where((m) => m['id'].toString().contains(':free')).toList();
      
      print('FOUND ${freeModels.length} FREE MODELS:');
      for (var m in freeModels) {
        print('- ${m['id']}');
      }
    } else {
      print('FAILED (${response.statusCode}): ${response.body}');
    }
  } catch (e) {
    print('ERROR: $e');
  }
}
