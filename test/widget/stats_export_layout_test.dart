import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/features/stats/stats_screen.dart';

/// Item 12 regression: the export must capture the *whole* stats page, so the
/// layout it rasterises has to grow past one screenful instead of being clamped
/// to the viewport (which would silently crop the shared image).
void main() {
  testWidgets('export layout grows to the full page height, not one screenful',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: <Widget>[
            // Mirrors the overlay entry: a Positioned child of a Stack, which
            // is laid out with unbounded height.
            Positioned(
              left: 0,
              top: 0,
              child: StatsExportLayout(
                boundaryKey: key,
                width: 412,
                children: <Widget>[
                  for (var i = 0; i < 30; i++) const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final size = key.currentContext!.size!;
    expect(size.width, 412);
    expect(size.height, greaterThanOrEqualTo(30 * 100));
    expect(size.height, greaterThan(915));
  });
}
