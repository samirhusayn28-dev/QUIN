import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/settings/app_settings.dart';
import 'app_typography.dart';
import 'neo_palette.dart';
import 'neo_theme.dart';

abstract final class AppTheme {
  /// The active theme for the selected [AppThemeVariant].
  static ThemeData forVariant(AppThemeVariant variant) => switch (variant) {
        AppThemeVariant.neo => neo(),
        AppThemeVariant.mint => neo(
            paper: const Color(0xFFEFFBF1),
            canvas: const Color(0xFFE3F6E7),
            paperAlt: const Color(0xFFD8F1E0),
            primary: NeoPalette.teal,
            accent: NeoPalette.teal,
            sticker: NeoPalette.lime,
          ),
        AppThemeVariant.sunset => neo(
            paper: const Color(0xFFFFF3E6),
            canvas: const Color(0xFFFFE8D1),
            paperAlt: const Color(0xFFFFE0C2),
            primary: NeoPalette.orange,
            accent: NeoPalette.orange,
            sticker: NeoPalette.pink,
          ),
        AppThemeVariant.lavender => neo(
            paper: const Color(0xFFF7F2FF),
            canvas: const Color(0xFFEDE5FF),
            paperAlt: const Color(0xFFE4D9FF),
            primary: NeoPalette.purple,
            accent: NeoPalette.purple,
            sticker: NeoPalette.cyan,
          ),
        AppThemeVariant.ocean => neo(
            paper: const Color(0xFFEEF6FF),
            canvas: const Color(0xFFDCEEFF),
            paperAlt: const Color(0xFFD3E6FF),
            primary: NeoPalette.blue,
            accent: NeoPalette.blue,
            sticker: NeoPalette.lime,
          ),
        AppThemeVariant.blush => neo(
            paper: const Color(0xFFFFF1F6),
            canvas: const Color(0xFFFFE3ED),
            paperAlt: const Color(0xFFFFD6E4),
            primary: NeoPalette.pink,
            accent: NeoPalette.pink,
            sticker: NeoPalette.yellow,
          ),
        AppThemeVariant.latte => neo(
            paper: const Color(0xFFF7EFE1),
            canvas: const Color(0xFFEFE3CF),
            paperAlt: const Color(0xFFE7D8BE),
            primary: kLatteBrown,
            accent: kLatteBrown,
            sticker: NeoPalette.orange,
          ),
      };

  /// The brown that carries Latte's buttons and toggles.
  static const Color kLatteBrown = Color(0xFF8B5E3C);

  /// The accent a theme paints its primary buttons / toggles with. Used by the
  /// theme picker so every chip previews its own colour.
  static Color accentFor(AppThemeVariant variant) => switch (variant) {
        AppThemeVariant.neo => NeoPalette.pink,
        AppThemeVariant.mint => NeoPalette.teal,
        AppThemeVariant.sunset => NeoPalette.orange,
        AppThemeVariant.lavender => NeoPalette.purple,
        AppThemeVariant.ocean => NeoPalette.blue,
        AppThemeVariant.blush => NeoPalette.pink,
        AppThemeVariant.latte => kLatteBrown,
      };

  /// Neo-brutalism: the main app theme.
  static ThemeData neo({
    Color paper = NeoPalette.paper,
    Color canvas = NeoPalette.paper,
    Color paperAlt = NeoPalette.paperAlt,
    Color primary = NeoPalette.pink,
    Color accent = NeoPalette.pink,
    Color sticker = NeoPalette.yellow,
  }) {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final scheme = ColorScheme.light(
      primary: accent,
      onPrimary: NeoPalette.white,
      secondary: NeoPalette.cyan,
      onSecondary: NeoPalette.ink,
      tertiary: sticker,
      onTertiary: NeoPalette.ink,
      surface: paper,
      onSurface: NeoPalette.ink,
      error: NeoPalette.red,
      onError: NeoPalette.white,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: paper,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textTheme: AppTypography.textTheme(base.textTheme),
      extensions: <ThemeExtension<dynamic>>[
        NeoTheme(paper: paper, paperAlt: paperAlt, accent: accent, sticker: sticker),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: NeoPalette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: NeoPalette.ink,
        thickness: 3,
        space: 24,
      ),
      iconTheme: const IconThemeData(color: NeoPalette.ink),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NeoPalette.ink,
        contentTextStyle: AppTypography.grotesk(color: NeoPalette.paper, weight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: NeoPalette.ink, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(NeoPalette.radius)),
        ),
      ),
    );
  }
}
