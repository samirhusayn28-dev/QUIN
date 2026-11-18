import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../features/widgets/widgets.dart';
import 'stats_math.dart';
import 'stats_cards.dart';
import 'stats_charts.dart';
import 'stats_comparison.dart';

enum StatsPeriod { day, week, month, year, all }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsPeriod _period = StatsPeriod.week;
  String? _selectedCounterId;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final counters = ref.watch(countersStreamProvider);

    return Scaffold(
      backgroundColor: context.neo.paperAlt,
      bottomNavigationBar: const AppBottomNav(current: AppTab.stats),
      appBar: AppBar(
        backgroundColor: context.neo.paperAlt,
        title: Text('Stats', style: AppTypography.display(22, 1.0, -0.6)),
        actions: <Widget>[
          IconButton(
            key: const Key('stats-export-button'),
            tooltip: 'Export as image',
            icon: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.ios_share_rounded),
            onPressed: _exporting ? null : _exportImage,
          ),
        ],
      ),
      body: counters.when(
        data: (items) {
          if (items.isEmpty) return _emptyState(context);
          final counter = _selectedCounterId != null
              ? items.firstWhere((c) => c.id == _selectedCounterId, orElse: () => items.first)
              : items.first;
          final taps = ref.watch(tapsProvider(counter.id));
          return taps.when(
            data: (counterTaps) {
              final ct = counterTaps
                  .map((t) => TapEvent(timestamp: t.at, delta: t.delta, counterId: t.counterId))
                  .toList();
              return _buildStats(context, counter, ct, items);
            },
            loading: () => _loadingState(),
            error: (_, __) => _errorState(),
          );
        },
        loading: () => _loadingState(),
        error: (_, __) => _errorState(),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => _CenteredState(
        icon: Icons.insights_rounded,
        title: 'No stats yet',
        message: 'Create a counter and start tapping — your streaks, charts and heatmap will appear here.',
        action: NeoButton(
          label: 'New Counter',
          onPressed: () => _showSnack(context, 'Open the Counters tab to add one.'),
        ),
      );

  Widget _loadingState() => const _CenteredState(
        icon: Icons.hourglass_top_rounded,
        title: 'Crunching numbers',
        message: 'Building your stats…',
      );

  Widget _errorState() => const _CenteredState(
        icon: Icons.warning_amber_rounded,
        title: 'Something broke',
        message: 'We could not read your stats. Try again in a moment.',
      );

  Widget _buildStats(
    BuildContext context,
    Counter counter,
    List<TapEvent> counterTaps,
    List<Counter> allCounters,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: _statWidgets(counter, counterTaps, allCounters),
    );
  }

  /// Every stats block in order. Shared by the on-screen list and the exported
  /// image so both always show the same thing.
  List<Widget> _statWidgets(
    Counter counter,
    List<TapEvent> counterTaps,
    List<Counter> allCounters,
  ) {
    final summary = StatsMath.summarize(counterTaps, targetValue: counter.targetValue);
    final heatmap = StatsMath.buildHeatmap(counterTaps, weeks: 52);
    final sessions = StatsMath.detectSessions(counterTaps);
    final hourly = StatsMath.hourOfDay(counterTaps);
    final weekly = List<int>.generate(7, (i) {
      final d = <TapEvent>[];
      for (final t in counterTaps) {
        if (t.timestamp.weekday == (i + 1) % 7 + 1) d.add(t);
      }
      return d.fold<int>(0, (s, t) => s + t.delta);
    });

    final start = _periodStart(_period);
    final filtered = counterTaps.where((t) => t.timestamp.isAfter(start)).toList();
    final cumulative = StatsMath.cumulative(filtered, start: start, end: DateTime.now());
    final dailyAgg = StatsMath.aggregate(
      filtered,
      level: AggregationLevel.daily,
      start: start,
      end: DateTime.now(),
    );

    return <Widget>[
        // Per-counter view picker. The all-counters comparison lives further
        // down in `ComparisonCard`, so both views are always reachable.
        _CounterSelector(
          counters: allCounters,
          selectedId: counter.id,
          onSelect: (id) => setState(() => _selectedCounterId = id),
        ),
        const SizedBox(height: 14),
        _HeroTile(counter: counter, total: summary.total),
        const SizedBox(height: 16),
        StreakCard(summary: summary),
        const SizedBox(height: 14),
        BentoRow(children: <Widget>[
          SummaryCard(summary: summary),
          StatsSelector(period: _period, onChanged: (p) => setState(() => _period = p)),
        ]),
        const SizedBox(height: 14),
        BentoRow(children: <Widget>[
          HeatmapCard(heatmap: heatmap),
          HourlyCard(hourly: hourly),
        ]),
        const SizedBox(height: 14),
        BentoRow(children: <Widget>[
          CumulativeChart(cumulative: cumulative),
          BarChartCard(data: dailyAgg, title: 'Daily'),
        ]),
        const SizedBox(height: 14),
        BentoRow(children: <Widget>[
          RadialChart(hourly: hourly),
          DayOfWeekCard(weekly: weekly),
        ]),
        const SizedBox(height: 14),
        SessionStatsCard(sessions: sessions),
        const SizedBox(height: 14),
        GoalProgressRing(counter: counter, current: summary.total),
        const SizedBox(height: 14),
        MilestonesCard(taps: counterTaps),
        const SizedBox(height: 14),
        ComparisonCard(allCounters: allCounters, counterTaps: counterTaps),
        const StatsFooter(),
    ];
  }

  /// Exports the whole stats page — not just the visible part — as a single
  /// long PNG and hands it to the system share sheet.
  Future<void> _exportImage() async {
    if (_exporting) return;
    final counters = ref.read(countersStreamProvider).value;
    if (counters == null || counters.isEmpty) {
      _showSnack(context, 'No stats to export yet.');
      return;
    }
    final counter = _selectedCounterId != null
        ? counters.firstWhere((c) => c.id == _selectedCounterId,
            orElse: () => counters.first)
        : counters.first;
    final raw = ref.read(tapsProvider(counter.id)).value;
    final events = (raw ?? const <Tap>[])
        .map((t) => TapEvent(timestamp: t.at, delta: t.delta, counterId: t.counterId))
        .toList();

    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await _renderStatsImage(counter, events, counters);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/quin-stats-${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(file.path, mimeType: 'image/png', name: 'QUIN stats'),
          ],
          subject: 'QUIN stats',
          title: 'QUIN stats',
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Renders the full, un-scrolled stats layout into an image. The layout is
  /// built inside an off-screen overlay (so every widget exists at its real
  /// size), painted once, then rasterised at a high pixel ratio.
  Future<Uint8List> _renderStatsImage(
    Counter counter,
    List<TapEvent> events,
    List<Counter> allCounters,
  ) async {
    final key = GlobalKey();
    final width = MediaQuery.of(context).size.width;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 0,
        child: Transform.translate(
          offset: const Offset(-20000, 0),
          child: StatsExportLayout(
            boundaryKey: key,
            width: width,
            children: _statWidgets(counter, events, allCounters),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data!.buffer.asUint8List();
    } finally {
      if (entry.mounted) entry.remove();
    }
  }

  DateTime _periodStart(StatsPeriod p) {
    final now = DateTime.now();
    switch (p) {
      case StatsPeriod.day:
        return DateTime(now.year, now.month, now.day);
      case StatsPeriod.week:
        return now.subtract(Duration(days: now.weekday - 1));
      case StatsPeriod.month:
        return DateTime(now.year, now.month, 1);
      case StatsPeriod.year:
        return DateTime(now.year, 1, 1);
      case StatsPeriod.all:
        return DateTime(2000);
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Horizontal chips that choose which counter the stats page is showing.
class _CounterSelector extends StatelessWidget {
  const _CounterSelector({
    required this.counters,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Counter> counters;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (counters.length < 2) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: counters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = counters[i];
          final selected = c.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(c.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Color(c.accentColor) : NeoPalette.paper,
                border: Border.all(color: NeoPalette.ink, width: 2),
                borderRadius: BorderRadius.circular(NeoPalette.radius),
                boxShadow: selected
                    ? const <BoxShadow>[
                        BoxShadow(color: NeoPalette.ink, offset: Offset(3, 3)),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                c.name,
                style: AppTypography.grotesk(
                  size: 13,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Sticker-bordered hero showing the selected counter at a glance.
class _HeroTile extends StatelessWidget {
  const _HeroTile({required this.counter, required this.total});

  final Counter counter;
  final int total;

  @override
  Widget build(BuildContext context) {
    final accent = Color(counter.accentColor);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent,
        border: Border.all(color: NeoPalette.ink, width: 3),
        borderRadius: BorderRadius.circular(NeoPalette.radius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: NeoPalette.ink, offset: Offset(6, 6)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  counter.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.grotesk(size: 13, weight: FontWeight.w700, spacing: 0.8),
                ),
                const SizedBox(height: 6),
                Text('$total', style: AppTypography.display(44, 1.0, -1.5)),
                Text(
                  'TOTAL TAPS',
                  style: AppTypography.grotesk(size: 11, weight: FontWeight.w700, spacing: 0.8),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NeoPalette.paper,
              border: Border.all(color: NeoPalette.ink, width: 3),
              borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
            ),
            child: const Icon(Icons.bar_chart_rounded, size: 30),
          ),
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 52),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.display(26, 1.05, -0.8), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.grotesk(size: 14, color: NeoPalette.inkSoft),
            ),
            if (action != null) ...<Widget>[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// Lays the whole stats page out at its natural (unbounded) height inside a
/// strip of [width], so the export can capture far more than one screenful.
///
/// The caller puts this in an overlay entry as a `Positioned` child of a
/// `Stack`; positioned Stack children are laid out with *unbounded* height, so
/// fixing only the width here lets the page grow to its full length. Wrapping
/// the boundary in a bounded box (or a plain `Positioned.fill`) would crop the
/// exported image at the first screenful.
class StatsExportLayout extends StatelessWidget {
  const StatsExportLayout({
    super.key,
    required this.boundaryKey,
    required this.width,
    required this.children,
  });

  /// Key on the [RepaintBoundary] the caller rasterises.
  final Key boundaryKey;
  final double width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: NeoPalette.paperAlt,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
