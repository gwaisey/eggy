import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/interfaces/i_egg_recipe.dart';
import '../../core/interfaces/i_egg_calculator.dart';
import '../../core/models/recipe_step.dart';
import '../../core/models/step_icon_type.dart';
import '../../core/models/recipe_models.dart';

/// Abstract base with shared logic. Concrete recipes extend this.
abstract class EggBase implements IEggRecipe {
  final EggCalculator _calculator;

  EggBase(this._calculator);

  @override
  bool get hasYolkCustomizer => true;

  @override
  String get difficulty => 'Easy';

  @override
  List<ProTip> get proTips => [];

  @override
  Duration calculateCookingTime(UserEggPreferences prefs, double sliderValue) {
    final targetTemp = _calculator.calculateTargetTemp(sliderValue);
    return _calculator.calculateCookingTime(targetTemp, prefs);
  }

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 155, protein: 13, fatTotal: 11, fatSaturated: 3.3,
    carbs: 1.1, cholesterol: 372, sodium: 124, potassium: 126,
  );
}

// ── Concrete Recipes ──────────────────────────────────────────────────────────

class BoiledEgg extends EggBase {
  BoiledEgg(super.calculator);

  @override String get id       => 'boiled_01';
  @override String get title    => 'Boiled Egg';
  @override String get subtitle => 'Classic';
  @override String get description => 'The absolute culinary baseline. Whether you like a "liquid gold" dip or a firm, solid center, Eggy ensures perfect thermal equilibrium every time!';
  @override String get icon     => 'assets/images/recipe_boiled.png';
  @override CookingMethod get cookingMethod => CookingMethod.boiled;
  @override MascotState getMascotState() => MascotState.cooking;

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Fresh Eggs', iconType: StepIconType.egg, quantity: '1-6'),
    PrepItem(name: 'Water', iconType: StepIconType.water, quantity: 'Enough to cover'),
    PrepItem(name: 'Ice Cubes', iconType: StepIconType.iceBath, quantity: 'For cooling'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Small Pot', iconType: StepIconType.pot),
    PrepItem(name: 'Glass Bowl', iconType: StepIconType.bowl),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'boil_tip_1',
      title: 'No-Crack Secret',
      message: 'Add a pinch of salt to the water. If an egg cracks, the salt helps the white solidify instantly to seal the leak!',
      triggerStepIndex: 1,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 61.0, label: 'Liquid Gold', hexColor: Color(0xFFFF8C00), viscosity: 0.0),
    YolkState(temperature: 64.0, label: 'Jammy',       hexColor: Color(0xFFFFAA00), viscosity: 0.25),
    YolkState(temperature: 69.0, label: 'Custardy',    hexColor: Color(0xFFFFCC00), viscosity: 0.5),
    YolkState(temperature: 72.0, label: 'Soft Set',    hexColor: Color(0xFFFFD966), viscosity: 0.75),
    YolkState(temperature: 77.0, label: 'Firm',        hexColor: Color(0xFFC8860A), viscosity: 1.0),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    const RecipeStep(
      title: 'Strategic Arrangement',
      instruction: 'Arrange your eggs gently in a single layer at the bottom of the pot',
      actionCommand: 'Place eggs in pot',
      iconType: StepIconType.egg,
    ),
    const RecipeStep(
      title: 'The Thermal Bath',
      instruction: 'Fill with water until the eggs are submerged by at least an inch',
      actionCommand: 'Add water',
      iconType: StepIconType.water,
    ),
    RecipeStep(
      title: 'Molecular Coagulation',
      instruction: 'Bring to a rolling boil over high heat, then start the Eggy timer',
      actionCommand: 'Start the heat',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'The Eggy timer uses the Williams Formula to predict coagulation times based on thermal diffusivity and start temperature.',
        metadata: {'Domain': 'Thermal_Physics', 'Entity': 'Coagulation_Time', 'Property': 'Williams_Equation'},
        lineage: {'dc:creator': 'Charles D.H. Williams', 'dc:date': '1992', 'dc:source': 'University of Exeter'},
        trustScore: 0.99,
        classification: 'Theory',
        policy: 'Cooking Guide',
      ),
    ),
    const RecipeStep(
      title: 'Atomic Freeze',
      instruction: 'Transfer immediately to an ice bath to cool down',
      actionCommand: 'Cool in ice bath',
      iconType: StepIconType.iceBath,
    ),
  ];
}

class ScrambledEgg extends EggBase {
  ScrambledEgg(super.calculator);

  @override String get id       => 'scrambled_01';
  @override String get title    => 'Scrambled Egg';
  @override String get subtitle => 'Creamy';
  @override String get description => 'A gentle, buttery fusion where slow folding creates soft, silky protein clouds. The ultimate comfort breakfast!';
  @override String get icon     => 'assets/images/recipe_scrambled.png';
  @override String get difficulty => 'Intermediate';
  @override CookingMethod get cookingMethod => CookingMethod.scrambled;
  @override MascotState getMascotState() => MascotState.preparing;
  @override bool get hasYolkCustomizer => false;

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 196, protein: 12, fatTotal: 15, fatSaturated: 7.2,
    carbs: 2.2, cholesterol: 360, sodium: 280, potassium: 142,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Large Eggs', iconType: StepIconType.egg, quantity: '2-3'),
    PrepItem(name: 'Butter', iconType: StepIconType.butter, quantity: '1 tbsp'),
    PrepItem(name: 'Salt & Cream', iconType: StepIconType.salt, quantity: 'Pinch/Splash'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Non-stick Pan', iconType: StepIconType.pan),
    PrepItem(name: 'Silicone Spatula', iconType: StepIconType.spatula),
    PrepItem(name: 'Whisk', iconType: StepIconType.whisk),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'scramble_tip_1',
      title: 'The Carry-over',
      message: 'Pull the eggs off the heat while they still look a bit wet—the residual heat will finish them perfectly on the plate!',
      triggerStepIndex: 3,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 65.0, label: 'Silky Soft', hexColor: Color(0xFFFFCC44), viscosity: 0.2),
    YolkState(temperature: 70.0, label: 'Creamy',     hexColor: Color(0xFFFFD966), viscosity: 0.5),
    YolkState(temperature: 75.0, label: 'Fluffy Set', hexColor: Color(0xFFE8A800), viscosity: 0.8),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      title: 'Emulsion Phase',
      instruction: 'In a small bowl, whisk eggs with salt and cream until uniform and pale yellow',
      actionCommand: 'Whisk eggs well',
      iconType: StepIconType.whisk,
      context: DataContext(
        content: 'Mechanical agitation denatures proteins; whisking duck eggs introduces air into a higher-lipid environment, creating a sturdier foam than hen eggs.',
        metadata: {'Domain': 'Molecular_Gastronomy', 'Entity': 'Protein_Foam', 'Property': 'Species_Agitation'},
        lineage: {'dc:creator': 'FAO', 'dc:date': '2026', 'dc:source': 'Circular Economy Report'},
        trustScore: 0.95,
        classification: 'Theory',
        policy: 'Ingredient Insight',
      ),
    ),
    const RecipeStep(
      title: 'Lipid Fusion',
      instruction: 'Melt butter over medium-low heat until it foams, then pour in your eggs',
      actionCommand: 'Melt the butter',
      iconType: StepIconType.butter,
    ),
    const RecipeStep(
      title: 'Folding Aeration',
      instruction: 'Start the timer and fold the eggs gently every 20 seconds using a spatula',
      actionCommand: 'Cook & fold',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    const RecipeStep(
      title: 'Plating Masterpiece',
      instruction: 'Remove from heat just before they set—residual heat finishes them on the plate',
      actionCommand: 'Finish on plate',
      iconType: StepIconType.plate,
    ),
  ];
}

class PoachedEgg extends EggBase {
  PoachedEgg(super.calculator);

  @override String get id       => 'poached_01';
  @override String get title    => 'Poached Egg';
  @override String get subtitle => 'Delicate';
  @override String get description => 'The pinnacle of egg mastery. A silky-soft white nest protecting a rich, liquid core. Elegant and impressively simple once you know the secret!';
  @override String get icon     => 'assets/images/recipe_poached.png';
  @override String get difficulty => 'Advanced';
  @override CookingMethod get cookingMethod => CookingMethod.poached;
  @override MascotState getMascotState() => MascotState.cooking;

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 158, protein: 13, fatTotal: 11, fatSaturated: 3.3,
    carbs: 1.1, cholesterol: 372, sodium: 135, potassium: 126,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Fresh Egg', iconType: StepIconType.egg, quantity: '1'),
    PrepItem(name: 'Cold Water', iconType: StepIconType.water, quantity: '3 inches deep'),
    PrepItem(name: 'Vinegar', iconType: StepIconType.sauce, quantity: '1 tbsp'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Wide Pan', iconType: StepIconType.pan),
    PrepItem(name: 'Slotted Spoon', iconType: StepIconType.spoon),
    PrepItem(name: 'Small Bowl', iconType: StepIconType.bowl),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'poach_tip_1',
      title: 'Freshness is Key',
      message: 'The fresher the egg, the tighter the white! If your eggs are older, use a fine-mesh sieve to drain off the watery "loose" white first.',
      triggerStepIndex: 2,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 63.0, label: 'Runny',   hexColor: Color(0xFFFF8C00), viscosity: 0.1),
    YolkState(temperature: 67.0, label: 'Flowing',  hexColor: Color(0xFFFFAA00), viscosity: 0.4),
    YolkState(temperature: 71.0, label: 'Set',      hexColor: Color(0xFFFFD966), viscosity: 0.7),
  ];

  @override
  List<RecipeStep> getStepInstructions() => const [
    RecipeStep(
      title: 'The Static Pool',
      instruction: 'Fill a wide pan with 3 inches of water and bring to a very gentle simmer',
      actionCommand: 'Simmer water',
      iconType: StepIconType.water,
    ),
    RecipeStep(
      title: 'Acid Alignment',
      instruction: 'Add a splash of vinegar—this helps the whites stay neatly tucked around the yolk',
      actionCommand: 'Add vinegar',
      iconType: StepIconType.heat,
    ),
    RecipeStep(
      title: 'The Gentle Drop',
      instruction: 'Crack egg into a small bowl first, then slide gently into the center of the pan',
      actionCommand: 'Slide in eggs',
      iconType: StepIconType.crack,
    ),
    RecipeStep(
      title: 'Precision Poach',
      instruction: 'Start the timer and let the egg float peacefully—no stirring required',
      actionCommand: 'Poach eggs',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      title: 'The Elevation',
      instruction: 'Lift out with a slotted spoon and rest on a paper towel',
      actionCommand: 'Lift and rest',
      iconType: StepIconType.plate,
    ),
  ];
}

class Omelette extends EggBase {
  Omelette(super.calculator);

  @override String get id       => 'omelette_01';
  @override String get title    => 'Omelette';
  @override String get subtitle => 'Golden & pillowy';
  @override String get description => 'A pillowy canvas of golden eggs, folded perfectly to trap steam and maintain a tender, juicy interior. Breakfast luxury at home!';
  @override String get icon     => 'assets/images/recipe_omelette.png';
  @override CookingMethod get cookingMethod => CookingMethod.omelette;
  @override MascotState getMascotState() => MascotState.preparing;
  @override bool get hasYolkCustomizer => false;

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 212, protein: 12, fatTotal: 17, fatSaturated: 8.5,
    carbs: 1.8, cholesterol: 360, sodium: 310, potassium: 138,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Large Eggs', iconType: StepIconType.egg, quantity: '2'),
    PrepItem(name: 'Butter', iconType: StepIconType.butter, quantity: '1 tbsp'),
    PrepItem(name: 'Salt', iconType: StepIconType.whisk, quantity: 'Pinch'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Small Non-stick', iconType: StepIconType.pan),
    PrepItem(name: 'Silicone Spatula', iconType: StepIconType.spatula),
    PrepItem(name: 'Bowl & Whisk', iconType: StepIconType.whisk),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'omelette_tip_1',
      title: 'Beat Well',
      message: 'Whisk your eggs until no streaks of white remain. This ensures a consistent, pillowy texture without "rubbery" spots!',
      triggerStepIndex: 0,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 70.0, label: 'Tender',    hexColor: Color(0xFFFFD700), viscosity: 0.3),
    YolkState(temperature: 75.0, label: 'Golden',    hexColor: Color(0xFFE8A800), viscosity: 0.6),
    YolkState(temperature: 80.0, label: 'Well Done', hexColor: Color(0xFFC8860A), viscosity: 0.9),
  ];

  @override
  List<RecipeStep> getStepInstructions() => const [
    RecipeStep(
      title: 'Structural Whisking',
      instruction: 'Whisk eggs and salt until no streaks remain for a pillowy, golden result',
      actionCommand: 'Whisk smooth',
      iconType: StepIconType.whisk,
    ),
    RecipeStep(
      title: 'Pan Priming',
      instruction: 'Melt butter in a non-stick pan over medium heat until it bubbles and sizzles',
      actionCommand: 'Melt butter',
      iconType: StepIconType.butter,
    ),
    RecipeStep(
      title: 'The Swirl Flow',
      instruction: 'Pour in eggs, start the timer, and use a spatula to pull the edges inward',
      actionCommand: 'Cook & swirl',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      title: 'The Final Fold',
      instruction: 'Fold the omelette gently in half and slide it onto a warm porcelain plate',
      actionCommand: 'Fold and serve',
      iconType: StepIconType.fold,
    ),
  ];
}

class FriedEgg extends EggBase {
  FriedEgg(super.calculator);

  @override String get id       => 'fried_01';
  @override String get title    => 'Fried Egg';
  @override String get subtitle => 'Crispy edges';
  @override String get description => 'Sizzling hot with caramelized lacy edges and a glowing, intact sun-side yolk core. The king of toast toppings!';
  @override String get icon     => 'assets/images/recipe_fried.png';
  @override String get difficulty => 'Easy';
  @override CookingMethod get cookingMethod => CookingMethod.fried;
  @override MascotState getMascotState() => MascotState.cooking;

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 232, protein: 11, fatTotal: 20, fatSaturated: 9.8,
    carbs: 0.9, cholesterol: 350, sodium: 240, potassium: 120,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Fresh Egg', iconType: StepIconType.egg, quantity: '1'),
    PrepItem(name: 'Butter', iconType: StepIconType.butter, quantity: '1 tsp'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Stainless Pan', iconType: StepIconType.pan),
    PrepItem(name: 'Thin Turner', iconType: StepIconType.spatula),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'fried_tip_1',
      title: 'The Sizzling Shimmer',
      message: 'Heat your pan first! If the butter doesn\'t sizzle immediately when it hits the pan, it\'s not hot enough for those crispy edges.',
      triggerStepIndex: 1,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 63.0, label: 'Sunny Side',  hexColor: Color(0xFFFF8C00), viscosity: 0.0),
    YolkState(temperature: 67.0, label: 'Over Easy',   hexColor: Color(0xFFFFAA00), viscosity: 0.3),
    YolkState(temperature: 71.0, label: 'Over Medium', hexColor: Color(0xFFFFD966), viscosity: 0.6),
    YolkState(temperature: 77.0, label: 'Over Hard',   hexColor: Color(0xFFC8860A), viscosity: 1.0),
  ];

  @override
  List<RecipeStep> getStepInstructions() => const [
    RecipeStep(
      title: 'Metal Calibration',
      instruction: 'Pre-heat a stainless steel pan over medium-low heat for two minutes',
      actionCommand: 'Heat the pan',
      iconType: StepIconType.heat,
    ),
    RecipeStep(
      title: 'Butter Shimmer',
      instruction: 'Add butter and wait for the "nutty" simmer—avoid any hints of smoke',
      actionCommand: 'Melt butter',
      iconType: StepIconType.butter,
    ),
    RecipeStep(
      title: 'Sizzling Ignition',
      instruction: 'Crack egg gently into the center and start the Eggy timer',
      actionCommand: 'Fry the egg',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      title: 'Steam Trap',
      instruction: 'Cover with a lid for the final 30 seconds for a flawless steamed finish',
      actionCommand: 'Cover and steam',
      iconType: StepIconType.crack,
    ),
    RecipeStep(
      title: 'Lacy Finish',
      instruction: 'Slide onto a warm plate—look for golden lacy edges and a glossy yolk',
      actionCommand: 'Serve crispy',
      iconType: StepIconType.plate,
    ),
  ];
}

class EggsBenedict extends EggBase {
  EggsBenedict(super.calculator);

  @override String get id       => 'benedict_01';
  @override String get title    => 'Egg Benedict';
  @override String get subtitle => 'The brunch classic';
  @override String get description => 'Classic brunch elegance. Toasted muffins, seared ham, and precision-poached eggs draped in a silky, citrus-butter emulsion.';
  @override String get icon     => 'assets/images/recipe_benedict.png';
  @override String get difficulty => 'Advanced';
  @override CookingMethod get cookingMethod => CookingMethod.poached; // Uses same physics
  @override MascotState getMascotState() => MascotState.preparing;

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 288, protein: 11, fatTotal: 22, fatSaturated: 11.5,
    carbs: 14.5, cholesterol: 295, sodium: 580, potassium: 185,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Fresh Eggs', iconType: StepIconType.egg, quantity: '2'),
    PrepItem(name: 'Cold Water', iconType: StepIconType.water, quantity: 'For poaching'),
    PrepItem(name: 'English Muffins', iconType: StepIconType.muffin, quantity: '1'),
    PrepItem(name: 'Canadian Bacon', iconType: StepIconType.bacon, quantity: '2 slices'),
    PrepItem(name: 'Hollandaise', iconType: StepIconType.sauce, quantity: 'Generous pour'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Toaster / Pan', iconType: StepIconType.pan),
    PrepItem(name: 'Poaching Pot', iconType: StepIconType.pot),
    PrepItem(name: 'Saucier Bowl', iconType: StepIconType.bowl),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'benedict_tip_1',
      title: 'Warm Plates!',
      message: 'Benedict cools down fast. Warm your plates in the oven on a low setting for 5 minutes before assembling!',
      triggerStepIndex: 4,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 63.0, label: 'Runny',   hexColor: Color(0xFFFF8C00), viscosity: 0.1),
    YolkState(temperature: 67.0, label: 'Flowing',  hexColor: Color(0xFFFFAA00), viscosity: 0.4),
    YolkState(temperature: 71.0, label: 'Set',      hexColor: Color(0xFFFFD966), viscosity: 0.7),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    const RecipeStep(
      title: 'The Foundation',
      instruction: 'Toast English muffin halves until they are perfectly golden brown',
      actionCommand: 'Toast muffins',
      iconType: StepIconType.heat,
    ),
    const RecipeStep(
      title: 'Core Precision',
      instruction: 'Prepare the poached eggs using the precision Eggy timer',
      actionCommand: 'Poach eggs',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    const RecipeStep(
      title: 'The Meat Sear',
      instruction: 'Lightly sear Canadian bacon or ham in a hot buttered pan',
      actionCommand: 'Sear the bacon',
      iconType: StepIconType.butter,
    ),
    RecipeStep(
      title: 'The Silk Whip',
      instruction: 'Whisk the Hollandaise sauce vigorously until smooth and creamy',
      actionCommand: 'Make Hollandaise',
      iconType: StepIconType.whisk,
      isCookingStep: true,
      customDuration: const Duration(minutes: 2),
      context: DataContext(
        content: 'Thermal Inactivation: Keeping yolks at 60°C for at least 5 minutes ensures the inactivation of potential pathogens (e.g., Salmonella) without compromising the emulsion.',
        metadata: {'Domain': 'Food_Safety', 'Entity': 'Raw_Yolk', 'Property': 'Thermal_Point'},
        lineage: {'dc:creator': 'Hervé This', 'dc:date': '2010', 'dc:source': 'Molecular Gastronomy: Exploring the Science of Flavor'},
        trustScore: 1.0,
        classification: 'Safety',
        policy: 'Safety Guide',
      ),
    ),
    const RecipeStep(
      title: 'Final Assembly',
      instruction: 'Assemble: Muffin, ham, egg, and a generous pour of Hollandaise!',
      actionCommand: 'Assemble & serve',
      iconType: StepIconType.plate,
    ),
  ];
}

class SoySauceEgg extends EggBase {
  SoySauceEgg(super.calculator);

  @override String get id       => 'soy_sauce_01';
  @override String get title    => 'Soy Sauce Egg';
  @override String get subtitle => 'Aromatic Braise';
  @override String get description => 'Deep mahogany eggs braised in an aromatic sweet-soy reduction. A savory explosion of Kecap Manis and ginger!';
  @override String get icon     => 'assets/images/recipe_soy_sauce.png';
  @override String get difficulty => 'Intermediate';
  @override CookingMethod get cookingMethod => CookingMethod.soySauceEgg;
  @override MascotState getMascotState() => MascotState.cooking;

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 178, protein: 13, fatTotal: 11, fatSaturated: 3.3,
    carbs: 8.5, cholesterol: 372, sodium: 850, potassium: 195,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Fresh Egg', iconType: StepIconType.egg, quantity: '1'),
    PrepItem(name: 'Cold Water', iconType: StepIconType.water, quantity: 'For boiling'),
    PrepItem(name: 'Kecap Manis', iconType: StepIconType.sauce, quantity: '2 tbsp'),
    PrepItem(name: 'Aromatics', iconType: StepIconType.salt, quantity: 'Garlic/Ginger'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Boiling Pot', iconType: StepIconType.pot),
    PrepItem(name: 'Small Saucepan', iconType: StepIconType.saucepan),
    PrepItem(name: 'Paring Knife', iconType: StepIconType.knife),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'soy_tip_1',
      title: 'Peel Technique',
      message: 'Crack the shell all over and peel under a thin stream of cold water to keep the delicate whites perfectly smooth!',
      triggerStepIndex: 1,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 61.0, label: 'Sun Side', hexColor: Color(0xFFFF8C00), viscosity: 0.0),
    YolkState(temperature: 64.0, label: 'Jammy',    hexColor: Color(0xFFFFAA00), viscosity: 0.25),
    YolkState(temperature: 70.0, label: 'Standard', hexColor: Color(0xFFFFCC00), viscosity: 0.5),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      title: 'Alpha Boil',
      instruction: 'Prepare a jammy boiled egg using the Eggy timer, then cool in an ice bath',
      actionCommand: 'Boil eggs',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'The first phase requires a precision boil to ensure the yolk remains liquid or jammy before the braising phase.',
        metadata: {'Phase': 'Base_Cook', 'Target': 'Viscosity_Control'},
        lineage: {'dc:creator': 'Eggy Research Lab', 'dc:date': '2026'},
        trustScore: 0.98,
        classification: 'Theory',
        policy: 'Culinary Guide',
      ),
    ),
    const RecipeStep(
      title: 'Aromatic Ignition',
      instruction: 'Sauté minced aromatics in a saucepan over low heat until they smell sweet',
      actionCommand: 'Sauté aromatics',
      iconType: StepIconType.heat,
    ),
    const RecipeStep(
      title: 'The Umami Glaze',
      instruction: 'Stir in the soy glazes and simmer until the sauce thickens slightly',
      actionCommand: 'Build the glaze',
      iconType: StepIconType.water,
    ),
    const RecipeStep(
      title: 'Braised Finish',
      instruction: 'Gently braise the peeled eggs in the glaze until they stained a deep mahogany',
      actionCommand: 'Simmer in glaze',
      iconType: StepIconType.heat,
    ),
  ];
}
