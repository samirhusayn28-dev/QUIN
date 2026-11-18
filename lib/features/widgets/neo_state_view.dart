import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/spring.dart';

/// A chunky, reusable empty/loading/error state view.
class NeoStateView extends StatelessWidget {
  const NeoStateView({
    super.key,
    required this.state,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.delay = Duration.zero,
  });

  final StateKind state;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? icon;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return SpringEntrance(
      offset: const Offset(0, 0.08),
      child: RepaintBoundary(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: NeoCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    icon!,
                    const SizedBox(height: 16),
                  ],
                  if (state == StateKind.loading)
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: NeoPalette.ink,
                        backgroundColor: context.neo.paperAlt,
                      ),
                    ),
                  if (state == StateKind.empty && icon == null)
                    const Icon(Icons.inventory_2_outlined, size: 48),
                  if (state == StateKind.error && icon == null)
                    const Icon(Icons.warning_amber_rounded, size: 48),
                  if (title != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      title!,
                      style: AppTypography.display(24, 1.08, -0.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: AppTypography.grotesk(size: 16, color: NeoPalette.inkSoft),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (onAction != null && actionLabel != null) ...<Widget>[
                    const SizedBox(height: 20),
                    NeoButton(
                      label: actionLabel!,
                      variant: NeoButtonVariant.primary,
                      onPressed: onAction,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum StateKind { loading, empty, error }
