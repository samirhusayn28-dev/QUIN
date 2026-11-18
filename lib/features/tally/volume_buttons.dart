import 'package:flutter/services.dart';

/// A leading-edge gate: the first call inside a window is allowed, every
/// further call inside the same window is dropped.
///
/// Used to make one hardware key press produce exactly one count, no matter how
/// many duplicate or repeated events the platform delivers.
class Debouncer {
  Debouncer(this.window);

  final Duration window;
  DateTime? _last;

  /// Overridable clock so tests can advance time deterministically instead of
  /// sleeping through the real window.
  static DateTime Function() clock = DateTime.now;

  bool allow() {
    final at = clock();
    final last = _last;
    if (last != null && at.difference(last) < window) return false;
    _last = at;
    return true;
  }

  void reset() => _last = null;
}

/// Bridges Android hardware volume buttons into Dart.
///
/// On Android the activity forwards `KEYCODE_VOLUME_UP` / `KEYCODE_VOLUME_DOWN`
/// to this channel while capture is enabled, and consumes the event so the
/// system volume does not change. A no-op on every other platform.
///
/// This is the *only* volume path: there is no separate keyboard listener, so a
/// single physical press can never count twice.
class VolumeButtons {
  VolumeButtons._();

  static const MethodChannel _channel = MethodChannel('tally_counter/volume');
  static const Duration debounce = Duration(milliseconds: 150);
  static bool _supported = true;

  /// Whether the platform can capture volume buttons at all.
  static bool get supported => _supported;

  /// Enables or disables native capture.
  static Future<void> setEnabled(bool enabled) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('setEnabled', enabled);
    } on MissingPluginException {
      _supported = false;
    } on PlatformException {
      // Non-fatal: fall back to the on-screen buttons.
    }
  }

  /// Subscribes to button presses. Returns a disposer.
  static VoidCallbackLike listen(void Function(bool up) onPress) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onVolume') {
        onPress(call.arguments == 'up');
      }
      return null;
    });
    return () => _channel.setMethodCallHandler(null);
  }
}

/// Local typedef so this file does not depend on Flutter widgets.
typedef VoidCallbackLike = void Function();
