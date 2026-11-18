import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('counters', () {
    test('createCounter stores defaults and returns the row', () async {
      final counter = await db.createCounter(name: 'Pushups');

      expect(counter.id, isNotEmpty);
      expect(counter.name, 'Pushups');
      expect(counter.currentValue, 0);
      expect(counter.startValue, 0);
      expect(counter.direction, 1);
      expect(counter.stepSize, 1);
      expect(counter.lineStyle, 'ink');
      expect(counter.celebrateOnTarget, isTrue);
      expect(counter.archived, isFalse);
    });

    test('createCounter honours custom configuration', () async {
      final counter = await db.createCounter(
        name: 'Countdown',
        startValue: 100,
        targetValue: 0,
        direction: -1,
        stepSize: 5,
        lineStyle: 'charcoal',
      );

      expect(counter.currentValue, 100);
      expect(counter.direction, -1);
      expect(counter.stepSize, 5);
      expect(counter.lineStyle, 'charcoal');
    });

    test('getAllCounters hides archived rows unless asked', () async {
      final a = await db.createCounter(name: 'A');
      await db.createCounter(name: 'B');
      await db.updateCounter(id: a.id, archived: true);

      expect((await db.getAllCounters()).length, 1);
      expect((await db.getAllCounters(includeArchived: true)).length, 2);
    });

    test('reorderCounters rewrites orderIndex', () async {
      final a = await db.createCounter(name: 'A');
      final b = await db.createCounter(name: 'B');
      final c = await db.createCounter(name: 'C');

      await db.reorderCounters(<String>[c.id, a.id, b.id]);

      final ordered = await db.getAllCounters();
      expect(ordered.map((e) => e.name).toList(), <String>['C', 'A', 'B']);
    });

    test('updateCounter patches only the supplied fields', () async {
      final counter = await db.createCounter(name: 'Original');
      final updated = await db.updateCounter(
        id: counter.id,
        name: 'Renamed',
        targetValue: 42,
      );

      expect(updated.name, 'Renamed');
      expect(updated.targetValue, 42);
      expect(updated.lineStyle, counter.lineStyle);
    });

    test('archiving keeps description, target and lineStyle intact', () async {
      final counter = await db.createCounter(
        name: 'Pushups',
        description: 'Morning set',
        targetValue: 100,
        lineStyle: 'cave_ochre',
      );

      final archived = await db.updateCounter(id: counter.id, archived: true);

      expect(archived.archived, isTrue);
      // The archive flag must not clobber any other column.
      expect(archived.description, 'Morning set');
      expect(archived.targetValue, 100);
      expect(archived.lineStyle, 'cave_ochre');

      final restored = await db.updateCounter(id: counter.id, archived: false);
      expect(restored.archived, isFalse);
      expect(restored.description, 'Morning set');
      expect(restored.targetValue, 100);
    });

    test('archived counters round-trip through persistence', () async {
      final counter = await db.createCounter(name: 'Temp', description: 'keep me');
      await db.updateCounter(id: counter.id, archived: true);

      // Simulate a fresh read after the archive write (as the stream would).
      final reloaded = await db.getCounter(counter.id);
      expect(reloaded!.archived, isTrue);
      expect(reloaded.description, 'keep me');

      final visible = await db.getAllCounters();
      expect(visible, isEmpty);
      final all = await db.getAllCounters(includeArchived: true);
      expect(all.single.id, counter.id);
    });

    test('explicit clears null out description and target', () async {
      final counter = await db.createCounter(
        name: 'Clearable',
        description: 'gone soon',
        targetValue: 5,
      );

      final cleared = await db.updateCounter(
        id: counter.id,
        clearDescription: true,
        clearTarget: true,
      );

      expect(cleared.description, isNull);
      expect(cleared.targetValue, isNull);
    });

    test('deleting a counter cascades to its taps', () async {
      final counter = await db.createCounter(name: 'A');
      await db.tapCounter(counter.id);
      await db.tapCounter(counter.id);
      expect((await db.getAllTaps()).length, 2);

      await (db.delete(db.counters)..where((t) => t.id.equals(counter.id))).go();

      expect(await db.getAllTaps(), isEmpty);
    });

    test('number layout defaults to the reserved slot above the grid', () async {
      final c = await db.createCounter(name: 'HUD');

      expect(c.numberPosX, 0.5);
      expect(c.numberPosY, 0.13);
      expect(c.numberScale, 1.0);
      expect(c.numberOpacity, 1.0);
      expect(c.numberColor, isNull);
    });

    test('deleteCounter snapshots, restoreCounter brings history back', () async {
      final c = await db.createCounter(name: 'Undo me', lineStyle: 'ink_brush');
      await db.tapCounter(c.id);
      await db.tapCounter(c.id);

      final snapshot = await db.deleteCounter(c.id);
      expect(await db.getCounter(c.id), isNull);
      expect(await db.getAllTaps(), isEmpty);

      await db.restoreCounter(snapshot);
      final restored = await db.getCounter(c.id);
      expect(restored, isNotNull);
      expect(restored!.lineStyle, 'ink_brush');
      expect(restored.currentValue, 2);
      expect((await db.getAllTaps()).length, 2);
    });

    test('deleteCounter on a missing id is a safe no-op', () async {
      final snapshot = await db.deleteCounter('nope');
      expect(snapshot.counter, isNull);
      await db.restoreCounter(snapshot); // must not throw
    });
  });

  group('tapping', () {
    test('applies step and direction and records a tap', () async {
      final counter = await db.createCounter(
        name: 'A',
        startValue: 10,
        stepSize: 3,
        direction: 1,
      );

      await db.tapCounter(counter.id);
      final afterUp = await db.getCounter(counter.id);
      expect(afterUp!.currentValue, 13);

      final down = await db.createCounter(
        name: 'B',
        startValue: 10,
        stepSize: 3,
        direction: -1,
      );
      await db.tapCounter(down.id);
      expect((await db.getCounter(down.id))!.currentValue, 7);

      final taps = await db.getAllTaps();
      expect(taps.length, 2);
      expect(taps.map((t) => t.delta).toSet(), <int>{3, -3});
    });

    test('supports negative deltas for corrections', () async {
      final counter = await db.createCounter(name: 'A', stepSize: 1);
      await db.tapCounter(counter.id);
      await db.tapCounter(counter.id);
      await db.tapCounter(counter.id, delta: -1);

      expect((await db.getCounter(counter.id))!.currentValue, 1);
    });

    test('resetCounter returns to the start value', () async {
      final counter = await db.createCounter(name: 'A', startValue: 5);
      await db.tapCounter(counter.id);
      await db.tapCounter(counter.id);

      await db.resetCounter(counter.id);

      expect((await db.getCounter(counter.id))!.currentValue, 5);
    });

    test('tap edits update/delete individual taps', () async {
      final counter = await db.createCounter(name: 'A');
      await db.tapCounter(counter.id);
      final tap = (await db.getAllTaps()).single;

      await db.updateTapNote(tap.id, 'note');
      await db.updateTapDelta(tap.id, 9);
      final edited = (await db.getAllTaps()).single;
      expect(edited.note, 'note');
      expect(edited.delta, 9);

      await db.deleteTap(tap.id);
      expect(await db.getAllTaps(), isEmpty);
    });
  });

  group('seeding & settings', () {
    test('seedIfEmpty seeds once only', () async {
      await db.seedIfEmpty();
      expect((await db.getAllCounters()).length, 3);

      await db.seedIfEmpty();
      expect((await db.getAllCounters()).length, 3);
    });

    test('settings round-trip through single and batch writes', () async {
      await db.setSetting('pref_sound', 'true');
      expect(await db.getSetting('settings_absent'), isNull);
      expect(await db.getSetting('pref_sound'), 'true');

      await db.setSettings(<String, String>{'pref_haptics': '0', 'x': 'y'});
      final all = await db.getSettings();
      expect(all['pref_sound'], 'true');
      expect(all['pref_haptics'], '0');

      await db.setSettings(<String, String>{'pref_sound': 'false'});
      expect(await db.getSetting('pref_sound'), 'false');
    });

    test('deleteAllData wipes counters, taps and sessions', () async {
      final counter = await db.createCounter(name: 'A');
      await db.tapCounter(counter.id);
      await db.setSetting('pref_sound', 'true');

      await db.deleteAllData();

      expect(await db.getAllCounters(includeArchived: true), isEmpty);
      expect(await db.getAllTaps(), isEmpty);
      expect(await db.getAllSessions(), isEmpty);
      // Settings are intentionally preserved.
      expect(await db.getSetting('pref_sound'), 'true');
    });
    test('watchAllTaps pages with a limit for the history screen', () async {
      final counter = await db.createCounter(name: 'A');
      for (var i = 0; i < 5; i++) {
        await db.tapCounter(counter.id);
      }

      final firstPage = await db.watchAllTaps(limit: 2).first;
      expect(firstPage.length, 2);

      final everything = await db.watchAllTaps().first;
      expect(everything.length, 5);
    });
  });

  group('schema', () {    test('hot-path indexes exist after open', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND tbl_name IN ('taps', 'sessions', 'counters')",
          )
          .get();
      final names = rows.map((r) => r.read<String>('name')).toSet();

      expect(
        names,
        containsAll(<String>[
          'taps_counter_at_idx',
          'taps_session_idx',
          'sessions_counter_idx',
          'counters_name_idx',
        ]),
      );
    });

    test('foreign keys are enabled', () async {
      final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(result.data.values.first, 1);
    });
  });
}
