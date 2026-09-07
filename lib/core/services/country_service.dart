import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CountryService {
  static const String endpoint = '${ApiService.baseUrl}/countries';

  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final res = await http.get(
        Uri.parse(endpoint),
        headers: ApiService.headers(),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success') {
          final data = body['data'] as List;
          return data.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('CountryService error: $e');
    }
    return [];
    //getCountriesFromAssets
  }
  Future<List<Map<String, dynamic>>> getCountriesFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/countries.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading countries from assets: $e');
      return [];
    }
  }
}
