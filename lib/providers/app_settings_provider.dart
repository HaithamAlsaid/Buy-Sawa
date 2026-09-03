// ─────────────────────────────────────────────────────────────────────────────
// AppSettingsProvider — يجيب إعدادات التطبيق من الـ API (زي اللوجو)
// لما الأدمن يغير اللوجو من الـ Dashboard، الـ URL بيتغير وهنا بيتحدث تلقائياً
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/services/api_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  // الـ Logo URL اللي بييجي من الـ API
  String? _logoUrl;
  bool _isLoading = false;
  bool _hasError = false;

  String? get logoUrl => _logoUrl;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  // هل عندنا Logo URL من الـ API؟
  bool get hasRemoteLogo => _logoUrl != null && _logoUrl!.isNotEmpty;

  /// بيجيب الإعدادات من الـ API
  /// الـ Response المتوقع:
  /// {
  ///   "logo_url": "https://cdn.buysawa.com/logo.png",
  ///   "app_name": "BuySawa",
  ///   "primary_color": "#1BA8A0"
  /// }
  Future<void> fetchSettings() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse(ApiService.platformSettingsEndpoint),
            headers: ApiService.headers(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _logoUrl = data['logo_url'] as String?;
      } else {
        _hasError = true;
      }
    } catch (_) {
      // لو الـ API مش جاهز أو في مشكلة في الـ Network
      // الـ App هيستخدم الـ local asset كـ fallback تلقائياً
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
