import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../physics/thermal_state.dart';
import '../../core/constants.dart';
import '../../core/interfaces/i_egg_calculator.dart';
import '../../core/egg_physics_engine.dart';

/// YolkOMeterViewModel — The "Bridge" state layer.
/// Dependency Inversion: depends on EggCalculator abstract, not concrete engine.
class YolkOMeterViewModel extends ChangeNotifier {
  final EggPhysicsEngine _engine;
  UserEggPreferences _prefs;

  double _sliderValue = 0.2; // Default: Jammy
  final List<double> _boundaries = EggConstants.yolkBoundaries;

  YolkOMeterViewModel(this._engine, {UserEggPreferences? prefs})
      : _prefs = prefs ?? const UserEggPreferences(species: EggSpecies.henWhite);

  // ── Getters ──────────────────────────────────────────────────────────────────

  double get sliderValue => _sliderValue;
  UserEggPreferences get prefs => _prefs;

  String get yolkLabel => _engine.yolkLabelFromSlider(_sliderValue);

  /// Dynamic yolk color from physics engine for real-time cross-section morph
  Color get yolkColor => ThermalState(
        threshold: _sliderValue,
        species: _prefs.species,
      ).yolkColor;

  /// Current cooking duration based on slider + preferences
  Duration get cookingTime {
    final targetTemp = _engine.calculateTargetTemp(_sliderValue);
    return _engine.calculateCookingTime(targetTemp, _prefs);
  }

  String get formattedCookingTime {
    final d = cookingTime;
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void updateSlider(double newValue) {
    final clamped = newValue.clamp(0.0, 1.0);
    
    // Haptic Density Logic: Heavier impact as viscosity increases
    if ((clamped - _sliderValue).abs() > 0.05) {
      if (clamped < 0.35) {
        HapticFeedback.lightImpact();
      } else if (clamped < 0.75) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    }

    _sliderValue = clamped;
    notifyListeners();
  }

  void updatePrefs(UserEggPreferences newPrefs) {
    _prefs = newPrefs;
    notifyListeners();
  }

  void updateSize(EggSize size) {
    _prefs = UserEggPreferences(
      size: size,
      species: _prefs.species,
      startTemp: _prefs.startTemp,
      eggCount: _prefs.eggCount,
    );
    notifyListeners();
  }

  void updateSpecies(EggSpecies species) {
    _prefs = UserEggPreferences(
      size: _prefs.size,
      species: species,
      startTemp: _prefs.startTemp,
      eggCount: _prefs.eggCount,
    );
    notifyListeners();
  }

  void updateStartTemp(StartTemp temp) {
    _prefs = UserEggPreferences(
      size: _prefs.size,
      species: _prefs.species,
      startTemp: temp,
      eggCount: _prefs.eggCount,
    );
    notifyListeners();
  }

  void updateEggCount(int delta) {
    final newCount = (_prefs.eggCount + delta).clamp(1, 12);
    _prefs = UserEggPreferences(
      size: _prefs.size,
      species: _prefs.species,
      startTemp: _prefs.startTemp,
      eggCount: newCount,
    );
    notifyListeners();
    HapticFeedback.selectionClick();
  }
}
