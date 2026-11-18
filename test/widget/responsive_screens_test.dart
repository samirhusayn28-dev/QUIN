import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/features/backup/backup_screen.dart';
import 'package:tally_counter/features/counters/counter_edit_screen.dart';
import 'package:tally_counter/features/counters/counters_screen.dart';
import 'package:tally_counter/features/history/history_screen.dart';
import 'package:tally_counter/features/onboarding/onboarding_screen.dart';
import 'package:tally_counter/features/settings/settings_screen.dart';
import 'package:tally_counter/features/stats/stats_screen.dart';
import 'package:tally_counter/features/tally/western_tally_screen.dart';
import 'package:tally_counter/features/widgets_service/widget_config_screen.dart';

import '../support/test_harness.dart';

const List<Size> _sizes = <Size>[
  Size(360, 640), // small phone portrait
  Size(412, 915), // phone portrait
  Size(768, 1024), // tablet portrait
  Size(1280, 800), // tablet landscape
];

const List<double> _scales = <double>[1.0, 1.5];
const List<Brightness> _brightnesses = <Brightness>[
  Brightness.light,
  Brightness.dark,
];

void main() {
  final screens = <String, Widget Function(String id)>{
    'counters': (_) => const CountersScreen(),
    'counter_new': (_) => const CounterEditScreen(),
    'counter_edit': (id) => CounterEditScreen(counterId: id),
    'tally': (id) => WesternTallyScreen(counterId: id, enableKeepAwake: false),
    'stats': (_) => const StatsScreen(),
    'history': (_) => const HistoryScreen(),
    'settings': (_) => const SettingsScreen(),
    'backup': (_) => const BackupScreen(),
    'onboarding': (_) => const OnboardingScreen(),
    'widget_config': (_) => const WidgetConfigScreen(appWidgetId: 1),
  };

  for (final entry in screens.entries) {
    testWidgets('renders ${entry.key} at every size/scale/brightness',
        (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);
      final counters = await db.getAllCounters();
      final id = counters.isEmpty ? 'missing' : counters.first.id;

      for (final size in _sizes) {
        for (final scale in _scales) {
          for (final brightness in _brightnesses) {
            await pumpSubject(
              tester,
              entry.value(id),
              db: db,
              size: size,
              textScale: scale,
              brightness: brightness,
            );
            final exception = tester.takeException();
            if (exception != null) {
              debugPrint('DETAIL>>> ${lastFlutterErrorDetails?.toString()}');
            }
            expect(
              exception,
              isNull,
              reason: '${entry.key} @ $size '
                  'scale=$scale brightness=$brightness',
            );
          }
        }
      }

      // Dispose database-backed providers and flush drift's zero-duration
      // close timer so no pending timer survives into the test teardown.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }
}
