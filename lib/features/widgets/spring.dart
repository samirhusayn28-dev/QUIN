import 'package:flutter/widgets.dart';

import '../../core/motion/motion_tokens.dart';

/// Animates to a new [value] using a spring curve — never a default tween.
class AnimatedSpring extends StatelessWidget {
  const AnimatedSpring({
    super.key,
    required this.value,
    required this.builder,
    this.curve,
    this.duration,
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Curve? curve;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final m = context.motion;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: m.duration(duration ?? m.medium),
      curve: curve ?? m.snappy,
      builder: (context, v, _) => builder(context, v),
    );
  }
}

/// Fade + slide entrance used for staggered lists and page sections.
class SpringEntrance extends StatelessWidget {
  const SpringEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 0.12),
    this.enabled = true,
  });

  final Widget child;
  final int index;
  final Offset offset;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final m = context.motion;
    if (!m.enabled) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: m.slow + m.stagger(index),
      curve: m.snappy,
      builder: (context, t, inner) {
        final clamped = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - t) * 100,
              offset.dy * (1 - t) * 100,
            ),
            child: inner,
          ),
        );
      },
      child: child,
    );
  }
}
