import 'package:flutter/material.dart';

import 'neo_palette.dart';

/// Bundled, fully offline typography.
///
/// * `SpaceGrotesk` — body, labels and numbers (variable weight axis).
/// * `ArchivoBlack` — headings and the big tally numbers.
///
/// The files live in `assets/fonts/` and are declared in `pubspec.yaml`, so
/// nothing is downloaded at runtime.
abstract final class AppTypography {
  static const String bodyFamily = 'SpaceGrotesk';
  static const String displayFamily = 'ArchivoBlack';

  /// Tabular, evenly spaced digits — keeps odometers from jittering.
  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _grotesk({
    required double size,
    required double weight,
    required Color color,
    double height = 1.3,
    double spacing = 0,
  }) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        color: color,
        height: height,
        letterSpacing: spacing,
        fontFeatures: _tabular,
        fontVariations: <FontVariation>[FontVariation('wght', weight)],
      );

  static TextStyle _archivo({
    required double size,
    required Color color,
    required double height,
    required double spacing,
  }) =>
      TextStyle(
        fontFamily: displayFamily,
        fontSize: size,
        color: color,
        height: height,
        letterSpacing: spacing,
      );

  /// The app-wide text theme. Headings run heavy (Archivo Black), body copy is
  /// Space Grotesk semibold so the neo-brutalist hierarchy stays legible.
  static TextTheme textTheme(TextTheme base) => base.copyWith(
        displayLarge: display(64, 0.98, -2.0),
        displayMedium: display(52, 1.0, -1.6),
        displaySmall: display(40, 1.02, -1.2),
        headlineLarge: display(34, 1.04, -0.8),
        headlineMedium: display(28, 1.06, -0.6),
        headlineSmall: display(24, 1.08, -0.4),
        titleLarge: grotesk(size: 22, weight: FontWeight.w700, spacing: -0.2, height: 1.15),
        titleMedium: grotesk(size: 17, weight: FontWeight.w700, spacing: -0.1),
        titleSmall: grotesk(size: 15, weight: FontWeight.w700, spacing: 0.1),
        bodyLarge: grotesk(size: 17, weight: FontWeight.w600),
        bodyMedium: grotesk(size: 15, weight: FontWeight.w600),
        bodySmall: grotesk(size: 13, weight: FontWeight.w600, color: NeoPalette.inkSoft),
        labelLarge: grotesk(size: 15, weight: FontWeight.w700, spacing: 0.6),
        labelMedium: grotesk(size: 12.5, weight: FontWeight.w700, spacing: 0.8),
        labelSmall: grotesk(
          size: 11,
          weight: FontWeight.w700,
          spacing: 1.1,
          color: NeoPalette.inkSoft,
        ),
      );

  /// Big numbers / headings (Archivo Black).
  static TextStyle display(
    double size,
    double height,
    double spacing, {
    Color color = NeoPalette.ink,
  }) =>
      _archivo(size: size, color: color, height: height, spacing: spacing);

  /// Space Grotesk body/label text.
  static TextStyle grotesk({
    double size = 15,
    FontWeight weight = FontWeight.w600,
    Color color = NeoPalette.ink,
    double height = 1.3,
    double spacing = 0,
  }) =>
      _grotesk(
        size: size,
        weight: weight.value.toDouble(),
        color: color,
        height: height,
        spacing: spacing,
      );

  /// Tabular-figure numerals. Kept as the `mono` entry point so call sites that
  /// predate the redesign still get aligned digits (no monospace look).
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w700,
    Color color = NeoPalette.ink,
    double height = 1.3,
    double spacing = 0.2,
  }) =>
      _grotesk(
        size: size,
        weight: weight.value.toDouble(),
        color: color,
        height: height,
        spacing: spacing,
      );
}
