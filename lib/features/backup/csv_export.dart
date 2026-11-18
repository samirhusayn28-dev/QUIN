import '../../data/database/app_database.dart';

/// Builds spreadsheet-ready CSV text. Pure functions so they are unit tested.
abstract final class CsvExport {
  static const String _bom = '\uFEFF';

  /// One row per tap, newest data included, joined with the counter name.
  static String tapsCsv(List<Counter> counters, List<Tap> taps) {
    final names = <String, String>{for (final c in counters) c.id: c.name};
    final buffer = StringBuffer()
      ..writeln(_row(<String>[
        'tap_id',
        'counter_id',
        'counter_name',
        'delta',
        'value_after',
        'at',
        'local_date',
        'session_id',
        'note',
      ]));
    final sorted = <Tap>[...taps]..sort((a, b) => a.at.compareTo(b.at));
    for (final t in sorted) {
      buffer.writeln(_row(<String>[
        t.id,
        t.counterId,
        names[t.counterId] ?? '',
        '${t.delta}',
        '${t.valueAfter}',
        t.at.toIso8601String(),
        _date(t.at),
        t.sessionId ?? '',
        t.note ?? '',
      ]));
    }
    return _bom + buffer.toString();
  }

  /// One row per session.
  static String sessionsCsv(List<Counter> counters, List<Session> sessions) {
    final names = <String, String>{for (final c in counters) c.id: c.name};
    final buffer = StringBuffer()
      ..writeln(_row(<String>[
        'session_id',
        'counter_id',
        'counter_name',
        'label',
        'tags',
        'started_at',
        'ended_at',
        'start_value',
        'end_value',
        'delta',
      ]));
    final sorted = <Session>[...sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    for (final s in sorted) {
      final end = s.endValue;
      buffer.writeln(_row(<String>[
        s.id,
        s.counterId,
        names[s.counterId] ?? '',
        s.label ?? '',
        s.tags ?? '',
        s.startedAt.toIso8601String(),
        s.endedAt?.toIso8601String() ?? '',
        '${s.startValue}',
        end?.toString() ?? '',
        end == null ? '' : '${end - s.startValue}',
      ]));
    }
    return _bom + buffer.toString();
  }

  static String _date(DateTime at) {
    final d = at.toLocal();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _row(List<String> cells) => cells.map(_cell).join(',');

  static String _cell(String raw) {
    if (raw.contains(',') || raw.contains('"') || raw.contains('\n') || raw.contains('\r')) {
      return '"${raw.replaceAll('"', '""')}"';
    }
    return raw;
  }
}
