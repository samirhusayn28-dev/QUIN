import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Motion tokens — the single source of truth for every animation in the app.
///
/// No default tweens anywhere: every transition reads a spring from here.
/// Read from context with `context.motion` (see [MotionContext]).
@immutable
class MotionTokens {
  const MotionTokens({this.reduceMotion = false});

  /// True when the platform asks for reduced motion (accessibility setting).
  final bool reduceMotion;

  static const MotionTokens reduced = MotionTokens(reduceMotion: true);
  static const MotionTokens standard = MotionTokens();

  static MotionTokens of(BuildContext context) {
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disable ? reduced : standard;
  }

  bool get enabled => !reduceMotion;

  /// Collapses any duration to zero when reduce-motion is on.
  Duration duration(Duration value) => reduceMotion ? Duration.zero : value;

  // ------------------------------------------------------------------ durations
  Duration get instant => duration(const Duration(milliseconds: 90));
  Duration get fast => duration(const Duration(milliseconds: 160));
  Duration get medium => duration(const Duration(milliseconds: 240));
  Duration get slow => duration(const Duration(milliseconds: 400));
  Duration get slower => duration(const Duration(milliseconds: 640));
  Duration get celebration => duration(const Duration(milliseconds: 900));
  Duration get cursorBlink => duration(const Duration(milliseconds: 900));

  /// Staggered entrance offset for item [index].
  Duration stagger(int index, {Duration step = const Duration(milliseconds: 55)}) =>
      reduceMotion ? Duration.zero : step * index;

  /// Convenience for `flutter_animate` interval based staggered reveals.
  Interval staggerInterval(int index, {int total = 10, double overlap = 0.35}) {
    if (reduceMotion) return const Interval(0, 1, curve: Curves.linear);
    final span = 1 / (total * (1 - overlap) + overlap);
    final start = (index * (1 - overlap) * span).clamp(0.0, 0.95);
    return Interval(start, (start + span).clamp(0.0, 1.0), curve: snappy);
  }

  // -------------------------------------------------------------------- springs
  static const SpringDescription springSnappy =
      SpringDescription(mass: 0.9, stiffness: 820, damping: 32);
  static const SpringDescription springBouncy =
      SpringDescription(mass: 1.0, stiffness: 600, damping: 17);
  static const SpringDescription springGentle =
      SpringDescription(mass: 1.0, stiffness: 340, damping: 30);
  static const SpringDescription springPress =
      SpringDescription(mass: 0.7, stiffness: 1200, damping: 44);
  static const SpringDescription springRelease =
      SpringDescription(mass: 0.9, stiffness: 700, damping: 20);
  static const SpringDescription springSoft =
      SpringDescription(mass: 1.2, stiffness: 260, damping: 26);

  // --------------------------------------------------------------------- curves
  static const Curve _snappy =
      SpringCurve(spring: springSnappy, referenceDuration: Duration(milliseconds: 520));
  static const Curve _bouncy =
      SpringCurve(spring: springBouncy, referenceDuration: Duration(milliseconds: 720));
  static const Curve _gentle =
      SpringCurve(spring: springGentle, referenceDuration: Duration(milliseconds: 620));
  static const Curve _press =
      SpringCurve(spring: springPress, referenceDuration: Duration(milliseconds: 260));
  static const Curve _release =
      SpringCurve(spring: springRelease, referenceDuration: Duration(milliseconds: 420));
  static const Curve _soft =
      SpringCurve(spring: springSoft, referenceDuration: Duration(milliseconds: 780));

  Curve get snappy => reduceMotion ? Curves.linear : _snappy;
  Curve get bouncy => reduceMotion ? Curves.linear : _bouncy;
  Curve get gentle => reduceMotion ? Curves.linear : _gentle;
  Curve get press => reduceMotion ? Curves.linear : _press;
  Curve get release => reduceMotion ? Curves.linear : _release;
  Curve get soft => reduceMotion ? Curves.linear : _soft;
  Curve get linear => Curves.linear;
}

/// A [Curve] driven by a real [SpringSimulation] instead of a bezier.
///
/// [referenceDuration] is the wall-clock span of the underlying simulation;
/// the actual animation duration still comes from the widget/controller, so
/// this compresses/stretches the spring to fit.
class SpringCurve extends Curve {
  const SpringCurve({
    required this.spring,
    this.referenceDuration = const Duration(milliseconds: 520),
    this.startVelocity = 0,
  });

  final SpringDescription spring;
  final Duration referenceDuration;
  final double startVelocity;

  @override
  double transformInternal(double t) {
    final simulation = SpringSimulation(spring, 0, 1, startVelocity)
      ..tolerance = const Tolerance(distance: 0.0004, velocity: 0.0004);
    final seconds = referenceDuration.inMicroseconds / 1e6;
    return simulation.x(t * seconds);
  }

  @override
  String toString() => 'SpringCurve($spring)';
}

extension MotionContext on BuildContext {
  MotionTokens get motion => MotionTokens.of(this);
}
