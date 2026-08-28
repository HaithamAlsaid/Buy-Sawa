import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'isLoggedIn';
  final SharedPreferences _prefs;

  bool _isLoggedIn;
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  AuthProvider(this._prefs) : _isLoggedIn = _prefs.getBool(_key) ?? false {
    if (_isLoggedIn) _loadUserFromApi();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => !_isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  // ─── Load user data from /auth/me ───────────────────────────
  Future<void> _loadUserFromApi() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      _isLoggedIn = false;
      await _prefs.setBool(_key, false);
      notifyListeners();
      return;
    }
    try {
      final res = await http.get(
        Uri.parse(ApiService.meEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Support both {data: {...}} and {...} formats
        final userData = body['data'] ?? body;
        _user = UserModel.fromJson(userData);
        _isLoggedIn = true;
      } else {
        // Token expired or invalid
        _isLoggedIn = false;
        _user = null;
        await _prefs.setBool(_key, false);
        await SecureStorageService.clearToken();
      }
    } catch (_) {
      // No internet - stay logged in with cached state
    }
    notifyListeners();
  }

  // ─── Login ───────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(ApiService.loginEndpoint),
        headers: ApiService.headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Extract token - handle multiple response formats
        final data = body['data'] ?? body;
        final token = data['token'] ?? data['access_token'] ?? body['token'];

        if (token != null) {
          await SecureStorageService.saveToken(token.toString());
        }

        // Extract user data
        final userData = data['user'] ?? data;
        if (userData is Map<String, dynamic> && userData.containsKey('id')) {
          _user = UserModel.fromJson(userData);
        } else {
          // Fetch user from /me if not in login response
          await _loadUserFromApi();
          _isLoading = false;
          return _isLoggedIn;
        }

        _isLoggedIn = true;
        await _prefs.setBool(_key, true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle error response
        _errorMessage = body['message'] ?? body['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Server timeout. Please try again.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        _errorMessage = 'Cannot reach server: dxbalpha.com - Check your internet or the server may be down.';
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Register ────────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? referralCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(ApiService.registerEndpoint),
        headers: ApiService.headers(),
        body: jsonEncode({
          'name': fullName,
          'email': email,
          'password': password,
          'password_confirmation': password,
          if (phone.isNotEmpty) 'phone': phone,
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = body['data'] ?? body;
        final token = data['token'] ?? data['access_token'] ?? body['token'];

        if (token != null) {
          await SecureStorageService.saveToken(token.toString());
        }

        final userData = data['user'] ?? data;
        if (userData is Map<String, dynamic> && userData.containsKey('id')) {
          _user = UserModel.fromJson(userData);
        } else {
          await _loadUserFromApi();
          _isLoading = false;
          return _isLoggedIn;
        }

        _isLoggedIn = true;
        await _prefs.setBool(_key, true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Extract validation errors or message
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          _errorMessage = errors.values.first is List
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString();
        } else {
          _errorMessage = body['message'] ?? 'Registration failed';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Server timeout. Please try again.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        _errorMessage = 'Cannot reach server: dxbalpha.com - Check your internet or the server may be down.';
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Update Profile ──────────────────────────────────────────
  void updateProfile(String fullName, String birthdate) {
    if (_user != null) {
      _user = _user!.copyWith(fullName: fullName, birthdate: birthdate);
      notifyListeners();
    }
  }

  // ─── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiService.logoutEndpoint),
          headers: ApiService.headers(token: token),
        );
      }
    } catch (_) {}

    _isLoggedIn = false;
    _user = null;
    _errorMessage = null;
    await _prefs.setBool(_key, false);
    await SecureStorageService.clearToken();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
