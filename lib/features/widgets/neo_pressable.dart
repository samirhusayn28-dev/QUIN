import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/motion/motion_tokens.dart';

enum NeoHaptic { light, medium, heavy, selection, none }

/// Low-level press behaviour for every interactive neo-brutalist surface.
///
/// Handles the sink-into-shadow press, spring release and haptics, then hands
/// the normalized press value (0..1, spring-shaped) to [builder].
class NeoPressable extends StatefulWidget {
  const NeoPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.haptic = NeoHaptic.medium,
  });

  final Widget Function(BuildContext context, double press) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final NeoHaptic haptic;

  @override
  State<NeoPressable> createState() => _NeoPressableState();
}

class _NeoPressableState extends State<NeoPressable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 240));

  bool get _active => widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    if (!_active) return;
    final m = context.motion;
    _controller.animateTo(1, duration: m.fast, curve: m.press);
    _fire();
  }

  void _up([TapUpDetails? _]) {
    if (!_active) return;
    final m = context.motion;
    _controller.animateBack(0, duration: m.slow, curve: m.release);
  }

  void _fire() {
    switch (widget.haptic) {
      case NeoHaptic.light:
        HapticFeedback.lightImpact();
      case NeoHaptic.medium:
        HapticFeedback.mediumImpact();
      case NeoHaptic.heavy:
        HapticFeedback.heavyImpact();
      case NeoHaptic.selection:
        HapticFeedback.selectionClick();
      case NeoHaptic.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.motion;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _up,
      onTap: _active ? widget.onTap : null,
      onLongPress: _active
          ? () {
              HapticFeedback.selectionClick();
              widget.onLongPress?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => widget.builder(context, m.reduceMotion ? 0 : _controller.value),
      ),
    );
  }
}
