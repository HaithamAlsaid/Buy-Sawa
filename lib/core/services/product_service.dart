// ─────────────────────────────────────────────────────────────────────────────
// ProductService — شغال بـ Mock Data دلوقتي
// لما يجهز الـ API: شيل الـ mock وفك تعليق الـ http calls
// ─────────────────────────────────────────────────────────────────────────────
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../../models/product_model.dart';
import '../../models/category_model.dart';
// import 'api_service.dart';
// import 'auth_service.dart';

class ProductService {
  // ─── Get All Products ────────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<List<ProductModel>> getProducts({String? query, String? category}) async {
  //   final token = await AuthService.getToken();
  //   var url = ApiService.productsEndpoint;
  //   if (query != null) url += '?q=$query';
  //   if (category != null) url += '${query != null ? '&' : '?'}category=$category';
  //   final res = await http.get(Uri.parse(url), headers: ApiService.headers(token: token));
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body) as List;
  //     return data.map((e) => ProductModel.fromJson(e)).toList();
  //   }
  //   return [];
  // }

  // MOCK (remove when API is ready):
  static Future<List<ProductModel>> getProducts({
    String? query,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    var list = List<ProductModel>.from(mockProducts);
    if (category != null) {
      list = list.where((p) => p.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return list;
  }

  // ─── Get Product By ID ───────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<ProductModel?> getProductById(String id) async {
  //   final token = await AuthService.getToken();
  //   final res = await http.get(
  //     Uri.parse('${ApiService.productsEndpoint}/$id'),
  //     headers: ApiService.headers(token: token),
  //   );
  //   if (res.statusCode == 200) return ProductModel.fromJson(jsonDecode(res.body));
  //   return null;
  // }

  // MOCK:
  static Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return mockProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Get Categories ──────────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<List<CategoryModel>> getCategories() async {
  //   final res = await http.get(Uri.parse(ApiService.categoriesEndpoint));
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body) as List;
  //     return data.map((e) => CategoryModel.fromJson(e)).toList();
  //   }
  //   return [];
  // }

  // MOCK:
  static Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockCategories;
  }
}
