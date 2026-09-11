// ─────────────────────────────────────────────────────────────────────────────
// CartProvider — متربط بالـ API الحقيقي
// لو المستخدم مسجل → بيحفظ في السيرفر
// لو غير مسجل (guest) → بيحفظ محلياً
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../core/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  bool _isLoading = false;
  bool _isSynced = false; // هل جبنا الـ Cart من السيرفر؟
  String? _token;

  CartProvider() {
    _loadLocalCart();
  }

  static const _localCartKey = 'guest_cart';

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get count => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0, (s, i) => s + i.totalPrice);
  double get total => subtotal;

  // ─── تحديد التوكن وجلب الـ Cart من السيرفر ───────────────────
  void setToken(String? token) {
    _token = token;
    if (token != null && !_isSynced) {
      fetchCart();
      fetchCart();
    } else if (token == null) {
      // Guest mode: load local cart if available
      _isSynced = false;
      _loadLocalCart();
    }
  }

  // ─── جلب الـ Cart من السيرفر ─────────────────────────────────
  Future<void> fetchCart() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    final serverItems = await CartService.getCart();
    _items.clear();
    _items.addAll(serverItems);
    _isSynced = true;
    _isLoading = false;
    _isLoading = false;
    notifyListeners();
  }

  // ─── Local Persistence ──────────────────────────────────────────
  Future<void> _saveLocalCart() async {
    if (_token != null) return; // Only save locally if guest
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((i) => i.toJson()).toList();
    await prefs.setString(_localCartKey, jsonEncode(jsonList));
  }

  Future<void> _loadLocalCart() async {
    if (_token != null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_localCartKey);
      if (str != null) {
        final List<dynamic> jsonList = jsonDecode(str);
        _items.clear();
        _items.addAll(jsonList.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (_) {}
  }

  // ─── إضافة منتج ──────────────────────────────────────────────
  Future<void> add(ProductModel product, {String? variantId, ProductVariationModel? variation, String? groupId, String? referralCode}) async {
    // تحديث فوري في الـ UI
    final idx = _items.indexWhere((i) => i.product.id == product.id && i.variantId == variantId);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItemModel(product: product, variantId: variantId, variation: variation));
    }
    notifyListeners();
    _saveLocalCart();

    // إرسال للسيرفر في الخلفية
    if (_token != null) {
      final newId = await CartService.addItem(
        productId: product.id,
        variantId: variantId,
        quantity: 1,
        groupId: groupId,
        referralCode: referralCode,
      );
      // تحديث الـ ID لو جاء من السيرفر
      if (newId != null) {
        final i = _items.indexWhere((e) => e.product.id == product.id && e.variantId == variantId);
        if (i >= 0 && _items[i].cartItemId == null) {
          _items[i] = CartItemModel(
            cartItemId: newId,
            product: _items[i].product,
            variantId: _items[i].variantId,
            variation: _items[i].variation,
            quantity: _items[i].quantity,
          );
        }
      }
    }
  }

  // ─── حذف منتج ────────────────────────────────────────────────
  Future<void> remove(String productId) async {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    final item = _items[idx];
    _items.removeAt(idx);
    notifyListeners();
    _saveLocalCart();

    // إرسال للسيرفر
    if (_token != null && item.cartItemId != null) {
      await CartService.removeItem(item.cartItemId!);
    }
  }

  // ─── زيادة الكمية ────────────────────────────────────────────
  Future<void> increment(String productId) async {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    _items[idx].quantity++;
    notifyListeners();
    _saveLocalCart();

    if (_token != null && _items[idx].cartItemId != null) {
      await CartService.updateItem(
        cartItemId: _items[idx].cartItemId!,
        quantity: _items[idx].quantity,
      );
    }
  }

  // ─── تقليل الكمية ────────────────────────────────────────────
  Future<void> decrement(String productId) async {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    if (_items[idx].quantity > 1) {
      _items[idx].quantity--;
      notifyListeners();
      _saveLocalCart();

      if (_token != null && _items[idx].cartItemId != null) {
        await CartService.updateItem(
          cartItemId: _items[idx].cartItemId!,
          quantity: _items[idx].quantity,
        );
      }
    } else {
      await remove(productId);
    }
  }

  // ─── مسح الـ Cart ─────────────────────────────────────────────
  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    _saveLocalCart();

    if (_token != null) {
      await CartService.clearCart();
    }
  }
}
