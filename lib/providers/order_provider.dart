// ─────────────────────────────────────────────────────────────────────────────
// OrderProvider — يجيب الطلبات من الـ API
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../core/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _token;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _orders.isEmpty;

  // ─── تحديد التوكن وجلب الطلبات ──────────────────────────────
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      fetchOrders();
    } else {
      _orders = [];
      notifyListeners();
    }
  }

  // ─── جلب كل الطلبات ──────────────────────────────────────────
  Future<void> fetchOrders() async {
    if (_token == null) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final result = await OrderService.getOrders();
    _orders = result;
    _isLoading = false;
    _hasError = false;
    notifyListeners();
  }

  // ─── Checkout (تنفيذ الطلب) ───────────────────────────────────
  Future<({bool success, String? error, OrderModel? order})> checkout({
    required String shippingAddressId,
    String? billingAddressId,
    required String paymentMethod,
    String? phone,
    String currency = 'EGP',
    String? customerNote,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await OrderService.checkout(
      shippingAddressId: shippingAddressId,
      billingAddressId: billingAddressId,
      paymentMethod: paymentMethod,
      phone: phone,
      currency: currency,
      customerNote: customerNote,
    );

    _isLoading = false;

    if (result.order != null) {
      _orders.insert(0, result.order!);
      notifyListeners();
      return (success: true, error: null, order: result.order);
    } else {
      notifyListeners();
      return (success: false, error: result.error, order: null);
    }
  }

  // ─── إلغاء طلب ───────────────────────────────────────────────
  Future<bool> cancelOrder(String orderId) async {
    final success = await OrderService.cancelOrder(orderId);
    if (success) {
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = OrderModel(
          id: _orders[idx].id,
          status: 'cancelled',
          total: _orders[idx].total,
          currency: _orders[idx].currency,
          createdAt: _orders[idx].createdAt,
          items: _orders[idx].items,
          paymentMethod: _orders[idx].paymentMethod,
        );
        notifyListeners();
      }
    }
    return success;
  }

  // ─── إعادة طلب ──────────────────────────────────────────────
  Future<bool> reorder(String orderId) async {
    return OrderService.reorder(orderId);
  }
}
