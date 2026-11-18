import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';

/// Neo-brutalist bento card shared by every stats tile.
///
/// Flat paper background, heavy ink border and a hard (un-blurred) drop shadow —
/// the same language as the rest of the app, with none of the old terminal look.
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.child,
    this.title,
    this.accent = NeoPalette.yellow,
    this.color,
    this.padding = const EdgeInsets.all(14),
    this.trailing,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final Color accent;

  /// Card face; falls back to the active theme's paper.
  final Color? color;
  final EdgeInsets padding;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.neo.paper,
        border: Border.all(color: NeoPalette.ink, width: 3),
        borderRadius: BorderRadius.circular(NeoPalette.radius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: NeoPalette.ink, offset: Offset(5, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            StatsHeader(title: title!, accent: accent, trailing: trailing),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
    return RepaintBoundary(
      child: onTap == null
          ? body
          : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: body),
    );
  }
}

/// Small sticker + label used as a card header.
class StatsHeader extends StatelessWidget {
  const StatsHeader({
    super.key,
    required this.title,
    this.accent = NeoPalette.yellow,
    this.trailing,
  });

  final String title;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: accent,
            border: Border.all(color: NeoPalette.ink, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTypography.grotesk(size: 13, weight: FontWeight.w700, spacing: 0.8),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A big number + caption, the core bento unit.
class StatBig extends StatelessWidget {
  const StatBig({
    super.key,
    required this.value,
    required this.label,
    this.accent = NeoPalette.ink,
    this.size = 30,
  });

  final String value;
  final String label;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(value, style: AppTypography.display(size, 1.0, -1, color: accent)),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.grotesk(size: 11, weight: FontWeight.w700, color: NeoPalette.inkSoft, spacing: 0.6),
        ),
      ],
    );
  }
}
