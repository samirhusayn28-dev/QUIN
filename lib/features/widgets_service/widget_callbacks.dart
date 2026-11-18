import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/database/app_database.dart';
import '../../tally_styles/line_style.dart';
import 'notification_service.dart';
import 'widget_keys.dart';

/// Entry point run in a *background isolate* — no Flutter UI.
///
/// Triggered by the home-screen widget `+1` button and by the persistent
/// notification `+1` / `-1` actions. Writes straight to the shared Drift
/// database, then refreshes the widget + notification.
@pragma('vm:entry-point')
Future<void> widgetInteractivityCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri == null) return;

  final params = uri.queryParameters;
  final counterId = params['counterId'];
  final delta = int.tryParse(params['delta'] ?? '1') ?? 1;

  final db = AppDatabase();
  try {
    if (uri.host == 'increment' && counterId != null && counterId.isNotEmpty) {
      await db.tapCounter(counterId, delta: delta);
      final c = await db.getCounter(counterId);
      if (c != null) {
        await HomeWidget.saveWidgetData<int>(
            WidgetKeys.total(c.id), c.currentValue);
        await _refreshWidgets();
        final enabled = await db.getSetting(WidgetKeys.notificationEnabled);
        final selected = await db.getSetting(WidgetKeys.notificationCounter);
        if (enabled == 'true' && selected == c.id) {
          try {
            await NotificationService.update(
              counterId: c.id,
              name: c.name,
              total: c.currentValue,
              strokeColor: lineStyleStrokeValue(c.lineStyle),
              accentColor: c.accentColor,
            );
          } catch (_) {
            // The notification channel is only registered on the main engine;
            // the native receiver already refreshed the notification.
          }
        }
      }
    }
  } finally {
    await db.close();
  }
}

Future<void> _refreshWidgets() async {
  for (final name in <String>[
    'com.tallycounter.tally_counter.widget.TallyWidgetSmallProvider',
    'com.tallycounter.tally_counter.widget.TallyWidgetMediumProvider',
  ]) {
    try {
      await HomeWidget.updateWidget(
        androidName: name.split('.').last,
        qualifiedAndroidName: name,
        iOSName: 'TallyWidget',
      );
    } catch (_) {}
  }
}
