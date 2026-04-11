import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final apiKey = 'AIzaSyBqUiLPaIXPhx7qOSpYMPAk2ckKvxaOAqg';
  final List<String> modelsToTest = [
    'gemini-flash-latest',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
  ];

  for(var modelStr in modelsToTest) {
    try {
      print("Testing \$modelStr...");
      final model = GenerativeModel(
        model: modelStr,
        apiKey: apiKey,
      );
      final chat = model.startChat();
      final response = await chat.sendMessage(Content.text("Say 'test'"));
      print("\$modelStr works: \${response.text}");
    } catch (e) {
      if (e.toString().contains("Quota") || e.toString().contains("billing")) {
        print("\$modelStr Error: Quota/Billing");
      } else {
        print("\$modelStr Error: \${e.toString()}");
      }
    }
  }
}
