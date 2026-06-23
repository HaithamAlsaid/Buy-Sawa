import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  void markLaunched() {
    _prefs.setBool('launched', true);
  }

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'code': 'ar', 'name': 'العربية (الإمارات)', 'native': 'Emirati Arabic · RTL', 'flag': '🇦🇪'},
    {'code': 'es', 'name': 'Español', 'native': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'zh', 'name': '中文', 'native': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ru', 'name': 'Русский', 'native': 'Russian', 'flag': '🇷🇺'},
  ];
}
