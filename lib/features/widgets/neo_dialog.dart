import 'package:flutter/material.dart';

import '../../core/motion/motion_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import 'neo_button.dart';
import 'neo_card.dart';

/// Spring pop-in dialog. Drop-in replacement for `showDialog`.
Future<T?> showNeoDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  final m = context.motion;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? NeoPalette.ink.withValues(alpha: 0.55),
    transitionDuration: m.medium,
    pageBuilder: (context, _, __) => SafeArea(
      child: Builder(builder: (context) => Center(child: builder(context))),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: m.bouncy, reverseCurve: m.gentle);
      final scale = Tween<double>(begin: 0.82, end: 1).animate(curved);
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: m.gentle),
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

/// The dialog card itself: sticker-style, with an oversized title.
class NeoDialog extends StatelessWidget {
  const NeoDialog({
    super.key,
    required this.title,
    this.message,
    this.child,
    this.actions = const <Widget>[],
    this.icon,
    this.accent = NeoPalette.yellow,
    this.maxWidth = 420,
  });

  final String title;
  final String? message;
  final Widget? child;
  final List<Widget> actions;
  final IconData? icon;
  final Color accent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeoCard(
          shadowOffset: NeoPalette.shadowOffsetLarge,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (icon != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: accent,
                    border: Border.all(color: NeoPalette.ink, width: 3),
                    borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
                  ),
                  child: Icon(icon, size: 22, color: NeoPalette.ink),
                ),
              Text(title, style: AppTypography.display(26, 1.08, -0.4)),
              if (message != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(message!, style: AppTypography.grotesk(size: 15)),
              ],
              if (child != null) ...<Widget>[
                const SizedBox(height: 16),
                child!,
              ],
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience confirm dialog.
Future<bool> showNeoConfirm({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'Yes',
  String cancelLabel = 'Nope',
  Color accent = NeoPalette.red,
  IconData? icon,
}) async {
  final result = await showNeoDialog<bool>(
    context: context,
    builder: (context) => NeoDialog(
      title: title,
      message: message,
      icon: icon,
      accent: accent,
      actions: <Widget>[
        NeoButton(
          label: cancelLabel,
          variant: NeoButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        NeoButton(
          label: confirmLabel,
          color: accent,
          foreground: NeoPalette.white,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}
