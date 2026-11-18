import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_counter/data/providers.dart';
import 'package:tally_counter/data/settings/app_settings.dart';
import 'package:tally_counter/features/counters/counters_screen.dart';
import 'package:tally_counter/features/onboarding/onboarding_screen.dart';
import 'package:tally_counter/features/tally/volume_buttons.dart';
import 'package:tally_counter/features/tally/western_tally_screen.dart';
import 'package:tally_counter/router/launch_state.dart';

import '../support/test_harness.dart';

/// Delivers a volume-key event to the app exactly like the native activity
/// does, so the single volume path is exercised end to end.
Future<void> sendVolume(bool up) async {
  const codec = StandardMethodCodec();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'tally_counter/volume',
    codec.encodeMethodCall(MethodCall('onVolume', up ? 'up' : 'down')),
    (_) {},
  );
}

/// Tears the widget tree down and flushes the zero-duration timer drift
/// schedules when a query stream is cancelled. Without this the test framework
/// sees a pending timer and fails the test.
Future<void> disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  group('Debouncer (volume / accidental-tap gate)', () {
    test('allows one event per window, then lets the next one through', () {
      final gate = Debouncer(const Duration(milliseconds: 150));
      var now = DateTime(2020, 1, 1);
      Debouncer.clock = () => now;
      addTearDown(() => Debouncer.clock = DateTime.now);

      expect(gate.allow(), isTrue, reason: 'first press');
      now = now.add(const Duration(milliseconds: 50));
      expect(gate.allow(), isFalse, reason: 'still inside the window');
      now = now.add(const Duration(milliseconds: 99));
      expect(gate.allow(), isFalse, reason: '149ms, still inside');
      now = now.add(const Duration(milliseconds: 1));
      expect(gate.allow(), isTrue, reason: 'exactly 150ms, allowed again');
    });
  });

  group('volume buttons: one press, one count', () {
    testWidgets('10 discrete presses = 10 counts, for up and for down',
        (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase(withData: false);
      addTearDown(db.close);
      final counter = await db.createCounter(name: 'Vol', lineStyle: 'ink');

      await pumpSubject(
        tester,
        WesternTallyScreen(counterId: counter.id, enableKeepAwake: false),
        db: db,
      );
      await tester.pump(const Duration(milliseconds: 200));

      var now = DateTime(2020, 1, 1);
      Debouncer.clock = () => now;
      addTearDown(() => Debouncer.clock = DateTime.now);

      Future<void> press(bool up) async {
        now = now.add(const Duration(milliseconds: 200));
        await sendVolume(up);
        await tester.pump(const Duration(milliseconds: 80));
      }

      for (var i = 0; i < 10; i++) {
        await press(true);
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect((await db.getCounter(counter.id))?.currentValue, 10,
          reason: 'ten volume-up presses must be ten counts');

      for (var i = 0; i < 10; i++) {
        await press(false);
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect((await db.getCounter(counter.id))?.currentValue, 0,
          reason: 'ten volume-down presses must undo exactly ten counts');

      await disposeTree(tester);
    });

    testWidgets('a held key (repeats inside the window) counts once',
        (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase(withData: false);
      addTearDown(db.close);
      final counter = await db.createCounter(name: 'Held', lineStyle: 'ink');

      await pumpSubject(
        tester,
        WesternTallyScreen(counterId: counter.id, enableKeepAwake: false),
        db: db,
      );
      await tester.pump(const Duration(milliseconds: 200));

      final frozen = DateTime(2020, 1, 1);
      Debouncer.clock = () => frozen;
      addTearDown(() => Debouncer.clock = DateTime.now);

      // Ten repeats with zero time passing between them.
      for (var i = 0; i < 10; i++) {
        await sendVolume(true);
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect((await db.getCounter(counter.id))?.currentValue, 1,
          reason: 'repeats inside the debounce window collapse to one count');

      await disposeTree(tester);
    });
  });

  group('counter cards: swipe right deletes, swipe left archives', () {
    testWidgets('swipe right asks to confirm, then permanently deletes',
        (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);
      final before = await db.getAllCounters();
      final victim = before.first;

      await pumpSubject(tester, const CountersScreen(), db: db);
      await tester.pump(const Duration(milliseconds: 200));

      await tester.drag(find.text(victim.name), const Offset(600, 0));
      await tester.pumpAndSettle();

      // The confirmation dialog must appear before anything is deleted.
      expect(find.textContaining('Delete'), findsWidgets);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      final after = await db.getAllCounters(includeArchived: true);
      expect(after.any((c) => c.id == victim.id), isFalse,
          reason: 'the counter is truly gone from Drift, not merely archived');
      // The undo snackbar is offered.
      expect(find.text('Undo'), findsOneWidget);

      // Let the undo SnackBar expire so no timer is left pending.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await disposeTree(tester);
    });

    testWidgets('swipe left archives the counter', (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase();
      addTearDown(db.close);
      final before = await db.getAllCounters();
      final victim = before.first;

      await pumpSubject(tester, const CountersScreen(), db: db);
      await tester.pump(const Duration(milliseconds: 200));

      await tester.drag(find.text(victim.name), const Offset(-600, 0));
      await tester.pumpAndSettle();

      final all = await db.getAllCounters(includeArchived: true);
      final archived = all.where((c) => c.id == victim.id).first;
      expect(archived.archived, isTrue,
          reason: 'swipe left moves the counter into the archive');
      expect((await db.getAllCounters()).any((c) => c.id == victim.id), isFalse,
          reason: 'archived counters leave the active list');

      // Restoring brings it straight back.
      await db.updateCounter(id: victim.id, archived: false);
      final restored = await db.getAllCounters(includeArchived: true);
      expect(restored.firstWhere((c) => c.id == victim.id).archived, isFalse);

      // Let the archive SnackBar expire so no timer is left pending.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await disposeTree(tester);
    });
  });

  group('onboarding gating', () {
    test('a flag or any existing counter permanently rules onboarding out', () {
      LaunchState.apply(flagSet: false, hasCounters: false);
      expect(LaunchState.onboardingDone, isFalse);
      expect(LaunchState.initialLocation, '/onboarding');

      LaunchState.apply(flagSet: true, hasCounters: false);
      expect(LaunchState.onboardingDone, isTrue);
      expect(LaunchState.initialLocation, '/');

      LaunchState.apply(flagSet: false, hasCounters: true);
      expect(LaunchState.onboardingDone, isTrue);

      LaunchState.apply(flagSet: true, hasCounters: true);
      expect(LaunchState.onboardingDone, isTrue);
    });

    testWidgets('skipping persists the flag and returns home', (tester) async {
      mockPlatformChannels();
      final db = await seededDatabase(withData: false);
      addTearDown(db.close);

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: <RouteBase>[
          GoRoute(
            path: '/onboarding',
            builder: (_, __) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('home')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byKey(const Key('onboarding-skip')));
      // The onboarding screens run a forever-repeating pulse, so settle would
      // never return; advance fixed frames instead.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }

      expect(await db.getSetting(SettingsKeys.onboardingComplete), '1',
          reason: 'the one-time flag is written on skip');
      expect(find.text('home'), findsOneWidget);

      await disposeTree(tester);
    });
  });
}
