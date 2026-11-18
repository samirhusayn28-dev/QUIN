import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import '../../tally_styles/line_style.dart';

/// Version of the *backup file format* (independent of the database schema).
///
/// - `1`: initial format (counters, taps, sessions, settings).
const int kBackupFormatVersion = 1;

/// Oldest format we can still read.
const int kBackupMinSupportedVersion = 1;

class BackupCounter {
  const BackupCounter({required this.id, required this.name, this.description,
    this.startValue = 0, this.targetValue, this.direction = 1, this.stepSize = 1,
    this.currentValue = 0, this.accentColor = 0xFFFFD23F, this.lineStyle = 'ink',
    this.numberPosX = 0.5, this.numberPosY = 0.13, this.numberScale = 1.0,
    this.numberOpacity = 1.0, this.numberColor,
    this.autoArchive = false, this.celebrateOnTarget = true, this.showGroupBreakdown = true,
    this.autoCount = false, this.autoIntervalMs = 1000,
    this.orderIndex = 0, this.pinned = false, this.archived = false, this.createdAt, this.updatedAt});

  final String id;
  final String name;
  final String? description;
  final int startValue;
  final int? targetValue;
  final int direction;
  final int stepSize;
  final int currentValue;
  final int accentColor;
  final String lineStyle;
  final double numberPosX;
  final double numberPosY;
  final double numberScale;
  final double numberOpacity;
  final int? numberColor;
  final bool autoArchive;
  final bool celebrateOnTarget;
  final bool showGroupBreakdown;
  final bool autoCount;
  final int autoIntervalMs;
  final int orderIndex;
  final bool pinned;
  final bool archived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BackupCounter.fromRow(Counter c) => BackupCounter(
        id: c.id, name: c.name, description: c.description, startValue: c.startValue,
        targetValue: c.targetValue, direction: c.direction, stepSize: c.stepSize,
        currentValue: c.currentValue, accentColor: c.accentColor, lineStyle: c.lineStyle,
        numberPosX: c.numberPosX, numberPosY: c.numberPosY, numberScale: c.numberScale,
        numberOpacity: c.numberOpacity, numberColor: c.numberColor,
        autoArchive: c.autoArchive, celebrateOnTarget: c.celebrateOnTarget,
        showGroupBreakdown: c.showGroupBreakdown, orderIndex: c.orderIndex, pinned: c.pinned,
        archived: c.archived, createdAt: c.createdAt, updatedAt: c.updatedAt,
        autoCount: c.autoCount, autoIntervalMs: c.autoIntervalMs,
      );

  CountersCompanion toCompanion() => CountersCompanion.insert(
        id: id,
        name: name,
        description: Value(description),
        startValue: Value(startValue),
        targetValue: Value(targetValue),
        direction: Value(direction),
        stepSize: Value(stepSize),
        currentValue: Value(currentValue),
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
        orderIndex: Value(orderIndex),
        pinned: Value(pinned),
        archived: Value(archived),
        createdAt: Value(createdAt ?? DateTime.now()),
        updatedAt: Value(updatedAt ?? DateTime.now()),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id, 'name': name, 'description': description, 'startValue': startValue,
        'targetValue': targetValue, 'direction': direction, 'stepSize': stepSize,
        'currentValue': currentValue, 'accentColor': accentColor, 'lineStyle': lineStyle,
        'numberPosX': numberPosX, 'numberPosY': numberPosY, 'numberScale': numberScale,
        'numberOpacity': numberOpacity, 'numberColor': numberColor,
        'autoArchive': autoArchive, 'celebrateOnTarget': celebrateOnTarget,
        'showGroupBreakdown': showGroupBreakdown, 'orderIndex': orderIndex, 'pinned': pinned,
        'archived': archived,
        'autoCount': autoCount, 'autoIntervalMs': autoIntervalMs,
        'createdAt': createdAt?.toIso8601String(), 'updatedAt': updatedAt?.toIso8601String(),
      };

  factory BackupCounter.fromJson(Map<String, dynamic> j) => BackupCounter(
        id: _str(j['id']),
        name: _str(j['name'], fallback: 'Counter'),
        description: j['description'] as String?,
        startValue: _int(j['startValue']),
        targetValue: j['targetValue'] == null ? null : _int(j['targetValue']),
        direction: _int(j['direction'], fallback: 1),
        stepSize: _int(j['stepSize'], fallback: 1),
        currentValue: _int(j['currentValue']),
        accentColor: _int(j['accentColor'], fallback: 0xFFFFD23F),
        // Backups written before the line-style rework stored `tallyStyle`
        // (or a now-removed style id); those are normalised on read.
        lineStyle: LineStyle.fromId(_str(j['lineStyle'] ?? j['tallyStyle'], fallback: 'ink')).id,
        numberPosX: _double(j['numberPosX'], fallback: 0.5),
        numberPosY: _double(j['numberPosY'], fallback: 0.13),
        numberScale: _double(j['numberScale'], fallback: 1.0),
        numberOpacity: _double(j['numberOpacity'], fallback: 1.0),
        numberColor: j['numberColor'] == null ? null : _int(j['numberColor']),
        autoArchive: _bool(j['autoArchive']),
        celebrateOnTarget: _bool(j['celebrateOnTarget'], fallback: true),
        showGroupBreakdown: _bool(j['showGroupBreakdown'], fallback: true),
        autoCount: _bool(j['autoCount']),
        autoIntervalMs: _int(j['autoIntervalMs'], fallback: 1000),
        orderIndex: _int(j['orderIndex']),
        pinned: _bool(j['pinned']),
        archived: _bool(j['archived']),
        createdAt: _date(j['createdAt']),
        updatedAt: _date(j['updatedAt']),
      );
}

class BackupTap {
  const BackupTap({required this.id, required this.counterId, this.sessionId,
    required this.delta, required this.valueAfter, required this.at, this.note});

  final String id;
  final String counterId;
  final String? sessionId;
  final int delta;
  final int valueAfter;
  final DateTime at;
  final String? note;

  factory BackupTap.fromRow(Tap t) => BackupTap(
        id: t.id, counterId: t.counterId, sessionId: t.sessionId, delta: t.delta,
        valueAfter: t.valueAfter, at: t.at, note: t.note,
      );

  TapsCompanion toCompanion() => TapsCompanion.insert(
        id: id, counterId: counterId, sessionId: Value(sessionId), delta: delta,
        valueAfter: valueAfter, at: Value(at), note: Value(note),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id, 'counterId': counterId, 'sessionId': sessionId, 'delta': delta,
        'valueAfter': valueAfter, 'at': at.toIso8601String(), 'note': note,
      };

  factory BackupTap.fromJson(Map<String, dynamic> j) => BackupTap(
        id: _str(j['id']),
        counterId: _str(j['counterId']),
        sessionId: j['sessionId'] as String?,
        delta: _int(j['delta'], fallback: 1),
        valueAfter: _int(j['valueAfter']),
        at: _date(j['at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        note: j['note'] as String?,
      );
}

class BackupSession {
  const BackupSession({required this.id, required this.counterId, this.label, this.tags,
    required this.startedAt, this.endedAt, this.startValue = 0, this.endValue});

  final String id;
  final String counterId;
  final String? label;
  final String? tags;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int startValue;
  final int? endValue;

  factory BackupSession.fromRow(Session s) => BackupSession(
        id: s.id, counterId: s.counterId, label: s.label, tags: s.tags,
        startedAt: s.startedAt, endedAt: s.endedAt, startValue: s.startValue, endValue: s.endValue,
      );

  SessionsCompanion toCompanion() => SessionsCompanion.insert(
        id: id, counterId: counterId, label: Value(label), tags: Value(tags),
        startedAt: Value(startedAt), endedAt: Value(endedAt),
        startValue: Value(startValue), endValue: Value(endValue),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id, 'counterId': counterId, 'label': label, 'tags': tags,
        'startedAt': startedAt.toIso8601String(), 'endedAt': endedAt?.toIso8601String(),
        'startValue': startValue, 'endValue': endValue,
      };

  factory BackupSession.fromJson(Map<String, dynamic> j) => BackupSession(
        id: _str(j['id']),
        counterId: _str(j['counterId']),
        label: j['label'] as String?,
        tags: j['tags'] as String?,
        startedAt: _date(j['startedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        endedAt: _date(j['endedAt']),
        startValue: _int(j['startValue']),
        endValue: j['endValue'] == null ? null : _int(j['endValue']),
      );
}

/// A full, self-describing backup payload.
class BackupBundle {
  const BackupBundle({
    this.formatVersion = kBackupFormatVersion,
    required this.exportedAt,
    this.appVersion = '',
    this.dbSchemaVersion = 0,
    this.counters = const <BackupCounter>[],
    this.taps = const <BackupTap>[],
    this.sessions = const <BackupSession>[],
    this.settings = const <String, String>{},
  });

  final int formatVersion;
  final DateTime exportedAt;
  final String appVersion;
  final int dbSchemaVersion;
  final List<BackupCounter> counters;
  final List<BackupTap> taps;
  final List<BackupSession> sessions;
  final Map<String, String> settings;

  bool get isEmpty => counters.isEmpty && taps.isEmpty && sessions.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'magic': 'tally-counter-backup',
        'formatVersion': formatVersion,
        'appVersion': appVersion,
        'dbSchemaVersion': dbSchemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'counters': counters.map((c) => c.toJson()).toList(),
        'taps': taps.map((t) => t.toJson()).toList(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'settings': settings,
      };

  factory BackupBundle.fromJson(Map<String, dynamic> json) {
    final version = _int(json['formatVersion'], fallback: 1);
    if (version > kBackupFormatVersion) {
      throw BackupFormatException.tooNew(version);
    }
    if (version < kBackupMinSupportedVersion) {
      throw BackupFormatException.unsupported(version);
    }
    // Future migrations go here:
    //   if (version < 2) { json = _migrateV1toV2(json); }

    return BackupBundle(
      formatVersion: kBackupFormatVersion,
      exportedAt: _date(json['exportedAt']) ?? DateTime.now(),
      appVersion: _str(json['appVersion']),
      dbSchemaVersion: _int(json['dbSchemaVersion']),
      counters: _list(json['counters']).map(BackupCounter.fromJson).toList(),
      taps: _list(json['taps']).map(BackupTap.fromJson).toList(),
      sessions: _list(json['sessions']).map(BackupSession.fromJson).toList(),
      settings: _map(json['settings']),
    );
  }
}

/// Everything needed to show a confirmation screen before writing anything.
class BackupPreview {
  const BackupPreview({
    required this.bundle,
    required this.counterCount,
    required this.tapCount,
    required this.newCounterCount,
    required this.newTapCount,
    required this.skippedTapCount,
    this.firstTap,
    this.lastTap,
    this.encrypted = false,
    this.compressed = false,
  });

  final BackupBundle bundle;
  final int counterCount;
  final int tapCount;
  final int newCounterCount;
  final int newTapCount;
  final int skippedTapCount;
  final DateTime? firstTap;
  final DateTime? lastTap;
  final bool encrypted;
  final bool compressed;

  bool get hasData => counterCount > 0 || tapCount > 0;
}

/// Outcome of an import.
class BackupImportResult {
  const BackupImportResult({
    required this.countersAdded,
    required this.tapsAdded,
    required this.sessionsAdded,
    required this.countersSkipped,
    required this.tapsSkipped,
    required this.sessionsSkipped,
    required this.settingsApplied,
    required this.replaced,
  });

  final int countersAdded;
  final int tapsAdded;
  final int sessionsAdded;
  final int countersSkipped;
  final int tapsSkipped;
  final int sessionsSkipped;
  final int settingsApplied;
  final bool replaced;

  int get added => countersAdded + tapsAdded + sessionsAdded;
}

enum BackupImportMode { replace, merge }

class BackupFormatException implements Exception {
  BackupFormatException(this.message, {this.tooNewVersion = false});

  BackupFormatException.tooNew(int v)
      : message = 'Backup format v$v is newer than this app supports',
        tooNewVersion = true;
  BackupFormatException.unsupported(int v)
      : message = 'Backup format v$v is no longer supported',
        tooNewVersion = false;

  final String message;
  final bool tooNewVersion;

  @override
  String toString() => 'BackupFormatException: $message';
}

// --- small JSON coercion helpers (never throw on bad input) ---------------

String _str(Object? v, {String fallback = ''}) => v is String ? v : (v?.toString() ?? fallback);
int _int(Object? v, {int fallback = 0}) => v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? fallback);
double _double(Object? v, {double fallback = 0}) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? fallback;
bool _bool(Object? v, {bool fallback = false}) => v is bool ? v : ('$v' == 'true' ? true : ('$v' == 'false' ? false : fallback));
DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

List<Map<String, dynamic>> _list(Object? v) {
  if (v is! List) return const <Map<String, dynamic>>[];
  return v.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
}

Map<String, String> _map(Object? v) {
  if (v is! Map) return const <String, String>{};
  return v.map((k, value) => MapEntry('$k', '$value'));
}
