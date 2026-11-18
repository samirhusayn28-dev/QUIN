import 'dart:io';

import 'package:flutter/services.dart';

/// iOS Live Activity + lock-screen widget bridge.
///
/// The native side is `TallyActivityManager.swift` (ActivityKit). The lock
/// screen *widget* itself is the WidgetKit extension `TallyWidgetExtension`.
class LiveActivityService {
  LiveActivityService._();

  static const MethodChannel _channel =
      MethodChannel('tally_counter/live_activity');

  static bool get _isIOS => Platform.isIOS;

  /// Start (or restart) the Live Activity for a counter.
  static Future<void> start({
    required String counterId,
    required String name,
    required int total,
    required int strokeColor,
    required int accentColor,
  }) async {
    if (!_isIOS) return;
    try {
      await _channel.invokeMethod<void>('start', {
        'counterId': counterId,
        'name': name,
        'total': total,
        'strokeColor': strokeColor,
        'accentColor': accentColor,
      });
    } on PlatformException {
      // ActivityKit unavailable (e.g. iOS < 16.1) — ignore.
    }
  }

  static Future<void> update({
    required String counterId,
    required String name,
    required int total,
    required int strokeColor,
    required int accentColor,
  }) async {
    if (!_isIOS) return;
    try {
      await _channel.invokeMethod<void>('update', {
        'counterId': counterId,
        'name': name,
        'total': total,
        'strokeColor': strokeColor,
        'accentColor': accentColor,
      });
    } on PlatformException {
      // ignore
    }
  }

  static Future<void> end({required String counterId}) async {
    if (!_isIOS) return;
    try {
      await _channel.invokeMethod<void>('end', {'counterId': counterId});
    } on PlatformException {
      // ignore
    }
  }
}
