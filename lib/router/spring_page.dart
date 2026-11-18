import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/motion_tokens.dart';

enum SpringTransition { fade, fadeSlideUp, scaleUp }

/// Build a spring-driven CustomTransitionPage.
Page<T> springPage<T>({
  LocalKey? key,
  required Widget child,
  String? name,
  SpringTransition transition = SpringTransition.fadeSlideUp,
}) {
  return CustomTransitionPage<T>(
    key: key ?? (name != null ? ValueKey(name) : null),
    name: name,
    child: child,
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final m = context.motion;
      return _buildTransition(context, m, animation, secondaryAnimation, child, transition);
    },
  );
}

Widget _buildTransition(
  BuildContext context,
  MotionTokens m,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
  SpringTransition transition,
) {
  final fade = CurvedAnimation(parent: animation, curve: m.gentle);
  final curve = CurvedAnimation(parent: animation, curve: m.snappy);
  switch (transition) {
    case SpringTransition.fade:
      return FadeTransition(opacity: fade, child: child);
    case SpringTransition.scaleUp:
      return ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(curve),
        child: FadeTransition(opacity: fade, child: child),
      );
    case SpringTransition.fadeSlideUp:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .chain(CurveTween(curve: m.snappy))
            .animate(animation),
        child: FadeTransition(opacity: fade, child: child),
      );
  }
}
