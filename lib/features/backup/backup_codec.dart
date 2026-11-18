import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart' as c;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart' as pc;

import 'backup_models.dart';

/// Raised when a container cannot be decoded.
class BackupCodecException implements Exception {
  BackupCodecException(this.message, {this.wrongPassword = false});

  final String message;
  final bool wrongPassword;

  @override
  String toString() => 'BackupCodecException: $message';
}

/// Encodes/decodes backup bytes: JSON, optional zip, optional AES encryption.
///
/// Encrypted container layout (all big-endian, no padding between fields):
///
/// ```
///   magic     8   "TALLYENC"
///   version   1
///   salt     16   PBKDF2 salt
///   iv       16   AES-CBC IV
///   mac      32   HMAC-SHA256(version|salt|iv|ciphertext)
///   data      n   AES-256-CBC ciphertext
/// ```
///
/// The key material is 64 bytes of PBKDF2-HMAC-SHA256 split into an encryption
/// key and a MAC key, giving encrypt-then-MAC authentication.
abstract final class BackupCodec {
  static const String jsonEntryName = 'tally-backup.json';
  static const List<int> _magic = <int>[0x54, 0x41, 0x4C, 0x4C, 0x59, 0x45, 0x4E, 0x43]; // TALLYENC
  static const int _containerVersion = 1;
  static const int _iterations = 120000;

  static Uint8List encodeJson(BackupBundle bundle) =>
      Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(bundle.toJson())));

  static BackupBundle decodeJson(Uint8List bytes) {
    final dynamic decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) {
      throw BackupCodecException('backup root is not an object');
    }
    return BackupBundle.fromJson(decoded.cast<String, dynamic>());
  }

  // --- zip ----------------------------------------------------------------

  static Uint8List zip(Uint8List jsonBytes) {
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(jsonEntryName, jsonBytes));
    return ZipEncoder().encodeBytes(archive, level: DeflateLevel.bestCompression);
  }

  static Uint8List unzip(Uint8List zipBytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } on Object catch (e) {
      throw BackupCodecException('not a readable zip: $e');
    }
    ArchiveFile? match = archive.find(jsonEntryName);
    match ??= archive.files.where((f) => f.name.toLowerCase().endsWith('.json')).firstOrNull;
    if (match == null) {
      throw BackupCodecException('zip has no backup json');
    }
    return match.content;
  }

  // --- encryption ---------------------------------------------------------

  static Uint8List encrypt(Uint8List plain, String password) {
    final salt = _randomBytes(16);
    final iv = _randomBytes(16);
    final keys = _derive(password, salt);
    final encKey = enc.Key(Uint8List.sublistView(keys, 0, 32));
    final macKey = keys.sublist(32);

    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
    final cipher = Uint8List.fromList(
      encrypter.encryptBytes(plain, iv: enc.IV(iv)).bytes,
    );

    final builder = BytesBuilder(copy: false)
      ..add(_magic)
      ..addByte(_containerVersion)
      ..add(salt)
      ..add(iv);
    final mac = c.Hmac(c.sha256, macKey).convert(<int>[
      _containerVersion,
      ...salt,
      ...iv,
      ...cipher,
    ]).bytes;
    builder
      ..add(mac)
      ..add(cipher);
    return builder.toBytes();
  }

  static Uint8List decrypt(Uint8List container, String password) {
    if (!isEncrypted(container)) {
      throw BackupCodecException('not an encrypted backup');
    }
    if (container.length < 8 + 1 + 16 + 16 + 32) {
      throw BackupCodecException('encrypted backup is truncated');
    }
    final version = container[8];
    if (version != _containerVersion) {
      throw BackupCodecException('unsupported container version $version');
    }
    final salt = Uint8List.sublistView(container, 9, 25);
    final iv = Uint8List.sublistView(container, 25, 41);
    final mac = Uint8List.sublistView(container, 41, 73);
    final cipher = Uint8List.sublistView(container, 73);

    final keys = _derive(password, salt);
    final encKey = enc.Key(Uint8List.sublistView(keys, 0, 32));
    final macKey = keys.sublist(32);

    final expected = c.Hmac(c.sha256, macKey)
        .convert(<int>[version, ...salt, ...iv, ...cipher])
        .bytes;
    if (!_constantTimeEquals(expected, mac)) {
      throw BackupCodecException('password is incorrect', wrongPassword: true);
    }

    try {
      final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
      return Uint8List.fromList(
        encrypter.decryptBytes(enc.Encrypted(cipher), iv: enc.IV(iv)),
      );
    } on Object {
      throw BackupCodecException('password is incorrect', wrongPassword: true);
    }
  }

  // --- detection ----------------------------------------------------------

  static bool isEncrypted(Uint8List bytes) {
    if (bytes.length < _magic.length) return false;
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) return false;
    }
    return true;
  }

  static bool isZip(Uint8List bytes) =>
      bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B; // "PK"

  // --- internals ----------------------------------------------------------

  static Uint8List _derive(String password, Uint8List salt) {
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(salt, _iterations, 64));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  static Uint8List _randomBytes(int n) {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(n, (_) => rnd.nextInt(256)));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
