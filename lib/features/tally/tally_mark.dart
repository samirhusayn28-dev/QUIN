import 'package:flutter/material.dart';

import '../../tally_styles/registry.dart';

/// One completed group in the tally grid. Marks only — no material panel — so
/// the grid stays a clean tally, and the group keeps its diagonal.
class CompletedGroupMark extends StatelessWidget {
  const CompletedGroupMark({
    super.key,
    required this.lineStyle,
    this.color,
  });

  final LineStyle lineStyle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: LineStyleGroupPainter(
          style: lineStyle,
          countInGroup: kTallyGroupSize,
          color: color,
          strokeScale: 1.15,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// The in-progress group in the middle of the tally screen.
///
/// [marks] is the single source of truth for how many strokes are visible in
/// this group (0..[kTallyGroupSize]). While the fifth-tap animation runs it is
/// held at [kTallyGroupSize] so the diagonal can sweep across the four lines
/// before the finished group shrinks and slides into the grid.
class ActiveTallyGroup extends StatelessWidget {
  const ActiveTallyGroup({
    super.key,
    required this.lineStyle,
    required this.marks,
    this.color,
    this.fifthProgress = 1,
    this.newestScale = 1,
  });

  final LineStyle lineStyle;

  /// Visible strokes in the active group, 0..5. `5` draws the four lines plus
  /// the diagonal slash.
  final int marks;

  final Color? color;

  /// 0..1 draw progress of the fifth stroke.
  final double fifthProgress;

  /// Scale pulse for the newest mark only.
  final double newestScale;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: LineStyleGroupPainter(
          style: lineStyle,
          countInGroup: marks.clamp(0, kTallyGroupSize),
          color: color,
          fifthProgress: fifthProgress,
          newestScale: newestScale,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
