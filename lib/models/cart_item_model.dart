import 'package:buysawa/models/product_model.dart';

import 'product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CartItemModel — يدعم الـ API Response والـ Local Cart
// ─────────────────────────────────────────────────────────────────────────────

class CartItemModel {
  final String? cartItemId; // ID الـ Item في السيرفر (null لو local بس)
  final ProductModel product;
  final String? variantId;
  final ProductVariationModel? variation;
  int quantity;

  CartItemModel({
    this.cartItemId,
    required this.product,
    this.variantId,
    this.variation,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  /// بناء CartItemModel من الـ API Response
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // استخرج بيانات المنتج من الـ response
    final productData = json['product'] as Map<String, dynamic>? ?? {};
    final variantData = json['variant'] as Map<String, dynamic>?;

    // السعر من الـ variant أو المنتج
    final price = (json['price'] as num?)?.toDouble() ??
        (variantData?['price'] as num?)?.toDouble() ??
        (productData['price'] as num?)?.toDouble() ??
        0.0;

      var extractedUrl = '';
      if (productData['avatar'] is Map && productData['avatar']['url'] != null) {
        extractedUrl = productData['avatar']['url'].toString();
      } else {        
        extractedUrl = productData['image_url'] ?? productData['image'] ?? '';
      }

    final product = ProductModel(
      id: (productData['id'] ?? json['product_id'] ?? '').toString(),
      name: productData['name'] ?? productData['title'] ?? '',
      arabicName: productData['name_ar'] ?? productData['arabic_name'] ?? productData['name'] ?? '',
      category: productData['category'] ?? '',
      price: price,
      originalPrice: (productData['original_price'] as num?)?.toDouble(),
      rating: (productData['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: productData['review_count'] ?? 0,
      imageUrl: _buildImageUrl(extractedUrl),
      description: productData['description'] ?? '',
      arabicDescription: productData['description_ar'] ?? productData['description'] ?? '',
    );

    ProductVariationModel? variation;
    if (variantData != null) {
      variation = ProductVariationModel.fromJson(variantData);
    }

    return CartItemModel(
      cartItemId: json['id']?.toString(),
      product: product,
      variantId: variantData?['id']?.toString() ?? json['product_variant_id']?.toString(),
      variation: variation,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': cartItemId,
      'product': product.toJson(),
      'variant_id': variantId,
      if (variation != null) 'variant': {
        'id': variation!.id,
        'name': variation!.name,
        'pricing': { 'price': variation!.price },
      },
      'quantity': quantity,
    };
  }

  static String _buildImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    String path = url.toString();
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('storage/') && !path.startsWith('images/')) {
       path = 'storage/$path';
    }
    return 'https://buysawa.com/$path';
  }
}
