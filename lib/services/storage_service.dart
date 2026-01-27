import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  StorageService() : _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== SECURE STORAGE (Token) ====================

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== SHARED PREFERENCES (Caching) ====================

  Future<void> saveToCache(String key, dynamic data) async {
    await _prefs?.setString(key, jsonEncode(data));
  }

  Future<T?> getFromCache<T>(String key) async {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as T?;
  }

  Future<void> removeFromCache(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearCache() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key != _tokenKey && key != _userKey) {
        await _prefs?.remove(key);
      }
    }
  }

  // ==================== USER DATA ====================

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = _prefs?.getString(_userKey);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>?;
  }

  Future<void> clearUserData() async {
    await _prefs?.remove(_userKey);
  }

  // ==================== THEME PREFERENCE ====================

  Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  Future<String?> getThemeMode() async {
    return _prefs?.getString('theme_mode');
  }

  // ==================== CLEAR ALL ====================

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
