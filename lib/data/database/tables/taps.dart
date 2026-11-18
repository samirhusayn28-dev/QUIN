import 'package:drift/drift.dart';
import 'counters.dart';

@TableIndex(name: 'taps_counter_at_idx', columns: {#counterId, #at})
@TableIndex(name: 'taps_session_idx', columns: {#sessionId})
class Taps extends Table {
  TextColumn get id => text()();
  TextColumn get counterId => text().references(Counters, #id, onDelete: KeyAction.cascade)();
  TextColumn get sessionId => text().nullable()();
  IntColumn get delta => integer()();
  IntColumn get valueAfter => integer()();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
