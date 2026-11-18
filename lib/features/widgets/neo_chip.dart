import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import 'neo_pressable.dart';

/// Selectable sticker chip. Always bordered; sinks when pressed.
class NeoChip extends StatelessWidget {
  const NeoChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color = NeoPalette.yellow,
    this.icon,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final bg = selected ? color : neo.paper;
    final fg = NeoPalette.ink;

    return NeoPressable(
      onTap: onTap,
      haptic: NeoHaptic.selection,
      enabled: onTap != null,
      builder: (context, press) {
        return Transform.translate(
          offset: neo.shadowOffsetSmall * press,
          child: Container(
            padding: dense
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: NeoPalette.ink, width: neo.borderWidth),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: neo.shadowColor,
                  offset: neo.shadowOffsetSmall * (1 - press),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: dense ? 13 : 15, color: fg),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.grotesk(
                      size: dense ? 12 : 13.5,
                      weight: FontWeight.w700,
                      color: fg,
                      spacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
