import 'package:flutter/material.dart';

import '../motion/motion_tokens.dart';


class TypedCursor extends StatefulWidget {
  const TypedCursor({super.key, this.color = Colors.green, this.width = 10});

  final Color color;
  final double width;

  @override
  State<TypedCursor> createState() => _TypedCursorState();
}

class _TypedCursorState extends State<TypedCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: MotionTokens.of(context).cursorBlink)
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(width: widget.width, height: 16, color: widget.color),
    );
  }
}
