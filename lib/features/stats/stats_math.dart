import 'dart:math' as math;

/// Statistical computations for tally counter analytics.
class StatsMath {
  StatsMath._();

  /// Calculate streak (consecutive days with at least one tap).
  static StreakResult calculateStreak({
    required List<DateTime> tapDates,
    int graceDays = 0,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = tapDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) {
      return StreakResult(current: 0, longest: 0, freezeUsed: false);
    }

    var current = 0;
    var longest = 0;
    var streak = 0;
    var graceRemaining = graceDays;

    // Check from today backwards
    var checkDate = today;
    var i = dates.length - 1;

    // Current streak
    while (i >= 0) {
      if (dates[i] == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
        i--;
      } else if (graceRemaining > 0 && dates[i] == checkDate.subtract(const Duration(days: 1))) {
        // One day is missing at `checkDate`; spend a grace day and continue.
        graceRemaining--;
        streak++;
        checkDate = dates[i].subtract(const Duration(days: 1));
        i--;
      } else {
        break;
      }
    }
    current = streak;

    // Longest streak (forward scan)
    streak = 0;
    graceRemaining = graceDays;
    var prevDate = dates.first;
    streak = 1;
    longest = 1;

    for (var j = 1; j < dates.length; j++) {
      final diff = dates[j].difference(prevDate).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff - 1 <= graceRemaining) {
        graceRemaining -= (diff - 1);
        streak++;
      } else {
        streak = 1;
        graceRemaining = graceDays;
      }
      longest = math.max(longest, streak);
      prevDate = dates[j];
    }

    return StreakResult(
      current: current,
      longest: longest,
      freezeUsed: graceDays > 0 && graceRemaining < graceDays,
    );
  }

  /// GitHub-style heatmap data: `Map<DateTime, int>` (date -> count).
  static Map<DateTime, int> buildHeatmap(
    List<TapEvent> taps, {
    int? weeks,
  }) {
    final now = DateTime.now();
    final start = weeks != null
        ? DateTime(now.year, now.month, now.day).subtract(Duration(days: weeks * 7))
        : DateTime(now.year - 1, now.month, now.day);

    final map = <DateTime, int>{};
    for (var d = start; d.isBefore(now.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      map[DateTime(d.year, d.month, d.day)] = 0;
    }

    for (final tap in taps) {
      final key = DateTime(tap.timestamp.year, tap.timestamp.month, tap.timestamp.day);
      if (map.containsKey(key)) {
        map[key] = (map[key] ?? 0) + tap.delta;
      }
    }
    return map;
  }

  /// Cumulative totals over time.
  static List<CumulativePoint> cumulative(
    List<TapEvent> taps, {
    required DateTime start,
    required DateTime end,
    int bucketDays = 1,
  }) {
    final buckets = <DateTime, int>{};
    var current = DateTime(start.year, start.month, start.day);
    while (!current.isAfter(end)) {
      buckets[current] = 0;
      current = current.add(Duration(days: bucketDays));
    }

    int running = 0;
    for (final tap in taps) {
      if (tap.timestamp.isAfter(start) && tap.timestamp.isBefore(end.add(const Duration(days: 1)))) {
        running += tap.delta;
        final key = DateTime(tap.timestamp.year, tap.timestamp.month, tap.timestamp.day);
        if (buckets.containsKey(key)) {
          buckets[key] = running;
        }
      }
    }

    return buckets.entries
        .map((e) => CumulativePoint(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Daily/weekly/monthly aggregation.
  static List<ChartBucket> aggregate(
    List<TapEvent> taps, {
    required AggregationLevel level,
    required DateTime start,
    required DateTime end,
  }) {
    final map = <String, int>{};
    for (final tap in taps) {
      if (tap.timestamp.isBefore(start) || tap.timestamp.isAfter(end)) continue;
      String key;
      switch (level) {
        case AggregationLevel.daily:
          key = '${tap.timestamp.year}-${tap.timestamp.month.toString().padLeft(2, '0')}-${tap.timestamp.day.toString().padLeft(2, '0')}';
          break;
        case AggregationLevel.weekly:
          final week = _weekOfYear(tap.timestamp);
          key = '${tap.timestamp.year}-W${week.toString().padLeft(2, '0')}';
          break;
        case AggregationLevel.monthly:
          key = '${tap.timestamp.year}-${tap.timestamp.month.toString().padLeft(2, '0')}';
          break;
      }
      map[key] = (map[key] ?? 0) + tap.delta;
    }

    return map.entries
        .map((e) => ChartBucket(label: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  static int _weekOfYear(DateTime dt) {
    final firstDay = DateTime(dt.year, 1, 1);
    final daysDiff = dt.difference(firstDay).inDays;
    return (daysDiff / 7).ceil();
  }

  /// Hour of day distribution (0-23).
  static List<ChartBucket> hourOfDay(List<TapEvent> taps) {
    final counts = List<int>.filled(24, 0);
    for (final tap in taps) {
      counts[tap.timestamp.hour] += tap.delta;
    }
    return List.generate(24, (h) => ChartBucket(label: '$h:00', value: counts[h]));
  }

  /// Day of week distribution.
  static List<ChartBucket> dayOfWeek(List<TapEvent> taps) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = List<int>.filled(7, 0);
    for (final tap in taps) {
      final idx = (tap.timestamp.weekday - 1) % 7;
      counts[idx] += tap.delta;
    }
    return List.generate(7, (i) => ChartBucket(label: days[i], value: counts[i]));
  }

  /// Session detection: group taps with gap <= gapMinutes.
  static List<Session> detectSessions(
    List<TapEvent> taps, {
    int gapMinutes = 30,
  }) {
    if (taps.isEmpty) return [];
    final sorted = [...taps]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final sessions = <Session>[];
    var current = Session(
      start: sorted.first.timestamp,
      end: sorted.first.timestamp,
      taps: 1,
      total: sorted.first.delta,
    );

    for (var i = 1; i < sorted.length; i++) {
      final diff = sorted[i].timestamp.difference(sorted[i - 1].timestamp).inMinutes;
      if (diff <= gapMinutes) {
        current = Session(
          start: current.start,
          end: sorted[i].timestamp,
          taps: current.taps + 1,
          total: current.total + sorted[i].delta,
        );
      } else {
        sessions.add(current);
        current = Session(
          start: sorted[i].timestamp,
          end: sorted[i].timestamp,
          taps: 1,
          total: sorted[i].delta,
        );
      }
    }
    sessions.add(current);
    return sessions;
  }

  /// Statistical summary.
  static StatsSummary summarize(
    List<TapEvent> taps, {
    DateTime? start,
    DateTime? end,
    int activeDayThreshold = 1,
    int? targetValue,
  }) {
    final filtered = taps.where((t) {
      if (start != null && t.timestamp.isBefore(start)) return false;
      if (end != null && t.timestamp.isAfter(end)) return false;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return StatsSummary.empty();
    }

    final total = filtered.fold<int>(0, (s, t) => s + t.delta);
    final count = filtered.length;
    final avg = total / count;

    final daily = <DateTime, int>{};
    for (final tap in filtered) {
      final key = DateTime(tap.timestamp.year, tap.timestamp.month, tap.timestamp.day);
      daily[key] = (daily[key] ?? 0) + tap.delta;
    }

    final activeDays = daily.values.where((v) => v >= activeDayThreshold).length;
    final avgPerActiveDay = activeDays > 0 ? total / activeDays : 0.0;

    final sortedDaily = daily.values.toList()..sort();
    final bestDay = sortedDaily.isNotEmpty ? sortedDaily.last : 0;
    final median = _median(sortedDaily.map((e) => e.toDouble()).toList());

    // Standard deviation
    final mean = daily.values.reduce((a, b) => a + b) / daily.length;
    final variance = daily.values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / daily.length;
    final stdDev = math.sqrt(variance);

    // Peak session
    final sessions = detectSessions(filtered);
    final peakSession = sessions.fold<Session?>(
      null,
      (max, s) => (max == null || s.total > max.total) ? s : max,
    );

    // Moving averages
    final ma7 = _movingAverage(daily, 7);
    final ma30 = _movingAverage(daily, 30);

    // Trend line (linear regression)
    final trend = _linearRegression(daily);
    final projectedGoal = _projectGoal(
      daily: daily,
      slope: trend.slope,
      intercept: trend.intercept,
      targetValue: targetValue,
    );

    final streak = calculateStreak(
      tapDates: filtered.map((t) => t.timestamp).toList(),
    );
    return StatsSummary(
      total: total,
      count: count,
      average: avg,
      activeDays: activeDays,
      avgPerActiveDay: avgPerActiveDay,
      bestDay: bestDay,
      median: median,
      stdDev: stdDev,
      peakSession: peakSession,
      movingAverage7: ma7,
      movingAverage30: ma30,
      trendSlope: trend.slope,
      trendIntercept: trend.intercept,
      projectedGoalDate: projectedGoal,
      currentStreak: streak.current,
      longestStreak: streak.longest,
      streakFreezeUsed: streak.freezeUsed,
    );
  }

  static double _median(List<double> sorted) {
    if (sorted.isEmpty) return 0;
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  static List<double> _movingAverage(Map<DateTime, int> daily, int window) {
    final values = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (values.length < window) return [];
    final result = <double>[];
    for (var i = window - 1; i < values.length; i++) {
      final sum = values.sublist(i - window + 1, i + 1).fold(0, (s, e) => s + e.value);
      result.add(sum / window);
    }
    return result;
  }

  static _RegressionResult _linearRegression(Map<DateTime, int> daily) {
    final entries = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (entries.length < 2) return _RegressionResult(slope: 0, intercept: 0);
    final n = entries.length.toDouble();
    var sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumX2 = 0.0;
    for (var i = 0; i < entries.length; i++) {
      final x = i.toDouble();
      final y = entries[i].value.toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    return _RegressionResult(slope: slope, intercept: intercept);
  }

  /// Projects when [targetValue] will be reached from the regression trend.
  ///
  /// The regression x-axis is the index of each *active* day. Beyond the last
  /// active day we convert index distance to calendar days using the average
  /// gap between active days, which keeps the estimate stable for sporadic use.
  static DateTime? _projectGoal({
    required Map<DateTime, int> daily,
    required double slope,
    required double intercept,
    int? targetValue,
  }) {
    if (targetValue == null || slope <= 1e-6) return null;
    final entries = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (entries.length < 2) return null;
    final x = (targetValue - intercept) / slope;
    if (!x.isFinite || x <= 0) return null;
    final extraIndex = x - (entries.length - 1);
    if (extraIndex <= 0) return null;
    final firstDate = entries.first.key;
    final lastDate = entries.last.key;
    final spanDays = lastDate.difference(firstDate).inDays;
    final avgGap = entries.length > 1 ? math.max(1.0, spanDays / (entries.length - 1)) : 1.0;
    final calendarDays = math.max(1, (extraIndex * avgGap).ceil());
    if (calendarDays > 3650) return null;
    return lastDate.add(Duration(days: calendarDays));
  }
}

// --- Data classes ---

class TapEvent {
  final DateTime timestamp;
  final int delta;
  final String counterId;

  TapEvent({required this.timestamp, required this.delta, required this.counterId});
}

class StreakResult {
  final int current;
  final int longest;
  final bool freezeUsed;

  StreakResult({required this.current, required this.longest, required this.freezeUsed});
}

class CumulativePoint {
  final DateTime date;
  final int value;

  CumulativePoint({required this.date, required this.value});
}

class ChartBucket {
  final String label;
  final int value;

  ChartBucket({required this.label, required this.value});
}

enum AggregationLevel { daily, weekly, monthly }

class Session {
  final DateTime start;
  final DateTime end;
  final int taps;
  final int total;

  Session({required this.start, required this.end, required this.taps, required this.total});

  Duration get duration => end.difference(start);
}

class StatsSummary {
  final int total;
  final int count;
  final double average;
  final int activeDays;
  final double avgPerActiveDay;
  final int bestDay;
  final double median;
  final double stdDev;
  final Session? peakSession;
  final List<double> movingAverage7;
  final List<double> movingAverage30;
  final double trendSlope;
  final double trendIntercept;
  /// Estimated date the counter's target is reached from the current trend.
  /// `null` when there is no target or the trend is flat/negative.
  final DateTime? projectedGoalDate;
  final int currentStreak;
  final int longestStreak;
  final bool streakFreezeUsed;

  StatsSummary({
    required this.total,
    required this.count,
    required this.average,
    required this.activeDays,
    required this.avgPerActiveDay,
    required this.bestDay,
    required this.median,
    required this.stdDev,
    this.peakSession,
    required this.movingAverage7,
    required this.movingAverage30,
    required this.trendSlope,
    required this.trendIntercept,
    this.projectedGoalDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakFreezeUsed = false,
  });

  factory StatsSummary.empty() => StatsSummary(
        total: 0,
        count: 0,
        average: 0,
        activeDays: 0,
        avgPerActiveDay: 0,
        bestDay: 0,
        median: 0,
        stdDev: 0,
        movingAverage7: [],
        movingAverage30: [],
        trendSlope: 0,
        trendIntercept: 0,
      );
}

class _RegressionResult {
  final double slope;
  final double intercept;

  _RegressionResult({required this.slope, required this.intercept});
}