import 'step_icon_type.dart';

/// Represents an item (ingredient or tool) needed for the Mission Briefing.
class PrepItem {
  final String name;
  final StepIconType iconType;
  final String? quantity;

  const PrepItem({
    required this.name,
    required this.iconType,
    this.quantity,
  });
}

/// A "Strategic Pep-Talk" from Professor Eggy.
class ProTip {
  final String id;
  final String title;
  final String message;
  final int triggerStepIndex; // The step at which this tip should appear

  const ProTip({
    required this.id,
    required this.title,
    required this.message,
    required this.triggerStepIndex,
  });
}

/// Detailed nutrition data to support fitness and diet tracking.
class NutritionFacts {
  final double calories;     // kcal
  final double protein;      // g
  final double fatTotal;     // g
  final double fatSaturated; // g
  final double carbs;        // g
  final double cholesterol;   // mg
  final double sodium;        // mg
  final double potassium;     // mg

  const NutritionFacts({
    this.calories = 0,
    this.protein = 0,
    this.fatTotal = 0,
    this.fatSaturated = 0,
    this.carbs = 0,
    this.cholesterol = 0,
    this.sodium = 0,
    this.potassium = 0,
  });

  /// Scales nutrition based on egg mass (species/size) and quantity.
  /// Also accounts for recipe baseline (e.g. Benedict has sauce).
  NutritionFacts scale({
    required double massGrams,
    required int quantity,
    double massScalingFactor = 1.0, // Used for ingredients like flour/sauce
  }) {
    // Standard scaling: (Base Value / 100g) * (Total Mass * scaling)
    double scale(double base) => (base / 100) * (massGrams * quantity * massScalingFactor);
    
    return NutritionFacts(
      calories:     scale(calories),
      protein:      scale(protein),
      fatTotal:     scale(fatTotal),
      fatSaturated: scale(fatSaturated),
      carbs:        scale(carbs),
      cholesterol:  scale(cholesterol),
      sodium:       scale(sodium),
      potassium:    scale(potassium),
    );
  }

  String get dietInsight {
    if (protein > 20) return "💪 Protein Powerhouse: Ideal for muscle recovery.";
    if (fatTotal < 10 && calories < 200) return "✨ Lean & Light: Perfect for a low-calorie diet.";
    if (fatTotal > 30) return "🍳 High Energy: Packed with healthy culinary fats.";
    if (cholesterol > 400) return "🥚 Rich in Choline: Great for brain health.";
    return "🥗 Balanced Mastery: Traditional nutritional profile.";
  }
}
