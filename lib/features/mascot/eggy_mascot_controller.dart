import 'package:flutter/foundation.dart';
import 'mascot_theme.dart';

/// Handles the "mood" and animation physics of the Eggy Mascot.
/// Strictly watches progress and computes visual output variables.
class EggyMascotController extends ChangeNotifier {
  double _progress = 0.0;
  MascotMood _mood = MascotMood.cozy;
  
  bool _isCelebrating = false;
  bool _isProfessorMode = false;
  
  double get progress => _progress;
  MascotMood get mood => _mood;
  bool get isProfessorMode => _isProfessorMode;

  // Anti-Gravity Physics derived from progress
  double get speed => _isCelebrating ? 45.0 : 4.0 + (_progress * 12.0); 
  double get amplitude => _isCelebrating ? 40.0 : 12.0 + (_progress * 18.0);
  
  // High-frequency wiggle when nearing completion or celebrating
  bool get isExcited => _isCelebrating || _progress > 0.9;

  Future<void> celebrate() async {
    _isCelebrating = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));
    _isCelebrating = false;
    notifyListeners();
  }

  void updateProgress(double value) {
    if (_progress == value) return;
    _progress = value;
    notifyListeners();
  }

  void setMood(MascotMood value) {
    if (_mood == value) return;
    _mood = value;
    notifyListeners();
  }

  void resetMood() {
    if (_mood == MascotMood.cozy) return;
    _mood = MascotMood.cozy;
    notifyListeners();
  }

  void setProfessorMode(bool value) {
    if (_isProfessorMode == value) return;
    _isProfessorMode = value;
    notifyListeners();
  }
}
