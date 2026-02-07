import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider(this._apiService, this._storageService);

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _storageService.hasToken();
      if (hasToken) {
        _token = await _storageService.getToken();
        _apiService.setAuthToken(_token);
        await _fetchUser();
      }
    } catch (e) {
      _token = null;
      _user = null;
      _apiService.setAuthToken(null);
      await _storageService.deleteToken();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      final data = response.data;

      if (data['token'] != null) {
        _token = data['token'] as String;
        await _storageService.saveToken(_token!);
        _apiService.setAuthToken(_token);

        if (data['user'] != null) {
          _user = User.fromJson(data['user'] as Map<String, dynamic>);
          await _storageService.saveUserData(data['user'] as Map<String, dynamic>);
        } else {
          await _fetchUser();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed: No token received';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final data = response.data;

      if (data['token'] != null) {
        _token = data['token'] as String;
        await _storageService.saveToken(_token!);
        _apiService.setAuthToken(_token);

        if (data['user'] != null) {
          _user = User.fromJson(data['user'] as Map<String, dynamic>);
          await _storageService.saveUserData(data['user'] as Map<String, dynamic>);
        } else {
          await _fetchUser();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout API errors
    } finally {
      _token = null;
      _user = null;
      _apiService.setAuthToken(null);
      await _storageService.deleteToken();
      await _storageService.clearUserData();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUser() async {
    try {
      final response = await _apiService.getUser();
      final data = response.data;
      // API returns {user: {...}} so we need to extract the user object
      final userData = data['user'] ?? data;
      _user = User.fromJson(userData as Map<String, dynamic>);
      await _storageService.saveUserData(userData as Map<String, dynamic>);
    } catch (e) {
      _token = null;
      _user = null;
      _apiService.setAuthToken(null);
      await _storageService.deleteToken();
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    if (_token == null) return;

    try {
      await _fetchUser();
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      final data = response.data;
      if (data['user'] != null) {
        _user = User.fromJson(data['user'] as Map<String, dynamic>);
        await _storageService.saveUserData(data['user'] as Map<String, dynamic>);
      } else if (data != null) {
        _user = User.fromJson(data as Map<String, dynamic>);
        await _storageService.saveUserData(data);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final message = e.toString();
      if (message.contains('DioException')) {
        if (message.contains('401')) {
          return 'Invalid email or password';
        } else if (message.contains('422')) {
          return 'Validation error. Please check your input.';
        } else if (message.contains('connection')) {
          return 'Connection error. Please check your internet.';
        }
      }
      return message.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
