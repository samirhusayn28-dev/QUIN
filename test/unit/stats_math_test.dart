import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/features/stats/stats_math.dart';

TapEvent _tap(DateTime at, int delta, [String counterId = 'c1']) =>
    TapEvent(timestamp: at, delta: delta, counterId: counterId);

void main() {
  group('calculateStreak', () {
    final today = DateTime.now();
    DateTime dayOffset(int days) =>
        DateTime(today.year, today.month, today.day + days);

    test('counts a consecutive run ending today', () {
      final result = StatsMath.calculateStreak(tapDates: <DateTime>[
        dayOffset(0),
        dayOffset(-1),
        dayOffset(-2),
      ]);
      expect(result.current, 3);
      expect(result.longest, 3);
      expect(result.freezeUsed, isFalse);
    });

    test('ignores days that are not today when computing current', () {
      final result = StatsMath.calculateStreak(tapDates: <DateTime>[
        dayOffset(-3),
        dayOffset(-4),
      ]);
      expect(result.current, 0);
      expect(result.longest, 2);
    });

    test('grace day bridges a single missed day', () {
      final result = StatsMath.calculateStreak(
        tapDates: <DateTime>[dayOffset(0), dayOffset(-2)],
        graceDays: 1,
      );
      expect(result.current, 2);
      expect(result.freezeUsed, isTrue);
    });

    test('empty input yields zeroes', () {
      final result = StatsMath.calculateStreak(tapDates: const <DateTime>[]);
      expect(result.current, 0);
      expect(result.longest, 0);
      expect(result.freezeUsed, isFalse);
    });
  });

  group('buildHeatmap', () {
    test('buckets deltas per calendar day', () {
      final now = DateTime.now();
      DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
      final map = StatsMath.buildHeatmap(<TapEvent>[
        _tap(day(0), 1),
        _tap(day(0), 2),
        _tap(day(-1), 5),
      ], weeks: 2);

      expect(map[day(0)], 3);
      expect(map[day(-1)], 5);
      expect(map.length, greaterThan(10));
    });
  });

  group('aggregate', () {
    final start = DateTime(2024, 1, 1);
    final end = DateTime(2024, 1, 31);
    final taps = <TapEvent>[
      _tap(DateTime(2024, 1, 1, 9), 4),
      _tap(DateTime(2024, 1, 1, 21), 6),
      _tap(DateTime(2024, 1, 8, 12), 10),
    ];

    test('daily groups by date and sums deltas', () {
      final buckets = StatsMath.aggregate(
        taps,
        level: AggregationLevel.daily,
        start: start,
        end: end,
      );
      expect(buckets.length, 2);
      expect(buckets.first.label, '2024-01-01');
      expect(buckets.first.value, 10);
    });

    test('monthly groups by month', () {
      final buckets = StatsMath.aggregate(
        taps,
        level: AggregationLevel.monthly,
        start: start,
        end: end,
      );
      expect(buckets.single.label, '2024-01');
      expect(buckets.single.value, 20);
    });

    test('drops taps outside the window', () {
      final buckets = StatsMath.aggregate(
        <TapEvent>[_tap(DateTime(2023, 12, 31), 99)],
        level: AggregationLevel.daily,
        start: start,
        end: end,
      );
      expect(buckets, isEmpty);
    });
  });

  group('hourOfDay / dayOfWeek', () {
    test('hourOfDay returns 24 buckets', () {
      final buckets = StatsMath.hourOfDay(<TapEvent>[
        _tap(DateTime(2024, 1, 1, 7), 3),
      ]);
      expect(buckets.length, 24);
      expect(buckets[7].value, 3);
    });

    test('dayOfWeek returns 7 buckets starting Monday', () {
      // 2024-01-01 is a Monday.
      final buckets = StatsMath.dayOfWeek(<TapEvent>[
        _tap(DateTime(2024, 1, 1, 9), 2),
        _tap(DateTime(2024, 1, 3, 9), 5),
      ]);
      expect(buckets.length, 7);
      expect(buckets.first.label, 'Mon');
      expect(buckets.first.value, 2);
      expect(buckets[2].value, 5);
    });
  });

  group('detectSessions', () {
    test('splits sessions on the gap threshold', () {
      final sessions = StatsMath.detectSessions(<TapEvent>[
        _tap(DateTime(2024, 1, 1, 10, 0), 1),
        _tap(DateTime(2024, 1, 1, 10, 5), 1),
        _tap(DateTime(2024, 1, 1, 12, 0), 1),
      ]);
      expect(sessions.length, 2);
      expect(sessions.first.taps, 2);
      expect(sessions.first.total, 2);
      expect(sessions.last.taps, 1);
    });

    test('empty input yields no sessions', () {
      expect(StatsMath.detectSessions(const <TapEvent>[]), isEmpty);
    });
  });

  group('summarize', () {
    test('computes totals, averages and streaks', () {
      final today = DateTime.now();
      DateTime day(int offset) => DateTime(today.year, today.month, today.day + offset);
      final summary = StatsMath.summarize(<TapEvent>[
        _tap(day(0), 10),
        _tap(day(-1), 20),
        _tap(day(-2), 30),
      ]);

      expect(summary.total, 60);
      expect(summary.count, 3);
      expect(summary.average, 20);
      expect(summary.activeDays, 3);
      expect(summary.avgPerActiveDay, 20);
      expect(summary.bestDay, 30);
      expect(summary.currentStreak, 3);
      expect(summary.longestStreak, 3);
    });

    test('empty input returns the empty summary', () {
      final summary = StatsMath.summarize(const <TapEvent>[]);
      expect(summary.total, 0);
      expect(summary.count, 0);
      expect(summary.peakSession, isNull);
      expect(summary.projectedGoalDate, isNull);
    });

    test('projects the goal date from a rising trend', () {
      final summary = StatsMath.summarize(
        <TapEvent>[
          _tap(DateTime(2024, 1, 1), 10),
          _tap(DateTime(2024, 1, 2), 20),
          _tap(DateTime(2024, 1, 3), 30),
        ],
        targetValue: 100,
      );
      // Regression over [10, 20, 30] -> slope 10, intercept 10; x = 9,
      // extra index 7, one calendar day per index -> 7 days past Jan 3.
      expect(summary.projectedGoalDate, DateTime(2024, 1, 10));
    });

    test('no projection without a target or a rising trend', () {
      final noTarget = StatsMath.summarize(<TapEvent>[
        _tap(DateTime(2024, 1, 1), 10),
        _tap(DateTime(2024, 1, 2), 20),
      ]);
      expect(noTarget.projectedGoalDate, isNull);

      final flat = StatsMath.summarize(
        <TapEvent>[
          _tap(DateTime(2024, 1, 1), 10),
          _tap(DateTime(2024, 1, 2), 10),
        ],
        targetValue: 100,
      );
      expect(flat.projectedGoalDate, isNull);
    });

    test('filters taps outside the requested window', () {
      final summary = StatsMath.summarize(
        <TapEvent>[
          _tap(DateTime(2024, 1, 1), 5),
          _tap(DateTime(2024, 3, 1), 5),
        ],
        start: DateTime(2024, 2, 1),
      );
      expect(summary.total, 5);
      expect(summary.count, 1);
    });
  });
}
