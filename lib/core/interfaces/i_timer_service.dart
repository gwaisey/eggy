/// Interface for the countdown timer service.
/// Separated from IEggRecipe and ISoundPlayer (Interface Segregation).
abstract class ITimerService {
  Stream<int> get onTick;       // emits remaining milliseconds
  Stream<void> get onComplete;
  bool get isRunning;
  bool get isPaused;

  void start(Duration duration);
  void pause();
  void resume();
  void cancel();
}
