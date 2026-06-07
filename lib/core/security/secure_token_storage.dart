import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized secure token storage using Android Keystore /
/// iOS Keychain. Never uses SharedPreferences for tokens.
class SecureTokenStorage {
  SecureTokenStorage._();
  static final instance = SecureTokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Forces Android Keystore hardware-backed AES-256 on API 23+.
      // Automatically uses StrongBox on API 28+ if available.
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _kAccessToken = 'sb_access_token';
  static const _kRefreshToken = 'sb_refresh_token';
  static const _kUserId = 'sb_user_id';
  static const _kFcmToken = 'sb_fcm_token';

  // ─── Write ────────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kUserId, value: userId),
    ]);
  }

  Future<void> saveFcmToken(String token) =>
      _storage.write(key: _kFcmToken, value: token);

  // ─── Read ─────────────────────────────────────────────────────────────────

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<String?> getUserId() => _storage.read(key: _kUserId);
  Future<String?> getFcmToken() => _storage.read(key: _kFcmToken);

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kUserId),
      _storage.delete(key: _kFcmToken),
    ]);
  }

  // ─── Verification ─────────────────────────────────────────────────────────

  /// Returns true if the write was accepted (implies EncryptedSharedPrefs works).
  Future<bool> isAvailable() async {
    try {
      const testKey = '__roadrobos_hw_probe__';
      await _storage.write(key: testKey, value: '1');
      final val = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);
      return val == '1';
    } catch (_) {
      return false;
    }
  }
}
