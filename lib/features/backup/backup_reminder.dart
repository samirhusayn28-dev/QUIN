import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/neo_palette.dart';
import '../../data/providers.dart';
import '../../data/settings/settings_provider.dart';
import '../../router/app_router.dart';
import '../widgets/widgets.dart';

/// Shows a one-time "time to back up" prompt after the app has real data.
///
/// Lives inside `MaterialApp.builder`, so it renders nothing itself — it just
/// schedules the dialog against the root navigator.
class BackupReminder extends ConsumerStatefulWidget {
  const BackupReminder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BackupReminder> createState() => _BackupReminderState();
}

class _BackupReminderState extends ConsumerState<BackupReminder> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    if (_handled) return;
    _handled = true;

    final settings = await ref.read(settingsProvider.future);
    if (!settings.backupReminderDue()) return;

    // Never nag someone who has not started using the app yet.
    final taps = await ref.read(databaseProvider).getAllTaps();
    if (taps.isEmpty) return;

    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final strings = AppStrings.of(context);
    final go = await showNeoDialog<bool>(
      context: context,
      builder: (c) => NeoDialog(
        title: strings.autoBackup,
        message: strings.backupReminderHint,
        icon: Icons.notifications_active_outlined,
        accent: NeoPalette.yellow,
        actions: <Widget>[
          NeoButton(
            label: strings.cancel,
            variant: NeoButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
          NeoButton(
            label: strings.exportData,
            icon: Icons.ios_share,
            variant: NeoButtonVariant.accent,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ],
      ),
    );
    if (go == true) {
      appRouter.push('/backup');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
