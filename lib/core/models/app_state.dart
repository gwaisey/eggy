import '../constants.dart';

/// DTO to capture the current app state for AI context injection.
class EggyAppState {
  final String activeRecipe;
  final EggSize eggSize;
  final StartTemp startTemp;

  const EggyAppState({
    required this.activeRecipe,
    required this.eggSize,
    required this.startTemp,
  });

  /// Default "Unknown" state
  factory EggyAppState.unknown() => const EggyAppState(
    activeRecipe: 'None selected',
    eggSize: EggSize.large,
    startTemp: StartTemp.fridge,
  );
}
