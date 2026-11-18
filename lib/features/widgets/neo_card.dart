import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import 'neo_pressable.dart';

/// Sticker-like card: thick border, hard offset shadow, optional tilt.
/// If [onTap] is provided the whole card sinks into its shadow on press.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius,
    this.borderWidth,
    this.shadowOffset,
    this.shadowColor,
    this.tilt = 0,
    this.onTap,
    this.onLongPress,
    this.haptic = NeoHaptic.light,
    this.showShadow = true,
    this.border = true,
    this.clip = false,
    this.width,
    this.height,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final double? borderWidth;
  final Offset? shadowOffset;
  final Color? shadowColor;
  final double tilt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final NeoHaptic haptic;
  final bool showShadow;
  final bool border;
  final bool clip;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final r = radius ?? neo.radius;
    final bw = borderWidth ?? neo.borderWidth;
    final offset = shadowOffset ?? neo.shadowOffset;
    final bg = color ?? neo.paper;

    Widget surface(double press) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        decoration: BoxDecoration(
          color: Color.lerp(bg, NeoPalette.ink, 0.06 * press),
          border: border ? Border.all(color: NeoPalette.ink, width: bw) : null,
          borderRadius: BorderRadius.circular(r),
          boxShadow: showShadow
              ? <BoxShadow>[
                  BoxShadow(
                    color: shadowColor ?? neo.shadowColor,
                    offset: offset * (1 - press),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: child,
      );
    }

    Widget content;
    if (onTap != null || onLongPress != null) {
      content = NeoPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        haptic: haptic,
        builder: (context, press) => Transform.translate(offset: offset * press, child: surface(press)),
      );
    } else {
      content = surface(0);
    }

    if (tilt != 0) {
      content = Transform.rotate(angle: tilt * math.pi / 180, child: content);
    }
    return content;
  }
}
