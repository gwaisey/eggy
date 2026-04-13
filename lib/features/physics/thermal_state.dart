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
    // Strictly derived from EggyColors.vibrantYolk
    if (threshold < 0.4) return EggyColors.vibrantYolk;
    if (threshold < 0.7) {
      final t = (threshold - 0.4) / 0.3;
      return Color.lerp(EggyColors.vibrantYolk, EggyColors.vibrantYolk.withValues(alpha: 0.8), t)!;
    }
    if (threshold < 0.98) {
      final t = (threshold - 0.7) / 0.28;
      // Transition to a more technical, set color (Onyx)
      return Color.lerp(EggyColors.vibrantYolk, EggyColors.onyx.withValues(alpha: 0.4), t)!;
    }
    return EggyColors.onyx.withValues(alpha: 0.2); // Fully set/Technical look
  }

  /// Molecular Albumen Color Mapping
  Color get albumenColor {
    // Strictly derived from White and Alabaster
    if (threshold < 0.3) return EggyColors.white.withValues(alpha: 0.1); 
    if (threshold < 0.6) {
      final t = (threshold - 0.3) / 0.3;
      return Color.lerp(EggyColors.white.withValues(alpha: 0.2), EggyColors.white.withValues(alpha: 0.7), t)!;
    }
    return EggyColors.white; 
  }

  /// Ambient Shell Heat Mapping
  Color get shellColor {
    // Strictly derived from Alabaster and Slate
    if (threshold < 0.2) return EggyColors.alabaster;
    if (threshold < 0.8) return EggyColors.alabaster.withValues(alpha: 0.6);
    return EggyColors.slate.withValues(alpha: 0.1); // Warm technical glow
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
