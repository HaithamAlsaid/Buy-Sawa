import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'isLoggedIn';
  final SharedPreferences _prefs;

  bool _isLoggedIn;
  UserModel? _user;

  AuthProvider(this._prefs)
      : _isLoggedIn = _prefs.getBool(_key) ?? false {
    if (_isLoggedIn) _loadMockUser();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => !_isLoggedIn;
  UserModel? get user => _user;

  void _loadMockUser() {
    _user = UserModel(
      id: 'u1',
      fullName: 'هيثم الصيد',
      email: 'haitham@buysawa.app',
      phone: '01063286843',
      birthdate: '04 / 15 / 1992',
      referralCode: 'HAITHAM25',
      walletBalance: 150.00,
      friendsReferred: 3,
    );
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _loadMockUser();
      await _prefs.setBool(_key, true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? referralCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _user = UserModel(
      id: 'u_new',
      fullName: fullName,
      email: email,
      phone: phone,
      birthdate: '',
      referralCode: 'SAWA${DateTime.now().millisecond}',
      walletBalance: referralCode != null && referralCode.isNotEmpty ? 15.0 : 0.0,
    );
    await _prefs.setBool(_key, true);
    notifyListeners();
    return true;
  }

  void updateProfile(String fullName, String birthdate) {
    if (_user != null) {
      _user = _user!.copyWith(fullName: fullName, birthdate: birthdate);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    await _prefs.setBool(_key, false);
    notifyListeners();
  }
}
