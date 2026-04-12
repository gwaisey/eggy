import 'package:flutter/material.dart';

// ── Yolk Doneness States ─────────────────────────────────────────────────────
class YolkState {
  final double temperature;
  final String label;
  final Color hexColor;
  final double viscosity; // 0.0 = liquid, 1.0 = fully set

  const YolkState({
    required this.temperature,
    required this.label,
    required this.hexColor,
    required this.viscosity,
  });
}

/// The five canonical yolk states — the "Golden Rules" of the PhysicsEngine.
const List<YolkState> kYolkStates = [
  YolkState(temperature: 61.0, label: 'Liquid Gold', hexColor: Color(0xFFFF8C00), viscosity: 0.0),
  YolkState(temperature: 63.5, label: 'Jammy',       hexColor: Color(0xFFFFAA00), viscosity: 0.25),
  YolkState(temperature: 69.0, label: 'Custardy',    hexColor: Color(0xFFFFCC00), viscosity: 0.5),
  YolkState(temperature: 73.0, label: 'Soft Set',    hexColor: Color(0xFFFFD966), viscosity: 0.75),
  YolkState(temperature: 77.0, label: 'Firm',        hexColor: Color(0xFFC8860A), viscosity: 1.0),
];

// ── Color Palette ─────────────────────────────────────────────────────────────
class EggyColors {
  static const alabaster     = Color(0xFFFBFBF8);
  static const champagne     = Color(0xFFD4AF37);
  static const onyx          = Color(0xFF1A1A1A);
  static const ivory         = Color(0xFFF9F6EE);
  static const slate         = Color(0xFF334756); // For Professor Mode
  static const glassWhite    = Color(0xCCFBFBF8);
  static const shadowSoft    = Color(0x0A1A1A1A);
  static const liquidGold    = Color(0xFFC5A059);
  static const bronze        = Color(0xFF8C7851);
  
  // Backwards compatibility for now
  static const warmWhite     = alabaster;
  static const butterYellow  = champagne;
  static const softCharcoal  = onyx;
  static const creamFoam     = ivory;

  // Restored for Legacy/Backwards compatibility
  static const blushPink     = Color(0xFFF1E6E6); // A very soft, muted champagne-pink
  static const firmYolk      = bronze;

  // ── New Sleek Kawaii Palette ────────────────────────────────────────────────
  static const tastyTeal     = Color(0xFF00ADB5); // Punchy yet premium teal
  static const eggyPink      = Color(0xFFFFB7B7); // Soft, sophisticated pink
  static const vibrantYolk   = Color(0xFFFFCC33); // High-saturation glowing yolk
  static const accentGold    = Color(0xFFFFE082); // For highlights
}

// ── Egg Physical Constants ────────────────────────────────────────────────────
class EggConstants {
  /// Specific heat of a whole egg (J/g·K)
  static const double specificHeat = 3.7;

  /// Density of a whole egg (g/cm³) by species
  static const Map<EggSpecies, double> speciesDensity = {
    EggSpecies.quail:    1.038,
    EggSpecies.henWhite: 1.038,
    EggSpecies.henBrown: 1.038,
    EggSpecies.duck:     1.042,
    EggSpecies.goose:    1.045,
    EggSpecies.emu:      1.080,
    EggSpecies.ostrich:  1.140,
  };

  /// Thermal conductivity of egg (W/cm·K) by species
  static const Map<EggSpecies, double> speciesConductivity = {
    EggSpecies.quail:    0.0054,
    EggSpecies.henWhite: 0.0054,
    EggSpecies.henBrown: 0.0054,
    EggSpecies.duck:     0.0051,
    EggSpecies.goose:    0.0050,
    EggSpecies.emu:      0.0048, // Thicker shells
    EggSpecies.ostrich:  0.0045, // Extreme thermal barrier
  };

  /// Fridge starting temperature (°C)
  static const double fridgeTemp = 4.0;

  /// Room starting temperature (°C)
  static const double roomTemp = 21.0;

  /// Boiling point at sea level (°C)
  static const double seaLevelBoilingPoint = 100.0;

  /// Egg masses by species (grams) - midpoint of typical ranges
  static const Map<EggSpecies, double> speciesMasses = {
    EggSpecies.quail:    11.0,
    EggSpecies.henWhite: 58.0,
    EggSpecies.henBrown: 58.0,
    EggSpecies.duck:     75.0,
    EggSpecies.goose:    160.0,
    EggSpecies.emu:      600.0,
    EggSpecies.ostrich:  1400.0,
  };

  /// Target yolk temperatures for "Jammy" status by species
  static const Map<EggSpecies, double> speciesJammyTemps = {
    EggSpecies.quail:    62.0,
    EggSpecies.henWhite: 63.0,
    EggSpecies.henBrown: 63.0,
    EggSpecies.duck:     64.0,
    EggSpecies.goose:    65.0,
    EggSpecies.emu:      66.0,
    EggSpecies.ostrich:  68.0, // Higher mass requires slightly higher core temp to ensure white set
  };

  /// Mass multipliers for size variations (relative to standard mass)
  static const Map<EggSize, double> sizeMultipliers = {
    EggSize.small:  0.85,
    EggSize.medium: 1.0,
    EggSize.large:  1.15,
    EggSize.jumbo:  1.3,
  };

  /// Haptic boundary thresholds for the Yolk-o-Meter
  static const List<double> yolkBoundaries = [0.15, 0.35, 0.55, 0.75];
}

// ── Egg Visual Metadata ──────────────────────────────────────────────────────
class EggSpeciesTheme {
  final String label;
  final Color shellColor;
  final double visualScale; // For UI comparisons

  const EggSpeciesTheme({
    required this.label,
    required this.shellColor,
    this.visualScale = 1.0,
  });

  static const Map<EggSpecies, EggSpeciesTheme> registry = {
    EggSpecies.quail: EggSpeciesTheme(
      label: 'Quail',
      shellColor: Color(0xFFDED6C6), // Light speckled beige
      visualScale: 0.7,
    ),
    EggSpecies.henWhite: EggSpeciesTheme(
      label: 'White Hen',
      shellColor: Colors.white,
      visualScale: 1.0,
    ),
    EggSpecies.henBrown: EggSpeciesTheme(
      label: 'Brown Hen',
      shellColor: Color(0xFFC08A64), // Warm Sienna/Brown
      visualScale: 1.0,
    ),
    EggSpecies.duck: EggSpeciesTheme(
      label: 'Duck',
      shellColor: Color(0xFFE8F5E9), // Pale mint eggshell
      visualScale: 1.15,
    ),
    EggSpecies.goose: EggSpeciesTheme(
      label: 'Goose',
      shellColor: Color(0xFFF5F5F5),
      visualScale: 1.3,
    ),
    EggSpecies.emu: EggSpeciesTheme(
      label: 'Emu',
      shellColor: Color(0xFF003D33), // Deep Oceanic Teal
      visualScale: 1.5,
    ),
    EggSpecies.ostrich: EggSpeciesTheme(
      label: 'Ostrich',
      shellColor: Color(0xFFFFF9E7), // Creamy/Ivory
      visualScale: 1.7,
    ),
  };
}

// ── Enums ─────────────────────────────────────────────────────────────────────
enum EggSize      { small, medium, large, jumbo }
enum EggSpecies   { quail, henWhite, henBrown, duck, goose, emu, ostrich }
enum StartTemp    { fridge, roomTemp }
enum CookingMethod{ boiled, scrambled, poached, omelette, fried, benedict, soySauceEgg }
enum MascotState  { idle, preparing, cooking, warning, success, sadRaw }
