import 'package:flutter/services.dart';

/// Dart bridge to the native persistent-notification foreground service.
///
/// Android: a foreground service keeps an ongoing notification with the live
/// count and `+1` / `-1` actions, marked `VISIBILITY_PUBLIC` so it is shown on
/// the lock screen.
///
/// iOS: no-op here — the lock-screen presence is provided by the WidgetKit
/// lock screen widget and the Live Activity (see `live_activity.dart`).
class NotificationService {
  NotificationService._();

  static const MethodChannel _channel =
      MethodChannel('tally_counter/notification');

  /// Ask for the Android 13+ notification runtime permission (no-op elsewhere).
  static Future<void> requestPermission() async {
    await _channel.invokeMethod<void>('requestPermission');
  }

  static Future<void> start({required String counterId}) async {
    await _channel.invokeMethod<void>('start', {'counterId': counterId});
  }

  static Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }

  /// Push the latest name/total/colors to the ongoing notification.
  static Future<void> update({
    required String counterId,
    required String name,
    required int total,
    required int strokeColor,
    required int accentColor,
  }) async {
    await _channel.invokeMethod<void>('update', {
      'counterId': counterId,
      'name': name,
      'total': total,
      'strokeColor': strokeColor,
      'accentColor': accentColor,
    });
  }
}
