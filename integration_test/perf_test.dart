import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tally_counter/app.dart';
import 'package:tally_counter/data/database/app_database.dart';
import 'package:tally_counter/data/providers.dart';
import 'package:tally_counter/features/history/history_screen.dart';
import 'package:tally_counter/features/tally/western_tally_screen.dart';
import 'package:tally_counter/router/app_router.dart';

/// Budgets the journey must stay inside on a real device.
const double kAvgBuildRasterBudgetMs = 8;
const double kWorstFrameBudgetMs = 16;
const double kColdStartBudgetMs = 1500;
const int kTapCount = 300;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('counting journey stays inside the frame budgets', (tester) async {
    final db = AppDatabase();
    addTearDown(db.close);
    await db.deleteAllData();
    await db.seedIfEmpty();
    final perfCounter = await db.createCounter(name: 'Perf counter');

    // Cold start: measure from first build to first painted frame.
    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const TallyApp(),
      ),
    );
    await tester.pump();
    final coldStartMs = stopwatch.elapsedMilliseconds;

    // Sanity: the counters list renders and scrolls.
    await _settle(tester);
    final list = find.byType(ReorderableListView);
    if (list.evaluate().isNotEmpty) {
      await tester.drag(list, const Offset(0, -160));
      await _settle(tester);
    }

    // 200 taps on the tally screen under a frame-timing capture.
    appRouter.go('/counter/${perfCounter.id}');
    await _settle(tester);
    expect(find.byType(WesternTallyScreen), findsOneWidget);

    await binding.watchPerformance(() async {
      for (var i = 0; i < kTapCount; i++) {
        await tester.tapAt(tester.getCenter(find.byType(WesternTallyScreen)));
        await tester.pump(const Duration(milliseconds: 16));
      }
    }, reportKey: 'tap_journey');

    // Timeline capture while opening every route and switching filters.
    Object? timelineError;
    await binding.traceAction(() async {
      appRouter.go('/stats');
      await _settle(tester);
      for (final label in <String>['WEEK', 'MONTH', 'YEAR', 'ALL', 'DAY']) {
        final chip = find.text(label);
        if (chip.evaluate().isNotEmpty) {
          await tester.tap(chip.first);
          await _settle(tester);
        }
      }
      appRouter.go('/history');
      await _settle(tester);
      final history = find.byType(HistoryScreen);
      if (history.evaluate().isNotEmpty) {
        await tester.drag(history, const Offset(0, -240));
        await _settle(tester);
      }
      for (final route in <String>[
        '/counter/new',
        '/counter/${perfCounter.id}/edit',
        '/settings',
        '/backup',
        '/widget-config?id=1',
        '/onboarding',
        '/',
      ]) {
        appRouter.go(route);
        await _settle(tester);
      }
    }, reportKey: 'navigation_timeline').catchError((Object error) {
      timelineError = error;
    });

    final reportData = binding.reportData ?? <String, dynamic>{};
    final frames = _asMap(reportData['tap_journey']);
    final avgBuildRaster = _num(frames['average_frame_build_time_millis']) +
        _num(frames['average_frame_rasterizer_time_millis']);
    final worstFrame = math.max(
      _num(frames['worst_frame_build_time_millis']),
      _num(frames['worst_frame_rasterizer_time_millis']),
    );

    final report = <String, dynamic>{
      'generated_at': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'tap_count': kTapCount,
      'cold_start_ms': coldStartMs,
      'avg_build_plus_raster_ms': avgBuildRaster,
      'worst_frame_ms': worstFrame,
      'frame_count': frames['frame_count'],
      'timeline_event_count': _timelineEventCount(reportData['navigation_timeline']),
      'timeline_error': timelineError?.toString(),
      'budgets': <String, double>{
        'avg_build_plus_raster_ms': kAvgBuildRasterBudgetMs,
        'worst_frame_ms': kWorstFrameBudgetMs,
        'cold_start_ms': kColdStartBudgetMs,
      },
      'passed': coldStartMs < kColdStartBudgetMs &&
          avgBuildRaster < kAvgBuildRasterBudgetMs &&
          worstFrame < kWorstFrameBudgetMs,
    };

    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['perf_report'] = report;
    await _writePerfReport(report);

    expect(coldStartMs, lessThan(kColdStartBudgetMs),
        reason: 'cold start must stay under ${kColdStartBudgetMs}ms');
    expect(avgBuildRaster, lessThan(kAvgBuildRasterBudgetMs),
        reason:
            'average build+raster must stay under ${kAvgBuildRasterBudgetMs}ms');
    expect(worstFrame, lessThan(kWorstFrameBudgetMs),
        reason: 'worst frame must stay under ${kWorstFrameBudgetMs}ms');
  });
}

double _num(Object? value) => (value as num?)?.toDouble() ?? 0;

int _timelineEventCount(Object? timeline) {
  final map = _asMap(timeline);
  final events = map['traceEvents'];
  return events is List ? events.length : 0;
}

Map<String, dynamic> _asMap(Object? value) =>
    (value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _writePerfReport(Map<String, dynamic> report) async {
  const encoder = JsonEncoder.withIndent('  ');
  for (final path in <String>['/perf_report.json', 'perf_report.json']) {
    try {
      await File(path).writeAsString(encoder.convert(report));
      return;
    } catch (_) {
      // Try the next candidate; on-device roots are not always writable.
    }
  }
}
