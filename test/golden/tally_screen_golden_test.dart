import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/features/tally/tally_mark.dart';
import 'package:tally_counter/features/tally/western_tally_screen.dart';
import 'package:tally_counter/tally_styles/line_style_painter.dart';

import '../support/test_harness.dart';

/// Golden captures of the tally screen at every supported size class.
///
/// The grain shader is gated off so the background is deterministic; the
/// shader itself is covered by `test/golden/tally_styles_test.dart`.
void main() {
  const sizes = <String, Size>{
    'phone_portrait': Size(360, 640),
    'phone_large': Size(412, 915),
    'tablet_portrait': Size(768, 1024),
    'tablet_landscape': Size(1280, 800),
  };

  sizes.forEach((name, size) {
    testWidgets('tally screen golden @ $name (${size.width}x${size.height})',
        (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);
      final id = (await db.getAllCounters()).first.id;

      await pumpSubject(
        tester,
        WesternTallyScreen(counterId: id, enableKeepAwake: false),
        db: db,
        size: size,
        reducedEffects: true,
      );
      // Fixed pumps (not pumpAndSettle) keep the capture deterministic and
      // avoid draining google_fonts' async fetch in the test zone.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      await expectLater(
        find.byType(Scaffold).first,
        matchesGoldenFile('goldens/tally_$name.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  });

  // Golden checkpoints for the two interesting tap states: the fifth tap
  // (group complete, diagonal drawn) and the sixth (fresh group, diagonal back
  // to rest). Both must match the captured references at the phone size.
  for (final tap in <int>[5, 6]) {
    testWidgets('tally golden @ tap $tap', (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase(withData: false);
      addTearDown(db.close);
      final counter = await db.createCounter(name: 'Golden', lineStyle: 'ink');

      await pumpSubject(
        tester,
        WesternTallyScreen(counterId: counter.id, enableKeepAwake: false),
        db: db,
        size: const Size(412, 915),
        reducedEffects: true,
      );
      await tester.pump(const Duration(milliseconds: 120));

      final center =
          tester.getCenter(find.byKey(const Key('tally-tap-target')));
      for (var i = 0; i < tap; i++) {
        await tester.tapAt(center);
        for (var p = 0; p < 10; p++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
      }

      // Guard against a "both captures look identical" regression: assert the
      // state that actually differs between the fifth and sixth tap before
      // snapshotting the pixels.
      final active =
          tester.widget<ActiveTallyGroup>(find.byType(ActiveTallyGroup));
      expect(active.marks, tap % kTallyGroupSize);
      expect(active.newestScale, 1.0, reason: 'newest mark must rest at 1.0');
      expect(find.byType(CompletedGroupMark), findsNWidgets(tap ~/ kTallyGroupSize));
      expect((await db.getCounter(counter.id))?.currentValue, tap);

      await expectLater(
        find.byType(WesternTallyScreen),
        matchesGoldenFile('goldens/tally_tap_$tap.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }
}
