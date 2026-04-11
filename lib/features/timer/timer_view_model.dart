import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/interfaces/i_timer_service.dart';

/// Millisecond-precise countdown timer service.
/// Single Responsibility: ONLY counts down. Knows nothing about eggs.
class CountdownService implements ITimerService {
  final _tickController      = StreamController<int>.broadcast();
  final _completeController  = StreamController<void>.broadcast();

  Timer? _timer;
  int _remainingMs = 0;
  bool _isRunning  = false;
  bool _isPaused   = false;
  DateTime? _lastTick;

  @override Stream<int>  get onTick     => _tickController.stream;
  @override Stream<void> get onComplete => _completeController.stream;
  @override bool get isRunning => _isRunning;
  @override bool get isPaused  => _isPaused;

  @override
  void start(Duration duration) {
    _remainingMs = duration.inMilliseconds;
    _isRunning   = true;
    _isPaused    = false;
    _lastTick    = DateTime.now();
    _tick();
  }

  @override
  void pause() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused  = true;
  }

  @override
  void resume() {
    if (!_isPaused) return;
    _isRunning = true;
    _isPaused  = false;
    _lastTick  = DateTime.now();
    _tick();
  }

  @override
  void cancel() {
    _timer?.cancel();
    _isRunning   = false;
    _isPaused    = false;
    _remainingMs = 0;
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now     = DateTime.now();
      final elapsed = now.difference(_lastTick!).inMilliseconds;
      _lastTick     = now;
      _remainingMs -= elapsed;

      if (_remainingMs <= 0) {
        _remainingMs = 0;
        _isRunning   = false;
        _timer?.cancel();
        _tickController.add(0);
        _completeController.add(null);
      } else {
        _tickController.add(_remainingMs);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _tickController.close();
    _completeController.close();
  }
}

/// TimerViewModel — bridges CountdownService to the UI
class TimerViewModel extends ChangeNotifier {
  final CountdownService _service;

  int _remainingMs  = 0;
  int _totalMs      = 0;
  bool _isComplete  = false;

  StreamSubscription<int>?  _tickSub;
  StreamSubscription<void>? _completeSub;

  TimerViewModel(this._service);

  int  get remainingMs  => _remainingMs;
  int  get totalMs      => _totalMs;
  bool get isRunning    => _service.isRunning;
  bool get isPaused     => _service.isPaused;
  bool get isComplete   => _isComplete;

  /// Progress 0.0 → 1.0
  double get progress => _totalMs == 0 ? 0 : 1 - (_remainingMs / _totalMs);

  String get formattedTime {
    final ms = _remainingMs;
    final m  = (ms ~/ 60000).toString().padLeft(2, '0');
    final s  = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void startTimer(Duration duration) {
    _totalMs     = duration.inMilliseconds;
    _remainingMs = _totalMs;
    _isComplete  = false;

    _tickSub?.cancel();
    _completeSub?.cancel();

    _service.start(duration);

    _tickSub = _service.onTick.listen((ms) {
      _remainingMs = ms;
      notifyListeners();
    });

    _completeSub = _service.onComplete.listen((_) {
      _isComplete = true;
      notifyListeners();
    });
  }

  void togglePause() {
    // Optimistic Update: Notify listeners before service calls
    if (_service.isRunning) {
      _service.pause();
    } else if (_service.isPaused) {
      _service.resume();
    }
    notifyListeners();
    
    // Background Persistence (Fire and Forget)
    _saveTimerState();
  }

  void pause() {
    _service.pause();
    notifyListeners();
    _saveTimerState();
  }

  void resume() {
    _service.resume();
    notifyListeners();
  }

  void _saveTimerState() {
    // Placeholder for future persistence logic (Firebase/SharedPrefs)
    // Should NOT be awaited to keep UI snappy
  }

  void cancel() {
    _service.cancel();
    _remainingMs = 0;
    _isComplete  = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tickSub?.cancel();
    _completeSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
