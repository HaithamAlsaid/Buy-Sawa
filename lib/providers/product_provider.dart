import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _all = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _query = '';
  String? _selectedCategory;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  List<ProductModel> get products {
    var list = _all;
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    return list;
  }

  List<ProductModel> get trending => _all.take(6).toList();
  List<ProductModel> get groupDeals =>
      _all.where((p) => p.hasGroupDeal).toList();

  /// Call once on app start
  Future<void> loadProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final fetched = await ProductService.getProducts(
        query: _query.isNotEmpty ? _query : null,
        category: _selectedCategory,
      );
      _all = fetched;
      _hasError = false;
    } catch (_) {
      _hasError = true;
      // Keep whatever we had before (cache or mock fallback from ProductService)
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String q) {
    _query = q;
    notifyListeners();
    // Re-fetch from API with search query
    loadProducts();
  }

  void filterByCategory(String? cat) {
    _selectedCategory = cat;
    notifyListeners();
    loadProducts();
  }

  Future<void> refreshProducts() async {
    _query = '';
    _selectedCategory = null;
    await loadProducts();
  }
}
