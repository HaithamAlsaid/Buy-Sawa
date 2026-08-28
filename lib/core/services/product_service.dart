// ─────────────────────────────────────────────────────────────────────────────
// ProductService — متربط بالـ API الحقيقي بتاع dxbalpha.com
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';
import 'cache_service.dart';

class ProductService {

  // ─── Get All Products ────────────────────────────────────────
  static Future<List<ProductModel>> getProducts({
    String? query,
    String? category,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      var url = ApiService.productsEndpoint;

      // Add query params if present
      final params = <String, String>{};
      if (query != null && query.isNotEmpty) params['search'] = query;
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
      }

      final res = await http.get(
        Uri.parse(url),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Handle both {"data": [...]} and [...] formats
        final rawList = body['data'] is List ? body['data'] as List : (body is List ? body : []);
        final products = rawList
            .map((e) => _productFromApi(e as Map<String, dynamic>))
            .whereType<ProductModel>()
            .toList();

        // Cache the products
        try { await CacheService.saveProducts(rawList.cast<Map<String, dynamic>>()); } catch (_) {}

        return products;
      }
    } catch (e) {
      // No internet → try cache
    }

    // Fallback to cache
    try {
      final cached = await CacheService.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        var list = cached
            .map((e) => _productFromApi(e))
            .whereType<ProductModel>()
            .toList();
        if (category != null) {
          list = list.where((p) => p.category == category).toList();
        }
        if (query != null && query.isNotEmpty) {
          list = list.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
        }
        return list;
      }
    } catch (_) {}

    // Fallback to mock if API and cache both fail
    return mockProducts;
  }

  // ─── Get Product By ID ───────────────────────────────────────
  static Future<ProductModel?> getProductById(dynamic id) async {
    try {
      final token = await SecureStorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiService.productDetailEndpoint(id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'] ?? body;
        return _productFromApi(data as Map<String, dynamic>);
      }
    } catch (_) {}

    // Fallback to mock
    try { return mockProducts.firstWhere((p) => p.id == id.toString()); } catch (_) {}
    return null;
  }

  // ─── Get Categories ──────────────────────────────────────────
  // NOTE: No categories endpoint in API yet - using mock
  static Future<List<CategoryModel>> getCategories() async {
    return mockCategories;
  }

  // ─── Map API product response to ProductModel ────────────────
  static ProductModel? _productFromApi(Map<String, dynamic> json) {
    try {
      // Handle various field name conventions
      final id = json['id']?.toString() ?? '';
      final name = json['name'] ?? json['title'] ?? '';
      final arabicName = json['arabic_name'] ?? json['name_ar'] ?? json['title_ar'] ?? name;
      final category = json['category'] ?? json['category_name'] ?? '';
      final price = (json['price'] as num?)?.toDouble() ?? 0.0;
      final originalPrice = (json['original_price'] ?? json['compare_price'] as num?)?.toDouble();
      final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
      final reviewCount = json['review_count'] ?? json['reviews_count'] ?? 0;

      // Handle image URL - could be full URL or just a path
      var imageUrl = json['image_url'] ?? json['image'] ?? json['thumbnail'] ?? '';
      if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        imageUrl = '${ApiService.baseUrl.replaceAll('/api/v1', '')}/$imageUrl';
      }

      final description = json['description'] ?? '';
      final arabicDescription = json['arabic_description'] ?? json['description_ar'] ?? description;

      return ProductModel(
        id: id,
        name: name.toString(),
        arabicName: arabicName.toString(),
        category: category.toString(),
        price: price,
        originalPrice: originalPrice,
        rating: rating,
        reviewCount: reviewCount is int ? reviewCount : int.tryParse(reviewCount.toString()) ?? 0,
        imageUrl: imageUrl.toString(),
        description: description.toString(),
        arabicDescription: arabicDescription.toString(),
        hasGroupDeal: json['has_group_deal'] == true,
        groupDealDiscount: json['group_deal_discount'] as int?,
        shareEarnPercent: (json['share_earn_percent'] as num?)?.toDouble(),
      );
    } catch (e) {
      return null;
    }
  }
}
