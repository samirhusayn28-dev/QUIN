import 'package:flutter/material.dart';

/// The stored "line style" of a counter.
///
/// There is exactly one tally look now: a plain straight bold black bar with a
/// soft emboss (four bars and a slash). The three members below survive only as
/// compatibility aliases for data written by earlier versions — the Drift
/// `lineStyle` column, backups and the Android widget / notification bridge —
/// and every one of them resolves to the same flat black bar.
enum LineStyle {
  chalk(
    id: 'chalk',
    label: 'Chalk',
    note: 'Legacy alias. Now draws the single bold bar look.',
    stroke: Color(0xFF111111),
    icon: Icons.draw_outlined,
  ),
  charcoal(
    id: 'charcoal',
    label: 'Charcoal',
    note: 'Legacy alias. Now draws the single bold bar look.',
    stroke: Color(0xFF111111),
    icon: Icons.brush_outlined,
  ),
  ink(
    id: 'ink',
    label: 'Ink',
    note: 'Flat black, uniform width, with a subtle emboss.',
    stroke: Color(0xFF111111),
    icon: Icons.format_paint_outlined,
  );

  const LineStyle({
    required this.id,
    required this.label,
    required this.note,
    required this.stroke,
    required this.icon,
  });

  /// Stable id persisted in the database.
  final String id;
  final String label;
  final String note;

  /// The colour this material writes in.
  final Color stroke;
  final IconData icon;

  /// What an unknown / legacy id collapses to.
  static const LineStyle fallback = LineStyle.ink;

  static LineStyle fromId(String? id) {
    if (id == null) return fallback;
    for (final style in values) {
      if (style.id == id) return style;
    }
    // Anything else is a legacy id from an older install. Map the old material
    // onto the closest surviving one instead of losing it.
    final legacy = id.toLowerCase();
    if (legacy.contains('chalk') ||
        legacy.contains('wax') ||
        legacy.contains('pencil')) {
      return LineStyle.chalk;
    }
    if (legacy.contains('charcoal') ||
        legacy.contains('stone') ||
        legacy.contains('wood') ||
        legacy.contains('cave') ||
        legacy.contains('ochre')) {
      return LineStyle.charcoal;
    }
    return fallback;
  }
}

/// The ARGB value of the stroke colour a stored style id writes in. Used when
/// bridging a counter to the Android widget / notification / Live Activity,
/// which speak plain ints.
int lineStyleStrokeValue(String? id) =>
    LineStyle.fromId(id).stroke.toARGB32();

/// Plain app-background value for the platform widget previews. Tally marks
/// never paint their own surface, so this is the single shared paper colour.
const int kWidgetSurfaceValue = 0xFFFFFBF0;
