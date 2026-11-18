import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../core/theme/neo_theme.dart';
import '../../data/providers.dart';
import '../../data/settings/app_settings.dart';
import '../../data/settings/settings_provider.dart';
import '../../features/widgets/widgets.dart';
import '../../tally_styles/line_style.dart';
import '../widgets_service/live_activity.dart';
import '../widgets_service/notification_service.dart';
import 'developer_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _notificationCounterId;

  @override
  void initState() {
    super.initState();
    _loadNotificationCounter();
  }

  Future<void> _loadNotificationCounter() async {
    final value = await ref
        .read(databaseProvider)
        .getSetting(SettingsKeys.notificationCounter);
    if (mounted) setState(() => _notificationCounterId = value);
  }

  // ------------------------------------------------------------- notification

  Future<void> _toggleNotificationCounting(bool value) async {
    final db = ref.read(databaseProvider);
    final counters = await db.getAllCounters();
    if (counters.isEmpty) return;
    var id = _notificationCounterId;
    id ??= counters.first.id;

    await db.setSetting(SettingsKeys.notificationCounter, id);
    await ref.read(settingsProvider.notifier).setNotificationCounting(value);
    if (!mounted) return;
    setState(() => _notificationCounterId = id);

    final c = counters.firstWhere((x) => x.id == id, orElse: () => counters.first);
    if (value) {
      if (Platform.isAndroid) {
        await NotificationService.requestPermission();
        await NotificationService.start(counterId: id);
        await NotificationService.update(
          counterId: id,
          name: c.name,
          total: c.currentValue,
          strokeColor: lineStyleStrokeValue(c.lineStyle),
          accentColor: c.accentColor,
        );
      } else if (Platform.isIOS) {
        await LiveActivityService.start(
          counterId: id,
          name: c.name,
          total: c.currentValue,
          strokeColor: lineStyleStrokeValue(c.lineStyle),
          accentColor: c.accentColor,
        );
      }
    } else {
      if (Platform.isAndroid) {
        await NotificationService.stop();
      } else if (Platform.isIOS) {
        await LiveActivityService.end(counterId: id);
      }
    }
    await ref.read(widgetSyncProvider).syncAll();
  }

  Future<void> _pickNotificationCounter() async {
    final strings = AppStrings.of(context);
    final counters = await ref.read(databaseProvider).getAllCounters();
    if (!mounted) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.neo.paperAlt,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                strings.counterShown,
                style: AppTypography.grotesk(size: 16, weight: FontWeight.w700),
              ),
            ),
            ...counters.map(
              (c) => ListTile(
                leading: Icon(Icons.circle, color: Color(c.accentColor), size: 16),
                title: Text(c.name),
                selected: c.id == _notificationCounterId,
                onTap: () => Navigator.pop(ctx, c.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await ref
        .read(databaseProvider)
        .setSetting(SettingsKeys.notificationCounter, picked);
    setState(() => _notificationCounterId = picked);

    final enabled = ref.read(appSettingsProvider).notificationCounting;
    if (enabled) {
      final c = counters.firstWhere((x) => x.id == picked, orElse: () => counters.first);
      if (Platform.isAndroid) {
        await NotificationService.update(
          counterId: c.id,
          name: c.name,
          total: c.currentValue,
          strokeColor: lineStyleStrokeValue(c.lineStyle),
          accentColor: c.accentColor,
        );
      } else if (Platform.isIOS) {
        await LiveActivityService.update(
          counterId: c.id,
          name: c.name,
          total: c.currentValue,
          strokeColor: lineStyleStrokeValue(c.lineStyle),
          accentColor: c.accentColor,
        );
      }
    }
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final strings = AppStrings.of(context);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.settings),
      appBar: AppBar(
        title: Text(strings.settings,
            style: AppTypography.grotesk(size: 18, weight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            tooltip: strings.backupTitle,
            onPressed: () => context.push('/backup'),
            icon: const Icon(Icons.backup_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _appearanceCard(strings, settings, notifier),
          const SizedBox(height: 16),
          _countingCard(strings, settings, notifier),
          const SizedBox(height: 16),
          _lockScreenCard(strings, settings),
          const SizedBox(height: 16),
          _dataCard(strings, settings),
          const SizedBox(height: 16),
          // Designed & Developed By — also reachable from the QUIN top bar.
          DeveloperCard(),
          if (kDebugMode) ...<Widget>[
            const SizedBox(height: 16),
            _debugCard(context, strings),
          ],
          const SizedBox(height: 16),
          Center(
            child: Text('QUIN 1.0.0',
                style: AppTypography.grotesk(size: 12)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text.toUpperCase(),
        style: AppTypography.grotesk(
          size: 12,
          weight: FontWeight.w700,
          color: NeoPalette.inkSoft,
          spacing: 1.2,
        ),
      );

  Widget _choiceWrap<T>({
    required List<T> values,
    required T selected,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
    Color color = NeoPalette.yellow,
    Color Function(T)? colorOf,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map((v) => NeoChip(
                label: label(v),
                selected: v == selected,
                color: colorOf?.call(v) ?? color,
                onTap: () => onChanged(v),
              ))
          .toList(),
    );
  }

  Widget _appearanceCard(AppStrings s, AppSettings settings, SettingsController notifier) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(s.appearance),
          const SizedBox(height: 14),
          Text(s.theme, style: AppTypography.grotesk(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          _choiceWrap<AppThemeVariant>(
            values: AppThemeVariant.values,
            selected: settings.theme,
            label: (v) => v.label,
            colorOf: AppTheme.accentFor,
            onChanged: notifier.setTheme,
          ),
          const SizedBox(height: 18),
          Text(s.language, style: AppTypography.grotesk(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          _choiceWrap<AppLanguage>(
            values: AppLanguage.values,
            selected: settings.language,
            label: (v) => v.label,
            color: NeoPalette.cyan,
            onChanged: notifier.setLanguage,
          ),
          const SizedBox(height: 18),
          Text(s.tapArea, style: AppTypography.grotesk(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          _choiceWrap<TapArea>(
            values: TapArea.values,
            selected: settings.tapArea,
            label: (v) => v.label,
            color: NeoPalette.orange,
            onChanged: notifier.setTapArea,
          ),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: s.reduceMotion,
            subtitle: s.reduceMotionHint,
            value: settings.reduceMotion,
            onChanged: notifier.setReduceMotion,
          ),
        ],
      ),
    );
  }

  Widget _countingCard(AppStrings s, AppSettings settings, SettingsController notifier) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(s.counting),
          const SizedBox(height: 14),
          NeoToggleTile(
            title: s.haptics,
            subtitle: s.hapticsHint,
            value: settings.haptics,
            onChanged: notifier.setHaptics,
          ),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: s.sound,
            subtitle: s.soundHint,
            value: settings.sound,
            onChanged: notifier.setSound,
            activeColor: NeoPalette.cyan,
          ),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: s.accidentalTapProtection,
            subtitle: s.accidentalTapProtectionHint,
            value: settings.accidentalTapProtection,
            onChanged: notifier.setAccidentalTapProtection,
            activeColor: NeoPalette.orange,
          ),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: s.volumeButtons,
            subtitle: s.volumeButtonsHint,
            value: settings.volumeButtonCounting,
            onChanged: notifier.setVolumeButtonCounting,
            activeColor: NeoPalette.pink,
          ),
        ],
      ),
    );
  }

  Widget _lockScreenCard(AppStrings s, AppSettings settings) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(s.notificationCounting),
          const SizedBox(height: 8),
          Text(
            Platform.isIOS
                ? 'Shows a live-count Lock Screen widget and Live Activity.'
                : 'Shows a persistent notification with +1 / −1 on the lock screen.',
            style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
          ),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: s.notificationCounting,
            subtitle: s.notificationCountingHint,
            value: settings.notificationCounting,
            onChanged: _toggleNotificationCounting,
          ),
          if (settings.notificationCounting) ...<Widget>[
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.counterShown),
              subtitle: Text(_notificationCounterId ?? '—',
                  style: AppTypography.mono(size: 12, color: NeoPalette.ink)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickNotificationCounter,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dataCard(AppStrings s, AppSettings settings) {
    final last = settings.lastBackupAt;
    final subtitle = last == null
        ? s.neverBackedUp
        : s.backupDaysAgo(settings.daysSinceBackup ?? 0);
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(s.data),
          const SizedBox(height: 14),
          NeoButton(
            label: s.backupTitle,
            icon: Icons.backup_outlined,
            variant: NeoButtonVariant.accent,
            expand: true,
            onPressed: () => context.push('/backup'),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft)),
        ],
      ),
    );
  }

  Widget _debugCard(BuildContext context, AppStrings s) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle('Debug'),
          const SizedBox(height: 14),
          Text(
            'Run with --profile to use DevTools for profiling.',
            style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
          ),
        ],
      ),
    );
  }
}
