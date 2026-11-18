import 'package:drift/drift.dart';
import 'counters.dart';

@TableIndex(name: 'sessions_counter_idx', columns: {#counterId, #startedAt})
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get counterId => text().references(Counters, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get startValue => integer().withDefault(const Constant(0))();
  IntColumn get endValue => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
