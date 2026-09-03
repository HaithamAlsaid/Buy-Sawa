import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'secure_storage_service.dart';

class FavouriteService {
  // ─── Get Favourites ──────────────────────────────────────────
  /// GET /api/v1/profile/favorites
  static Future<List<Map<String, dynamic>>> getFavourites() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return [];

    try {
      final res = await http.get(
        Uri.parse(ApiService.favoritesEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      debugPrint('=== Favourites API Response ===');
      debugPrint(res.body);
      debugPrint('================================');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final rawList = body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);

        return rawList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Favourites error: $e');
    }
    return [];
  }

  // ─── Add Favourite 
  /// POST /api/v1/profile/favorites?model_type=product
  static Future<bool> addFavourite(dynamic productId) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse('${ApiService.favoritesEndpoint}?model_type=product'),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'model_id': productId.toString(),
        }),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Add favourite error: $e');
    }
    return false;
  }

  // ─── Remove Favourite ────────────────────────────────────────
  /// DELETE /api/v1/profile/favorites/{id}
  static Future<bool> removeFavourite(dynamic id) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse(ApiService.removeFavoriteEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('Remove favourite error: $e');
    }
    return false;
  }
}
