
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:tally_counter/tally_styles/registry.dart';

/// One golden per line style, plus the pure helpers that decide what a group
/// draws. Every style paints the same 5-bar tally — only the material differs —
/// so a single shared grid keeps the goldens comparable.
void main() {
  group('Line style goldens', () {
    for (final style in LineStyle.values) {
      testGoldens('${style.label} strokes 0-29', (tester) async {
        await tester.pumpWidgetBuilder(
          _buildGrid(
            builder: (count) => TallyGroupView(
              style: style,
              count: count,
              color: const Color(0xFF111111),
            ),
          ),
        );
        await screenMatchesGolden(tester, 'line_${style.id}');
      });
    }
  });

  group('LineStyle', () {
    test('exposes exactly the three lightweight strokes with stable ids', () {
      expect(
        LineStyle.values.map((s) => s.id).toList(),
        <String>['chalk', 'charcoal', 'ink'],
      );
      expect(LineStyle.values.every((s) => s.label.isNotEmpty), isTrue);
    });

    test('falls back to ink for unknown or legacy ids', () {
      expect(LineStyle.fromId('chalk'), LineStyle.chalk);
      expect(LineStyle.fromId('chalk_slate'), LineStyle.chalk);
      expect(LineStyle.fromId('wax_crayon'), LineStyle.chalk);
      expect(LineStyle.fromId('cave_ochre'), LineStyle.charcoal);
      expect(LineStyle.fromId('roman'), LineStyle.ink);
      expect(LineStyle.fromId(''), LineStyle.ink);
      expect(LineStyle.fallback, LineStyle.ink);
    });

    test('every style writes in a colour and has an icon', () {
      for (final style in LineStyle.values) {
        expect(style.stroke.a, greaterThan(0), reason: style.id);
        expect(style.icon.codePoint, greaterThan(0), reason: style.id);
      }
    });
  });

  group('marksForCount', () {
    test('reduces any value to a single 0..5 group', () {
      expect(marksForCount(0), 0);
      expect(marksForCount(1), 1);
      expect(marksForCount(4), 4);
      expect(marksForCount(5), 5);
      expect(marksForCount(6), 1);
      expect(marksForCount(25), 5);
      expect(marksForCount(26), 1);
    });

    test('clamps non-positive counts to an empty group', () {
      expect(marksForCount(-3), 0);
    });
  });

  group('LineStyleGroupPainter', () {
    test('renders every style at every group size without painting errors', () async {
      for (final style in LineStyle.values) {
        for (var count = 1; count <= kTallyGroupSize; count++) {
          final pixels = await _pixels(style, count: count);
          expect(pixels.length, 240 * 120 * 4, reason: '${style.id} @ $count');
          expect(pixels.any((b) => b != 0), isTrue,
              reason: '${style.id} @ $count painted nothing');
        }
      }
    });

    test('every stored material now paints the same single bar look', () async {
      final chalk = await _pixels(LineStyle.chalk);
      final charcoal = await _pixels(LineStyle.charcoal);
      final ink = await _pixels(LineStyle.ink);

      // The Chalk/Charcoal/Ink selector is gone: the three ids are kept only
      // for stored-data compatibility, and all of them draw the one bold bar.
      expect(chalk, equals(charcoal));
      expect(charcoal, equals(ink));
    });

    test('an empty size is ignored instead of throwing', () async {
      final pixels = await _pixels(LineStyle.charcoal, count: 3, size: Size.zero);
      expect(pixels, isEmpty);
    });

    test('a bare group (no material panel) still draws the marks', () async {
      final pixels = await _pixels(LineStyle.charcoal, count: 4, panel: false);
      expect(pixels.any((b) => b != 0), isTrue);
    });
  });
}

/// Rasterises one painted group so tests can make assertions about real output
/// instead of only about the painter not throwing.
Future<List<int>> _pixels(
  LineStyle style, {
  int count = kTallyGroupSize,
  Size size = const Size(240, 120),
  bool panel = true,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  LineStyleGroupPainter(
    style: style,
    countInGroup: count,
    color: const Color(0xFF111111),
    panel: panel,
  ).paint(canvas, size);
  final picture = recorder.endRecording();
  if (size.isEmpty) return <int>[];
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await image.toByteData();
  image.dispose();
  return data!.buffer.asUint8List();
}

Widget _buildGrid({required Widget Function(int) builder}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1100,
        height: 1320,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: 30,
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('$index', style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
                Expanded(child: Center(child: builder(index))),
              ],
            );
          },
        ),
      ),
    ),
  );
}
