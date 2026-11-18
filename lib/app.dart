import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/app_strings.dart';
import 'core/lifecycle/lifecycle_gate.dart';
import 'core/theme/app_theme.dart';
import 'data/settings/settings_provider.dart';
import 'features/backup/backup_reminder.dart';
import 'features/widgets_service/widget_sync_scope.dart';
import 'router/app_router.dart';

class TallyApp extends ConsumerWidget {
  const TallyApp({super.key, this.initialLocation = '/'});

  final String initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final code = settings.language.localeCode;

    return WidgetSyncScope(
      child: LifecycleGate(
        child: MaterialApp.router(
        title: 'QUIN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.forVariant(settings.theme),
        locale: code == null ? null : Locale(code),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: appRouter,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final Widget content = BackupReminder(
            child: child ?? const SizedBox.shrink(),
          );
          if (!settings.reduceMotion || media.disableAnimations) {
            return content;
          }
            return MediaQuery(
              data: media.copyWith(disableAnimations: true),
              child: content,
            );
          },
        ),
      ),
    );
  }
}
