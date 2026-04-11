import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum MascotMood { cozy, pensive, alert, excited, researching }

class MascotTheme {
  final String assetPath;
  final String? networkUrl;
  final Color glowColor;

  MascotTheme({
    required this.assetPath,
    this.networkUrl,
    required this.glowColor,
  });
}

class MascotThemeFactory {
  static MascotTheme getTheme(MascotState state, {MascotMood mood = MascotMood.cozy}) {
    // Mood overrides state-based visuals for alerts
    if (mood == MascotMood.alert) {
      return MascotTheme(
        assetPath: 'assets/images/eggy_cooking.png', // Placeholder for Wide Eyes
        glowColor: const Color(0xFFD32F2F), // Reserved Red
      );
    }
    if (mood == MascotMood.pensive) {
      return MascotTheme(
        assetPath: 'assets/images/eggy_idle.png', // Placeholder for Tilted Head
        glowColor: EggyColors.champagne.withValues(alpha: 0.5),
      );
    }
    if (mood == MascotMood.excited) {
      return MascotTheme(
        assetPath: 'assets/images/eggy_excited.png',
        glowColor: const Color(0xFF2E7D32), // Sage/Dark Green
      );
    }
    if (mood == MascotMood.researching) {
      return MascotTheme(
        assetPath: 'assets/images/eggy_idle.png', // Placeholder for researching
        glowColor: EggyColors.slate.withValues(alpha: 0.6),
      );
    }

    switch (state) {
      case MascotState.cooking:
      case MascotState.preparing:
        return MascotTheme(
          assetPath: 'assets/images/eggy_cooking.png',
          glowColor: EggyColors.champagne.withValues(alpha: 0.15), // Softer, classier glow
        );
      case MascotState.success:
        return MascotTheme(
          assetPath: 'assets/images/eggy_excited.png',
          glowColor: const Color(0xFF2E7D32),
        );
      case MascotState.warning:
        return MascotTheme(
          assetPath: 'assets/images/eggy_cooking.png',
          glowColor: const Color(0xFFD32F2F),
        );
      default:
        return MascotTheme(
          assetPath: 'assets/images/eggy_idle.png',
          glowColor: EggyColors.champagne.withValues(alpha: 0.3),
        );
    }
  }
}
