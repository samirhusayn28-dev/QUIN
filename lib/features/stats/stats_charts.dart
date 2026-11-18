import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import 'stats_card.dart';
import 'stats_math.dart';

/// Renders a chart series with a load animation so tiles animate in.
const Duration kChartAnim = Duration(milliseconds: 550);

class HeatmapCard extends StatelessWidget {
  const HeatmapCard({super.key, required this.heatmap});

  final Map<DateTime, int> heatmap;

  /// Sticker-flavoured intensity ramp (no terminal green here).
  static Color _cell(int value, int max) {
    if (value <= 0) return NeoPalette.white;
    final t = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    if (t < 0.34) return NeoPalette.lime;
    if (t < 0.67) return NeoPalette.yellow;
    return NeoPalette.orange;
  }

  @override
  Widget build(BuildContext context) {
    final entries = heatmap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final max =
        entries.isEmpty ? 0 : entries.map((e) => e.value).reduce(math.max);

    // One column per ISO week (7 days), newest last.
    final weeks = <List<MapEntry<DateTime, int>>>[];
    for (var i = 0; i < entries.length; i += 7) {
      weeks.add(entries.sublist(i, math.min(i + 7, entries.length)));
    }

    return StatsCard(
      title: 'Activity',
      accent: NeoPalette.lime,
      child: entries.isEmpty
          ? _EmptyHint(text: 'No taps yet — your heatmap will bloom here.')
          : RepaintBoundary(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((w) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Column(
                        children: w.map((e) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: _cell(e.value, max),
                              border:
                                  Border.all(color: NeoPalette.ink, width: 1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}

class HourlyCard extends StatelessWidget {
  const HourlyCard({super.key, required this.hourly});

  final List<ChartBucket> hourly;

  @override
  Widget build(BuildContext context) {
    final hasData = hourly.any((b) => b.value > 0);
    return StatsCard(
      title: 'By hour',
      accent: NeoPalette.cyan,
      child: hasData
          ? RepaintBoundary(
              child: SizedBox(
                height: 170,
                child: SfCartesianChart(
                  plotAreaBorderColor: NeoPalette.ink,
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: CategoryAxis(
                    labelStyle: AppTypography.grotesk(
                        size: 10, weight: FontWeight.w700),
                    majorGridLines:
                        const MajorGridLines(color: Colors.transparent),
                    axisLine: const AxisLine(color: NeoPalette.ink, width: 2),
                    majorTickLines: const MajorTickLines(size: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: AppTypography.grotesk(
                        size: 10, weight: FontWeight.w700),
                    majorGridLines: MajorGridLines(
                        color: NeoPalette.ink.withValues(alpha: 0.12)),
                    axisLine: const AxisLine(color: NeoPalette.ink, width: 2),
                    majorTickLines: const MajorTickLines(size: 0),
                  ),
                  series: <CartesianSeries<ChartBucket, String>>[
                    ColumnSeries<ChartBucket, String>(
                      animationDuration: kChartAnim.inMilliseconds.toDouble(),
                      dataSource: hourly,
                      xValueMapper: (ChartBucket d, _) =>
                          d.label.substring(0, 2),
                      yValueMapper: (ChartBucket d, _) => d.value,
                      color: NeoPalette.cyan,
                      borderColor: NeoPalette.ink,
                      borderWidth: 2,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            )
          : _EmptyHint(text: 'No hourly activity in this period.'),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        color: NeoPalette.paperAlt,
        border: Border.all(color: NeoPalette.ink, width: 2),
        borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.sticky_note_2_outlined, size: 28),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
          ),
        ],
      ),
    );
  }
}
