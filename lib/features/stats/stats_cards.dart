import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import 'stats_card.dart';
import 'stats_math.dart';
import 'stats_screen.dart';

/// Lays bento tiles in a row on wide screens and stacks them on phones.
class BentoRow extends StatelessWidget {
  const BentoRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Phones are too narrow to sit two bento cards side by side without
        // clipping; stack them below the foldable breakpoint.
        if (constraints.maxWidth < AppBreakpoints.foldableMin) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (var i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((c) => Expanded(child: c)).toList(),
        );
      },
    );
  }
}

class StatsSelector extends StatelessWidget {
  const StatsSelector({required this.period, required this.onChanged, super.key});

  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: 'Period',
      accent: NeoPalette.cyan,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: StatsPeriod.values.map((p) {
          final sel = p == period;
          return GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? NeoPalette.yellow : Colors.transparent,
                border: Border.all(color: NeoPalette.ink, width: 2),
                borderRadius: BorderRadius.circular(999),
                boxShadow: sel
                    ? const <BoxShadow>[BoxShadow(color: NeoPalette.ink, offset: Offset(2, 2))]
                    : null,
              ),
              child: Text(
                p.name.toUpperCase(),
                style: AppTypography.grotesk(size: 11, weight: FontWeight.w700, spacing: 0.6),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  const StreakCard({required this.summary, super.key});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: 'Streak',
      accent: NeoPalette.orange,
      child: Row(
        children: <Widget>[
          Expanded(
            child: StatBig(
              value: '${summary.currentStreak}',
              label: 'Current',
              accent: NeoPalette.orange,
            ),
          ),
          Container(width: 2, height: 40, color: NeoPalette.ink),
          const SizedBox(width: 14),
          Expanded(
            child: StatBig(value: '${summary.longestStreak}', label: 'Longest'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: summary.streakFreezeUsed ? NeoPalette.cyan : NeoPalette.white,
              border: Border.all(color: NeoPalette.ink, width: 2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              summary.streakFreezeUsed ? 'FREEZE ON' : 'FREEZE OFF',
              style: AppTypography.grotesk(size: 10, weight: FontWeight.w700, spacing: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.summary, super.key});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      title: 'Summary',
      accent: NeoPalette.lime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: <Widget>[
              StatBig(value: '${summary.total}', label: 'Total', accent: NeoPalette.ink, size: 26),
              StatBig(value: summary.avgPerActiveDay.toStringAsFixed(1), label: 'Avg / day', size: 26),
              StatBig(value: '${summary.bestDay}', label: 'Best day', size: 26),
              StatBig(value: summary.stdDev.toStringAsFixed(1), label: 'Std dev', size: 26),
            ],
          ),
          if (summary.projectedGoalDate != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: NeoPalette.paperAlt,
                border: Border.all(color: NeoPalette.ink, width: 2),
                borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.flag_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Goal around ${_formatGoalDate(summary.projectedGoalDate!)}',
                    style: AppTypography.grotesk(size: 12, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatGoalDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
