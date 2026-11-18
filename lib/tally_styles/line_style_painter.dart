import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'line_style.dart';

/// How many taps make one completed group. The Western tally draws four
/// vertical lines and crosses them with a fifth diagonal stroke.
const int kTallyGroupSize = 5;

/// The single flat ink every tally bar is drawn in.
const Color kTallyInk = Color(0xFF111111);

/// The direction the (virtual) light comes from, in screen space: the top-left.
/// The emboss puts its lighter edge on the side of a bar that faces it.
const Offset _lightDir = Offset(-0.7071067811865476, -0.7071067811865476);

/// Geometry for one tally group, computed from the real size of the field the
/// painter was given. Everything is derived from the group's own bounding box
/// (never hardcoded pixels) and the box is centred inside the field, so the
/// marks sit dead centre in both axes.
///
/// The diagonal rises bottom-left → top-right at ~23° above horizontal, starts
/// clearly left of the first line (below its centre) and ends clearly right of
/// the fourth (above its centre), overhanging the outer lines by one spacing.
class _GroupGeometry {
  const _GroupGeometry({
    required this.lineTop,
    required this.lineBottom,
    required this.xs,
    required this.strokeWidth,
    required this.diagonalStart,
    required this.diagonalEnd,
    required this.bounds,
  });

  final double lineTop;
  final double lineBottom;
  final List<double> xs;
  final double strokeWidth;
  final Offset diagonalStart;
  final Offset diagonalEnd;
  final Rect bounds;

  double x(int i) => xs[i];

  /// Height ÷ spacing between the four vertical bars.
  static const double heightToSpacing = 5.1;

  /// Stroke width as a fraction of the group height (a bold 9–10% bar).
  static const double strokeFraction = 0.095;

  /// Fractions of the group height where the diagonal starts and ends. The
  /// 0.416·H vertical drop over a 5·S horizontal run is what makes it 23°.
  static const double diagonalStartFraction = 0.783;
  static const double diagonalEndFraction = 0.367;

  factory _GroupGeometry.build(double width, double height, double strokeScale) {
    final scale = strokeScale <= 0 ? 1.0 : strokeScale;
    // Bounding-box width for a group of height H: 5·S + t, with S = H/5.1 and
    // t = 0.095·H·scale. Solve for the largest H that fits.
    final widthPerHeight =
        kTallyGroupSize / heightToSpacing + strokeFraction * scale;
    var h = width / widthPerHeight;
    if (h > height) h = height;

    final spacing = h / heightToSpacing;
    final strokeWidth =
        (h * strokeFraction * scale).clamp(1.2, h * 0.34).toDouble();

    final left = -spacing;
    final xs = <double>[for (var i = 0; i < 4; i++) left + spacing * (i + 1)];

    final start = Offset(left, h * diagonalStartFraction);
    final end = Offset(xs[3] + spacing, h * diagonalEndFraction);

    final half = strokeWidth / 2;
    final bounds = Rect.fromLTRB(
      math.min(left, math.min(start.dx, end.dx)) - half,
      0,
      math.max(xs[3] + spacing, math.max(start.dx, end.dx)) + half,
      h,
    );

    return _GroupGeometry(
      lineTop: 0,
      lineBottom: h,
      xs: xs,
      strokeWidth: strokeWidth,
      diagonalStart: start,
      diagonalEnd: end,
      bounds: bounds,
    );
  }
}

// ---------------------------------------------------------------------------
// Static, cached paths
//
// Every bar's outline — body, highlight and shade — is built exactly once and
// cached as a `Path`. Re-painting the same mark reuses the cached paths: no
// per-frame allocation, no per-frame randomness.
// ---------------------------------------------------------------------------

final Map<String, Path> _pathCache = <String, Path>{};

Path _cachedPath(String key, Path Function() build) {
  final cached = _pathCache[key];
  if (cached != null) return cached;
  if (_pathCache.length > 2048) _pathCache.clear();
  final path = build();
  _pathCache[key] = path;
  return path;
}

/// The one and only tally stroke: a plain straight bold bar.
///
/// A bar is a uniform-width rounded rectangle with flat ends — not tapered and
/// with no ball ends — plus a thin emboss that puts a lighter hair on the edge
/// facing the light and a darker hair on the opposite edge. Alpha in [color] is
/// honoured, so the faint background layer can reuse the same stroke instead of
/// wrapping it in an `Opacity` widget.
class TallyStrokePainter {
  const TallyStrokePainter({this.color = kTallyInk});

  final Color color;

  /// Every stored line style resolves to the same bar now; [color] only exists
  /// so a caller can fade the marks without changing their shape.
  static TallyStrokePainter of(LineStyle style, {Color? color}) =>
      TallyStrokePainter(color: color ?? kTallyInk);

  /// Paints one bar from [a] to [b] with the given [width]. [height] is the
  /// group height; the bar itself is purely a function of `a`, `b` and `width`.
  void paintStroke(
    Canvas canvas,
    Offset a,
    Offset b,
    double width,
    double height,
  ) {
    final dir = b - a;
    final len = dir.distance;
    if (len <= 0.01 || width <= 0.01) return;
    final half = width / 2;
    // In a bar's own (rotated) frame the local +y axis is this normal, so
    // asking which side faces the light tells us where the emboss goes.
    final normal = Offset(-dir.dy / len, dir.dx / len);
    final lift =
        normal.dx * _lightDir.dx + normal.dy * _lightDir.dy >= 0 ? 1.0 : -1.0;
    final key = cacheKey(a, b, width);

    canvas.save();
    canvas.translate(a.dx, a.dy);
    canvas.rotate(dir.direction);

    final body = _cachedPath('$key:body', () {
      final rect = Rect.fromLTWH(0, -half, len, width);
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(half)));
    });
    canvas.drawPath(body, Paint()..color = color);

    // A hair of emboss, straight along the bar and drawn in the lit/shaded
    // direction. Cached as a unit-length path and translated into place.
    final inset = math.max(0.7, width * 0.16);
    final edge = _cachedPath('$key:edge', () {
      final x0 = width * 0.32;
      final x1 = math.max(x0, len - width * 0.32);
      return Path()
        ..moveTo(x0, 0)
        ..lineTo(x1, 0);
    });
    final edgeWidth = math.min(1.5, math.max(0.9, width * 0.34));
    final highlight = Paint()
      ..color = const Color(0x3DFFFFFF)
      ..strokeWidth = edgeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final shade = Paint()
      ..color = const Color(0x3D000000)
      ..strokeWidth = edgeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.save();
    canvas.translate(0, lift * (half - inset));
    canvas.drawPath(edge, highlight);
    canvas.restore();
    canvas.save();
    canvas.translate(0, -lift * (half - inset));
    canvas.drawPath(edge, shade);
    canvas.restore();

    canvas.restore();
  }

  /// Stable, resolution-aware cache key for one bar.
  String cacheKey(Offset a, Offset b, double width) =>
      '${a.dx.toStringAsFixed(2)},${a.dy.toStringAsFixed(2)},'
      '${b.dx.toStringAsFixed(2)},${b.dy.toStringAsFixed(2)},'
      '${width.toStringAsFixed(2)}';
}

/// Draws one Western tally group — four vertical bars and, when the group is
/// complete, the fifth diagonal slash — in the single QUIN bar look.
///
/// [countInGroup] is 0..[kTallyGroupSize]: 1..4 draw that many vertical bars,
/// 5 draws the four bars and the diagonal. [fifthProgress] animates the
/// diagonal as it crosses the bars in a single stroke.
class LineStyleGroupPainter extends CustomPainter {
  const LineStyleGroupPainter({
    required this.style,
    required this.countInGroup,
    this.color,
    this.fifthProgress = 1,
    this.strokeScale = 1,
    this.newestScale = 1,
    this.panel = false,
  });

  /// Retained for stored-data compatibility; every style paints the same bar.
  final LineStyle style;
  final int countInGroup;

  /// Overrides the flat black ink. Alpha is honoured (used by the faint
  /// completed-groups background layer).
  final Color? color;
  final double fifthProgress;
  final double strokeScale;

  /// Scale applied to the *newest* vertical mark only (1 = resting). Earlier
  /// marks never re-animate: they are drawn from cached paths.
  final double newestScale;

  /// Retained for API compatibility. Tally marks never paint a surface.
  final bool panel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || size.width <= 0 || size.height <= 0) return;
    final g = _GroupGeometry.build(size.width, size.height, strokeScale);
    final stroke = TallyStrokePainter.of(style, color: color);

    canvas.save();
    // Centre the marks' real bounding box in the field — no manual offsets.
    canvas.translate(
      size.width / 2 - g.bounds.center.dx,
      size.height / 2 - g.bounds.center.dy,
    );

    final marks = countInGroup.clamp(0, kTallyGroupSize);
    for (var i = 0; i < 4 && i < marks; i++) {
      final a = Offset(g.x(i), g.lineTop);
      final b = Offset(g.x(i), g.lineBottom);
      // Only the newest mark pulses; every earlier mark is a cached path and
      // is re-painted untouched.
      final isNewest = i == marks - 1;
      if (isNewest && newestScale != 1) {
        final pivot = Offset(g.x(i), (g.lineTop + g.lineBottom) / 2);
        canvas.save();
        canvas.translate(pivot.dx, pivot.dy);
        canvas.scale(newestScale);
        canvas.translate(-pivot.dx, -pivot.dy);
        stroke.paintStroke(canvas, a, b, g.strokeWidth, g.lineBottom);
        canvas.restore();
      } else {
        stroke.paintStroke(canvas, a, b, g.strokeWidth, g.lineBottom);
      }
    }
    if (marks >= kTallyGroupSize && fifthProgress > 0) {
      final a = g.diagonalStart;
      final b = g.diagonalEnd;
      final end = Offset.lerp(a, b, fifthProgress.clamp(0.0, 1.0))!;
      stroke.paintStroke(canvas, a, end, g.strokeWidth, g.lineBottom);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LineStyleGroupPainter old) =>
      old.style != style ||
      old.countInGroup != countInGroup ||
      old.color != color ||
      old.fifthProgress != fifthProgress ||
      old.strokeScale != strokeScale ||
      old.newestScale != newestScale;
}
