// ─────────────────────────────────────────────────────────────────────────────
// AddressService — يتكلم مع API الـ Addresses بتاع buysawa.com
// Base: /api/v1/profile/addresses
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/address_model.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class AddressService {
  // ─── Get All Addresses ───────────────────────────────────────
  /// GET /api/v1/profile/addresses
  static Future<List<AddressModel>> getAddresses() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return [];

    try {
      final res = await http.get(
        Uri.parse(ApiService.addressesEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final rawList = body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);

        return rawList
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  //  Create Address 
  /// POST /api/v1/profile/addresses
  static Future<AddressModel?> createAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String country,
    String? postalCode,
    String? label,
    String? instructions,
    String? phoneCode,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    try {
      final body = <String, dynamic>{
        'address_line_1': addressLine1,
        'city': city,
        'state': state,
        'country': country,
        'is_default': isDefault,
        if (addressLine2 != null && addressLine2.isNotEmpty) 'address_line_2': addressLine2,
        if (postalCode != null && postalCode.isNotEmpty) 'postal_code': postalCode,
        if (label != null && label.isNotEmpty) 'label': label,
        if (instructions != null && instructions.isNotEmpty) 'instructions': instructions,
        if (phoneCode != null) 'phone_code': phoneCode,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      final res = await http.post(
        Uri.parse(ApiService.addressesEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return AddressModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  // ─── Update Address ──────────────────────────────────────────
  /// PUT /api/v1/profile/addresses/{id}
  static Future<AddressModel?> updateAddress(
    String id,
    Map<String, dynamic> fields,
  ) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    try {
      final res = await http.put(
        Uri.parse(ApiService.addressEndpoint(id)),
        headers: ApiService.headers(token: token),
        body: jsonEncode(fields),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return AddressModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  // ─── Set Default Address ─────────────────────────────────────
  /// POST /api/v1/profile/addresses/{id}/default
  static Future<bool> setDefault(String id) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse(ApiService.addressDefaultEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // ─── Delete Address ──────────────────────────────────────────
  /// DELETE /api/v1/profile/addresses/{id}
  static Future<bool> deleteAddress(String id) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse(ApiService.addressEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }
}
