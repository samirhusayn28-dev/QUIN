import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/features/tally/tally_mark.dart';
import 'package:tally_counter/features/tally/western_tally_screen.dart';

import '../support/test_harness.dart';

/// Item 9 regression: tapping 1..25 must leave exactly `n ~/ 5` completed marks
/// in the grid and `n % 5` marks in the active group at every step, including
/// the fifth tap where the freshly-completed group animates into the grid.
void main() {
  testWidgets('taps 1..25 keep the grid, active group and value in lock-step',
      (tester) async {
    mockPlatformChannels();
    final db = await seededDatabase(withData: false);
    addTearDown(db.close);
    final counter = await db.createCounter(
      name: 'Tap Test',
      lineStyle: 'ink',
      startValue: 0,
      stepSize: 1,
      direction: 1,
    );

    await pumpSubject(
      tester,
      WesternTallyScreen(counterId: counter.id, enableKeepAwake: false),
      db: db,
      reducedEffects: true,
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final tapFinder = find.byKey(const Key('tally-tap-target'));
    final center = tester.getCenter(tapFinder);

    for (var n = 1; n <= 25; n++) {
      await tester.tapAt(center);
      // Process the tap, the drift write, the stream emission and — on every
      // fifth tap — the full group-slide animation (900ms).
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(
        find.byType(CompletedGroupMark),
        findsNWidgets(n ~/ 5),
        reason: 'after tap $n the grid should hold ${n ~/ 5} completed groups',
      );

      final active = tester.widget<ActiveTallyGroup>(find.byType(ActiveTallyGroup));
      expect(
        active.marks,
        n % 5,
        reason: 'after tap $n the active group should show ${n % 5} marks',
      );
      // Regression: the newest mark must rest at full scale, otherwise the
      // pulse animation freezes it at 0 and the mark is invisible.
      expect(
        active.newestScale,
        1.0,
        reason: 'after tap $n the newest mark must be fully visible',
      );

      // The persisted value is the single source of truth for the whole screen.
      final stored = await db.getCounter(counter.id);
      expect(stored?.currentValue, n);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
