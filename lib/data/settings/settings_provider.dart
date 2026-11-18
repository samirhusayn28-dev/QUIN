import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../providers.dart';
import 'app_settings.dart';

/// Loads [AppSettings] from the database and persists changes back.
final settingsProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// Synchronous snapshot for widgets that cannot `await` (falls back to
/// [AppSettings.defaults] for the first frame).
final appSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider).value ?? AppSettings.defaults;
});

class SettingsController extends AsyncNotifier<AppSettings> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  Future<AppSettings> build() async {
    return AppSettings.fromMap(await _db.getSettings());
  }

  /// Applies [mutate] to the current settings, updates listeners immediately
  /// and persists in the background.
  ///
  /// Named `mutate` (not `update`) because `AsyncNotifier` reserves `update`.
  Future<AppSettings> mutate(AppSettings Function(AppSettings) mutate) async {
    final current = state.value ?? AppSettings.defaults;
    final next = mutate(current);
    state = AsyncData(next);
    await _db.setSettings(next.toMap());
    return next;
  }

  /// Convenience setters so call sites stay terse.
  Future<void> setNumberPosition(TotalPosition value) =>
      mutate((s) => s.copyWith(numberPosition: value));
  Future<void> setSound(bool value) => mutate((s) => s.copyWith(sound: value));
  Future<void> setHaptics(bool value) =>
      mutate((s) => s.copyWith(haptics: value));
  Future<void> setTheme(AppThemeVariant value) =>
      mutate((s) => s.copyWith(theme: value));
  Future<void> setTapArea(TapArea value) =>
      mutate((s) => s.copyWith(tapArea: value));
  Future<void> setAccidentalTapProtection(bool value) =>
      mutate((s) => s.copyWith(accidentalTapProtection: value));
  Future<void> setNotificationCounting(bool value) =>
      mutate((s) => s.copyWith(notificationCounting: value));
  Future<void> setVolumeButtonCounting(bool value) =>
      mutate((s) => s.copyWith(volumeButtonCounting: value));
  Future<void> setReduceMotion(bool value) =>
      mutate((s) => s.copyWith(reduceMotion: value));
  Future<void> setLanguage(AppLanguage value) =>
      mutate((s) => s.copyWith(language: value));
  Future<void> setBackupReminderDays(int value) =>
      mutate((s) => s.copyWith(backupReminderDays: value));

  Future<void> markBackedUp([DateTime? at]) =>
      mutate((s) => s.copyWith(lastBackupAt: at ?? DateTime.now()));

  Future<void> reload() async {
    state = AsyncData(AppSettings.fromMap(await _db.getSettings()));
  }
}
