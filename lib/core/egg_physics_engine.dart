import 'dart:math' as math;
import 'constants.dart';
import '../core/interfaces/i_egg_calculator.dart';

/// The PhysicsEngine — Single Responsibility: ONLY handles the math.
/// Implements the real heat-transfer formula for egg doneness.
///
/// Formula: t = (M^(2/3) * c * ρ^(1/3)) / (K * π² * (4π/3)^(2/3))
///              * ln(0.76 * (T_water - T_start) / (T_water - T_yolk))
class EggPhysicsEngine implements EggCalculator {
  /// Maps slider 0.0–1.0 → target yolk temperature in °C (61°C–77°C range)
  @override
  double calculateTargetTemp(double sliderValue) {
    const minTemp = 61.0;
    const maxTemp = 77.0;
    return minTemp + (sliderValue.clamp(0.0, 1.0) * (maxTemp - minTemp));
  }

  /// Full heat-transfer calculation using the Williams Formula
  @override
  Duration calculateCookingTime(
    double targetYolkTemp,
    UserEggPreferences prefs,
  ) {
    final tWater = prefs.boilingPoint;
    final tStart = prefs.startTempCelsius;
    final M      = prefs.massGrams;

    // Safety: prevent log of negative / zero / undefined
    if (tWater <= tStart || tWater <= targetYolkTemp || targetYolkTemp <= tStart) {
      // Return a "maximum safety" duration if boiling point is too low or logic fails
      return const Duration(minutes: 10);
    }

    // Laboratory Scalars from EggConstants (Species-specific)
    final c    = EggConstants.specificHeat; 
    final rho  = EggConstants.speciesDensity[prefs.species] ?? 1.038;
    final K    = EggConstants.speciesConductivity[prefs.species] ?? 0.0054;

    // The Williams Formula:
    // t = (M^(2/3) * c * rho^(1/3)) / (K * pi^2 * (4*pi/3)^(2/3)) 
    //     * ln(0.76 * (tStart - tWater) / (tYolk - tWater))

    final mPow   = math.pow(M, 2 / 3).toDouble();
    final rhoPow = math.pow(rho, 1 / 3).toDouble();
    final piTerm = math.pow(4 * math.pi / 3, 2 / 3).toDouble();
    
    final denom = K * math.pi * math.pi * piTerm;
    final numerator = mPow * c * rhoPow;

    // ln[0.76 * (T_egg - T_water) / (T_yolk - T_water)]
    final logArg = 0.76 * ((tStart - tWater) / (targetYolkTemp - tWater));
    
    // Final safety check for log
    if (logArg <= 0) return const Duration(minutes: 10);

    final tSeconds = (numerator / denom) * math.log(logArg);
    
    // Clamp result between 10 seconds and 1 hour
    final ms = (tSeconds * 1000).round().clamp(10000, 3600000);
    return Duration(milliseconds: ms);
  }

  /// Converts slider value to the nearest named yolk label
  String yolkLabelFromSlider(double sliderValue) {
    if (sliderValue < 0.15) return 'Liquid Gold';
    if (sliderValue < 0.35) return 'Jammy';
    if (sliderValue < 0.55) return 'Custardy';
    if (sliderValue < 0.75) return 'Soft Set';
    return 'Firm';
  }
}
