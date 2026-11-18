import 'package:flutter/material.dart';

import 'line_style.dart';
import 'line_style_painter.dart';

export 'line_style.dart';
export 'line_style_painter.dart'
    show kTallyGroupSize, LineStyleGroupPainter, TallyStrokePainter;

/// How many marks are drawn for a given raw count. Values above one group are
/// reduced so previews and history still show a sensible single group.
int marksForCount(int count) {
  if (count <= 0) return 0;
  final rem = count % kTallyGroupSize;
  return rem == 0 ? kTallyGroupSize : rem;
}

/// Renders a single tally group filling whatever space it is given. The painter
/// computes the group's real bounds and centres them, so the marks sit dead
/// centre in the field with no manual offsets.
class TallyGroupView extends StatelessWidget {
  const TallyGroupView({
    super.key,
    required this.style,
    required this.count,
    this.color,
    this.fifthProgress = 1,
    this.strokeScale = 1,
    this.panel = false,
  });

  final LineStyle style;

  /// Raw count; it is reduced to the current group with [marksForCount].
  final int count;
  final Color? color;
  final double fifthProgress;
  final double strokeScale;

  /// Retained for compatibility; tally marks never paint a surface.
  final bool panel;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: LineStyleGroupPainter(
          style: style,
          countInGroup: marksForCount(count),
          color: color,
          fifthProgress: fifthProgress,
          strokeScale: strokeScale,
          panel: panel,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// A single group rendered from a persisted line-style id. Kept as the one
/// entry point every screen uses so a style id is only parsed in one place.
class TallyStyleCanvas extends StatelessWidget {
  const TallyStyleCanvas({
    super.key,
    required this.styleId,
    required this.count,
    this.color,
    this.panel = false,
    this.strokeScale = 1,
  });

  final String styleId;
  final int count;
  final Color? color;
  final bool panel;
  final double strokeScale;

  @override
  Widget build(BuildContext context) {
    return TallyGroupView(
      style: LineStyle.fromId(styleId),
      count: count,
      color: color,
      panel: panel,
      strokeScale: strokeScale,
    );
  }
}

/// A *static* preview of a line style: one finished group, no animation. The
/// picker no longer runs a live self-drawing loop — the roughness is baked into
/// seeded, cached paths so a still frame is enough to tell the materials apart.
class LineStylePreview extends StatelessWidget {
  const LineStylePreview({
    super.key,
    required this.style,
    this.color,
    this.animate = false,
    this.panel = false,
  });

  final LineStyle style;
  final Color? color;

  /// Ignored. Kept so existing call sites continue to compile.
  final bool animate;
  final bool panel;

  @override
  Widget build(BuildContext context) {
    return TallyGroupView(
      style: style,
      count: kTallyGroupSize,
      color: color,
      panel: panel,
    );
  }
}
