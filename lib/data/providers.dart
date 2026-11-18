import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/widgets_service/widget_sync.dart';
import 'database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final widgetSyncProvider = Provider<WidgetSyncService>((ref) {
  return WidgetSyncService(ref.watch(databaseProvider));
});

/// How many tap rows the history screen pulls per page.
const int historyPageSize = 100;

/// Grows the history window as the user scrolls; keeps the list bounded so a
/// multi-year history never materialises in one allocation.
final historyPageLimitProvider = NotifierProvider<HistoryPageLimit, int>(
  HistoryPageLimit.new,
);

class HistoryPageLimit extends Notifier<int> {
  @override
  int build() => historyPageSize;

  void showMore() => state = state + historyPageSize;

  void reset() => state = historyPageSize;
}

final countersStreamProvider = StreamProvider<List<Counter>>((ref) {
  return ref.watch(databaseProvider).watchCounters();
});

/// Counters including archived ones — the counters screen filters them itself so
/// the "Archived" toggle can reveal them without a second query.
final allCountersStreamProvider = StreamProvider<List<Counter>>((ref) {
  return ref.watch(databaseProvider).watchCounters(includeArchived: true);
});

final counterProvider = StreamProvider.family<Counter?, String>((ref, id) {
  return ref.watch(databaseProvider).watchCounter(id);
});

final tapsProvider = StreamProvider.family<List<Tap>, String>((ref, counterId) {
  return ref.watch(databaseProvider).watchTaps(counterId);
});

final allTapsProvider = StreamProvider<List<Tap>>((ref) {
  final limit = ref.watch(historyPageLimitProvider);
  return ref.watch(databaseProvider).watchAllTaps(limit: limit);
});

final sessionsProvider = StreamProvider.family<List<Session>, String>((ref, counterId) {
  return ref.watch(databaseProvider).watchSessions(counterId);
});

final allSessionsProvider = StreamProvider<List<Session>>((ref) {
  return ref.watch(databaseProvider).watchAllSessions();
});

final counterActionsProvider = Provider<CounterActions>((ref) {
  return CounterActions(ref.watch(databaseProvider));
});

class CounterActions {
  CounterActions(this._db);
  final AppDatabase _db;

  Future<Counter> tap(String id, {int delta = 1}) => _db.tapCounter(id, delta: delta);
  Future<void> reset(String id) => _db.resetCounter(id);
  Future<DeletedCounter> delete(String id) => _db.deleteCounter(id);
  Future<void> restore(DeletedCounter snapshot) => _db.restoreCounter(snapshot);
  Future<Counter> create({
    required String name,
    String? description,
    int startValue = 0,
    int? targetValue,
    int direction = 1,
    int stepSize = 1,
    int accentColor = 0xFFFFD23F,
    String lineStyle = 'ink',
    bool autoArchive = false,
    bool celebrateOnTarget = true,
    bool showGroupBreakdown = true,
    bool autoCount = false,
    int autoIntervalMs = 1000,
  }) =>
      _db.createCounter(
        name: name,
        description: description,
        startValue: startValue,
        targetValue: targetValue,
        direction: direction,
        stepSize: stepSize,
        accentColor: accentColor,
        lineStyle: lineStyle,
        autoArchive: autoArchive,
        celebrateOnTarget: celebrateOnTarget,
        showGroupBreakdown: showGroupBreakdown,
        autoCount: autoCount,
        autoIntervalMs: autoIntervalMs,
      );
}