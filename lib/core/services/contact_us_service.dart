import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'secure_storage_service.dart';

class ContactUsService {
  /// GET /api/v1/contact-us/purposes
  static Future<List<Map<String, dynamic>>> getPurposes() async {
    try {
      final res = await http.get(
        Uri.parse(ApiService.contactUsPurposesEndpoint),
        headers: ApiService.headers(),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final rawList = body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);
        if (rawList.isNotEmpty) {
          return rawList.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('ContactUs getPurposes error: $e');
    }
    return [];
  }

  /// POST /api/v1/contact-us/submit
  static Future<bool> submitMessage({
    required String fullName,
    required String email,
    required String phone,
    int? purposeId,
    required String message,
  }) async {
    final token = await SecureStorageService.getToken(); // Might be null if guest, that's fine if API allows guest

    try {
      final body = <String, dynamic>{
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'message': message,
        'source': 'mobile_app',
      };
      
      if (purposeId != null) {
        body['purpose_id'] = purposeId;
      }

      final res = await http.post(
        Uri.parse(ApiService.contactUsSubmitEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('ContactUs submit error: $e');
    }
    return false;
  }
}
