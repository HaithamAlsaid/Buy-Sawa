import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/services/api_service.dart';
import '../core/services/secure_storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';
  Locale _locale;
  final SharedPreferences _prefs;

  LocaleProvider(this._prefs)
    : _locale = Locale(_prefs.getString(_key) ?? 'en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isFirstLaunch => !_prefs.containsKey('launched');

  void setLocale(String code) {
    _locale = Locale(code);
    _prefs.setString(_key, code);
    _prefs.setBool('launched', true);
    notifyListeners();
    _syncLocaleWithServer(code);
  }

  Future<void> _syncLocaleWithServer(String code) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return; // User not logged in, no need to sync

      await http.post(
        Uri.parse(ApiService.langSwitchEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({'locale': code}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Failed to sync locale with server: $e');
    }
  }

  void markLaunched() {
    _prefs.setBool('launched', true);
  }

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {
      'code': 'ar',
      'name': 'العربية (الإمارات)',
      'native': 'Emirati Arabic · RTL',
      'flag': '🇦🇪',
    },
  ];
}
