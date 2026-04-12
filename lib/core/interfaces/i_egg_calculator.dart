import '../constants.dart';

/// Calculates target yolk temperature from a 0.0–1.0 slider value,
/// and cooking time using the real heat-transfer formula.
///
/// Single Responsibility: knows only numbers — no widgets, no colors.
abstract class EggCalculator {
  /// Maps slider value (0.0 = Liquid Gold, 1.0 = Firm) → °C target
  double calculateTargetTemp(double sliderValue);

  /// Full heat-transfer formula → cooking Duration in milliseconds
  Duration calculateCookingTime(double targetYolkTemp, UserEggPreferences prefs);
}

/// Stores all user preferences needed for a calculation.
class UserEggPreferences {
  final EggSize size;
  final EggSpecies species;
  final StartTemp startTemp;

  const UserEggPreferences({
    this.size         = EggSize.large,
    this.species      = EggSpecies.henWhite,
    this.startTemp    = StartTemp.fridge,
  });

  /// Calculates mass based on species and size multiplier
  double get massGrams {
    final baseMass = EggConstants.speciesMasses[species]!;
    final multiplier = EggConstants.sizeMultipliers[size]!;
    return baseMass * multiplier;
  }

  double get startTempCelsius => startTemp == StartTemp.fridge
      ? EggConstants.fridgeTemp
      : EggConstants.roomTemp;

   /// Zero-Noise Physics: Standardized 100°C boiling point.
   /// This ensures maximum precision by focusing on internal thermal kinetics.
   double get boilingPoint => 100.0;
}
