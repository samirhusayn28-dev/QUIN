import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/motion/motion_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import 'spring.dart';

/// Squash-and-spring switch. Knob is a bordered square that slams across.
class NeoToggle extends StatelessWidget {
  const NeoToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = NeoPalette.lime,
    this.inactiveColor,
    this.width = 74,
    this.height = 40,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;

  /// Track colour when off; defaults to the theme's paper.
  final Color? inactiveColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final border = neo.borderWidth;
    final knob = height - border * 2 - 6;
    final travel = width - border * 2 - knob - 6;
    final enabled = onChanged != null;
    final off = inactiveColor ?? neo.paper;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onChanged!(!value);
              }
            : null,
        child: AnimatedSpring(
          value: value ? 1 : 0,
          curve: context.motion.bouncy,
          duration: context.motion.slow,
          builder: (context, t) {
            final track = Color.lerp(off, activeColor, t.clamp(0.0, 1.0))!;
            return Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(border + 3),
              decoration: BoxDecoration(
                color: track,
                border: Border.all(color: NeoPalette.ink, width: border),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: neo.shadowColor, offset: neo.shadowOffsetSmall, blurRadius: 0),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(travel * t.clamp(0.0, 1.15), 0),
                    child: Transform.scale(
                      scaleX: 1 + 0.08 * (1 - (t - 0.6).abs().clamp(0.0, 1.0)),
                      child: Container(
                        width: knob,
                        height: knob,
                        decoration: BoxDecoration(
                          color: value ? NeoPalette.paper : NeoPalette.ink,
                          border: Border.all(color: NeoPalette.ink, width: border),
                          borderRadius: BorderRadius.circular(knob / 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A labelled settings row wrapping [NeoToggle].
class NeoToggleTile extends StatelessWidget {
  const NeoToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.activeColor = NeoPalette.lime,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTypography.grotesk(size: 16, weight: FontWeight.w700)),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        NeoToggle(value: value, onChanged: onChanged, activeColor: activeColor),
      ],
    );
  }
}
