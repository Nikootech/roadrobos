import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// End-to-end encryption service using X25519 Diffie-Hellman key exchange
/// + AES-256-GCM for message encryption.
///
/// Usage flow:
///   1. Each user generates a key pair on first chat.
///   2. Public key is stored in Supabase `profiles.public_key`.
///   3. On chat start, both parties derive a shared key via X25519.
///   4. All messages are encrypted before insert / decrypted after fetch.
class EncryptionService {
  EncryptionService._();
  static final instance = EncryptionService._();

  static final _x25519 = X25519();
  static final _aesGcm = AesGcm.with256bits();

  // ─── Key pair generation ──────────────────────────────────────────────────

  /// Generate a new X25519 key pair. Store private key in SecureStorage,
  /// public key in Supabase profiles.
  Future<SimpleKeyPair> generateKeyPair() => _x25519.newKeyPair();

  /// Serialize a key pair's public key to base64 for Supabase storage.
  Future<String> publicKeyToBase64(SimpleKeyPair keyPair) async {
    final pub = await keyPair.extractPublicKey();
    return base64.encode(pub.bytes);
  }

  /// Serialize the private key bytes to base64 for SecureStorage.
  Future<String> privateKeyToBase64(SimpleKeyPair keyPair) async {
    final priv = await keyPair.extractPrivateKeyBytes();
    return base64.encode(priv);
  }

  /// Reconstruct a key pair from stored base64 private key bytes.
  Future<SimpleKeyPair> keyPairFromPrivateBase64(String b64) async {
    final bytes = base64.decode(b64);
    return _x25519.newKeyPairFromSeed(bytes);
  }

  // ─── Key exchange ─────────────────────────────────────────────────────────

  Future<SimplePublicKey> publicKeyFromBase64(String b64) async {
    return SimplePublicKey(base64.decode(b64), type: KeyPairType.x25519);
  }

  /// Derive a shared AES-256 key from our private key + their public key.
  Future<SecretKey> deriveSharedKey({
    required SimpleKeyPair ourKeyPair,
    required SimplePublicKey theirPublicKey,
  }) {
    return _x25519.sharedSecretKey(
      keyPair: ourKeyPair,
      remotePublicKey: theirPublicKey,
    );
  }

  // ─── Encrypt / Decrypt ───────────────────────────────────────────────────

  /// Encrypt a plaintext UTF-8 string with AES-256-GCM.
  /// Returns base64(nonce[12] + ciphertext + tag[16]).
  Future<String> encryptMessage(String plaintext, SecretKey key) async {
    final box = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    final combined = <int>[
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ];
    return base64.encode(Uint8List.fromList(combined));
  }

  /// Decrypt a base64-encoded AES-256-GCM message.
  Future<String> decryptMessage(String encryptedBase64, SecretKey key) async {
    final bytes = base64.decode(encryptedBase64);
    if (bytes.length < 12 + 16) throw const FormatException('Invalid ciphertext');
    final nonce = bytes.sublist(0, 12);
    final cipherText = bytes.sublist(12, bytes.length - 16);
    final mac = Mac(bytes.sublist(bytes.length - 16));

    final box = SecretBox(cipherText, nonce: nonce, mac: mac);
    final plain = await _aesGcm.decrypt(box, secretKey: key);
    return utf8.decode(plain);
  }
}
