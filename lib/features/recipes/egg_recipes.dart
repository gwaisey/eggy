import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/interfaces/i_egg_recipe.dart';
import '../../core/interfaces/i_egg_calculator.dart';
import '../../core/models/recipe_step.dart';
import '../../core/models/step_icon_type.dart';

/// Abstract base with shared logic. Concrete recipes extend this.
abstract class EggBase implements IEggRecipe {
  final EggCalculator _calculator;

  EggBase(this._calculator);

  @override
  bool get hasYolkCustomizer => true;

  @override
  Duration calculateCookingTime(UserEggPreferences prefs, double sliderValue) {
    final targetTemp = _calculator.calculateTargetTemp(sliderValue);
    return _calculator.calculateCookingTime(targetTemp, prefs);
  }
}

// ── Concrete Recipes ──────────────────────────────────────────────────────────

class BoiledEgg extends EggBase {
  BoiledEgg(super.calculator);

  @override String get id       => 'boiled_01';
  @override String get title    => 'Boiled Egg';
  @override String get subtitle => 'Classic';
  @override String get description => 'The absolute culinary baseline. Simmered in water to achieve anything from a runny liquid gold to a firm, molecularly stable matrix.';
  @override String get icon     => 'assets/images/recipe_boiled.png';
  @override CookingMethod get cookingMethod => CookingMethod.boiled;
  @override MascotState getMascotState() => MascotState.cooking;

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
      instruction: 'Place your eggs gently in the pot',
      iconType: StepIconType.egg,
    ),
    const RecipeStep(
      instruction: 'Fill with cold water until the eggs are fully covered',
      iconType: StepIconType.water,
    ),
    RecipeStep(
      instruction: 'Place pot on heat and start the Eggy timer',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'The Eggy timer uses the Williams Formula to predict coagulation times based on thermal diffusivity and start temperature.',
        metadata: {'Domain': 'Thermal_Physics', 'Entity': 'Coagulation_Time', 'Property': 'Williams_Equation'},
        lineage: {'dc:creator': 'Charles D.H. Williams', 'dc:date': '1992', 'dc:source': 'University of Exeter'},
        trustScore: 0.99,
        classification: 'Scientific',
        policy: 'Standard_Protocol',
      ),
    ),
    const RecipeStep(
      instruction: 'Transfer immediately to an ice bath to cool down',
      iconType: StepIconType.iceBath,
    ),
  ];
}

class ScrambledEgg extends EggBase {
  ScrambledEgg(super.calculator);

  @override String get id       => 'scrambled_01';
  @override String get title    => 'Scrambled Egg';
  @override String get subtitle => 'Creamy';
  @override String get description => 'A gentle mechanical fusion of eggs and lipids, where slow agitation creates soft, interconnected protein folds of unmatched silkiness.';
  @override String get icon     => 'assets/images/recipe_scrambled.png';
  @override CookingMethod get cookingMethod => CookingMethod.scrambled;
  @override MascotState getMascotState() => MascotState.preparing;
  @override bool get hasYolkCustomizer => false;

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 65.0, label: 'Silky Soft', hexColor: Color(0xFFFFCC44), viscosity: 0.2),
    YolkState(temperature: 70.0, label: 'Creamy',     hexColor: Color(0xFFFFD966), viscosity: 0.5),
    YolkState(temperature: 75.0, label: 'Fluffy Set', hexColor: Color(0xFFE8A800), viscosity: 0.8),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      instruction: 'Whisk eggs with a pinch of salt, a splash of cream, and a dash of whole milk',
      iconType: StepIconType.whisk,
      context: DataContext(
        content: 'Mechanical agitation denatures proteins; whisking duck eggs introduces air into a higher-lipid environment, creating a sturdier foam than hen eggs.',
        metadata: {'Domain': 'Molecular_Gastronomy', 'Entity': 'Protein_Foam', 'Property': 'Species_Agitation'},
        lineage: {'dc:creator': 'FAO', 'dc:date': '2026', 'dc:source': 'Circular Economy Report'},
        trustScore: 0.95,
        classification: 'Scientific',
        policy: 'Molecular_Profile',
      ),
    ),
    const RecipeStep(
      instruction: 'Melt butter in a stainless steel pan until it foams',
      iconType: StepIconType.butter,
    ),
    const RecipeStep(
      instruction: 'Pour in eggs and start the timer — fold gently every 20 seconds',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    const RecipeStep(
      instruction: 'Pull off heat just before they look set — they finish on the plate',
      iconType: StepIconType.plate,
    ),
  ];
}

class PoachedEgg extends EggBase {
  PoachedEgg(super.calculator);

  @override String get id       => 'poached_01';
  @override String get title    => 'Poached Egg';
  @override String get subtitle => 'Delicate';
  @override String get description => 'The pinnacle of egg delicacy. Whites are precision-set in a simmering water bath, protecting a rich, untreated yolk within a silky nest.';
  @override String get icon     => 'assets/images/recipe_poached.png';
  @override CookingMethod get cookingMethod => CookingMethod.poached;
  @override MascotState getMascotState() => MascotState.cooking;

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 63.0, label: 'Runny',   hexColor: Color(0xFFFF8C00), viscosity: 0.1),
    YolkState(temperature: 67.0, label: 'Flowing',  hexColor: Color(0xFFFFAA00), viscosity: 0.4),
    YolkState(temperature: 71.0, label: 'Set',      hexColor: Color(0xFFFFD966), viscosity: 0.7),
  ];

  @override
  List<RecipeStep> getStepInstructions() => const [
    RecipeStep(
      instruction: 'Fill a wide pan with 3 inches of water — bring to a gentle simmer',
      iconType: StepIconType.water,
    ),
    RecipeStep(
      instruction: 'Add a splash of white vinegar to help the white hold together',
      iconType: StepIconType.heat,
    ),
    RecipeStep(
      instruction: 'Crack egg into a small bowl first, then slide in gently',
      iconType: StepIconType.crack,
    ),
    RecipeStep(
      instruction: 'Start the timer — let it float peacefully, no stirring',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      instruction: 'Lift out with a slotted spoon and rest on a paper towel',
      iconType: StepIconType.plate,
    ),
  ];
}

class Omelette extends EggBase {
  Omelette(super.calculator);

  @override String get id       => 'omelette_01';
  @override String get title    => 'Omelette';
  @override String get subtitle => 'Golden & pillowy';
  @override String get description => 'A structured canvas of liquid gold, folded with precision to trap steam and maintain a tender, pillowy interior as it sets.';
  @override String get icon     => 'assets/images/recipe_omelette.png';
  @override CookingMethod get cookingMethod => CookingMethod.omelette;
  @override MascotState getMascotState() => MascotState.preparing;
  @override bool get hasYolkCustomizer => false;

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 70.0, label: 'Tender',    hexColor: Color(0xFFFFD700), viscosity: 0.3),
    YolkState(temperature: 75.0, label: 'Golden',    hexColor: Color(0xFFE8A800), viscosity: 0.6),
    YolkState(temperature: 80.0, label: 'Well Done', hexColor: Color(0xFFC8860A), viscosity: 0.9),
  ];

  @override
  List<RecipeStep> getStepInstructions() => const [
    RecipeStep(
      instruction: 'Whisk 2 eggs with a pinch of salt until smooth',
      iconType: StepIconType.whisk,
    ),
    RecipeStep(
      instruction: 'Melt butter in a stainless pan until it just begins to foam',
      iconType: StepIconType.butter,
    ),
    RecipeStep(
      instruction: 'Pour in eggs and start the timer — swirl the pan gently',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      instruction: 'Fold the omelette in half and slide onto a warm plate',
      iconType: StepIconType.fold,
    ),
  ];
}

class FriedEgg extends EggBase {
  FriedEgg(super.calculator);

  @override String get id       => 'fried_01';
  @override String get title    => 'Fried Egg';
  @override String get subtitle => 'Crispy edges';
  @override String get description => 'A high-heat Maillard reaction creating caramelized, crispy edges while preserving the glossy, intact sun-side yolk core.';
  @override String get icon     => 'assets/images/recipe_fried.png';
  @override CookingMethod get cookingMethod => CookingMethod.fried;
  @override MascotState getMascotState() => MascotState.cooking;

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
      instruction: 'Heat a stainless steel pan over medium-low heat',
      iconType: StepIconType.heat,
    ),
    RecipeStep(
      instruction: 'Add butter and wait for the shimmer — not the smoke',
      iconType: StepIconType.butter,
    ),
    RecipeStep(
      instruction: 'Crack egg gently into the pan — start the Eggy timer',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    RecipeStep(
      instruction: 'Cover with a lid for the last 30 seconds for a steamed finish',
      iconType: StepIconType.crack,
    ),
    RecipeStep(
      instruction: 'Slide onto a plate — golden edges, glossy yolk',
      iconType: StepIconType.plate,
    ),
  ];
}

class EggsBenedict extends EggBase {
  EggsBenedict(super.calculator);

  @override String get id       => 'benedict_01';
  @override String get title    => 'Egg Benedict';
  @override String get subtitle => 'The brunch classic';
  @override String get description => 'The ultimate brunch harmony: precision-poached eggs set atop seared ham and toasted muffins, draped in a rich citrus-butter emulsion.';
  @override String get icon     => 'assets/images/recipe_benedict.png';
  @override CookingMethod get cookingMethod => CookingMethod.poached; // Uses same physics
  @override MascotState getMascotState() => MascotState.preparing;

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 63.0, label: 'Runny',   hexColor: Color(0xFFFF8C00), viscosity: 0.1),
    YolkState(temperature: 67.0, label: 'Flowing',  hexColor: Color(0xFFFFAA00), viscosity: 0.4),
    YolkState(temperature: 71.0, label: 'Set',      hexColor: Color(0xFFFFD966), viscosity: 0.7),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    const RecipeStep(
      instruction: 'Toast English muffin halves until they are perfectly golden brown',
      iconType: StepIconType.heat,
    ),
    const RecipeStep(
      instruction: 'Prepare the poached eggs using the precision Eggy timer',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
    ),
    const RecipeStep(
      instruction: 'Lightly sear Canadian bacon or ham in a hot buttered pan',
      iconType: StepIconType.butter,
    ),
    RecipeStep(
      instruction: 'Whisk the Hollandaise sauce vigorously until smooth and creamy',
      iconType: StepIconType.whisk,
      isCookingStep: true,
      customDuration: const Duration(minutes: 2),
      context: DataContext(
        content: 'Thermal Inactivation: Keeping yolks at 60°C for at least 5 minutes ensures the inactivation of potential pathogens (e.g., Salmonella) without compromising the emulsion.',
        metadata: {'Domain': 'Food_Safety', 'Entity': 'Raw_Yolk', 'Property': 'Thermal_Point'},
        lineage: {'dc:creator': 'Hervé This', 'dc:date': '2010', 'dc:source': 'Molecular Gastronomy: Exploring the Science of Flavor'},
        trustScore: 1.0,
        classification: 'Safety',
        policy: 'Safety_Override_Protocol',
      ),
    ),
    const RecipeStep(
      instruction: 'Assemble: Muffin, ham, egg, and a generous pour of Hollandaise!',
      iconType: StepIconType.plate,
    ),
  ];
}

class SoySauceEgg extends EggBase {
  SoySauceEgg(super.calculator);

  @override String get id       => 'soy_sauce_01';
  @override String get title    => 'Soy Sauce Egg';
  @override String get subtitle => 'Aromatic Braise';
  @override String get description => 'specifically referring to eggs braised in an aromatic sweet soy sauce (Kecap Manis) reduction.';
  @override String get icon     => 'assets/images/recipe_soy_sauce.png';
  @override CookingMethod get cookingMethod => CookingMethod.soySauceEgg;
  @override MascotState getMascotState() => MascotState.cooking;

  @override
  List<YolkState> get yolkOptions => const [
    YolkState(temperature: 61.0, label: 'Sun Side', hexColor: Color(0xFFFF8C00), viscosity: 0.0),
    YolkState(temperature: 64.0, label: 'Jammy',    hexColor: Color(0xFFFFAA00), viscosity: 0.25),
    YolkState(temperature: 70.0, label: 'Standard', hexColor: Color(0xFFFFCC00), viscosity: 0.5),
  ];

  @override
  List<RecipeStep> getStepInstructions() => [
    RecipeStep(
      instruction: 'Boil your egg using the Eggy timer (Jammy is best!)',
      iconType: StepIconType.timerGo,
      isCookingStep: true,
      context: DataContext(
        content: 'The first phase requires a precision boil to ensure the yolk remains liquid or jammy before the braising phase.',
        metadata: {'Phase': 'Base_Cook', 'Target': 'Viscosity_Control'},
        lineage: {'dc:creator': 'Eggy Research Lab', 'dc:date': '2026'},
        trustScore: 0.98,
        classification: 'Scientific',
        policy: 'Culinary_Safety_Protocol',
      ),
    ),
    const RecipeStep(
      instruction: 'Sauté minced garlic, shallots, and ginger until fragrant',
      iconType: StepIconType.heat,
    ),
    const RecipeStep(
      instruction: 'Add Kecap Manis, light soy sauce, and a splash of water',
      iconType: StepIconType.water,
    ),
    const RecipeStep(
      instruction: 'Simmer peeled eggs in the glaze until mahogany brown',
      iconType: StepIconType.heat,
    ),
  ];
}
