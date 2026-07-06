import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keySessionId = 'session_id';
  static const _keyLanguage = 'language';
  static const _keyUsername = 'username';

  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<void> saveSessionId(String id) =>
      _storage.write(key: _keySessionId, value: id);

  static Future<String?> getSessionId() =>
      _storage.read(key: _keySessionId);

  static Future<void> saveLanguage(String lang) =>
      _storage.write(key: _keyLanguage, value: lang);

  static Future<String?> getLanguage() =>
      _storage.read(key: _keyLanguage);

  static Future<void> saveUsername(String username) =>
      _storage.write(key: _keyUsername, value: username);

  static Future<String?> getUsername() =>
      _storage.read(key: _keyUsername);

  static Future<void> clearAll() => _storage.deleteAll();
}
