import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:tally_counter/features/counters/counters_screen.dart';
import 'package:tally_counter/features/settings/settings_screen.dart';
import 'package:tally_counter/features/stats/stats_screen.dart';
import 'package:tally_counter/features/tally/western_tally_screen.dart';

import '../support/test_harness.dart';

/// Leak checks for the screens that own long-lived controllers/tickers.
///
/// `LeakTesting` is enabled globally (ignoring everything by default) in
/// `test/flutter_test_config.dart`; these tests opt back in.
LeakTesting get _tracked => LeakTesting.settings.withTrackedAll();

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets(
    'tally screen disposes tickers, focus node and volume subscription',
    (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);
      final id = (await db.getAllCounters()).first.id;

      await pumpSubject(
        tester,
        WesternTallyScreen(counterId: id, enableKeepAwake: false),
        db: db,
      );
      await tester.tap(find.byType(WesternTallyScreen));
      await tester.pump(const Duration(milliseconds: 200));
      await _unmount(tester);
    },
    experimentalLeakTesting: _tracked,
  );

  testWidgets(
    'counters screen disposes its scroll/state objects',
    (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);

      await pumpSubject(tester, const CountersScreen(), db: db);
      await _unmount(tester);
    },
    experimentalLeakTesting: _tracked,
  );

  testWidgets(
    'stats screen disposes chart/state objects',
    (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);

      await pumpSubject(tester, const StatsScreen(), db: db);
      await _unmount(tester);
    },
    experimentalLeakTesting: _tracked,
  );

  testWidgets(
    'settings screen disposes its state objects',
    (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);

      await pumpSubject(tester, const SettingsScreen(), db: db);
      await _unmount(tester);
    },
    experimentalLeakTesting: _tracked,
  );
}
