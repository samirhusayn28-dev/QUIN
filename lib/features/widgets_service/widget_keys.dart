/// Shared data contract between Dart and the native widget / notification code.
///
/// Everything is stored in the `home_widget` SharedPreferences (Android) /
/// UserDefaults app-group (iOS) so the native side can read it without any
/// channel round-trip.
library;

class WidgetKeys {
  WidgetKeys._();

  /// All counter ids, comma separated.
  static const String counterIds = 'tally_counter_ids';

  /// Counter id shown by the persistent notification.
  static const String notificationCounter = 'tally_notification_counter';

  /// Whether the persistent notification / foreground service is running.
  static const String notificationEnabled = 'tally_notification_enabled';

  // --- Per-counter keys (suffix with counter id) ---
  static String name(String id) => 'tally_counter_${id}_name';
  static String total(String id) => 'tally_counter_${id}_total';
  static String style(String id) => 'tally_counter_${id}_style';
  static String stroke(String id) => 'tally_counter_${id}_stroke';
  static String accent(String id) => 'tally_counter_${id}_accent';
  static String surface(String id) => 'tally_counter_${id}_surface';
  static String start(String id) => 'tally_counter_${id}_start';
  static String target(String id) => 'tally_counter_${id}_target';

  // --- Per widget-instance binding (suffix with appWidgetId) ---
  static String widgetCounter(int appWidgetId) => 'tally_widget_${appWidgetId}_counter';
  static String widgetIds = 'tally_widget_ids';

  /// URI scheme used by widget + notification buttons to talk back to Dart.
  static const String scheme = 'tally';

  static Uri incrementUri(String counterId, {int delta = 1}) =>
      Uri.parse('$scheme://increment?counterId=$counterId&delta=$delta');

  static Uri openUri([String? counterId]) =>
      Uri.parse('$scheme://open${counterId != null ? '?counterId=$counterId' : ''}');
}
