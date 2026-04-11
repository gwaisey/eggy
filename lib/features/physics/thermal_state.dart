import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum CoagulationState { dippy, jammy, set, hard_boiled, sulfur_risk }

class ThermalState {
  final double threshold; // 0.0 to 1.0 (0% to 100% coagulation)
  final EggSpecies species;

  ThermalState({required this.threshold, this.species = EggSpecies.henWhite});

  CoagulationState get state {
    if (threshold < 0.3) return CoagulationState.dippy;
    if (threshold < 0.6) return CoagulationState.jammy;
    if (threshold < 0.8) return CoagulationState.set;
    if (threshold < 0.95) return CoagulationState.hard_boiled;
    return CoagulationState.sulfur_risk;
  }

  /// Volumetric Yolk Color Mapping
  Color get yolkColor {
    if (threshold < 0.4) return const Color(0xFFFFD700); // Liquid Gold
    if (threshold < 0.7) {
      // Transition to Jammy
      final t = (threshold - 0.4) / 0.3;
      return Color.lerp(const Color(0xFFFFD700), const Color(0xFFFFA500), t)!;
    }
    if (threshold < 0.98) {
      // Transition to Hard Set (Appetizing Bright Sulfur Yellow)
      final t = (threshold - 0.7) / 0.28;
      // Fade from Jammy Orange to a creamy, firm Pale Yellow
      return Color.lerp(const Color(0xFFFFA500), const Color(0xFFFFF176), t)!;
    }
    return const Color(0xFFFFF59D); // Firm, vibrant solar yellow
  }

  /// Molecular Albumen Color Mapping
  Color get albumenColor {
    if (threshold < 0.3) return const Color(0x22B2EBF2); // Transparent Bluish
    if (threshold < 0.6) {
      final t = (threshold - 0.3) / 0.3;
      return Color.lerp(const Color(0x22FFFFFF), const Color(0xBBFFFFFF), t)!;
    }
    return const Color(0xFFFFFFFF); // Opaque White
  }

  /// Ambient Shell Heat Mapping
  Color get shellColor {
    if (threshold < 0.2) return const Color(0xFFF5F5F5);
    if (threshold < 0.8) return const Color(0xFFFFF3E0);
    return const Color(0xFFFFE0B2); // Warm
  }

  String get label {
    switch (state) {
      case CoagulationState.dippy: return "Dippy / Liquid";
      case CoagulationState.jammy: return "Perfectly Jammy";
      case CoagulationState.set:   return "Molecularly Set";
      case CoagulationState.hard_boiled: return "Hard Boiled";
      case CoagulationState.sulfur_risk: return "SULFUR WARNING";
    }
  }
}
