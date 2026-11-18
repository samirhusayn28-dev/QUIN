import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import 'neo_pressable.dart';

enum NeoButtonVariant { primary, secondary, accent, ghost, danger, dark }

enum NeoButtonSize { small, medium, large }

/// Chunky neo-brutalist button: 3px black border, hard offset shadow, and a
/// press that sinks the face into the shadow with a spring + haptic.
class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailing,
    this.variant = NeoButtonVariant.primary,
    this.size = NeoButtonSize.medium,
    this.color,
    this.foreground,
    this.expand = false,
    this.haptic = NeoHaptic.medium,
    this.radius,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? trailing;
  final NeoButtonVariant variant;
  final NeoButtonSize size;
  final Color? color;
  final Color? foreground;
  final bool expand;
  final NeoHaptic haptic;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final enabled = onPressed != null;
    final bg = color ?? _background(neo);
    final fg = foreground ?? _foreground;
    final geometry = _geometry(size, neo);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: NeoPressable(
        onTap: onPressed,
        haptic: haptic,
        enabled: enabled,
        builder: (context, press) {
          final sink = neo.shadowOffset * press;
          final face = Color.lerp(bg, NeoPalette.ink, 0.10 * press)!;
          return Transform.translate(
            offset: sink,
            child: Container(
              width: expand ? double.infinity : null,
              padding: geometry.padding,
              decoration: BoxDecoration(
                color: face,
                border: Border.all(color: NeoPalette.ink, width: neo.borderWidth),
                borderRadius: BorderRadius.circular(radius ?? neo.radius),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: neo.shadowColor,
                    offset: neo.shadowOffset * (1 - press),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: geometry.iconSize, color: fg),
                    SizedBox(width: geometry.gap),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.grotesk(
                        size: geometry.fontSize,
                        weight: FontWeight.w700,
                        color: fg,
                        height: 1.1,
                        spacing: 0.3,
                      ),
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    SizedBox(width: geometry.gap),
                    trailing!,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _background(NeoTheme neo) => switch (variant) {
        NeoButtonVariant.primary => neo.accent,
        NeoButtonVariant.secondary => NeoPalette.cyan,
        NeoButtonVariant.accent => neo.sticker,
        NeoButtonVariant.ghost => neo.paper,
        NeoButtonVariant.danger => NeoPalette.red,
        NeoButtonVariant.dark => NeoPalette.ink,
      };

  Color get _foreground => switch (variant) {
        NeoButtonVariant.primary => NeoPalette.white,
        NeoButtonVariant.secondary => NeoPalette.ink,
        NeoButtonVariant.accent => NeoPalette.ink,
        NeoButtonVariant.ghost => NeoPalette.ink,
        NeoButtonVariant.danger => NeoPalette.white,
        NeoButtonVariant.dark => NeoPalette.paper,
      };

  _NeoButtonGeometry _geometry(NeoButtonSize size, NeoTheme neo) => switch (size) {
        NeoButtonSize.small => const _NeoButtonGeometry(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            fontSize: 13,
            iconSize: 16,
            gap: 6,
          ),
        NeoButtonSize.medium => const _NeoButtonGeometry(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            fontSize: 15,
            iconSize: 19,
            gap: 8,
          ),
        NeoButtonSize.large => const _NeoButtonGeometry(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            fontSize: 19,
            iconSize: 24,
            gap: 10,
          ),
      };
}

class _NeoButtonGeometry {
  const _NeoButtonGeometry({
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.gap,
  });

  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;
  final double gap;
}
