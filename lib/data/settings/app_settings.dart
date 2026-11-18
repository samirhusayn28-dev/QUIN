import 'package:flutter/foundation.dart';

/// Where the big count number sits on the tally screen.
enum TotalPosition {
  topCenter,
  bottomCenter,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center;

  String get label => switch (this) {
        TotalPosition.topCenter => 'Top center',
        TotalPosition.bottomCenter => 'Bottom center',
        TotalPosition.topLeft => 'Top left',
        TotalPosition.topRight => 'Top right',
        TotalPosition.bottomLeft => 'Bottom left',
        TotalPosition.bottomRight => 'Bottom right',
        TotalPosition.center => 'Behind tally',
      };
}

/// How much of the tally screen is tappable to count.
enum TapArea {
  small,
  medium,
  large;

  String get label => switch (this) {
        TapArea.small => 'Small',
        TapArea.medium => 'Medium',
        TapArea.large => 'Whole screen',
      };

  /// Fraction of the shortest screen side that accepts taps.
  double get fraction => switch (this) {
        TapArea.small => 0.45,
        TapArea.medium => 0.7,
        TapArea.large => 1.0,
      };
}

/// Selectable color themes.
enum AppThemeVariant {
  neo,
  mint,
  sunset,
  lavender,
  ocean,
  blush,
  latte;

  String get label => switch (this) {
        AppThemeVariant.neo => 'Classic',
        AppThemeVariant.mint => 'Mint',
        AppThemeVariant.sunset => 'Sunset',
        AppThemeVariant.lavender => 'Lavender',
        AppThemeVariant.ocean => 'Ocean',
        AppThemeVariant.blush => 'Blush',
        AppThemeVariant.latte => 'Latte',
      };
}

/// UI language.
enum AppLanguage {
  system,
  english,
  spanish,
  french,
  german,
  hindi,
  arabic;

  String? get localeCode => switch (this) {
        AppLanguage.system => null,
        AppLanguage.english => 'en',
        AppLanguage.spanish => 'es',
        AppLanguage.french => 'fr',
        AppLanguage.german => 'de',
        AppLanguage.hindi => 'hi',
        AppLanguage.arabic => 'ar',
      };

  String get label => switch (this) {
        AppLanguage.system => 'System default',
        AppLanguage.english => 'English',
        AppLanguage.spanish => 'Español',
        AppLanguage.french => 'Français',
        AppLanguage.german => 'Deutsch',
        AppLanguage.hindi => 'हिन्दी',
        AppLanguage.arabic => 'العربية',
      };
}

/// Persisted application preferences.
///
/// Every value is stored as text in the `settings` table so backups stay
/// forward-compatible: unknown keys are preserved, unknown values fall back to
/// the default.
@immutable
class AppSettings {
  const AppSettings({
    this.numberPosition = TotalPosition.topCenter,
    this.sound = false,
    this.haptics = true,
    this.theme = AppThemeVariant.neo,
    this.tapArea = TapArea.large,
    this.accidentalTapProtection = false,
    this.notificationCounting = false,
    this.volumeButtonCounting = false,
    this.reduceMotion = false,
    this.language = AppLanguage.system,
    this.backupReminderDays = 7,
    this.lastBackupAt,
  });

  final TotalPosition numberPosition;
  final bool sound;
  final bool haptics;
  final AppThemeVariant theme;
  final TapArea tapArea;
  final bool accidentalTapProtection;
  final bool notificationCounting;
  final bool volumeButtonCounting;
  final bool reduceMotion;
  final AppLanguage language;

  /// Remind every N days. `0` disables the reminder.
  final int backupReminderDays;
  final DateTime? lastBackupAt;

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    TotalPosition? numberPosition,
    bool? sound,
    bool? haptics,
    AppThemeVariant? theme,
    TapArea? tapArea,
    bool? accidentalTapProtection,
    bool? notificationCounting,
    bool? volumeButtonCounting,
    bool? reduceMotion,
    AppLanguage? language,
    int? backupReminderDays,
    DateTime? lastBackupAt,
    bool clearLastBackup = false,
  }) {
    return AppSettings(
      numberPosition: numberPosition ?? this.numberPosition,
      sound: sound ?? this.sound,
      haptics: haptics ?? this.haptics,
      theme: theme ?? this.theme,
      tapArea: tapArea ?? this.tapArea,
      accidentalTapProtection:
          accidentalTapProtection ?? this.accidentalTapProtection,
      notificationCounting: notificationCounting ?? this.notificationCounting,
      volumeButtonCounting: volumeButtonCounting ?? this.volumeButtonCounting,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      language: language ?? this.language,
      backupReminderDays: backupReminderDays ?? this.backupReminderDays,
      lastBackupAt:
          clearLastBackup ? null : (lastBackupAt ?? this.lastBackupAt),
    );
  }

  /// Whether a backup reminder is due right now.
  bool backupReminderDue([DateTime? now]) {
    if (backupReminderDays <= 0) return false;
    final last = lastBackupAt;
    if (last == null) return true;
    final at = now ?? DateTime.now();
    return at.difference(last).inDays >= backupReminderDays;
  }

  int? get daysSinceBackup => lastBackupAt == null
      ? null
      : DateTime.now().difference(lastBackupAt!).inDays;

  Map<String, String> toMap() => <String, String>{
        SettingsKeys.numberPosition: numberPosition.name,
        SettingsKeys.sound: '$sound',
        SettingsKeys.haptics: '$haptics',
        SettingsKeys.theme: theme.name,
        SettingsKeys.tapArea: tapArea.name,
        SettingsKeys.accidentalTapProtection: '$accidentalTapProtection',
        SettingsKeys.notificationCounting: '$notificationCounting',
        SettingsKeys.volumeButtonCounting: '$volumeButtonCounting',
        SettingsKeys.reduceMotion: '$reduceMotion',
        SettingsKeys.language: language.name,
        SettingsKeys.backupReminderDays: '$backupReminderDays',
        if (lastBackupAt != null)
          SettingsKeys.lastBackupAt: lastBackupAt!.toIso8601String(),
      };

  factory AppSettings.fromMap(Map<String, String> map) {
    T enumOf<T extends Enum>(List<T> values, String key, T fallback) {
      final raw = map[key];
      if (raw == null) return fallback;
      for (final v in values) {
        if (v.name == raw) return v;
      }
      return fallback;
    }

    bool boolOf(String key, bool fallback) {
      final raw = map[key];
      if (raw == null) return fallback;
      return raw == 'true';
    }

    final lastRaw = map[SettingsKeys.lastBackupAt];
    return AppSettings(
      numberPosition: enumOf(
          TotalPosition.values, SettingsKeys.numberPosition, TotalPosition.topCenter),
      sound: boolOf(SettingsKeys.sound, false),
      haptics: boolOf(SettingsKeys.haptics, true),
      theme: enumOf(AppThemeVariant.values, SettingsKeys.theme, AppThemeVariant.neo),
      tapArea: enumOf(TapArea.values, SettingsKeys.tapArea, TapArea.large),
      accidentalTapProtection:
          boolOf(SettingsKeys.accidentalTapProtection, false),
      notificationCounting: boolOf(SettingsKeys.notificationCounting, false),
      volumeButtonCounting: boolOf(SettingsKeys.volumeButtonCounting, false),
      reduceMotion: boolOf(SettingsKeys.reduceMotion, false),
      language: enumOf(AppLanguage.values, SettingsKeys.language, AppLanguage.system),
      backupReminderDays:
          int.tryParse(map[SettingsKeys.backupReminderDays] ?? '') ?? 7,
      lastBackupAt: lastRaw == null ? null : DateTime.tryParse(lastRaw),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.numberPosition == numberPosition &&
      other.sound == sound &&
      other.haptics == haptics &&
      other.theme == theme &&
      other.tapArea == tapArea &&
      other.accidentalTapProtection == accidentalTapProtection &&
      other.notificationCounting == notificationCounting &&
      other.volumeButtonCounting == volumeButtonCounting &&
      other.reduceMotion == reduceMotion &&
      other.language == language &&
      other.backupReminderDays == backupReminderDays &&
      other.lastBackupAt == lastBackupAt;

  @override
  int get hashCode => Object.hash(
        numberPosition,
        sound,
        haptics,
        theme,
        tapArea,
        accidentalTapProtection,
        notificationCounting,
        volumeButtonCounting,
        reduceMotion,
        language,
        backupReminderDays,
        lastBackupAt,
      );
}

/// Database keys for [AppSettings]. Prefixed so they never collide with the
/// widget/notification keys and so imports can be filtered.
abstract final class SettingsKeys {
  static const String prefix = 'pref_';

  static const String numberPosition = '${prefix}number_position';
  static const String sound = '${prefix}sound';
  static const String haptics = '${prefix}haptics';
  static const String theme = '${prefix}theme';
  static const String tapArea = '${prefix}tap_area';
  static const String accidentalTapProtection = '${prefix}accidental_tap_protection';

  /// Canonical key shared with the native notification contract
  /// (`WidgetKeys.notificationEnabled`).
  static const String notificationCounting = 'tally_notification_enabled';

  /// Counter shown by the persistent notification / Live Activity.
  static const String notificationCounter = 'tally_notification_counter';
  static const String volumeButtonCounting = '${prefix}volume_button_counting';
  static const String reduceMotion = '${prefix}reduce_motion';
  static const String language = '${prefix}language';
  static const String backupReminderDays = '${prefix}backup_reminder_days';
  static const String lastBackupAt = '${prefix}last_backup_at';

  /// One-time onboarding marker: set when the first counter is created or the
  /// user skips setup. Once set (or if any counter already exists) onboarding is
  /// never shown again.
  static const String onboardingComplete = '${prefix}onboarding_complete';

  static const List<String> all = <String>[
    numberPosition,
    sound,
    haptics,
    theme,
    tapArea,
    accidentalTapProtection,
    notificationCounting,
    notificationCounter,
    volumeButtonCounting,
    reduceMotion,
    language,
    backupReminderDays,
    lastBackupAt,
  ];
}
