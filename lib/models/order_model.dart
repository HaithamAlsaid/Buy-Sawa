// ─────────────────────────────────────────────────────────────────────────────
// OrderModel — بيانات الطلب من الـ API
// ─────────────────────────────────────────────────────────────────────────────

class OrderModel {
  final String id;
  final String status;
  final double total;
  final String currency;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final String? paymentMethod;
  final String? trackingNumber;
  final String? customerNote;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    this.currency = 'EGP',
    required this.createdAt,
    this.items = const [],
    this.paymentMethod,
    this.trackingNumber,
    this.customerNote,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final rawItems = data['items'] as List? ?? [];

    return OrderModel(
      id: (data['id'] ?? '').toString(),
      status: data['status'] ?? 'pending',
      total: (data['total'] as num?)?.toDouble() ??
          (data['grand_total'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? data['target_currency'] ?? 'EGP',
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethod: data['payment_method']?.toString(),
      trackingNumber: data['tracking_number']?.toString(),
      customerNote: data['customer_note']?.toString(),
    );
  }

  String get statusArabic {
    switch (status.toLowerCase()) {
      case 'pending': return 'قيد الانتظار';
      case 'processing': return 'جارى التجهيز';
      case 'shipped': return 'تم الشحن';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? product['id'] ?? '').toString(),
      productName: product['name'] ?? product['title'] ?? json['name'] ?? '',
      productImage: product['image_url'] ?? product['image'] ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
