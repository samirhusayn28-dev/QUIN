import 'package:flutter/material.dart';

import 'neo_palette.dart';

/// Design-system geometry exposed through `ThemeExtension` so components never
/// hardcode a border width or shadow offset.
@immutable
class NeoTheme extends ThemeExtension<NeoTheme> {
  const NeoTheme({
    this.borderWidth = NeoPalette.borderWidth,
    this.radius = NeoPalette.radius,
    this.shadowOffset = NeoPalette.shadowOffset,
    this.shadowOffsetSmall = NeoPalette.shadowOffsetSmall,
    this.shadowOffsetLarge = NeoPalette.shadowOffsetLarge,
    this.shadowColor = NeoPalette.ink,
    this.ink = NeoPalette.ink,
    this.paper = NeoPalette.paper,
    this.paperAlt = NeoPalette.paperAlt,
    this.accent = NeoPalette.pink,
    this.sticker = NeoPalette.yellow,
    this.sunken = false,
  });

  final double borderWidth;
  final double radius;
  final Offset shadowOffset;
  final Offset shadowOffsetSmall;
  final Offset shadowOffsetLarge;
  final Color shadowColor;
  final Color ink;
  final Color paper;

  /// Sunken paper: input fills, secondary chips, the stats backdrop.
  final Color paperAlt;
  final Color accent;

  /// The theme's highlight sticker (nav pill, accent buttons).
  final Color sticker;

  /// When true the whole surface renders "pressed into" the shadow.
  final bool sunken;

  @override
  NeoTheme copyWith({
    double? borderWidth,
    double? radius,
    Offset? shadowOffset,
    Offset? shadowOffsetSmall,
    Offset? shadowOffsetLarge,
    Color? shadowColor,
    Color? ink,
    Color? paper,
    Color? paperAlt,
    Color? accent,
    Color? sticker,
    bool? sunken,
  }) =>
      NeoTheme(
        borderWidth: borderWidth ?? this.borderWidth,
        radius: radius ?? this.radius,
        shadowOffset: shadowOffset ?? this.shadowOffset,
        shadowOffsetSmall: shadowOffsetSmall ?? this.shadowOffsetSmall,
        shadowOffsetLarge: shadowOffsetLarge ?? this.shadowOffsetLarge,
        shadowColor: shadowColor ?? this.shadowColor,
        ink: ink ?? this.ink,
        paper: paper ?? this.paper,
        paperAlt: paperAlt ?? this.paperAlt,
        accent: accent ?? this.accent,
        sticker: sticker ?? this.sticker,
        sunken: sunken ?? this.sunken,
      );

  @override
  NeoTheme lerp(covariant NeoTheme? other, double t) {
    if (other == null) return this;
    return NeoTheme(
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t),
      radius: lerpDouble(radius, other.radius, t),
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
      shadowOffsetSmall: Offset.lerp(shadowOffsetSmall, other.shadowOffsetSmall, t)!,
      shadowOffsetLarge: Offset.lerp(shadowOffsetLarge, other.shadowOffsetLarge, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      paperAlt: Color.lerp(paperAlt, other.paperAlt, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      sticker: Color.lerp(sticker, other.sticker, t)!,
      sunken: t < 0.5 ? sunken : other.sunken,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension NeoThemeX on BuildContext {
  NeoTheme get neo => Theme.of(this).extension<NeoTheme>() ?? const NeoTheme();
}
