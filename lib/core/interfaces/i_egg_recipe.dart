import '../constants.dart';
import 'i_egg_calculator.dart';
import '../models/recipe_step.dart';

/// Interface for any egg recipe.
/// Adding a new recipe = new class implementing this. Never touch App.dart.
abstract class IEggRecipe {
  String get id;
  String get title;
  String get subtitle;
  String get description;
  CookingMethod get cookingMethod;
  String get icon;
  List<YolkState> get yolkOptions;

  /// Returns step-by-step instructions. Max 2 shown at a time in UI.
  List<RecipeStep> getStepInstructions();

  /// Cooking time based on user preferences
  Duration calculateCookingTime(UserEggPreferences prefs, double sliderValue);

  MascotState getMascotState();

  /// Whether this recipe uses the Yolk-o-Meter slider.
  /// Scrambled & Omelette override to false — they go straight to a prep guide.
  bool get hasYolkCustomizer => true;
}
