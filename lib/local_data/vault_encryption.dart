import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha256.dart';

/// Only place in the app that handles AES-256 encryption and PIN management.
/// Key and PIN hash both live exclusively in [FlutterSecureStorage] —
/// nothing sensitive ever touches SQFlite or disk in plaintext.
class VaultEncryption {
  VaultEncryption._();
  static final VaultEncryption instance = VaultEncryption._();

  static const _keyStorageKey = 'vault_aes_key_v1';
  static const _pinStorageKey = 'vault_pin_hash_v1';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  enc.Key? _cachedKey;

  // ── Key management ────────────────────────────────────────────────────────

  Future<enc.Key> _key() async {
    if (_cachedKey != null) return _cachedKey!;
    final stored = await _storage.read(key: _keyStorageKey);
    if (stored != null) {
      _cachedKey = enc.Key(base64Decode(stored));
      return _cachedKey!;
    }
    final fresh = enc.Key.fromSecureRandom(32);
    await _storage.write(key: _keyStorageKey, value: base64Encode(fresh.bytes));
    _cachedKey = fresh;
    return _cachedKey!;
  }

  Future<void> deleteKey() async {
    _cachedKey = null;
    await _storage.delete(key: _keyStorageKey);
  }

  // ── AES-256-CBC encrypt / decrypt ─────────────────────────────────────────

  /// Encrypts [plainBytes] and returns `IV (16 bytes) || ciphertext`.
  Future<Uint8List> encrypt(Uint8List plainBytes) async {
    final key = await _key();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    final out = Uint8List(16 + encrypted.bytes.length);
    out.setRange(0, 16, iv.bytes);
    out.setRange(16, out.length, encrypted.bytes);
    return out;
  }

  /// Decrypts data produced by [encrypt].  Expects `IV || ciphertext`.
  Future<Uint8List> decrypt(Uint8List combined) async {
    final key = await _key();
    final iv = enc.IV(combined.sublist(0, 16));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(combined.sublist(16)),
      iv: iv,
    );
    return Uint8List.fromList(decrypted);
  }

  /// Convenience: encrypt a UTF-8 string, return Base64-encoded ciphertext.
  Future<String> encryptString(String plain) async =>
      base64Encode(await encrypt(Uint8List.fromList(utf8.encode(plain))));

  /// Convenience: decrypt a Base64-encoded ciphertext back to a UTF-8 string.
  Future<String> decryptString(String encoded) async =>
      utf8.decode(await decrypt(base64Decode(encoded)));

  // ── PIN management ────────────────────────────────────────────────────────

  /// Returns true if a vault PIN has been set before.
  Future<bool> hasPinSet() async =>
      (await _storage.read(key: _pinStorageKey)) != null;

  /// Hashes [pin] with SHA-256 and stores the result securely.
  Future<void> savePin(String pin) async {
    final hash = _sha256(pin);
    await _storage.write(key: _pinStorageKey, value: hash);
  }

  /// Returns true if [pin] matches the stored PIN hash.
  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinStorageKey);
    if (stored == null) return false;
    return stored == _sha256(pin);
  }

  /// Deletes the stored PIN hash (vault wipe / reset).
  Future<void> deletePin() async =>
      _storage.delete(key: _pinStorageKey);

  // ── Private helpers ───────────────────────────────────────────────────────

  String _sha256(String input) {
    final digest = SHA256Digest();
    final bytes = digest.process(Uint8List.fromList(utf8.encode(input)));
    return base64Encode(bytes);
  }
}
