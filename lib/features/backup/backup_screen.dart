import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../../data/providers.dart';
import '../../data/settings/app_settings.dart';
import '../../data/settings/settings_provider.dart';
import '../widgets/widgets.dart';
import 'backup_codec.dart';
import 'backup_models.dart';
import 'backup_service.dart';
import 'csv_export.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final TextEditingController _password = TextEditingController();
  bool _compress = true;
  bool _encrypt = false;
  bool _busy = false;
  String _status = '';

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  BackupService get _service => BackupService(ref.read(databaseProvider));

  AppStrings get _s => AppStrings.of(context);

  // ---------------------------------------------------------------- export

  String _stamp() => DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());

  Future<void> _export({required bool share}) async {
    final strings = _s;
    if (_encrypt && _password.text.isEmpty) {
      _toast(strings.passwordHint);
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Building backup...';
    });
    try {
      final bundle = await _service.createBundle(includeSettings: true);
      var bytes = BackupCodec.encodeJson(bundle);
      if (_compress) bytes = BackupCodec.zip(bytes);
      if (_encrypt) bytes = BackupCodec.encrypt(bytes, _password.text);
      final name = 'tally-backup-${_stamp()}.tally';

      if (share) {
        await _shareBytes(name, bytes, 'QUIN backup');
      } else {
        await FilePicker.saveFile(
          fileName: name,
          bytes: bytes,
          mimeType: 'application/octet-stream',
        );
      }
      await ref.read(settingsProvider.notifier).markBackedUp();
      _toast(strings.exportDone);
    } catch (e) {
      _toast('${strings.importFailed}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
      }
    }
  }

  Future<void> _exportCsv({required bool share}) async {
    setState(() {
      _busy = true;
      _status = 'Building CSV...';
    });
    try {
      final db = ref.read(databaseProvider);
      final counters = await db.getAllCounters(includeArchived: true);
      final taps = await db.getAllTaps();
      final sessions = await db.getAllSessions();
      final tapsCsv = Uint8List.fromList(
        CsvExport.tapsCsv(counters, taps).codeUnits.toList(),
      );
      final sessionsCsv = Uint8List.fromList(
        CsvExport.sessionsCsv(counters, sessions).codeUnits.toList(),
      );
      final stamp = _stamp();
      if (share) {
        await _shareBytes('quin-taps-$stamp.csv', tapsCsv, 'QUIN taps CSV',
            extra: <String, Uint8List>{'quin-sessions-$stamp.csv': sessionsCsv});
      } else {
        await FilePicker.saveFile(
          fileName: 'quin-taps-$stamp.csv',
          bytes: tapsCsv,
          mimeType: 'text/csv',
        );
      }
      _toast('CSV ready');
    } catch (e) {
      _toast('CSV export failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
      }
    }
  }

  Future<void> _shareBytes(
    String name,
    Uint8List bytes,
    String subject, {
    Map<String, Uint8List> extra = const <String, Uint8List>{},
  }) async {
    final dir = await getTemporaryDirectory();
    final files = <XFile>[];
    final main = File('${dir.path}/$name');
    await main.writeAsBytes(bytes);
    files.add(XFile(main.path, mimeType: 'application/octet-stream', name: name));
    for (final entry in extra.entries) {
      final f = File('${dir.path}/${entry.key}');
      await f.writeAsBytes(entry.value);
      files.add(XFile(f.path, mimeType: 'text/csv', name: entry.key));
    }
    await SharePlus.instance.share(
      ShareParams(files: files, subject: subject, title: subject),
    );
  }

  // ---------------------------------------------------------------- import

  Future<void> _import() async {
    final strings = _s;
    final PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(
        type: FileType.any,
        dialogTitle: strings.pickFile,
      );
    } catch (e) {
      _toast('${strings.importFailed}: $e');
      return;
    }
    if (picked == null) return;
    final path = picked.path;
    if (path == null) {
      _toast(strings.invalidFile);
      return;
    }

    final Uint8List raw;
    try {
      raw = await File(path).readAsBytes();
    } catch (e) {
      _toast('${strings.invalidFile}: $e');
      return;
    }

    var encrypted = false;
    var compressed = false;
    var payload = raw;

    try {
      if (BackupCodec.isEncrypted(raw)) {
        encrypted = true;
        final pw = await _promptPassword();
        if (pw == null) return;
        payload = BackupCodec.decrypt(raw, pw);
      }
      if (BackupCodec.isZip(payload)) {
        compressed = true;
        payload = BackupCodec.unzip(payload);
      }
    } on BackupCodecException catch (e) {
      _toast(e.wrongPassword ? strings.wrongPassword : strings.invalidFile);
      return;
    }

    final BackupBundle bundle;
    try {
      bundle = BackupCodec.decodeJson(payload);
    } on BackupFormatException catch (e) {
      _toast(e.tooNewVersion ? strings.fileTooNew : strings.invalidFile);
      return;
    } catch (_) {
      _toast(strings.invalidFile);
      return;
    }

    if (bundle.isEmpty) {
      _toast(strings.nothingToImport);
      return;
    }

    final preview = await _service.preview(
      bundle,
      encrypted: encrypted,
      compressed: compressed,
    );
    if (!mounted) return;

    final mode = await _showPreview(preview);
    if (mode == null) return;

    await _applyImport(bundle, mode);
  }

  Future<void> _applyImport(BackupBundle bundle, BackupImportMode mode) async {
    final strings = _s;
    final progress = ValueNotifier<double>(0);
    final stage = ValueNotifier<String>('Starting');
    if (!mounted) return;
    showNeoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NeoDialog(
        title: mode == BackupImportMode.replace
            ? strings.replaceAll
            : strings.merge,
        icon: Icons.hourglass_top_rounded,
        accent: NeoPalette.cyan,
        child: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ValueListenableBuilder<String>(
                valueListenable: stage,
                builder: (context, s, _) => Text(s, style: AppTypography.mono(size: 12, color: NeoPalette.ink)),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 14,
                  backgroundColor: NeoPalette.paperAlt,
                  color: NeoPalette.cyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await _service.apply(
        bundle,
        mode: mode,
        applySettings: true,
        onProgress: (p, s) {
          progress.value = p;
          stage.value = s;
        },
      );
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      // Refresh everything that reads the database.
      _invalidateAll();
      await ref.read(settingsProvider.notifier).reload();
      if (!mounted) return;
      await _showResult(result);
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _toast('${strings.importFailed}: $e');
    }
  }

  void _invalidateAll() {
    ref.invalidate(countersStreamProvider);
    ref.invalidate(allTapsProvider);
    ref.invalidate(allSessionsProvider);
    ref.invalidate(counterProvider);
    ref.invalidate(tapsProvider);
    ref.invalidate(sessionsProvider);
  }

  // ---------------------------------------------------------------- dialogs

  Future<String?> _promptPassword() async {
    final controller = TextEditingController();
    final result = await showNeoDialog<String>(
      context: context,
      builder: (context) => NeoDialog(
        title: _s.password,
        icon: Icons.lock_outline_rounded,
        accent: NeoPalette.yellow,
        message: _s.passwordHint,
        actions: <Widget>[
          NeoButton(
            label: _s.cancel,
            variant: NeoButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          NeoButton(
            label: _s.ok,
            variant: NeoButtonVariant.accent,
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
        child: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<BackupImportMode?> _showPreview(BackupPreview preview) {
    final strings = _s;
    String range = '—';
    if (preview.firstTap != null && preview.lastTap != null) {
      final f = DateFormat.yMMMd().format(preview.firstTap!);
      final l = DateFormat.yMMMd().format(preview.lastTap!);
      range = f == l ? f : '$f → $l';
    }
    return showNeoDialog<BackupImportMode>(
      context: context,
      builder: (context) => NeoDialog(
        title: strings.preview,
        icon: Icons.inventory_2_outlined,
        accent: NeoPalette.lime,
        actions: <Widget>[
          NeoButton(
            label: strings.cancel,
            variant: NeoButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          NeoButton(
            label: strings.merge,
            variant: NeoButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(BackupImportMode.merge),
          ),
          NeoButton(
            label: strings.replaceAll,
            variant: NeoButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(BackupImportMode.replace),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (preview.encrypted || preview.compressed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 6,
                  children: <Widget>[
                    if (preview.encrypted) const NeoChip(label: 'AES', selected: true, color: NeoPalette.yellow),
                    if (preview.compressed) const NeoChip(label: 'ZIP', selected: true, color: NeoPalette.cyan),
                  ],
                ),
              ),
            _statRow(strings.counters, '${preview.counterCount}  (+${preview.newCounterCount})'),
            _statRow(strings.totalTaps, '${preview.tapCount}  (+${preview.newTapCount})'),
            _statRow(strings.dateRange, range),
            if (preview.skippedTapCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${preview.skippedTapCount} duplicates skipped',
                  style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft),
                ),
              ),
            const SizedBox(height: 16),
            Text('${strings.replaceAll} — ${strings.replaceAllHint}',
                style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft)),
            const SizedBox(height: 4),
            Text('${strings.merge} — ${strings.mergeHint}',
                style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft)),
          ],
        ),
      ),
    );
  }

  Future<void> _showResult(BackupImportResult result) {
    final strings = _s;
    return showNeoDialog<void>(
      context: context,
      builder: (context) => NeoDialog(
        title: strings.importDone,
        icon: Icons.check_circle_outline_rounded,
        accent: NeoPalette.lime,
        actions: <Widget>[
          NeoButton(
            label: strings.ok,
            variant: NeoButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _statRow(strings.counters, '+${result.countersAdded}'),
            _statRow(strings.totalTaps, '+${result.tapsAdded}'),
            if (result.sessionsAdded > 0) _statRow('Sessions', '+${result.sessionsAdded}'),
            if (result.tapsSkipped > 0) _statRow('Skipped', '${result.tapsSkipped}'),
            if (result.settingsApplied > 0) _statRow(strings.settings, '${result.settingsApplied}'),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: AppTypography.grotesk(size: 14, weight: FontWeight.w600)),
          Text(value, style: AppTypography.mono(size: 14, color: NeoPalette.ink, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final strings = _s;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.backupTitle,
            style: AppTypography.grotesk(size: 18, weight: FontWeight.w700)),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _exportCard(strings),
              const SizedBox(height: 16),
              _importCard(strings),
              const SizedBox(height: 16),
              _csvCard(strings),
              const SizedBox(height: 16),
              _reminderCard(strings, settings),
              const SizedBox(height: 24),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: NeoPalette.ink.withValues(alpha: 0.35),
                child: Center(
                  child: NeoCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const CircularProgressIndicator(color: NeoPalette.ink),
                        const SizedBox(height: 12),
                        Text(_status, style: AppTypography.grotesk(weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cardHeader(String title, String subtitle, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(title, style: AppTypography.grotesk(size: 16, weight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTypography.grotesk(size: 12, color: NeoPalette.inkSoft)),
      ],
    );
  }

  Widget _exportCard(AppStrings strings) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardHeader(strings.exportData, strings.exportHint, icon: Icons.ios_share_rounded),
          const SizedBox(height: 12),
          NeoToggleTile(
            title: strings.compress,
            subtitle: 'application/zip',
            value: _compress,
            onChanged: (v) => setState(() => _compress = v),
            activeColor: NeoPalette.cyan,
          ),
          NeoToggleTile(
            title: strings.encrypt,
            subtitle: strings.passwordHint,
            value: _encrypt,
            onChanged: (v) => setState(() => _encrypt = v),
            activeColor: NeoPalette.yellow,
          ),
          if (_encrypt) ...<Widget>[
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: strings.password,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: NeoButton(
                  label: strings.share,
                  icon: Icons.ios_share,
                  variant: NeoButtonVariant.accent,
                  expand: true,
                  onPressed: _busy ? null : () => _export(share: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoButton(
                  label: strings.saveToFiles,
                  icon: Icons.save_alt,
                  variant: NeoButtonVariant.secondary,
                  expand: true,
                  onPressed: _busy ? null : () => _export(share: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _importCard(AppStrings strings) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardHeader(strings.importData, strings.importHint, icon: Icons.download_rounded),
          const SizedBox(height: 14),
          NeoButton(
            label: strings.pickFile,
            icon: Icons.file_open,
            variant: NeoButtonVariant.primary,
            expand: true,
            onPressed: _busy ? null : _import,
          ),
        ],
      ),
    );
  }

  Widget _csvCard(AppStrings strings) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardHeader(strings.csvExport, strings.csvHint, icon: Icons.table_chart_outlined),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: NeoButton(
                  label: strings.share,
                  icon: Icons.ios_share,
                  variant: NeoButtonVariant.secondary,
                  expand: true,
                  onPressed: _busy ? null : () => _exportCsv(share: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoButton(
                  label: strings.saveToFiles,
                  icon: Icons.save_alt,
                  variant: NeoButtonVariant.ghost,
                  expand: true,
                  onPressed: _busy ? null : () => _exportCsv(share: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reminderCard(AppStrings strings, AppSettings settings) {
    const options = <int>[0, 1, 3, 7, 14, 30];
    final last = settings.lastBackupAt;
    final subtitle = last == null
        ? strings.neverBackedUp
        : strings.backupDaysAgo(settings.daysSinceBackup ?? 0);
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardHeader(strings.autoBackup, strings.backupReminderHint, icon: Icons.notifications_active_outlined),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((days) {
              final selected = settings.backupReminderDays == days;
              return NeoChip(
                label: days == 0 ? strings.off : '$days ${strings.days}',
                selected: selected,
                color: NeoPalette.yellow,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setBackupReminderDays(days),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(subtitle, style: AppTypography.grotesk(size: 13, color: NeoPalette.inkSoft)),
        ],
      ),
    );
  }
}
