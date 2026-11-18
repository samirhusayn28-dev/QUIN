import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_counter/data/database/app_database.dart';
import 'package:tally_counter/data/settings/app_settings.dart';
import 'package:tally_counter/features/backup/backup_codec.dart';
import 'package:tally_counter/features/backup/backup_models.dart';
import 'package:tally_counter/features/backup/backup_service.dart';
import 'package:tally_counter/features/backup/csv_export.dart';

void main() {
  group('BackupCodec', () {
    final bundle = BackupBundle(
      exportedAt: DateTime(2024, 5, 1),
      appVersion: '1.0.0',
      dbSchemaVersion: 3,
      counters: <BackupCounter>[
        const BackupCounter(id: 'c1', name: 'Drinks', currentValue: 7),
      ],
      taps: <BackupTap>[
        BackupTap(
          id: 't1',
          counterId: 'c1',
          delta: 1,
          valueAfter: 7,
          at: DateTime(2024, 4, 30, 12),
        ),
      ],
      sessions: <BackupSession>[
        BackupSession(id: 's1', counterId: 'c1', startedAt: DateTime(2024, 4, 30)),
      ],
      settings: <String, String>{SettingsKeys.sound: 'true'},
    );

    test('json round trip preserves the payload', () {
      final bytes = BackupCodec.encodeJson(bundle);
      final decoded = BackupCodec.decodeJson(bytes);

      expect(decoded.counters.single.name, 'Drinks');
      expect(decoded.taps.single.valueAfter, 7);
      expect(decoded.sessions.single.id, 's1');
      expect(decoded.settings[SettingsKeys.sound], 'true');
      expect(decoded.exportedAt, DateTime(2024, 5, 1));
    });

    test('decodeJson rejects a non-object root', () {
      final bytes = Uint8List.fromList(<int>[0x5B, 0x5D]); // "[]"
      expect(() => BackupCodec.decodeJson(bytes), throwsA(isA<BackupCodecException>()));
    });

    test('zip round trip', () {
      final json = BackupCodec.encodeJson(bundle);
      final zipped = BackupCodec.zip(json);
      expect(BackupCodec.isZip(zipped), isTrue);

      final restored = BackupCodec.unzip(zipped);
      expect(BackupCodec.decodeJson(restored).counters.single.name, 'Drinks');
    });

    test('unzip rejects non-zip bytes', () {
      expect(
        () => BackupCodec.unzip(Uint8List.fromList(<int>[1, 2, 3, 4])),
        throwsA(isA<BackupCodecException>()),
      );
    });

    test('encrypt/decrypt round trip with authentication', () {
      final plain = BackupCodec.encodeJson(bundle);
      final container = BackupCodec.encrypt(plain, 'hunter2');
      expect(BackupCodec.isEncrypted(container), isTrue);
      expect(BackupCodec.isZip(container), isFalse);

      final restored = BackupCodec.decrypt(container, 'hunter2');
      expect(BackupCodec.decodeJson(restored).counters.single.name, 'Drinks');
    });

    test('wrong password fails the MAC check', () {
      final container = BackupCodec.encrypt(BackupCodec.encodeJson(bundle), 'right');
      try {
        BackupCodec.decrypt(container, 'wrong');
        fail('expected a BackupCodecException');
      } on BackupCodecException catch (e) {
        expect(e.wrongPassword, isTrue);
      }
    });

    test('decrypt rejects plain bytes and truncated containers', () {
      expect(
        () => BackupCodec.decrypt(Uint8List.fromList(<int>[1, 2, 3]), 'x'),
        throwsA(isA<BackupCodecException>()),
      );
    });

    test('rejects a backup from a newer format version', () {
      final json = bundle.toJson()..['formatVersion'] = kBackupFormatVersion + 1;
      expect(
        () => BackupBundle.fromJson(json.cast<String, dynamic>()),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('BackupService', () {
    late AppDatabase db;
    late BackupService service;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      service = BackupService(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<Counter> seed() async {
      final counter = await db.createCounter(name: 'Drinks', targetValue: 10);
      await db.tapCounter(counter.id);
      await db.tapCounter(counter.id);
      await db.setSetting(SettingsKeys.sound, 'true');
      return counter;
    }

    test('createBundle captures rows and whitelisted settings', () async {
      await seed();
      final bundle = await service.createBundle();

      expect(bundle.counters.single.name, 'Drinks');
      expect(bundle.taps.length, 2);
      expect(bundle.dbSchemaVersion, 5);
      expect(bundle.settings[SettingsKeys.sound], 'true');
    });

    test('createBundle can omit settings', () async {
      await seed();
      final bundle = await service.createBundle(includeSettings: false);
      expect(bundle.settings, isEmpty);
    });

    test('preview counts new rows and skips duplicates', () async {
      await seed();
      final bundle = await service.createBundle();

      final preview = await service.preview(bundle);
      expect(preview.counterCount, 1);
      expect(preview.newCounterCount, 0);
      expect(preview.tapCount, 2);
      expect(preview.newTapCount, 0);
      expect(preview.skippedTapCount, 2);
      expect(preview.hasData, isTrue);
      expect(preview.firstTap, isNotNull);
    });

    test('merge import skips existing rows', () async {
      await seed();
      final bundle = await service.createBundle();

      final result = await service.apply(bundle, mode: BackupImportMode.merge);

      expect(result.countersAdded, 0);
      expect(result.tapsAdded, 0);
      expect(result.replaced, isFalse);
      expect((await db.getAllTaps()).length, 2);
    });

    test('replace import wipes then restores and applies settings', () async {
      await seed();
      final bundle = await service.createBundle();

      await db.createCounter(name: 'Extra');
      expect((await db.getAllCounters()).length, 2);

      final result = await service.apply(bundle, mode: BackupImportMode.replace);

      expect(result.replaced, isTrue);
      expect(result.countersAdded, 1);
      expect(result.tapsAdded, 2);
      expect(result.settingsApplied, greaterThanOrEqualTo(1));
      expect((await db.getAllCounters()).single.name, 'Drinks');
      expect((await db.getAllTaps()).length, 2);
    });

    test('merge import drops taps whose counter is absent', () async {
      final orphan = BackupBundle(
        exportedAt: DateTime(2024, 1, 1),
        taps: <BackupTap>[
          BackupTap(
            id: 't-orphan',
            counterId: 'missing',
            delta: 1,
            valueAfter: 1,
            at: DateTime(2024, 1, 1),
          ),
        ],
      );

      final result = await service.apply(orphan, mode: BackupImportMode.merge);

      expect(result.tapsAdded, 0);
      expect(result.tapsSkipped, 1);
      expect(await db.getAllTaps(), isEmpty);
    });

    test('import ignores unknown setting keys', () async {
      final bundle = BackupBundle(
        exportedAt: DateTime(2024, 1, 1),
        counters: <BackupCounter>[const BackupCounter(id: 'c1', name: 'A')],
        settings: <String, String>{
          'not_a_real_setting': '1',
          SettingsKeys.sound: 'false',
        },
      );

      final result = await service.apply(bundle, mode: BackupImportMode.merge);

      expect(result.settingsApplied, 1);
      expect(await db.getSetting('not_a_real_setting'), isNull);
      expect(await db.getSetting(SettingsKeys.sound), 'false');
    });
  });

  group('CsvExport', () {
    test('quotes cells containing commas and quotes', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final counter = await db.createCounter(name: 'A, "quoted"');
      await db.tapCounter(counter.id);
      final counters = await db.getAllCounters();
      final taps = await db.getAllTaps();

      final csv = CsvExport.tapsCsv(counters, taps);

      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv, contains('"A, ""quoted"""'));
      await db.close();
    });

    test('session csv renders an empty end value when open', () {
      final csv = CsvExport.sessionsCsv(const <Counter>[], const <Session>[]);
      expect(csv.split('\n').first, contains('session_id'));
    });
  });
}
