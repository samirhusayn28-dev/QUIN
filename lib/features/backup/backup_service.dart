import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import '../../data/settings/app_settings.dart';
import 'backup_models.dart';

/// Reads the database into a [BackupBundle] and writes one back.
///
/// The service is deliberately free of Flutter/UI types so it can be unit
/// tested against an in-memory database.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const String appVersion = '1.0.0';

  // --- export -------------------------------------------------------------

  Future<BackupBundle> createBundle({bool includeSettings = true}) async {
    final counters = await _db.getAllCounters(includeArchived: true);
    final taps = await _db.getAllTaps();
    final sessions = await _db.getAllSessions();
    return BackupBundle(
      exportedAt: DateTime.now(),
      appVersion: appVersion,
      dbSchemaVersion: _db.schemaVersion,
      counters: counters.map(BackupCounter.fromRow).toList(),
      taps: taps.map(BackupTap.fromRow).toList(),
      sessions: sessions.map(BackupSession.fromRow).toList(),
      settings: includeSettings ? await exportSettings() : const <String, String>{},
    );
  }

  /// App settings only — never the per-device widget bindings.
  Future<Map<String, String>> exportSettings() async {
    final all = await _db.getSettings();
    return <String, String>{
      for (final key in SettingsKeys.all)
        if (all[key] != null) key: all[key]!,
    };
  }

  // --- import -------------------------------------------------------------

  Future<BackupPreview> preview(BackupBundle bundle,
      {bool encrypted = false, bool compressed = false}) async {
    final existingCounterIds =
        (await _db.getAllCounters(includeArchived: true)).map((c) => c.id).toSet();
    final existingTaps = await _db.getAllTaps();
    final existingTapIds = existingTaps.map((t) => t.id).toSet();
    final existingSignatures = existingTaps.map(_tapSignature).toSet();

    var newCounters = 0;
    for (final c in bundle.counters) {
      if (!existingCounterIds.contains(c.id)) newCounters++;
    }

    var newTaps = 0;
    var skipped = 0;
    for (final t in bundle.taps) {
      if (existingTapIds.contains(t.id) || existingSignatures.contains(_tapSignatureRows(t))) {
        skipped++;
      } else {
        newTaps++;
      }
    }

    final dates = bundle.taps.map((t) => t.at).toList()..sort();
    return BackupPreview(
      bundle: bundle,
      counterCount: bundle.counters.length,
      tapCount: bundle.taps.length,
      newCounterCount: newCounters,
      newTapCount: newTaps,
      skippedTapCount: skipped,
      firstTap: dates.isEmpty ? null : dates.first,
      lastTap: dates.isEmpty ? null : dates.last,
      encrypted: encrypted,
      compressed: compressed,
    );
  }

  Future<BackupImportResult> apply(
    BackupBundle bundle, {
    required BackupImportMode mode,
    bool applySettings = true,
    void Function(double progress, String stage)? onProgress,
  }) async {
    final replaced = mode == BackupImportMode.replace;
    onProgress?.call(0.05, replaced ? 'Clearing existing data' : 'Preparing');
    if (replaced) {
      await _db.deleteAllData();
    }

    // Work out what is genuinely new (merge skips anything already present).
    final existingCounterIds = replaced
        ? <String>{}
        : (await _db.getAllCounters(includeArchived: true)).map((c) => c.id).toSet();
    final existingTaps = replaced ? <Tap>[] : await _db.getAllTaps();
    final existingTapIds = existingTaps.map((t) => t.id).toSet();
    final existingSignatures = existingTaps.map(_tapSignature).toSet();
    final existingSessionIds =
        replaced ? <String>{} : (await _db.getAllSessions()).map((s) => s.id).toSet();

    final countersToInsert = <CountersCompanion>[];
    var countersSkipped = 0;
    final knownCounterIds = <String>{...existingCounterIds};
    for (final c in bundle.counters) {
      if (knownCounterIds.contains(c.id)) {
        countersSkipped++;
      } else {
        countersToInsert.add(c.toCompanion());
        knownCounterIds.add(c.id);
      }
    }

    onProgress?.call(0.25, 'Importing counters');

    final tapsToInsert = <TapsCompanion>[];
    var tapsSkipped = 0;
    final seenSignatures = <String>{...existingSignatures};
    for (final t in bundle.taps) {
      // Drop taps whose counter is missing (foreign-key safety).
      if (!knownCounterIds.contains(t.counterId)) {
        tapsSkipped++;
        continue;
      }
      final sig = _tapSignatureRows(t);
      if (existingTapIds.contains(t.id) || seenSignatures.contains(sig)) {
        tapsSkipped++;
        continue;
      }
      tapsToInsert.add(t.toCompanion());
      seenSignatures.add(sig);
    }

    onProgress?.call(0.5, 'Importing taps');

    final sessionsToInsert = <SessionsCompanion>[];
    var sessionsSkipped = 0;
    for (final s in bundle.sessions) {
      if (!knownCounterIds.contains(s.counterId) || existingSessionIds.contains(s.id)) {
        sessionsSkipped++;
        continue;
      }
      sessionsToInsert.add(s.toCompanion());
    }

    onProgress?.call(0.7, 'Writing');

    await _db.transaction(() async {
      await _db.batch((b) {
        b.insertAll(_db.counters, countersToInsert,
            onConflict: DoNothing());
        b.insertAll(_db.taps, tapsToInsert, onConflict: DoNothing());
        b.insertAll(_db.sessions, sessionsToInsert, onConflict: DoNothing());
      });
    });

    var settingsApplied = 0;
    if (applySettings && bundle.settings.isNotEmpty) {
      onProgress?.call(0.85, 'Applying settings');
      final settings = <String, String>{
        for (final e in bundle.settings.entries)
          if (SettingsKeys.all.contains(e.key)) e.key: e.value,
      };
      settingsApplied = settings.length;
      await _db.setSettings(settings);
    }

    onProgress?.call(1.0, 'Done');
    return BackupImportResult(
      countersAdded: countersToInsert.length,
      tapsAdded: tapsToInsert.length,
      sessionsAdded: sessionsToInsert.length,
      countersSkipped: countersSkipped,
      tapsSkipped: tapsSkipped,
      sessionsSkipped: sessionsSkipped,
      settingsApplied: settingsApplied,
      replaced: replaced,
    );
  }

  static String _tapSignature(Tap t) =>
      '${t.counterId}|${t.at.toIso8601String()}|${t.delta}|${t.valueAfter}';

  static String _tapSignatureRows(BackupTap t) =>
      '${t.counterId}|${t.at.toIso8601String()}|${t.delta}|${t.valueAfter}';
}
