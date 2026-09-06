import 'dart:convert';
import 'dart:io';
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
        _errorMessage = 'Cannot reach server: buysawa.com - Check your internet or the server may be down.';
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
    required String passwordConfirmation,
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
          'password_confirmation': passwordConfirmation,
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
        _errorMessage = 'Cannot reach server: buysawa.com - Check your internet or the server may be down.';
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Update Profile ──────────────────────────────────────────
  Future<bool> updateProfile(String fullName, String birthdate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.put(
        Uri.parse(ApiService.profileEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'name': fullName,
          if (birthdate.isNotEmpty) 'date_of_birth': birthdate,
          if (_user != null) 'email': _user!.email,
          if (_user != null) 'phone': _user!.phone,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (_user != null) {
          _user = _user!.copyWith(fullName: fullName, birthdate: birthdate);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Upload Avatar ───────────────────────────────────────────
  Future<bool> uploadAvatar(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiService.avatarEndpoint),
      );
      request.headers.addAll(ApiService.headers(token: token));
      request.files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        // DEBUG: print full response to console
        debugPrint('=== Avatar Upload Response ===');
        debugPrint(response.body);
        debugPrint('==============================');
        
        final data = body['data'] ?? body;
        // Try all possible field names the backend might use
        final newAvatarUrl = data['avatar_url'] 
            ?? data['profile_image'] 
            ?? data['avatar'] 
            ?? data['image_url']
            ?? data['url'];
            
        if (newAvatarUrl != null) {
          _user = _user?.copyWith(avatarUrl: newAvatarUrl.toString());
        } else {
          // Reload from API to get updated profile with new avatar
          await _loadUserFromApi();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to upload image.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error uploading image: $e';
      _isLoading = false;
      notifyListeners();
      return false;
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

  // ─── Forgot Password ──────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(ApiService.forgotPasswordEndpoint),
        headers: ApiService.headers(),
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Failed to send reset link';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Change Password ──────────────────────────────────────────
  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.changePasswordEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Failed to change password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Resend Verification Email ────────────────────────────────
  Future<bool> resendVerificationEmail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.emailResendEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Failed to resend email';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── MFA Methods ─────────────────────────────────────────────
  Future<String?> setupMfa() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.mfaSetupEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        // Assuming backend returns QR code URL or secret in 'data'
        final data = body['data'] ?? body;
        return data['qr_code_url'] ?? data['secret'] ?? data['url']?.toString();
      } else {
        _errorMessage = body['message'] ?? 'Failed to setup MFA';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Connection error.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmMfa(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.mfaConfirmEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'code': code,
          'device_name': 'mobile_app',
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(res.body);
        _errorMessage = body['message'] ?? 'Invalid code';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyMfa(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For verify during login, token might be temporary or different, 
      // but assuming it's passed or stored temporarily.
      final token = await SecureStorageService.getToken(); 
      final res = await http.post(
        Uri.parse(ApiService.mfaVerifyEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'code': code,
          'device_name': 'mobile_app',
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(res.body);
        _errorMessage = body['message'] ?? 'Invalid code';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> disableMfa(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.mfaDisableEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'code': code,
          'device_name': 'mobile_app',
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(res.body);
        _errorMessage = body['message'] ?? 'Invalid code';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
