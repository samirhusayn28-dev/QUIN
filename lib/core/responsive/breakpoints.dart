import 'package:flutter/material.dart';

/// Screen-size classes derived from the spec breakpoints.
///
/// - phone        : `< 600`
/// - foldable     : `600 – 840` (large phone / foldable)
/// - tablet       : `> 840`
enum ScreenClass { phone, foldable, tablet }

/// Single source of truth for responsive layout decisions.
///
/// Never hardcode a width in a screen: read the [ScreenClass] from context or
/// wrap content in [ResponsiveBody] / [ResponsiveValue].
abstract final class AppBreakpoints {
  static const double foldableMin = 600;
  static const double tabletMin = 840;

  static ScreenClass of(BuildContext context) =>
      classify(MediaQuery.sizeOf(context).width);

  static ScreenClass classify(double width) {
    if (width < foldableMin) return ScreenClass.phone;
    if (width <= tabletMin) return ScreenClass.foldable;
    return ScreenClass.tablet;
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;
}

extension AppBreakpointsX on BuildContext {
  ScreenClass get screenClass => AppBreakpoints.of(this);
  bool get isTablet => screenClass == ScreenClass.tablet;
  bool get isFoldable => screenClass == ScreenClass.foldable;
  bool get isPhone => screenClass == ScreenClass.phone;
}

/// Returns the value matching the current [ScreenClass].
T responsiveValue<T>(
  BuildContext context, {
  required T phone,
  T? foldable,
  T? tablet,
}) {
  switch (AppBreakpoints.of(context)) {
    case ScreenClass.phone:
      return phone;
    case ScreenClass.foldable:
      return foldable ?? phone;
    case ScreenClass.tablet:
      return tablet ?? foldable ?? phone;
  }
}

/// Constrains [child] to a comfortable reading width on large screens while
/// keeping it edge-to-edge on phones. Use to avoid hardcoded max widths in
/// individual screens.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxContentWidth = 720,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxContentWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= AppBreakpoints.foldableMin) {
          return child;
        }
        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: child,
          ),
        );
      },
    );
  }
}
