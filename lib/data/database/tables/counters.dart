import 'package:drift/drift.dart';

@TableIndex(name: 'counters_name_idx', columns: {#name})
class Counters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();

  // Core counting config
  IntColumn get startValue => integer().withDefault(const Constant(0))();
  IntColumn get targetValue => integer().nullable()();
  IntColumn get direction => integer().withDefault(const Constant(1))(); // 1 = up, -1 = down
  IntColumn get stepSize => integer().withDefault(const Constant(1))();

  // Current state
  IntColumn get currentValue => integer().withDefault(const Constant(0))();

  // Theme colours. Only the accent survives: tally marks never paint their own
  // background or surface, so those columns were removed in schema v5.
  IntColumn get accentColor => integer().withDefault(const Constant(0xFFFFD23F))();

  // Line style (per-counter stroke material: chalk / charcoal / ink)
  TextColumn get lineStyle => text().withDefault(const Constant('ink'))();

  // Big-number HUD layout, all normalised so it survives any screen size.
  // (numberPosX/numberPosY) are the number's centre as a fraction of the
  // available area; scale/opacity are multipliers; colour is optional.
  RealColumn get numberPosX => real().withDefault(const Constant(0.5))();
  RealColumn get numberPosY => real().withDefault(const Constant(0.13))();
  RealColumn get numberScale => real().withDefault(const Constant(1.0))();
  RealColumn get numberOpacity => real().withDefault(const Constant(1.0))();
  IntColumn get numberColor => integer().nullable()();

  // Behavior
  BoolColumn get autoArchive => boolean().withDefault(const Constant(false))();
  BoolColumn get celebrateOnTarget => boolean().withDefault(const Constant(true))();
  BoolColumn get showGroupBreakdown => boolean().withDefault(const Constant(true))();

  // Auto-count: when [autoCount] is on, the tally counts +1 by itself after
  // every [autoIntervalMs] time slot (seconds or minutes chosen by the user).
  BoolColumn get autoCount => boolean().withDefault(const Constant(false))();
  IntColumn get autoIntervalMs => integer().withDefault(const Constant(1000))();

  // Ordering & meta
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}