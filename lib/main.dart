import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/egg_physics_engine.dart';
import 'core/interfaces/i_egg_recipe.dart';
import 'features/chat/conversation_service.dart';
import 'features/preferences/preferences_view_model.dart';
import 'features/recipes/recipe_factory.dart';
import 'screens/eggy_chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prep_list_screen.dart';
import 'screens/prep_guide_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/hatch_screen.dart';
import 'shared/ui/app_theme.dart';
import 'features/mascot/eggy_mascot_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env for Gemini API key
  try {
    await dotenv.load(fileName: '.env');
    // Security Guardrail: Check for placeholder or missing keys
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_openrouter_key_here') {
      debugPrint('âš ï¸ SECURITY ALERT: OpenRouter API key is missing or set to placeholder in .env.');
    }
  } catch (e) {
    debugPrint('âš ï¸ CONFIG ERROR: .env file not found. Ensure it exists and is ignored by Git.');
  }

  // Load persisted preferences
  final prefs = PreferencesViewModel();
  await prefs.load();

  runApp(EggyApp(persistedPrefs: prefs));
}

class EggyApp extends StatelessWidget {
  final PreferencesViewModel persistedPrefs;
  const EggyApp({super.key, required this.persistedPrefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EggyMascotController>(
          create: (_) => EggyMascotController(),
        ),
        Provider<EggPhysicsEngine>(create: (_) => EggPhysicsEngine()),
        ProxyProvider<EggPhysicsEngine, RecipeFactory>(
          update: (_, engine, __) => RecipeFactory(engine),
        ),
        Provider<EggyAIService>(
          create: (_) => EggyAIService(),
        ),
        Provider<ScriptedResponseService>(
          create: (_) => ScriptedResponseService(),
        ),
        ChangeNotifierProxyProvider3<EggyAIService, ScriptedResponseService, EggyMascotController, EggyChatViewModel>(
          create: (ctx) => EggyChatViewModel(
            ctx.read<EggyAIService>(), 
            ctx.read<ScriptedResponseService>(),
            ctx.read<EggyMascotController>(),
          ),
          update: (_, ai, local, mascot, prev) => prev ?? EggyChatViewModel(ai, local, mascot),
        ),
        ChangeNotifierProvider<PreferencesViewModel>.value(value: persistedPrefs),
      ],
      child: MaterialApp(
        title: 'Eggy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // ── Central Routing Engine ──────────────────────────────────────────
          // Handles argument injection for the culinary biodiversity flow.
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/chat':
              return MaterialPageRoute(builder: (_) => const EggyChatScreen());
            case '/settings':
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            // Integrated into PrepListScreen now
            case '/briefing':
              final recipe = settings.arguments as IEggRecipe;
              return MaterialPageRoute(builder: (_) => PrepListScreen(recipe: recipe));
            case '/prep':
              final recipe = settings.arguments as IEggRecipe;
              return MaterialPageRoute(builder: (_) => PrepGuideScreen(recipe: recipe));
            case '/timer':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => TimerScreen(
                  recipe: args['recipe'] as IEggRecipe,
                  duration: args['duration'] as Duration,
                  returnToStepIndex: args['returnToStepIndex'] ?? -1,
                ),
              );
            case '/hatch':
              final recipe = settings.arguments as IEggRecipe;
              return MaterialPageRoute(builder: (_) => HatchScreen(recipe: recipe));
            default:
              return null;
          }
        },
      ),
    );
  }
}
