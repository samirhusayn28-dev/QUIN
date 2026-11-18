import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/neo_palette.dart';

/// Full-screen celebration overlay: confetti burst + screen flash + haptic.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.controller,
    this.color = NeoPalette.pink,
  });

  final Widget child;
  final AnimationController controller;
  final Color color;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List<ConfettiParticle>.generate(40, (i) => ConfettiParticle.random(widget.color));
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.controller.reset();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            if (widget.controller.value == 0) return const SizedBox.shrink();
            return IgnorePointer(
              child: Stack(
                children: <Widget>[
                  // Screen flash
                  Container(
                    color: widget.color.withValues(alpha: 0.3 * (1 - widget.controller.value)),
                  ),
                  // Particles
                  CustomPaint(
                    painter: ConfettiPainter(
                      particles: _particles,
                      progress: widget.controller.value,
                    ),
                    size: Size.infinite,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ConfettiParticle {
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });

  final double x; // 0..1
  final double y; // 0..1
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final int shape; // 0=rect, 1=circle, 2=triangle

  factory ConfettiParticle.random(Color baseColor) {
    final rnd = math.Random();
    final colors = <Color>[
      baseColor,
      NeoPalette.yellow,
      NeoPalette.cyan,
      NeoPalette.lime,
      NeoPalette.orange,
      NeoPalette.purple,
      NeoPalette.teal,
    ];
    return ConfettiParticle(
      x: 0.5 + (rnd.nextDouble() - 0.5) * 0.3,
      y: 0.1 + rnd.nextDouble() * 0.1,
      vx: (rnd.nextDouble() - 0.5) * 1.2,
      vy: 0.5 + rnd.nextDouble() * 0.8,
      size: 6 + rnd.nextDouble() * 10,
      color: colors[rnd.nextInt(colors.length)],
      rotation: rnd.nextDouble() * math.pi * 2,
      rotationSpeed: (rnd.nextDouble() - 0.5) * 4,
      shape: rnd.nextInt(3),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  const ConfettiPainter({required this.particles, required this.progress});

  final List<ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final gravity = 0.003 * size.height;
    for (final p in particles) {
      final t = progress;
      final px = size.width * (p.x + p.vx * t * 0.5);
      final py = size.height * (p.y + p.vy * t + 0.5 * gravity * t * t);
      final rot = p.rotation + p.rotationSpeed * t;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final paint = Paint()..color = p.color.withValues(alpha: 1 - t);

      switch (p.shape) {
        case 0: // rect
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            paint,
          );
          break;
        case 1: // circle
          canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
          break;
        case 2: // triangle
          final path = Path()
            ..moveTo(0, -p.size * 0.6)
            ..lineTo(-p.size * 0.5, p.size * 0.5)
            ..lineTo(p.size * 0.5, p.size * 0.5)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter old) =>
      old.particles != particles || old.progress != progress;
}

/// Small goal-reached pulse for the counter card.
class GoalPulse extends StatefulWidget {
  const GoalPulse({super.key, required this.child, this.color = NeoPalette.lime});

  final Widget child;
  final Color color;

  @override
  State<GoalPulse> createState() => _GoalPulseState();
}

class _GoalPulseState extends State<GoalPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void trigger() {
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        if (t == 0) return child!;
        return Transform.scale(
          scale: 1 + 0.15 * math.sin(t * math.pi),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.color.withValues(alpha: 1 - t),
                width: 4 * (1 - t),
              ),
              borderRadius: BorderRadius.circular(NeoPalette.radius),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}