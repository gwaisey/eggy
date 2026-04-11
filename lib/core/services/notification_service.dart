import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service responsible for all OS-level alerts.
/// Emoji-free. Uses text-only payloads for maximum compatibility.
class EggyNotificationService {
  static final EggyNotificationService _instance = EggyNotificationService._internal();
  factory EggyNotificationService() => _instance;
  EggyNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);

    // Request Android 13+ permissions
    if (!kIsWeb && Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Fires the "Timer Done" notification — shown even in foreground.
  Future<void> showTimerComplete(String recipeTitle) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'eggy_kitchen',
        'Eggy Kitchen Alerts',
        channelDescription: 'Notifies you when your egg is ready for the next step.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      ),
    );

    await _plugin.show(
      0,
      'Perfectly Timed',
      '$recipeTitle is ready for the next step.',
      details,
    );
  }

  /// Fires the "All Done" notification when the last prep step is completed.
  Future<void> showAllDone(String recipeTitle) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'eggy_kitchen',
        'Eggy Kitchen Alerts',
        channelDescription: 'Notifies you when your egg is ready for the next step.',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      ),
    );

    await _plugin.show(
      1,
      'Kitchen Complete',
      '$recipeTitle is done. Time to eat.',
      details,
    );
  }

  // For web/desktop testing where local notifications are not supported
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
}

/// Helper mixin: call in main() or DI setup
extension NotificationInit on EggyNotificationService {
  Future<void> safeInit() async {
    try {
      if (isSupported) await initialize();
    } catch (e) {
      debugPrint('[EggyNotifications] Not supported on this platform: $e');
    }
  }
}
