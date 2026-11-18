import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/motion/motion_tokens.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';

/// Rolling odometer number: each digit slides on a spring when it changes.
class RollingOdometer extends StatelessWidget {
  const RollingOdometer({
    super.key,
    required this.value,
    this.style,
    this.digitHeight,
    this.color = NeoPalette.ink,
  });

  final int value;
  final TextStyle? style;
  final double? digitHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? AppTypography.display(64, 1.0, -1);
    final h = digitHeight ?? (textStyle.fontSize ?? 64) * 1.16;
    final text = value.toString();
    final children = <Widget>[];
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == '-') {
        children.add(SizedBox(
          height: h,
          child: Align(
            alignment: Alignment.center,
            child: Text(ch, style: textStyle.copyWith(color: color)),
          ),
        ));
      } else {
        children.add(_RollingDigit(
          digit: int.parse(ch),
          style: textStyle.copyWith(color: color),
          height: h,
        ));
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({required this.digit, required this.style, required this.height});

  final int digit;
  final TextStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final m = context.motion;
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: digit.toDouble(), end: digit.toDouble()),
        duration: m.duration(const Duration(milliseconds: 420)),
        curve: m.snappy,
        builder: (context, v, _) {
          final offset = v * height;
          return ClipRect(
            child: SizedBox(
              width: (style.fontSize ?? 64) * 0.62,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(0, -offset),
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List<Widget>.generate(
                          10,
                          (d) => SizedBox(
                            height: height,
                            child: Center(child: Text('$d', style: style)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple sparkline used in headers; draws with the neo ink stroke.
class MiniSparkline extends StatelessWidget {
  const MiniSparkline({super.key, required this.values, this.color = NeoPalette.ink, this.height = 40});

  final List<int> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SparkPainter(values, color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.values, this.color);

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(math.max).toDouble();
    final minV = values.reduce(math.min).toDouble();
    final span = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.values != values || old.color != color;
}
