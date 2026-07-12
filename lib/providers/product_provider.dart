import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final List<ProductModel> _all = List.from(mockProducts);
  String _query = '';
  String? _selectedCategory;

  List<ProductModel> get products {
    var list = _all;
    if (_selectedCategory != null) {
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

  void search(String q) {
    _query = q;
    notifyListeners();
  }

  void filterByCategory(String? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Shuffle the products to simulate "new" items appearing
    _all.shuffle();
    notifyListeners();
  }
}
