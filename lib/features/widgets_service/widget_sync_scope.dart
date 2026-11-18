import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/providers.dart';
import '../../router/app_router.dart';
import '../../tally_styles/line_style.dart';
import 'live_activity.dart';
import 'widget_keys.dart';

/// Wraps the app: keeps widgets / lock-screen previews / Live Activity in sync
/// with the database, and routes widget-config launches to the picker.
class WidgetSyncScope extends ConsumerStatefulWidget {
  const WidgetSyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WidgetSyncScope> createState() => _WidgetSyncScopeState();
}

class _WidgetSyncScopeState extends ConsumerState<WidgetSyncScope>
    with WidgetsBindingObserver {
  Timer? _debounce;
  StreamSubscription<dynamic>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Widget / notification interaction happened while the app is alive.
    _sub = HomeWidget.widgetClicked.listen((uri) {
      _refreshFromDisk();
      _scheduleSync();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialSync());
  }

  /// Widget / notification taps may have written to the database from a
  /// background isolate; re-read so the open UI reflects them instantly.
  void _refreshFromDisk() {
    ref.invalidate(countersStreamProvider);
    ref.invalidate(allTapsProvider);
    ref.invalidate(allSessionsProvider);
    ref.invalidate(counterProvider);
    ref.invalidate(tapsProvider);
    ref.invalidate(sessionsProvider);
  }

  Future<void> _initialSync() async {
    // Widget-config flow (launcher asks us to configure a new widget).
    final configureId =
        await HomeWidget.initiallyLaunchedFromHomeWidgetConfigure();
    if (configureId != null && mounted) {
      _openConfig(int.tryParse(configureId) ?? 0);
    }
    await ref.read(widgetSyncProvider).syncAll();
  }

  void _openConfig(int appWidgetId) {
    if (appWidgetId <= 0) return;
    // This widget lives above the MaterialApp, so route through the router
    // rather than looking up a Navigator from `context`.
    appRouter.push('/widget-config?id=$appWidgetId');
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final sync = ref.read(widgetSyncProvider);
      await sync.syncAll();
      await _syncLiveActivity();
    });
  }

  Future<void> _syncLiveActivity() async {
    final db = ref.read(databaseProvider);
    final enabled = await db.getSetting(WidgetKeys.notificationEnabled);
    final selected = await db.getSetting(WidgetKeys.notificationCounter);
    if (enabled == 'true' && selected != null) {
      final c = await db.getCounter(selected);
      if (c != null) {
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Widget / notification taps may have written to the database from a
      // background isolate; re-read so the open UI reflects them instantly.
      ref.invalidate(countersStreamProvider);
      ref.invalidate(allTapsProvider);
      ref.invalidate(allSessionsProvider);
      _scheduleSync();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the counters stream so every DB change schedules a sync.
    ref.listen(countersStreamProvider, (prev, next) {
      _scheduleSync();
    });
    return widget.child;
  }
}
