import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

/// Stores and persists the user's egg preferences across sessions.
class PreferencesViewModel extends ChangeNotifier {
  EggSize    _eggSize         = EggSize.large;
  StartTemp  _startTemp       = StartTemp.fridge;
  EggSpecies _eggSpecies      = EggSpecies.henWhite;
  bool       _hapticEnabled   = true;
  bool       _notifEnabled    = true;
  bool       _isProfessorMode = false;

  EggSize   get eggSize         => _eggSize;
  StartTemp get startTemp        => _startTemp;
  EggSpecies get eggSpecies      => _eggSpecies;
  bool      get hapticEnabled    => _hapticEnabled;
  bool      get notifEnabled     => _notifEnabled;
  bool      get isProfessorMode  => _isProfessorMode;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _eggSize        = EggSize.values[p.getInt('eggSize') ?? 1];
    _startTemp      = StartTemp.values[p.getInt('startTemp') ?? 0];
    _eggSpecies     = EggSpecies.values[p.getInt('eggSpecies') ?? 1]; // henWhite
    _hapticEnabled  = p.getBool('haptic') ?? true;
    _notifEnabled   = p.getBool('notif') ?? true;
    _isProfessorMode = p.getBool('profMode') ?? false;
    notifyListeners();
  }

  Future<void> setEggSize(EggSize size) async {
    _eggSize = size;
    final p = await SharedPreferences.getInstance();
    await p.setInt('eggSize', size.index);
    notifyListeners();
  }

  Future<void> setStartTemp(StartTemp temp) async {
    _startTemp = temp;
    final p = await SharedPreferences.getInstance();
    await p.setInt('startTemp', temp.index);
    notifyListeners();
  }

  Future<void> setEggSpecies(EggSpecies species) async {
    _eggSpecies = species;
    final p = await SharedPreferences.getInstance();
    await p.setInt('eggSpecies', species.index);
    notifyListeners();
  }

  Future<void> setHaptic(bool val) async {
    _hapticEnabled = val;
    final p = await SharedPreferences.getInstance();
    await p.setBool('haptic', val);
    notifyListeners();
  }

  Future<void> setNotif(bool val) async {
    _notifEnabled = val;
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif', val);
    notifyListeners();
  }

  Future<void> toggleProfessorMode() async {
    await setProfessorMode(!_isProfessorMode);
  }

  Future<void> setProfessorMode(bool val) async {
    _isProfessorMode = val;
    final p = await SharedPreferences.getInstance();
    await p.setBool('profMode', _isProfessorMode);
    notifyListeners();
  }
}
