import '../constants.dart';
import '../models/recipe_models.dart';
import '../models/recipe_step.dart';
import 'i_egg_calculator.dart';

/// Interface for any egg recipe.
/// Adding a new recipe = new class implementing this. Never touch App.dart.
abstract class IEggRecipe {
  String get id;
  String get title;
  String get subtitle;
  String get description;
  String get difficulty; // e.g. 'Novice', 'Advanced', 'Molecular Master'
  CookingMethod get cookingMethod;
  String get icon;
  List<YolkState> get yolkOptions;

  /// Items required for the "Lab Setup" Mission Briefing
  List<PrepItem> get ingredients;
  List<PrepItem> get tools;

  /// Strategic Pep-Talks from Professor Eggy
  List<ProTip> get proTips;

  /// Returns step-by-step instructions. Max 2 shown at a time in UI.
  List<RecipeStep> getStepInstructions();

  /// Cooking time based on user preferences
  Duration calculateCookingTime(UserEggPreferences prefs, double sliderValue);

  MascotState getMascotState();

  /// Whether this recipe uses the Yolk-o-Meter slider.
  /// Scrambled & Omelette override to false — they go straight to a prep guide.
  bool get hasYolkCustomizer;

  /// The recommended starting position for the Yolk-o-Meter [0.0 - 1.0]
  double get initialSliderValue;

  /// Returns the baseline nutrition (per 100g) for this specific recipe.
  /// This takes into account added ingredients like butter, oil, or sauces.
  NutritionFacts getBaseNutrition();
}
