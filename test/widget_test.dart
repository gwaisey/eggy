import 'package:eggy/features/preferences/preferences_view_model.dart';
import 'package:eggy/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Eggy app smoke test', (WidgetTester tester) async {
    final prefs = PreferencesViewModel();
    await tester.pumpWidget(EggyApp(persistedPrefs: prefs));
    expect(find.text('eggy 🥚'), findsOneWidget);
  });
}
