// ─────────────────────────────────────────────────────────────────────────────
// CartService — يتكلم مع API الـ Cart بتاع buysawa.com
// Base: /api/v1/cart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
        
        try {
          final f = File(r'C:\Users\Owner\.gemini\antigravity-ide\brain\c768fa9e-6f96-498e-b844-542f0f242689\scratch\cart_dump.json');
          f.createSync(recursive: true);
          f.writeAsStringSync(res.body);
        } catch (e) {
          debugPrint('Dump error: $e');
        }

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
    String? groupId,
    String? referralCode,
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
      if (groupId != null) {
        body['group_id'] = groupId;
      }
      if (referralCode != null) {
        body['referral_code'] = referralCode;
      }

      debugPrint('🛒 CartService.addItem → POST ${ApiService.cartItemsEndpoint}');
      debugPrint('🛒 Body: ${jsonEncode(body)}');

      final res = await http.post(
        Uri.parse(ApiService.cartItemsEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('🛒 CartService.addItem ← [${res.statusCode}] ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final respBody = jsonDecode(res.body);
        final data = respBody['data'] ?? respBody;
        final id = data['id']?.toString();
        debugPrint('✅ CartService.addItem: saved with id = $id');
        return id;
      } else {
        debugPrint('❌ CartService.addItem failed: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ CartService.addItem exception: $e');
    }
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
