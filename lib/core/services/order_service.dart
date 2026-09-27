// ─────────────────────────────────────────────────────────────────────────────

// Base: /api/v1/orders
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/order_model.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class OrderService {
  // ─── Get All Orders 
  /// GET /api/v1/orders?page=1&per_page=10
  static Future<List<OrderModel>> getOrders({int page = 1, int perPage = 20}) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return [];

    try {
      final url = '${ApiService.ordersEndpoint}?page=$page&per_page=$perPage';
      final res = await http.get(
        Uri.parse(url),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // DEBUG
        debugPrint('=== Orders API Response ===');
        debugPrint(res.body);
        debugPrint('===========================');
        final rawList = body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);

        return rawList
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ─── Get Order by ID ─────────────────────────────────────────
  /// GET /api/v1/orders/{id}
  static Future<OrderModel?> getOrder(dynamic id) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse(ApiService.orderEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return OrderModel.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  // ─── Checkout (Place Order) ───────────────────────────────────
  /// POST /api/v1/orders/checkout
  /// Supports: wallet, card (ngenius), bnpl (tamara)
  /// Returns: order, optional redirectionUrl, or error
  static Future<({OrderModel? order, String? redirectionUrl, String? error})> checkout({
    required String shippingAddressId,
    String? billingAddressId,
    required String paymentMethod, // 'wallet' | 'card' | 'bnpl'
    required String provider,      // 'wallet' | 'ngenius' | 'tamara'
    String? phone,
    String? customerNote,
    String? couponCode,
    String returnUrl = 'https://app.buysawa.ae/checkout/success',
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return (order: null, redirectionUrl: null, error: 'Not logged in');

    try {
      final body = <String, dynamic>{
        'shipping_address_id': int.tryParse(shippingAddressId) ?? shippingAddressId,
        'payment_method': paymentMethod,
        'provider': provider,
        'return_url': returnUrl,
      };
      if (billingAddressId != null) {
        body['billing_address_id'] = int.tryParse(billingAddressId) ?? billingAddressId;
      }
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (customerNote != null && customerNote.isNotEmpty) body['customer_note'] = customerNote;
      if (couponCode != null && couponCode.isNotEmpty) body['coupon_code'] = couponCode;

      debugPrint('=== Checkout Request ===');
      debugPrint(jsonEncode(body));

      final res = await http.post(
        Uri.parse(ApiService.checkoutEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      debugPrint('=== Checkout Response [${res.statusCode}] ===');
      debugPrint(res.body);

      final respBody = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Extract redirection URL if payment gateway requires it (supports N-Genius & Tamara formats)
        String? redirectionUrl;
        final orderData = respBody['data'] ?? respBody;
        final paymentAction = orderData['payment_action'] ?? respBody['payment_action'];
        
        if (paymentAction is Map) {
          redirectionUrl = paymentAction['redirection_url']?.toString() ??
                           paymentAction['checkout_url']?.toString() ??
                           paymentAction['payment_url']?.toString() ??
                           paymentAction['url']?.toString();
        }

        // Fallback for gateways that put it in the root data object
        if (redirectionUrl == null || redirectionUrl.isEmpty) {
          redirectionUrl = orderData['redirection_url']?.toString() ??
                           orderData['checkout_url']?.toString() ??
                           orderData['payment_url']?.toString();
        }
        return (
          order: OrderModel.fromJson(orderData),
          redirectionUrl: redirectionUrl,
          error: null,
        );
      }
      final errMsg = respBody['message'] ?? respBody['error'] ?? 'Checkout failed';
      return (order: null, redirectionUrl: null, error: errMsg.toString());
    } catch (e) {
      return (order: null, redirectionUrl: null, error: e.toString());
    }
  }

  // ─── Cancel Order ─────────────────────────────────────────────
  /// POST /api/v1/orders/{id}/cancel
  static Future<bool> cancelOrder(dynamic id) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse(ApiService.cancelOrderEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // ─── Reorder ──────────────────────────────────────────────────
  /// POST /api/v1/orders/{id}/reorder
  static Future<bool> reorder(dynamic id) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse(ApiService.reorderEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {}
    return false;
  }
}
