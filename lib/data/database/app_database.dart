import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/counters.dart';
import 'tables/sessions.dart';
import 'tables/taps.dart';
import 'tables/settings.dart';

part 'app_database.g.dart';

/// A counter plus everything it owned at the moment it was deleted. Used to
/// undo a permanent delete from the counters list.
class DeletedCounter {
  const DeletedCounter({
    required this.counter,
    this.taps = const <Tap>[],
    this.sessions = const <Session>[],
  });

  const DeletedCounter.empty()
      : counter = null,
        taps = const <Tap>[],
        sessions = const <Session>[];

  final Counter? counter;
  final List<Tap> taps;
  final List<Session> sessions;

  bool get isEmpty => counter == null;
}


@DriftDatabase(tables: [Counters, Taps, Sessions, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Ensure the hot-path indexes exist even for databases created before
          // the Drift schema annotations were added.
          await customStatement('CREATE INDEX IF NOT EXISTS taps_counter_at_idx ON taps (counter_id, at)');
          await customStatement('CREATE INDEX IF NOT EXISTS taps_at_idx ON taps (at)');
          await customStatement('CREATE INDEX IF NOT EXISTS taps_session_idx ON taps (session_id)');
          await customStatement('CREATE INDEX IF NOT EXISTS sessions_counter_idx ON sessions (counter_id, started_at)');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(counters, counters.startValue);
            await m.addColumn(counters, counters.targetValue);
            await m.addColumn(counters, counters.direction);
            await m.addColumn(counters, counters.stepSize);
            await m.addColumn(counters, counters.accentColor);
            await m.addColumn(counters, counters.lineStyle);
            await m.addColumn(counters, counters.numberPosX);
            await m.addColumn(counters, counters.numberPosY);
            await m.addColumn(counters, counters.numberScale);
            await m.addColumn(counters, counters.numberOpacity);
            await m.addColumn(counters, counters.numberColor);
            await m.addColumn(counters, counters.autoArchive);
            await m.addColumn(counters, counters.celebrateOnTarget);
            // Migrate existing data: copy colorValue -> accentColor,
            // currentValue -> startValue. Surface/background/stroke colours are
            // gone — tally marks no longer paint their own background.
            await customStatement('''
              UPDATE counters SET
                startValue = currentValue,
                targetValue = target,
                direction = 1,
                stepSize = step,
                accentColor = colorValue,
                lineStyle = 'ink',
                autoArchive = 0,
                celebrateOnTarget = 1,
                showGroupBreakdown = 1
            ''');
          }
          if (from < 3) {
            await m.addColumn(sessions, sessions.tags);
          }
          if (from < 4) {
            // The pluggable tally-style system is gone: only the Western tally
            // remains, and the stroke material is now a per-counter line style.
            if (from >= 2) {
              await m.addColumn(counters, counters.lineStyle);
              await m.addColumn(counters, counters.numberPosX);
              await m.addColumn(counters, counters.numberPosY);
              await m.addColumn(counters, counters.numberScale);
              await m.addColumn(counters, counters.numberOpacity);
              await m.addColumn(counters, counters.numberColor);
            }
            await customStatement('ALTER TABLE counters DROP COLUMN tally_style');
          }
          if (from < 5) {
            // Per-counter surfaces/backgrounds are gone: the tally always sits
            // on the plain app background. Drop the orphaned columns if an
            // older schema created them, then move every legacy stroke id onto
            // one of the three surviving materials (default: ink).
            for (final column in <String>[
              'surface_color',
              'background_color',
              'stroke_color',
            ]) {
              if (await _columnExists('counters', column)) {
                await m.dropColumn(counters, column);
              }
            }
            await customStatement(
              "UPDATE counters SET line_style = 'ink' "
              "WHERE line_style NOT IN ('chalk', 'charcoal', 'ink')",
            );
          }
          if (from < 6) {
            // Auto-count time slot: every counter gains an off-by-default
            // timer with a 1 second default slot.
            await m.addColumn(counters, counters.autoCount);
            await m.addColumn(counters, counters.autoIntervalMs);
          }
        },
      );

  /// Whether [table] currently has a column named [column]. Used by the v5
  /// migration so dropping a column is a no-op on databases that never had it.
  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    for (final row in rows) {
      if (row.read<String>('name') == column) return true;
    }
    return false;
  }

  static QueryExecutor _open() =>
      driftDatabase(name: 'tally_counter');

  // --- Counters ------------------------------------------------------------
  Future<List<Counter>> getAllCounters({bool includeArchived = false}) async {
    final query = select(counters);
    if (!includeArchived) {
      query.where((tbl) => tbl.archived.equals(false));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex), (tbl) => OrderingTerm.asc(tbl.createdAt)]);
    return query.get();
  }

  Stream<List<Counter>> watchCounters({bool includeArchived = false}) {
    final query = select(counters);
    if (!includeArchived) {
      query.where((tbl) => tbl.archived.equals(false));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex), (tbl) => OrderingTerm.asc(tbl.createdAt)]);
    return query.watch();
  }

  Stream<Counter?> watchCounter(String id) =>
      (select(counters)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();

  Future<Counter?> getCounter(String id) =>
      (select(counters)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<Counter> createCounter({
    required String name,
    String? description,
    int startValue = 0,
    int? targetValue,
    int direction = 1,
    int stepSize = 1,
    int accentColor = 0xFFFFD23F,
    String lineStyle = 'ink',
    double numberPosX = 0.5,
    double numberPosY = 0.13,
    double numberScale = 1.0,
    double numberOpacity = 1.0,
    int? numberColor,
    bool autoArchive = false,
    bool celebrateOnTarget = true,
    bool showGroupBreakdown = true,
    bool autoCount = false,
    int autoIntervalMs = 1000,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final companion = CountersCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      startValue: Value(startValue),
      targetValue: Value(targetValue),
      direction: Value(direction),
      stepSize: Value(stepSize),
      currentValue: Value(startValue),
      accentColor: Value(accentColor),
      lineStyle: Value(lineStyle),
      numberPosX: Value(numberPosX),
      numberPosY: Value(numberPosY),
      numberScale: Value(numberScale),
      numberOpacity: Value(numberOpacity),
      numberColor: Value(numberColor),
      autoArchive: Value(autoArchive),
      celebrateOnTarget: Value(celebrateOnTarget),
      showGroupBreakdown: Value(showGroupBreakdown),
      autoCount: Value(autoCount),
      autoIntervalMs: Value(autoIntervalMs < 1000 ? 1000 : autoIntervalMs),
      orderIndex: Value(DateTime.now().millisecondsSinceEpoch % 10000),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    await into(counters).insert(companion);
    return (select(counters)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<Counter> updateCounter({
    required String id,
    String? name,
    String? description,
    bool clearDescription = false,
    int? startValue,
    int? targetValue,
    bool clearTarget = false,
    int? direction,
    int? stepSize,
    int? currentValue,
    int? accentColor,
    String? lineStyle,
    double? numberPosX,
    double? numberPosY,
    double? numberScale,
    double? numberOpacity,
    int? numberColor,
    bool clearNumberColor = false,
    bool? autoArchive,
    bool? celebrateOnTarget,
    bool? showGroupBreakdown,
    bool? autoCount,
    int? autoIntervalMs,
    bool? archived,
    int? orderIndex,
  }) async {
    final now = DateTime.now();
    final companion = CountersCompanion(
      name: name == null ? Value.absent() : Value(name),
      // Only touch nullable columns when a value was actually supplied —
      // otherwise `updateCounter(id:, archived: true)` would silently wipe the
      // description and target (the original "archive does nothing" bug).
      description: clearDescription
          ? const Value(null)
          : (description == null ? Value.absent() : Value(description)),
      startValue: startValue == null ? Value.absent() : Value(startValue),
      targetValue: clearTarget
          ? const Value(null)
          : (targetValue == null ? Value.absent() : Value(targetValue)),
      direction: direction == null ? Value.absent() : Value(direction),
      stepSize: stepSize == null ? Value.absent() : Value(stepSize),
      currentValue: currentValue == null ? Value.absent() : Value(currentValue),
      accentColor: accentColor == null ? Value.absent() : Value(accentColor),
      lineStyle: lineStyle == null ? Value.absent() : Value(lineStyle),
      numberPosX: numberPosX == null ? Value.absent() : Value(numberPosX),
      numberPosY: numberPosY == null ? Value.absent() : Value(numberPosY),
      numberScale: numberScale == null ? Value.absent() : Value(numberScale),
      numberOpacity: numberOpacity == null ? Value.absent() : Value(numberOpacity),
      numberColor: clearNumberColor
          ? const Value(null)
          : (numberColor == null ? Value.absent() : Value(numberColor)),
      autoArchive: autoArchive == null ? Value.absent() : Value(autoArchive),
      celebrateOnTarget: celebrateOnTarget == null ? Value.absent() : Value(celebrateOnTarget),
      showGroupBreakdown: showGroupBreakdown == null ? Value.absent() : Value(showGroupBreakdown),
      autoCount: autoCount == null ? Value.absent() : Value(autoCount),
      autoIntervalMs: autoIntervalMs == null
          ? Value.absent()
          : Value(autoIntervalMs < 1000 ? 1000 : autoIntervalMs),
      archived: archived == null ? Value.absent() : Value(archived),
      orderIndex: orderIndex == null ? Value.absent() : Value(orderIndex),
      updatedAt: Value(now),
    );
    await (update(counters)..where((tbl) => tbl.id.equals(id))).write(companion);
    return (select(counters)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<Counter> tapCounter(String id, {int delta = 1}) => tapCounterBatch(id, delta);

  /// Applies [count] presses in a *single* transaction and records one tap row
  /// per press. Negative counts undo. This is what the tally screen's
  /// coalescing writer calls, so a burst of rapid taps is one small write
  /// instead of one transaction per tap.
  Future<Counter> tapCounterBatch(String id, int count) async {
    return transaction(() async {
      final c = await (select(counters)..where((tbl) => tbl.id.equals(id))).getSingle();
      final step = c.stepSize;
      final dir = c.direction;
      final next = c.currentValue + count * step * dir;
      final now = DateTime.now();
      await (update(counters)..where((tbl) => tbl.id.equals(id))).write(
        CountersCompanion(currentValue: Value(next), updatedAt: Value(now)),
      );
      final abs = count.abs();
      if (abs > 0) {
        final rows = <TapsCompanion>[];
        for (var i = 0; i < abs; i++) {
          rows.add(TapsCompanion.insert(
            id: const Uuid().v4(),
            counterId: id,
            delta: count.sign * step * dir,
            valueAfter: next,
            at: Value(now),
          ));
        }
        await batch((b) => b.insertAll(taps, rows));
      }
      return c.copyWith(currentValue: next, updatedAt: now);
    });
  }

  Future<void> resetCounter(String id) async {
    final c = await (select(counters)..where((tbl) => tbl.id.equals(id))).getSingle();
    final now = DateTime.now();
    await (update(counters)..where((tbl) => tbl.id.equals(id))).write(
      CountersCompanion(currentValue: Value(c.startValue), updatedAt: Value(now)),
    );
  }

  Future<void> reorderCounters(List<String> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (update(counters)..where((tbl) => tbl.id.equals(orderedIds[i]))).write(
        CountersCompanion(
          orderIndex: Value(i),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Stream<List<Tap>> watchTaps(String counterId) => (select(taps)
        ..where((tbl) => tbl.counterId.equals(counterId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.at)]))
      .watch();

  /// All taps, newest first. Pass [limit] to page large histories instead of
  /// materialising every row at once.
  Stream<List<Tap>> watchAllTaps({int? limit}) {
    final query = select(taps)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.at)]);
    if (limit != null) query.limit(limit);
    return query.watch();
  }

  Stream<List<Session>> watchSessions(String counterId) => (select(sessions)
        ..where((tbl) => tbl.counterId.equals(counterId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
      .watch();

  Stream<List<Session>> watchAllSessions() => (select(sessions)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
      .watch();

  Future<void> updateTapNote(String tapId, String? note) async {
    await (update(taps)..where((tbl) => tbl.id.equals(tapId))).write(
      TapsCompanion(note: Value(note)),
    );
  }

  Future<void> updateTapDelta(String tapId, int delta) async {
    await (update(taps)..where((tbl) => tbl.id.equals(tapId))).write(
      TapsCompanion(delta: Value(delta)),
    );
  }

  Future<void> deleteTap(String tapId) async {
    await (delete(taps)..where((tbl) => tbl.id.equals(tapId))).go();
  }

  Future<void> updateSessionMeta(String sessionId, {String? label, String? tags}) async {
    await (update(sessions)..where((tbl) => tbl.id.equals(sessionId))).write(
      SessionsCompanion(
        label: Value(label),
        tags: Value(tags),
      ),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await (update(taps)..where((tbl) => tbl.sessionId.equals(sessionId))).write(
      const TapsCompanion(sessionId: Value(null)),
    );
    await (delete(sessions)..where((tbl) => tbl.id.equals(sessionId))).go();
  }

  // --- Settings -----------------------------------------------------------
  Future<String?> getSetting(String key) async {
    final r = await (select(settingsTable)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return r?.value;
  }

  Future<void> setSetting(String key, String value) async {
    final now = DateTime.now();
    await into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(
        key: key,
        value: Value(value),
        updatedAt: Value(now),
      ),
    );
  }

  /// Every setting as a key/value map.
  Future<Map<String, String>> getSettings() async {
    final rows = await select(settingsTable).get();
    return <String, String>{
      for (final row in rows) row.key: row.value ?? '',
    };
  }

  /// Insert or update many settings in one batch.
  Future<void> setSettings(Map<String, String> values) async {
    if (values.isEmpty) return;
    final now = DateTime.now();
    await batch((b) {
      for (final entry in values.entries) {
        final companion = SettingsTableCompanion.insert(
          key: entry.key,
          value: Value(entry.value),
          updatedAt: Value(now),
        );
        b.insert(settingsTable, companion, onConflict: DoUpdate((_) => companion));
      }
    });
  }

  /// One-shot reads used by backup/export.
  Future<List<Tap>> getAllTaps() => (select(taps)
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.at)]))
      .get();

  Future<List<Session>> getAllSessions() => (select(sessions)
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.startedAt)]))
      .get();

  /// Wipes every counter, tap and session (used by "Replace all" imports).
  Future<void> deleteAllData() async {
    await transaction(() async {
      await delete(taps).go();
      await delete(sessions).go();
      await delete(counters).go();
    });
  }

  /// Deletes a counter together with every tap and session it owns, returning a
  /// snapshot that [restoreCounter] can put back. This powers the swipe-to-
  /// delete Undo: nothing is lost until the snackbar times out.
  Future<DeletedCounter> deleteCounter(String id) async {
    return transaction(() async {
      final counter = await getCounter(id);
      if (counter == null) return const DeletedCounter.empty();
      final tapRows =
          await (select(taps)..where((t) => t.counterId.equals(id))).get();
      final sessionRows =
          await (select(sessions)..where((s) => s.counterId.equals(id))).get();
      await (delete(counters)..where((t) => t.id.equals(id))).go();
      return DeletedCounter(
        counter: counter,
        taps: tapRows,
        sessions: sessionRows,
      );
    });
  }

  /// Puts a [DeletedCounter] snapshot back exactly as it was.
  Future<void> restoreCounter(DeletedCounter snapshot) async {
    final counter = snapshot.counter;
    if (counter == null) return;
    await transaction(() async {
      await into(counters)
          .insert(counter.toCompanion(false), mode: InsertMode.insertOrReplace);
      if (snapshot.taps.isNotEmpty) {
        await batch((b) => b.insertAll(
              taps,
              snapshot.taps.map((t) => t.toCompanion(false)).toList(),
              mode: InsertMode.insertOrReplace,
            ));
      }
      if (snapshot.sessions.isNotEmpty) {
        await batch((b) => b.insertAll(
              sessions,
              snapshot.sessions.map((s) => s.toCompanion(false)).toList(),
              mode: InsertMode.insertOrReplace,
            ));
      }
    });
  }

  Future<void> seedIfEmpty() async {
    final count = await (select(counters)..limit(1)).get();
    if (count.isNotEmpty) return;
    final now = DateTime.now();
    final rows = <CountersCompanion>[
      CountersCompanion.insert(
        id: const Uuid().v4(),
        name: 'Drinks',
        accentColor: const Value(0xFF45C4F5),
        lineStyle: const Value('ink'),
        orderIndex: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      CountersCompanion.insert(
        id: const Uuid().v4(),
        name: 'Pushups',
        accentColor: const Value(0xFFFF5C8A),
        lineStyle: const Value('ink'),
        orderIndex: const Value(1),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      CountersCompanion.insert(
        id: const Uuid().v4(),
        name: 'Pages',
        accentColor: const Value(0xFF9BE15D),
        lineStyle: const Value('ink'),
        orderIndex: const Value(2),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    ];
    await batch((b) => b.insertAll(counters, rows));
  }
}