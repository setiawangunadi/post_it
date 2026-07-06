import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keySessionId = 'session_id';
  static const _keyLanguage = 'language';
  static const _keyUsername = 'username';
  static const _keyBankName = 'payment_bank_name';
  static const _keyBankAccountNumber = 'payment_bank_account_number';
  static const _keyBankAccountHolder = 'payment_bank_account_holder';

  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<void> saveSessionId(String id) =>
      _storage.write(key: _keySessionId, value: id);

  static Future<String?> getSessionId() => _storage.read(key: _keySessionId);

  static Future<void> saveLanguage(String lang) =>
      _storage.write(key: _keyLanguage, value: lang);

  static Future<String?> getLanguage() => _storage.read(key: _keyLanguage);

  static Future<void> saveUsername(String username) =>
      _storage.write(key: _keyUsername, value: username);

  static Future<String?> getUsername() => _storage.read(key: _keyUsername);

  static Future<void> saveBankName(String name) =>
      _storage.write(key: _keyBankName, value: name);

  static Future<String?> getBankName() => _storage.read(key: _keyBankName);

  static Future<void> saveBankAccountNumber(String number) =>
      _storage.write(key: _keyBankAccountNumber, value: number);

  static Future<String?> getBankAccountNumber() =>
      _storage.read(key: _keyBankAccountNumber);

  static Future<void> saveBankAccountHolder(String name) =>
      _storage.write(key: _keyBankAccountHolder, value: name);

  static Future<String?> getBankAccountHolder() =>
      _storage.read(key: _keyBankAccountHolder);

  static Future<void> clearAll() => _storage.deleteAll();
}
