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
  double get initialSliderValue => 0.25;

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
    YolkState(temperature: 61.0, label: 'Liquid Gold', hexColor: EggyColors.vibrantYolk, viscosity: 0.0),
    YolkState(temperature: 64.0, label: 'Jammy',       hexColor: EggyColors.onyx, viscosity: 0.25),
    YolkState(temperature: 69.0, label: 'Custardy',    hexColor: EggyColors.vibrantYolk, viscosity: 0.5),
    YolkState(temperature: 72.0, label: 'Soft Set',    hexColor: EggyColors.onyx,         viscosity: 0.75),
    YolkState(temperature: 77.0, label: 'Firm',        hexColor: EggyColors.onyx,         viscosity: 1.0),
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
        content: 'Heat and protein uncurling: Applying heat agitates the globular egg proteins. They bash into water molecules and each other, breaking the weak bonds that keep them curled. Once uncurled, they form new bonds with other proteins, creating an interconnected protein web that captures water.',
        metadata: {'Domain': 'Thermal_Physics', 'Entity': 'Protein_Lattice', 'Property': 'Denaturation_Web'},
        lineage: {'dc:creator': 'Exploratorium', 'dc:source': 'Science Of Eggs'},
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
  @override bool get hasYolkCustomizer => true;
  @override double get initialSliderValue => 0.5; // Recommended: Creamy

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
    YolkState(temperature: 65.0, label: 'Silky Soft', hexColor: EggyColors.vibrantYolk, viscosity: 0.2),
    YolkState(temperature: 70.0, label: 'Creamy',     hexColor: EggyColors.vibrantYolk, viscosity: 0.5),
    YolkState(temperature: 75.0, label: 'Fluffy Set', hexColor: EggyColors.onyx,         viscosity: 0.8),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      title: 'Emulsion Phase',
      instruction: 'In a small bowl, whisk eggs with salt and cream until uniform and pale yellow',
      actionCommand: 'Whisk eggs well',
      iconType: StepIconType.whisk,
      context: DataContext(
        content: 'Beat \'em: Whisking incorporates air bubbles, unfolding egg proteins. Hydrophilic (water-loving) amino acids stay in the water, while hydrophobic (water-fearing) ones stick into the air. This uncurling creates a network that traps air bubbles, which expand when heated to provide lift.',
        metadata: {'Domain': 'Molecular_Gastronomy', 'Entity': 'Protein_Foam', 'Property': 'Air_Incorporation'},
        lineage: {'dc:creator': 'Exploratorium', 'dc:source': 'Science Of Eggs'},
        trustScore: 0.98,
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
    RecipeStep(
      title: 'Incubation Ritual',
      instruction: 'Start the Eggy timer and swirl the eggs every 15 seconds to ensure even thermal penetration.',
      actionCommand: 'Cook & swirl',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'The 69°C threshold targets the partial denaturation of ovalbumin, creating a non-Newtonian fluid state where the omelette remains semi-liquid yet structurally intact enough to drape.',
        metadata: {'Domain': 'Thermal_Physics', 'Entity': 'Phase_Transition', 'Property': 'Ovalbumin_Denaturation'},
        lineage: {'dc:creator': 'Kichi Kichi Research', 'dc:date': '2026'},
        trustScore: 0.98,
        classification: 'Theory',
        policy: 'Culinary Guide',
      ),
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
    YolkState(temperature: 63.0, label: 'Runny',   hexColor: EggyColors.vibrantYolk, viscosity: 0.1),
    YolkState(temperature: 67.0, label: 'Flowing',  hexColor: EggyColors.vibrantYolk, viscosity: 0.4),
    YolkState(temperature: 71.0, label: 'Set',      hexColor: EggyColors.onyx,         viscosity: 0.7),
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
  @override bool get hasYolkCustomizer => true;
  @override double get initialSliderValue => 0.5; // Recommended: Golden

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
    YolkState(temperature: 70.0, label: 'Tender',    hexColor: EggyColors.vibrantYolk, viscosity: 0.3),
    YolkState(temperature: 75.0, label: 'Golden',    hexColor: EggyColors.vibrantYolk, viscosity: 0.6),
    YolkState(temperature: 80.0, label: 'Well Done', hexColor: EggyColors.onyx,         viscosity: 0.9),
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
  @override double get initialSliderValue => 0.0; // Recommended: Sunny Side

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
    YolkState(temperature: 63.0, label: 'Sunny Side',  hexColor: EggyColors.vibrantYolk, viscosity: 0.0),
    YolkState(temperature: 67.0, label: 'Over Easy',   hexColor: EggyColors.vibrantYolk, viscosity: 0.3),
    YolkState(temperature: 71.0, label: 'Over Medium', hexColor: EggyColors.vibrantYolk, viscosity: 0.6),
    YolkState(temperature: 77.0, label: 'Over Hard',   hexColor: EggyColors.onyx,         viscosity: 1.0),
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
      context: DataContext(
        content: 'As heat bashes the proteins, they uncurl and bond with each other rather than themselves. This communal network captures water, but leaves it rubbery if over-bonded.',
        metadata: {'Domain': 'Thermal_Physics', 'Entity': 'Coagulation', 'Property': 'Protein_Network'},
        lineage: {'dc:creator': 'Exploratorium', 'dc:source': 'Science Of Eggs'},
        trustScore: 0.97,
        classification: 'Theory',
        policy: 'Culinary Insight',
      ),
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
  @override String get subtitle => 'The Brunch Classic';
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
    YolkState(temperature: 63.0, label: 'Runny',   hexColor: EggyColors.vibrantYolk, viscosity: 0.1),
    YolkState(temperature: 67.0, label: 'Flowing',  hexColor: EggyColors.vibrantYolk, viscosity: 0.4),
    YolkState(temperature: 71.0, label: 'Set',      hexColor: EggyColors.onyx,         viscosity: 0.7),
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
        content: 'Mix \'em: Hollandaise is an emulsion stabilized by Lecithin. This phospholipid has a water-loving "head" and a water-fearing "tail." The tail buries in fat droplets while the head sticks into the water, preventing droplets from coalescing.',
        metadata: {'Domain': 'Fluid_Dynamics', 'Entity': 'Emulsion', 'Property': 'Lecithin_Structure'},
        lineage: {'dc:creator': 'Exploratorium', 'dc:source': 'Science Of Eggs'},
        trustScore: 1.0,
        classification: 'Theory',
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
  @override MascotState getMascotState() => MascotState.preparing;
  @override double get initialSliderValue => 0.5; // Recommended: Jammy

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
    YolkState(temperature: 61.0, label: 'Sun Side', hexColor: EggyColors.vibrantYolk, viscosity: 0.0),
    YolkState(temperature: 64.0, label: 'Jammy',    hexColor: EggyColors.vibrantYolk, viscosity: 0.25),
    YolkState(temperature: 70.0, label: 'Standard', hexColor: EggyColors.onyx,         viscosity: 0.5),
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

class Omurice extends EggBase {
  Omurice(super.calculator);

  @override String get id       => 'omurice_01';
  @override String get title    => 'Omurice';
  @override String get subtitle => 'Tokyo Street Classic';
  @override String get description => 'A masterclass in texture. Savory ketchup fried rice topped with a soft-scrambled omelette that splits open to reveal a creamy, semi-liquid core.';
  @override String get icon     => 'assets/images/recipe_omurice.png';
  @override String get difficulty => 'Advanced';
  @override CookingMethod get cookingMethod => CookingMethod.omurice;
  @override MascotState getMascotState() => MascotState.preparing;
  @override bool get hasYolkCustomizer => true;
  @override double get initialSliderValue => 0.5; // Recommended: Creamy

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 170, protein: 9, fatTotal: 8, fatSaturated: 3.2,
    carbs: 22.0, cholesterol: 180, sodium: 450, potassium: 160,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Large Eggs', iconType: StepIconType.egg, quantity: '3'),
    PrepItem(name: 'Pre-cooked Rice', iconType: StepIconType.muffin, quantity: '1 bowl'),
    PrepItem(name: 'Chicken/Onion', iconType: StepIconType.bacon, quantity: 'Diced'),
    PrepItem(name: 'Ketchup', iconType: StepIconType.sauce, quantity: 'For rice & topping'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Wok / Heavy Pan', iconType: StepIconType.pan),
    PrepItem(name: 'Small Non-stick', iconType: StepIconType.pan),
    PrepItem(name: 'Silicone Spatula', iconType: StepIconType.spatula),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'omurice_tip_1',
      title: 'High Heat Rice',
      message: 'Fry the rice on high heat first. The ketchup should caramelize slightly (Maillard reaction) before you add the eggs on top!',
      triggerStepIndex: 1,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 66.0, label: 'Running', hexColor: EggyColors.vibrantYolk, viscosity: 0.1),
    YolkState(temperature: 69.0, label: 'Creamy',  hexColor: EggyColors.vibrantYolk, viscosity: 0.4),
    YolkState(temperature: 72.0, label: 'Set',     hexColor: EggyColors.onyx,         viscosity: 0.7),
  ];

  @override
  List<RecipeStep> getStepInstructions() => const [
    RecipeStep(
      title: 'Base Architecture',
      instruction: 'Sauté chicken and onions, then stir-fry rice with ketchup until every grain is coated and savory.',
      actionCommand: 'Fry the rice',
      iconType: StepIconType.heat,
    ),
    RecipeStep(
      title: 'The Omelette Matrix',
      instruction: 'Whisk eggs with a splash of cream. Pour into a hot non-stick pan and scramble rapidly to create small curds.',
      actionCommand: 'Scramble soft',
      iconType: StepIconType.whisk,
    ),
    RecipeStep(
      title: 'Core Encapsulation',
      instruction: 'Start the timer. Shape the omelette into a cigar form while the center remains semi-liquid.',
      actionCommand: 'Shape omelette',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      title: 'Culinary Reveal',
      instruction: 'Place the omelette over the rice, slit the top with a knife, and watch it drape over the base.',
      actionCommand: 'Slit and serve',
      iconType: StepIconType.fold,
    ),
  ];
}

class Fuyunghai extends EggBase {
  Fuyunghai(super.calculator);

  @override String get id       => 'fuyunghai_01';
  @override String get title    => 'Fu Yong Hai';
  @override String get subtitle => 'Puffy & Crispy';
  @override String get description => 'A Chinese-Indonesian celebratory omelette. Crispy, golden-furred edges meet a thick, fluffy interior packed with vegetables and shrimp.';
  @override String get icon     => 'assets/images/recipe_fuyunghai.png';
  @override String get difficulty => 'Intermediate';
  @override CookingMethod get cookingMethod => CookingMethod.fuyunghai;
  @override MascotState getMascotState() => MascotState.cooking;
  @override bool get hasYolkCustomizer => true;
  @override double get initialSliderValue => 1.0; // Recommended: Firm

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 250, protein: 11, fatTotal: 18, fatSaturated: 4.5,
    carbs: 12.0, cholesterol: 220, sodium: 550, potassium: 210,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Large Eggs', iconType: StepIconType.egg, quantity: '4'),
    PrepItem(name: 'Shredded Veg', iconType: StepIconType.muffin, quantity: 'Cabbage/Carrot'),
    PrepItem(name: 'Shrimp/Crab', iconType: StepIconType.bacon, quantity: '100g'),
    PrepItem(name: 'Sweet & Sour', iconType: StepIconType.sauce, quantity: 'Tomato based'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Deep Wok', iconType: StepIconType.pan),
    PrepItem(name: 'Mixing Bowl', iconType: StepIconType.bowl),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'fuyunghai_tip_1',
      title: 'The Flour Secret',
      message: 'Add 1-2 tbsp of flour to the egg mix. It helps structural integrity and creates that signature thick, puffy height!',
      triggerStepIndex: 0,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 75.0, label: 'Fluffy',   hexColor: EggyColors.vibrantYolk, viscosity: 0.6),
    YolkState(temperature: 82.0, label: 'Firm',     hexColor: EggyColors.onyx,         viscosity: 1.0),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      title: 'Vegetable Bonding',
      instruction: 'Mix the shredded vegetables and shrimp into the beaten eggs with a touch of flour and salt.',
      actionCommand: 'Mix ingredients',
      iconType: StepIconType.bowl,
    ),
    RecipeStep(
      title: 'The Deep Fry',
      instruction: 'Pour the mix into 2 inches of hot oil. The egg will puff up immediately. Start the Eggy timer.',
      actionCommand: 'Fry until puffy',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'Rapid high-heat immersion triggers an instantaneous expansion of trapped air and steam within the flour-protein matrix, resulting in a stable, aerated foam with high structural loft.',
        metadata: {'Domain': 'Fluid_Dynamics', 'Entity': 'Expansion_Kinetics', 'Property': 'Matrix_Aeration'},
        lineage: {'dc:creator': 'Institute of Culinary Physics', 'dc:date': '2026'},
        trustScore: 0.97,
        classification: 'Theory',
        policy: 'Matrix Guide',
      ),
    ),
    RecipeStep(
      title: 'Sauce Glaze',
      instruction: 'While the egg drains, warm the tomato-based pea sauce until it bubbles.',
      actionCommand: 'Heat the sauce',
      iconType: StepIconType.saucepan,
    ),
    RecipeStep(
      title: 'Umami Cascade',
      instruction: 'Plate the giant golden omelette and pour the sweet & sour sauce generously over the top.',
      actionCommand: 'Pour sauce & serve',
      iconType: StepIconType.plate,
    ),
  ];
}

class EggTofu extends EggBase {
  EggTofu(super.calculator);

  @override String get id       => 'tahutelor_01';
  @override String get title    => 'Egg Tofu';
  @override String get subtitle => 'Tahu Telor Classic';
  @override String get description => 'A practical, savory masterpiece originating from East Java, known locally as Tahu Telor. Cubed tofu bonded by a golden egg pancake, served with a rich Petis peanut sauce and fresh bean sprouts.';
  @override String get icon     => 'assets/images/recipe_egg_tofu.png';
  @override String get difficulty => 'Easy';
  @override CookingMethod get cookingMethod => CookingMethod.eggTofu;
  @override MascotState getMascotState() => MascotState.success;
  @override bool get hasYolkCustomizer => true;
  @override double get initialSliderValue => 1.0; // Recommended: Firm

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 328, protein: 12.6, fatTotal: 19.9, fatSaturated: 5.2,
    carbs: 24.6, cholesterol: 185, sodium: 410, potassium: 310,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Large Eggs', iconType: StepIconType.egg, quantity: '2-3'),
    PrepItem(name: 'White Tofu', iconType: StepIconType.muffin, quantity: 'Cubic Diced'),
    PrepItem(name: 'Petis Sauce', iconType: StepIconType.sauce, quantity: 'Peanut/Shrimp base'),
    PrepItem(name: 'Bean Sprouts', iconType: StepIconType.water, quantity: 'Fresh garnish'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Frying Pan', iconType: StepIconType.pan),
    PrepItem(name: 'Paring Knife', iconType: StepIconType.knife),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'tahutelor_tip_1',
      title: 'Tofu Crisp',
      message: 'Dry your tofu cubes with a paper towel before mixing with egg. This ensures the tofu stays firm inside while the egg gets crispy!',
      triggerStepIndex: 0,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 72.0, label: 'Tender Set', hexColor: EggyColors.vibrantYolk, viscosity: 0.7),
    YolkState(temperature: 78.0, label: 'Firm Set',   hexColor: EggyColors.onyx,         viscosity: 1.0),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      title: 'Cubic Integration',
      instruction: 'Cut tofu into small cubes and whisk into the seasoned egg mixture.',
      actionCommand: 'Dice & mix',
      iconType: StepIconType.knife,
    ),
    RecipeStep(
      title: 'The Golden Bond',
      instruction: 'Pour into a hot pan. Fry until the bottom is deeply golden, then flip. Start the timer.',
      actionCommand: 'Fry the cake',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'Soy protein (glycinin) and egg protein (conalbumin) form a composite cross-linked network, creating a superior structural bond that prevents the tofu cubes from separating during thermal agitation.',
        metadata: {'Domain': 'Molecular_Gastronomy', 'Entity': 'Protein_Bonding', 'Property': 'Glycinin_Crosslink'},
        lineage: {'dc:creator': 'East Java Culinary Lab', 'dc:date': '2026'},
        trustScore: 0.96,
        classification: 'Theory',
        policy: 'Bonding Guide',
      ),
    ),
    RecipeStep(
      title: 'Structural Garnish',
      instruction: 'Assemble the tall tofu-egg omelette with a handful of fresh bean sprouts and celery.',
      actionCommand: 'Top with garnish',
      iconType: StepIconType.water,
    ),
    RecipeStep(
      title: 'Petis Saturation',
      instruction: 'Drizzle the specialty black peanut-petis sauce over the top before serving hot.',
      actionCommand: 'Add sauce & serve',
      iconType: StepIconType.sauce,
    ),
  ];
}

class OnsenTamago extends EggBase {
  OnsenTamago(super.calculator);

  @override String get id       => 'onsentamago_01';
  @override String get title    => 'Onsen Tamago';
  @override String get subtitle => 'Hot Spring Silk';
  @override String get description => 'Thermal perfection. Slow-cooked at low temperature to achieve a delicate, custard-like white and a rich, creamy yolk that flows like thick honey.';
  @override String get icon     => 'assets/images/recipe_onsentamago.png';
  @override String get difficulty => 'Intermediate';
  @override CookingMethod get cookingMethod => CookingMethod.onsenTamago;
  @override MascotState getMascotState() => MascotState.preparing;
  @override bool get hasYolkCustomizer => true;
  @override double get initialSliderValue => 0.5; // Recommended: Creamy Gel

  @override
  NutritionFacts getBaseNutrition() => const NutritionFacts(
    calories: 155, protein: 13, fatTotal: 11, fatSaturated: 3.3,
    carbs: 1.1, cholesterol: 372, sodium: 124, potassium: 126,
  );

  @override
  List<PrepItem> get ingredients => const [
    PrepItem(name: 'Fresh Egg', iconType: StepIconType.egg, quantity: '1-4'),
    PrepItem(name: 'Cold Water', iconType: StepIconType.water, quantity: '200ml'),
    PrepItem(name: 'Dashi Broth', iconType: StepIconType.sauce, quantity: 'For serving'),
  ];

  @override
  List<PrepItem> get tools => const [
    PrepItem(name: 'Insulated Pot', iconType: StepIconType.pot),
    PrepItem(name: 'Kettle', iconType: StepIconType.timerGo),
  ];

  @override
  List<ProTip> get proTips => const [
    ProTip(
      id: 'onsen_tip_1',
      title: 'Thermal Buffer',
      message: 'Adding the cold water to the boiling water is CRITICAL—it drops the temp to ~80°C, which is the perfect starting point for slow steeping!',
      triggerStepIndex: 1,
    ),
  ];

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 63.5, label: 'Silk Custard', hexColor: EggyColors.vibrantYolk, viscosity: 0.3),
    YolkState(temperature: 65.5, label: 'Creamy Gel',   hexColor: EggyColors.vibrantYolk, viscosity: 0.5),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    const RecipeStep(
      title: 'Boiling Origin',
      instruction: 'Bring 1 liter of water to a rolling boil in a pot with a lid.',
      actionCommand: 'Boil water',
      iconType: StepIconType.heat,
    ),
    const RecipeStep(
      title: 'Thermal Calibration',
      instruction: 'Turn off heat and add 200ml of room-temperature water to dial in the steep temperature.',
      actionCommand: 'Add cold water',
      iconType: StepIconType.water,
    ),
    RecipeStep(
      title: 'Molecular Incubation',
      instruction: 'Gently lower the eggs, cover the lid, and let the residual heat work its magic. Start the timer.',
      actionCommand: 'Slow steep',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      customDuration: const Duration(minutes: 17),
      context: DataContext(
        content: 'Low-temperature denaturation of ovomucin and vitellin takes significantly longer but prevents the "rubbery" texture of rapid high-heat coagulation.',
        metadata: {'Domain': 'Thermal_Equilibrium', 'Target': '65°C'},
        lineage: {'dc:creator': 'Tsuyoshi Mizutani', 'dc:date': '2015'},
        trustScore: 1.0,
        classification: 'Theory',
        policy: 'Incubation Guide',
      ),
    ),
    const RecipeStep(
      title: 'The Disclosure',
      instruction: 'Crack the shell gently over a small dish. The egg should slide out as a silky, uniform custard.',
      actionCommand: 'Crack into bowl',
      iconType: StepIconType.plate,
    ),
  ];
}
