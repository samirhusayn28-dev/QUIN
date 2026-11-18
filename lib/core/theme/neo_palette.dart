import 'package:flutter/material.dart';

/// Flat, saturated, unapologetic. Neo-brutalism palette (+ board + paper).
abstract final class NeoPalette {
  // Ink & paper
  static const Color ink = Color(0xFF111111);
  static const Color inkSoft = Color(0xFF3A3A3A);
  static const Color paper = Color(0xFFFFFBF0);
  static const Color paperAlt = Color(0xFFFFF1CF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFB9B2A0);

  // Stickers
  static const Color yellow = Color(0xFFFFD23F);
  static const Color pink = Color(0xFFFF5C8A);
  static const Color cyan = Color(0xFF45C4F5);
  static const Color lime = Color(0xFF9BE15D);
  static const Color orange = Color(0xFFFF7A2F);
  static const Color purple = Color(0xFFA06CF5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color red = Color(0xFFEF4444);
  static const Color teal = Color(0xFF2EC4B6);

  static const List<Color> stickers = <Color>[
    yellow,
    pink,
    cyan,
    lime,
    orange,
    purple,
    blue,
    teal,
  ];

  // Chalkboard / paper (tally surfaces)
  static const Color board = Color(0xFF1F2A24);
  static const Color boardFrame = Color(0xFF6B4A2F);
  static const Color chalk = Color(0xFFF4F1E8);
  static const Color kraft = Color(0xFFE8DCC0);

  // Geometry
  static const double borderWidth = 3;
  static const double borderWidthThick = 4;
  static const double radius = 14;
  static const double radiusSmall = 8;
  static const Offset shadowOffset = Offset(6, 6);
  static const Offset shadowOffsetSmall = Offset(3, 3);
  static const Offset shadowOffsetLarge = Offset(9, 9);

  static Color sticker(int index) => stickers[index % stickers.length];
}
