// ─────────────────────────────────────────────────────────────────────────────
// CartService — يتكلم مع API الـ Cart بتاع buysawa.com
// Base: /api/v1/cart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/cart_item_model.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class CartService {
  // ─── Get Active Cart ─────────────────────────────────────────
  /// GET /api/v1/cart
  static Future<List<CartItemModel>> getCart() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return [];

    try {
      final res = await http.get(
        Uri.parse(ApiService.cartEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // يدعم {"data": {"items": [...]}} أو {"items": [...]} أو [...]
        final rawCart = body['data'] ?? body;
        final rawItems = rawCart['items'] as List? ??
            (body['data'] is List ? body['data'] : []);

        return (rawItems as List)
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ─── Add Item to Cart ────────────────────────────────────────
  /// POST /api/v1/cart/items/
  /// Returns the new cart item id or null on failure
  static Future<String?> addItem({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    try {
      final body = <String, dynamic>{
        'product_id': int.tryParse(productId) ?? productId,
        'quantity': quantity,
      };
      if (variantId != null) {
        body['product_variant_id'] = int.tryParse(variantId) ?? variantId;
      }

      final res = await http.post(
        Uri.parse(ApiService.cartItemsEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final respBody = jsonDecode(res.body);
        final data = respBody['data'] ?? respBody;
        return data['id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  // ─── Update Cart Item Quantity ───────────────────────────────
  /// PUT /api/v1/cart/items/{id}
  static Future<bool> updateItem({
    required String cartItemId,
    required int quantity,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse(ApiService.cartItemEndpoint(cartItemId)),
        headers: ApiService.headers(token: token),
        body: jsonEncode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // ─── Remove Item from Cart ───────────────────────────────────
  /// DELETE /api/v1/cart/items/{id}
  static Future<bool> removeItem(String cartItemId) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse(ApiService.cartItemEndpoint(cartItemId)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // ─── Clear All Items ─────────────────────────────────────────
  /// DELETE /api/v1/cart/items
  static Future<bool> clearCart() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse(ApiService.cartItemsEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }
}
