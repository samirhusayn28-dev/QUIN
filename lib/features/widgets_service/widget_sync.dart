import 'package:home_widget/home_widget.dart';

import '../../data/database/app_database.dart';
import '../../tally_styles/line_style.dart';
import 'notification_service.dart';
import 'widget_keys.dart';

/// Android widget provider class names (must match the Kotlin classes).
class TallyWidgets {
  TallyWidgets._();
  static const String small =
      'com.tallycounter.tally_counter.widget.TallyWidgetSmallProvider';
  static const String medium =
      'com.tallycounter.tally_counter.widget.TallyWidgetMediumProvider';
  static const List<String> all = <String>[small, medium];

  static const String androidPackage = 'com.tallycounter.tally_counter';
}

/// Keeps the home-screen widgets, lock-screen previews and the persistent
/// notification in sync with the Drift database.
class WidgetSyncService {
  WidgetSyncService(this._db);

  final AppDatabase _db;

  bool _syncing = false;

  /// Push every counter to the shared store, (re)render previews and refresh
  /// all widget instances + notification. Safe to call often.
  Future<void> syncAll() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final counters = await _db.getAllCounters(includeArchived: true);
      final ids = counters.map((c) => c.id).join(',');
      await HomeWidget.saveWidgetData<String>(WidgetKeys.counterIds, ids);

      for (final c in counters) {
        await _writeCounter(c);
      }

      await _refreshWidgets();
      await _syncNotification(counters);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _writeCounter(Counter c) async {
    await HomeWidget.saveWidgetData<int>(WidgetKeys.total(c.id), c.currentValue);
    await HomeWidget.saveWidgetData<String>(WidgetKeys.name(c.id), c.name);
    await HomeWidget.saveWidgetData<String>(WidgetKeys.style(c.id), c.lineStyle);
    await HomeWidget.saveWidgetData<int>(
        WidgetKeys.stroke(c.id), lineStyleStrokeValue(c.lineStyle));
    await HomeWidget.saveWidgetData<int>(WidgetKeys.accent(c.id), c.accentColor);
    await HomeWidget.saveWidgetData<int>(
        WidgetKeys.surface(c.id), kWidgetSurfaceValue);
    await HomeWidget.saveWidgetData<int>(WidgetKeys.start(c.id), c.startValue);
    await HomeWidget.saveWidgetData<int>(
        WidgetKeys.target(c.id), c.targetValue ?? -1);
  }

  Future<void> _refreshWidgets() async {
    for (final name in TallyWidgets.all) {
      try {
        await HomeWidget.updateWidget(
          androidName: name.split('.').last,
          qualifiedAndroidName: name,
          iOSName: 'TallyWidget',
        );
      } catch (_) {}
    }
  }

  Future<void> _syncNotification(List<Counter> counters) async {
    final enabled = await _db.getSetting(WidgetKeys.notificationEnabled);
    final selected = await _db.getSetting(WidgetKeys.notificationCounter);
    if (enabled != 'true' || selected == null) return;
    final c = counters.where((x) => x.id == selected).firstOrNull;
    if (c == null) return;
    await NotificationService.update(
      counterId: c.id,
      name: c.name,
      total: c.currentValue,
      strokeColor: lineStyleStrokeValue(c.lineStyle),
      accentColor: c.accentColor,
    );
  }
}

extension on Iterable<Counter> {
  Counter? get firstOrNull => isEmpty ? null : first;
}
