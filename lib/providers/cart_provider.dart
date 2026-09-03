// ─────────────────────────────────────────────────────────────────────────────
// CartProvider — متربط بالـ API الحقيقي
// لو المستخدم مسجل → بيحفظ في السيرفر
// لو غير مسجل (guest) → بيحفظ محلياً
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../core/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  bool _isLoading = false;
  bool _isSynced = false; // هل جبنا الـ Cart من السيرفر؟
  String? _token;

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
    } else if (token == null) {
      // Guest mode: امسح الـ Cart
      _items.clear();
      _isSynced = false;
      notifyListeners();
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
    notifyListeners();
  }

  // ─── إضافة منتج ──────────────────────────────────────────────
  Future<void> add(ProductModel product, {String? variantId}) async {
    // تحديث فوري في الـ UI
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }
    notifyListeners();

    // إرسال للسيرفر في الخلفية
    if (_token != null) {
      final newId = await CartService.addItem(
        productId: product.id,
        variantId: variantId,
        quantity: 1,
      );
      // تحديث الـ ID لو جاء من السيرفر
      if (newId != null) {
        final i = _items.indexWhere((e) => e.product.id == product.id);
        if (i >= 0 && _items[i].cartItemId == null) {
          _items[i] = CartItemModel(
            cartItemId: newId,
            product: _items[i].product,
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

    if (_token != null) {
      await CartService.clearCart();
    }
  }
}
