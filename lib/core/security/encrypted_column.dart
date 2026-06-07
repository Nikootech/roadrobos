import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

// ─── Hardware-backed key storage ─────────────────────────────────────────────

class ColumnEncryptionKey {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _keyName = 'roadrobos_column_aes_key_v1';
  static Uint8List? _cached;

  static Future<Uint8List> getKey() async {
    if (_cached != null) return _cached!;
    final stored = await _storage.read(key: _keyName);
    if (stored == null) {
      final rng = Random.secure();
      final key =
          Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
      await _storage.write(key: _keyName, value: base64.encode(key));
      _cached = key;
    } else {
      _cached = base64.decode(stored);
    }
    return _cached!;
  }

  /// Call once at app start to warm the cache asynchronously.
  static Future<void> prefetch() => getKey();
}

// ─── AES-256-GCM TypeConverter for Drift ─────────────────────────────────────

/// Transparently encrypts/decrypts a String column using AES-256-GCM.
/// Nonce (12 bytes) is prepended to ciphertext + 16-byte GCM tag.
/// Empty string is stored as empty string (no encryption overhead).
class EncryptedStringConverter extends TypeConverter<String, String>
    with JsonTypeConverter2<String, String, String> {
  // Key is fetched lazily; first access initialises it.
  // This converter is const-constructible for Drift table definitions.
  const EncryptedStringConverter();

  @override
  String fromSql(String fromDb) {
    if (fromDb.isEmpty) return '';
    try {
      final bytes = base64.decode(fromDb);
      if (bytes.length < 12 + 16) return ''; // corrupt / too short
      final nonce = bytes.sublist(0, 12);
      final cipherAndTag = bytes.sublist(12);
      final key = ColumnEncryptionKey._cached;
      if (key == null) return ''; // key not yet loaded — caller must prefetch
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)),
        );
      final plain = cipher.process(Uint8List.fromList(cipherAndTag));
      return utf8.decode(plain);
    } catch (_) {
      return '';
    }
  }

  @override
  String toSql(String value) {
    if (value.isEmpty) return '';
    final key = ColumnEncryptionKey._cached;
    if (key == null) {
      throw StateError(
        'EncryptedStringConverter: key not loaded. '
        'Call ColumnEncryptionKey.prefetch() before DB writes.',
      );
    }
    final nonce = Uint8List(12)
      ..setAll(
        0,
        List.generate(12, (_) => Random.secure().nextInt(256)),
      );
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)),
      );
    final cipherBytes =
        cipher.process(Uint8List.fromList(utf8.encode(value)));
    final result = Uint8List(12 + cipherBytes.length)
      ..setAll(0, nonce)
      ..setAll(12, cipherBytes);
    return base64.encode(result);
  }

  @override
  String fromJson(String json) => fromSql(json);

  @override
  String toJson(String value) => toSql(value);
}

/// Nullable variant — stores null as empty string.
class NullableEncryptedStringConverter
    extends TypeConverter<String?, String> {
  const NullableEncryptedStringConverter();

  static const _inner = EncryptedStringConverter();

  @override
  String? fromSql(String fromDb) {
    if (fromDb.isEmpty) return null;
    return _inner.fromSql(fromDb);
  }

  @override
  String toSql(String? value) {
    if (value == null) return '';
    return _inner.toSql(value);
  }
}
