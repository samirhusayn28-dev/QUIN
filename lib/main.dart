import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'app.dart';
import 'data/database/app_database.dart';
import 'data/providers.dart';
import 'data/settings/app_settings.dart';
import 'features/widgets_service/widget_callbacks.dart';
import 'router/launch_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Shared App Group used by the iOS lock-screen widget and Live Activity.
  await HomeWidget.setAppGroupId('group.com.tallycounter.tallyCounter');

  // Widget / notification button taps run this callback in a background isolate.
  await HomeWidget.registerInteractivityCallback(widgetInteractivityCallback);

  // The tally screen paints no background and no shader, so there is nothing
  // to warm up before the first frame.

  final db = AppDatabase();

  // Onboarding is shown once, to a genuinely new user only: the flag from a
  // previous run, or any counter the user already has (e.g. restored from a
  // backup), permanently rules it out. Decided *before* seeding so a fresh
  // install — which has no counters yet — still gets it.
  final flag = await db.getSetting(SettingsKeys.onboardingComplete);
  final counters = await db.getAllCounters();
  LaunchState.apply(flagSet: flag == '1', hasCounters: counters.isNotEmpty);
  await db.seedIfEmpty();
  if (LaunchState.onboardingDone && flag != '1') {
    await db.setSetting(SettingsKeys.onboardingComplete, '1');
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const TallyApp(),
    ),
  );
}
