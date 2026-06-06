import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value storage for sensitive data (tokens, user id).
/// Uses Keychain on iOS, EncryptedSharedPreferences on Android.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ─── Keys ────────────────────────────────────────────────────────────────
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kFcmToken = 'fcm_token';

  // ─── Token Operations ─────────────────────────────────────────────────────
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  // ─── User ID ──────────────────────────────────────────────────────────────
  Future<void> saveUserId(String userId) =>
      _storage.write(key: _kUserId, value: userId);
  Future<String?> getUserId() => _storage.read(key: _kUserId);

  // ─── FCM Token ────────────────────────────────────────────────────────────
  Future<void> saveFcmToken(String token) =>
      _storage.write(key: _kFcmToken, value: token);
  Future<String?> getFcmToken() => _storage.read(key: _kFcmToken);

  // ─── Clear all (on logout) ────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();

  /// Check if user has a saved session (for auto-login on app open)
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
