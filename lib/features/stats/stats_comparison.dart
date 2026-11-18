import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../data/database/app_database.dart' hide Session;
import 'stats_card.dart';
import 'stats_charts.dart' show kChartAnim;
import 'stats_math.dart';

class DayOfWeekCard extends StatelessWidget {
  const DayOfWeekCard({super.key, required this.weekly});

  final List<int> weekly;

  @override
  Widget build(BuildContext context) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final max = weekly.fold<int>(0, (m, v) => v > m ? v : m);
    final hasData = max > 0;
    return StatsCard(
      title: 'Day of week',
      accent: NeoPalette.purple,
      child: !hasData
          ? Text('No activity yet.', style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft))
          : Column(
              children: List.generate(7, (i) {
                final v = weekly[i];
                final pct = max > 0 ? v / max : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 34,
                        child: Text(days[i],
                            style: AppTypography.grotesk(size: 10, weight: FontWeight.w700)),
                      ),
                      Expanded(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: NeoPalette.paperAlt,
                            border: Border.all(color: NeoPalette.ink, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: pct,
                            child: AnimatedContainer(
                              duration: kChartAnim,
                              decoration: BoxDecoration(
                                color: NeoPalette.purple,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 34,
                        child: Text('$v',
                            textAlign: TextAlign.right,
                            style: AppTypography.grotesk(size: 11, weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}

class SessionStatsCard extends StatelessWidget {
  const SessionStatsCard({super.key, required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const StatsCard(
        title: 'Sessions',
        accent: NeoPalette.teal,
        child: _MiniEmpty(text: 'No sessions recorded yet.'),
      );
    }
    final count = sessions.length;
    final total = sessions.fold<int>(0, (s, e) => s + e.total);
    final avg = total / count;
    final peak = sessions.reduce((a, b) => (a.total > b.total) ? a : b);
    return StatsCard(
      title: 'Sessions',
      accent: NeoPalette.teal,
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: <Widget>[
          StatBig(value: '$count', label: 'Sessions', accent: NeoPalette.teal, size: 26),
          StatBig(value: avg.toStringAsFixed(1), label: 'Avg / session', size: 26),
          StatBig(value: '${peak.total}', label: 'Peak', size: 26),
        ],
      ),
    );
  }
}

class GoalProgressRing extends StatelessWidget {
  const GoalProgressRing({super.key, required this.counter, required this.current});

  final Counter counter;
  final int current;

  @override
  Widget build(BuildContext context) {
    final target = counter.targetValue;
    final pct = (target != null && target > 0) ? (current / target).clamp(0.0, 1.0) : 0.0;
    final rem = (target != null && target > 0) ? (target - current) : 0;
    return StatsCard(
      title: 'Goal',
      accent: NeoPalette.pink,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: pct),
                  duration: kChartAnim,
                  builder: (context, value, _) => SizedBox(
                    width: 78,
                    height: 78,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 9,
                      backgroundColor: NeoPalette.paperAlt,
                      valueColor: const AlwaysStoppedAnimation<Color>(NeoPalette.pink),
                    ),
                  ),
                ),
                Text('${(pct * 100).round()}%',
                    style: AppTypography.display(18, 1.0, -0.5)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (target == null)
                  Text('No target set.',
                      style: AppTypography.grotesk(size: 13, color: NeoPalette.inkSoft))
                else ...<Widget>[
                  Text('$current / $target',
                      style: AppTypography.display(26, 1.0, -1)),
                  const SizedBox(height: 4),
                  Text('$rem to go',
                      style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MilestonesCard extends StatelessWidget {
  const MilestonesCard({super.key, required this.taps});

  final List<TapEvent> taps;

  @override
  Widget build(BuildContext context) {
    final total = taps.fold<int>(0, (s, t) => s + t.delta);
    final milestones = <int>[10, 50, 100, 500, 1000, 5000];
    return StatsCard(
      title: 'Milestones',
      accent: NeoPalette.yellow,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: milestones.map((m) {
          final ok = total >= m;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ok ? NeoPalette.lime : NeoPalette.white,
              border: Border.all(color: NeoPalette.ink, width: 2),
              borderRadius: BorderRadius.circular(999),
              boxShadow: ok
                  ? const <BoxShadow>[BoxShadow(color: NeoPalette.ink, offset: Offset(2, 2))]
                  : null,
            ),
            child: Text('$m',
                style: AppTypography.grotesk(size: 11, weight: FontWeight.w700)),
          );
        }).toList(),
      ),
    );
  }
}

class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.allCounters, required this.counterTaps});

  final List<Counter> allCounters;
  final List<TapEvent> counterTaps;

  @override
  Widget build(BuildContext context) {
    if (allCounters.length < 2) {
      return const StatsCard(
        title: 'Compare',
        accent: NeoPalette.blue,
        child: _MiniEmpty(text: 'Add another counter to compare.'),
      );
    }
    final currentTotal = counterTaps.fold<int>(0, (s, t) => s + t.delta);
    final ranked = List<Counter>.from(allCounters)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    return StatsCard(
      title: 'Compare',
      accent: NeoPalette.blue,
      trailing: Text('this: $currentTotal',
          style: AppTypography.grotesk(size: 11, weight: FontWeight.w700, color: NeoPalette.inkSoft)),
      child: Column(
        children: ranked.take(4).map((c) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(c.accentColor),
                    border: Border.all(color: NeoPalette.ink, width: 2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.grotesk(size: 13, weight: FontWeight.w700)),
                ),
                Text('${c.currentValue}', style: AppTypography.display(16, 1.0, -0.5)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StatsFooter extends StatelessWidget {
  const StatsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 8),
      child: Column(
        children: <Widget>[
          const Icon(Icons.bar_chart_rounded, size: 22),
          const SizedBox(height: 6),
          // Wordmark: the export image carries the app name as its footer.
          Text(
            'QUIN',
            style: AppTypography.display(18, 1.0, -0.4),
          ),
        ],
      ),
    );
  }
}

class CumulativeChart extends StatelessWidget {
  const CumulativeChart({super.key, required this.cumulative});

  final List<CumulativePoint> cumulative;

  @override
  Widget build(BuildContext context) {
    final hasData = cumulative.length > 1;
    return StatsCard(
      title: 'Cumulative',
      accent: NeoPalette.orange,
      child: hasData
          ? SizedBox(
              height: 170,
              child: SfCartesianChart(
                plotAreaBorderColor: NeoPalette.ink,
                primaryXAxis: DateTimeAxis(
                  labelStyle: AppTypography.grotesk(size: 10, weight: FontWeight.w700),
                  majorGridLines: const MajorGridLines(color: Colors.transparent),
                  axisLine: const AxisLine(color: NeoPalette.ink, width: 2),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: AppTypography.grotesk(size: 10, weight: FontWeight.w700),
                  majorGridLines: MajorGridLines(color: NeoPalette.ink.withValues(alpha: 0.12)),
                  axisLine: const AxisLine(color: NeoPalette.ink, width: 2),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                series: <CartesianSeries<CumulativePoint, DateTime>>[
                  AreaSeries<CumulativePoint, DateTime>(
                    animationDuration: kChartAnim.inMilliseconds.toDouble(),
                    dataSource: cumulative,
                    xValueMapper: (CumulativePoint d, _) => d.date,
                    yValueMapper: (CumulativePoint d, _) => d.value,
                    color: NeoPalette.orange.withValues(alpha: 0.35),
                    borderColor: NeoPalette.ink,
                    borderWidth: 3,
                  ),
                ],
              ),
            )
          : const _MiniEmpty(text: 'Not enough data for this period.'),
    );
  }
}

class BarChartCard extends StatelessWidget {
  const BarChartCard({super.key, required this.data, required this.title});

  final List<ChartBucket> data;
  final String title;

  @override
  Widget build(BuildContext context) {
    final hasData = data.any((b) => b.value > 0);
    return StatsCard(
      title: title,
      accent: NeoPalette.yellow,
      child: hasData
          ? SizedBox(
              height: 170,
              child: SfCartesianChart(
                plotAreaBorderColor: NeoPalette.ink,
                primaryXAxis: CategoryAxis(
                  labelStyle: AppTypography.grotesk(size: 10, weight: FontWeight.w700),
                  majorGridLines: const MajorGridLines(color: Colors.transparent),
                  axisLine: const AxisLine(color: NeoPalette.ink, width: 2),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: AppTypography.grotesk(size: 10, weight: FontWeight.w700),
                  majorGridLines: MajorGridLines(color: NeoPalette.ink.withValues(alpha: 0.12)),
                  axisLine: const AxisLine(color: NeoPalette.ink, width: 2),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                series: <CartesianSeries<ChartBucket, String>>[
                  ColumnSeries<ChartBucket, String>(
                    animationDuration: kChartAnim.inMilliseconds.toDouble(),
                    dataSource: data,
                    xValueMapper: (ChartBucket d, _) => d.label,
                    yValueMapper: (ChartBucket d, _) => d.value,
                    color: NeoPalette.yellow,
                    borderColor: NeoPalette.ink,
                    borderWidth: 2,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
            )
          : const _MiniEmpty(text: 'No data in this period.'),
    );
  }
}

class RadialChart extends StatelessWidget {
  const RadialChart({super.key, required this.hourly});

  final List<ChartBucket> hourly;

  @override
  Widget build(BuildContext context) {
    final maxV = hourly.fold<int>(0, (m, v) => v.value > m ? v.value : m);
    return StatsCard(
      title: '24h radial',
      accent: NeoPalette.pink,
      child: maxV <= 0
          ? const _MiniEmpty(text: 'No hourly activity.')
          : SizedBox(
              height: 190,
              child: SfCircularChart(
                series: <CircularSeries<ChartBucket, String>>[
                  RadialBarSeries<ChartBucket, String>(
                    animationDuration: kChartAnim.inMilliseconds.toDouble(),
                    dataSource: hourly,
                    xValueMapper: (ChartBucket d, _) => d.label.substring(0, 2),
                    yValueMapper: (ChartBucket d, _) => d.value,
                    maximumValue: maxV.toDouble(),
                    innerRadius: '28%',
                    trackColor: NeoPalette.paperAlt,
                    trackBorderColor: NeoPalette.ink,
                    trackBorderWidth: 1,
                    pointColorMapper: (ChartBucket d, _) => NeoPalette.pink.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MiniEmpty extends StatelessWidget {
  const _MiniEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: NeoPalette.paperAlt,
        border: Border.all(color: NeoPalette.ink, width: 2),
        borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
      ),
    );
  }
}
