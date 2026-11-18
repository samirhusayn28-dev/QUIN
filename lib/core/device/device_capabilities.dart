import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coarse device capability used to opt *weak* devices into reduced effects.
///
/// Detection happens once at startup through a small method channel (RAM +
/// SDK level). On platforms without the channel we assume a capable device so
/// normal phones keep every effect.
@immutable
class DeviceCapabilities {
  const DeviceCapabilities({
    required this.lowEnd,
    this.totalRamMb,
    this.sdkInt,
  });

  final bool lowEnd;
  final int? totalRamMb;
  final int? sdkInt;

  static const DeviceCapabilities capable = DeviceCapabilities(lowEnd: false);

  /// RAM and SDK thresholds that mark a device as low-end.
  static const int lowRamMb = 3072;
  static const int minSdk = 26;

  static bool _isLowEnd({int? totalRamMb, int? sdkInt}) {
    if (totalRamMb != null && totalRamMb < lowRamMb) return true;
    if (sdkInt != null && sdkInt < minSdk) return true;
    return false;
  }

  static Future<DeviceCapabilities> detect() async {
    if (!Platform.isAndroid) return capable;
    try {
      const channel = MethodChannel('tally_counter/device');
      final Map<Object?, Object?>? info =
          await channel.invokeMapMethod<Object?, Object?>('caps');
      if (info == null) return capable;
      final ram = (info['totalRamMb'] as num?)?.toInt();
      final sdk = (info['sdkInt'] as num?)?.toInt();
      final lowRam = info['lowRam'] as bool? ?? false;
      return DeviceCapabilities(
        lowEnd: lowRam || _isLowEnd(totalRamMb: ram, sdkInt: sdk),
        totalRamMb: ram,
        sdkInt: sdk,
      );
    } on MissingPluginException {
      return capable;
    } on PlatformException {
      return capable;
    }
  }
}

/// Resolved once; read with `ref.watch(deviceCapabilitiesProvider).value`.
final deviceCapabilitiesProvider =
    FutureProvider<DeviceCapabilities>((ref) => DeviceCapabilities.detect());

/// True only on detected weak devices. Gates the optional heavy
/// (shader/animation) effects; never downgrades a normal device.
final reducedEffectsProvider = Provider<bool>((ref) {
  return ref.watch(deviceCapabilitiesProvider).value?.lowEnd ?? false;
});
