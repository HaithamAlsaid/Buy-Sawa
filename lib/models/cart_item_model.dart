import 'product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CartItemModel — يدعم الـ API Response والـ Local Cart
// ─────────────────────────────────────────────────────────────────────────────

class CartItemModel {
  final String? cartItemId; // ID الـ Item في السيرفر (null لو local بس)
  final ProductModel product;
  int quantity;

  CartItemModel({
    this.cartItemId,
    required this.product,
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

    final product = ProductModel(
      id: (productData['id'] ?? json['product_id'] ?? '').toString(),
      name: productData['name'] ?? productData['title'] ?? '',
      arabicName: productData['name_ar'] ?? productData['arabic_name'] ?? productData['name'] ?? '',
      category: productData['category'] ?? '',
      price: price,
      originalPrice: (productData['original_price'] as num?)?.toDouble(),
      rating: (productData['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: productData['review_count'] ?? 0,
      imageUrl: _buildImageUrl(productData['image_url'] ?? productData['image'] ?? ''),
      description: productData['description'] ?? '',
      arabicDescription: productData['description_ar'] ?? productData['description'] ?? '',
    );

    return CartItemModel(
      cartItemId: json['id']?.toString(),
      product: product,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  static String _buildImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://buysawa.com/$url';
  }
}
