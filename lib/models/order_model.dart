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
  final String rawStatus;

  OrderModel({
    required this.id,
    required this.status,
    required this.rawStatus,
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

    String rawStatus = data['status_label']?.toString() ?? 
                       data['status_name']?.toString() ?? 
                       (data['status'] is Map ? data['status']['label']?.toString() : data['status']?.toString()) ?? 
                       'pending';
                       
    // Normalize status to standard keys for tab filtering
    String normalizedStatus = 'pending';
    final lowerRaw = rawStatus.toLowerCase();
    
    if (lowerRaw.contains('pending') || lowerRaw.contains('انتظار') || data['status'] == 1) {
      normalizedStatus = 'pending';
    } else if (lowerRaw.contains('processing') || lowerRaw.contains('تجهيز') || data['status'] == 2) {
      normalizedStatus = 'processing';
    } else if (lowerRaw.contains('shipped') || lowerRaw.contains('شحن') || data['status'] == 3) {
      normalizedStatus = 'shipped';
    } else if (lowerRaw.contains('delivered') || lowerRaw.contains('تسليم') || data['status'] == 4) {
      normalizedStatus = 'delivered';
    } else if (lowerRaw.contains('cancel') || lowerRaw.contains('ملغي') || data['status'] == 5) {
      normalizedStatus = 'cancelled';
    }

    return OrderModel(
      id: (data['id'] ?? '').toString(),
      status: normalizedStatus,
      rawStatus: rawStatus,
      total: (data['total'] as num?)?.toDouble() ??
          (data['grand_total'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] is Map ? (data['currency']['code']?.toString() ?? 'AED') : (data['currency']?.toString() ?? data['target_currency']?.toString() ?? 'AED'),
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethod: data['payment_method']?.toString(),
      trackingNumber: data['tracking_number']?.toString(),
      customerNote: data['customer_note']?.toString(),
    );
  }

  String get statusArabic {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'processing': return 'جارى التجهيز';
      case 'shipped': return 'تم الشحن';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغي';
      default: return rawStatus;
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
    final product = json['product'] as Map<String, dynamic>? ?? json['orderable'] as Map<String, dynamic>? ?? {};
    
    var extractedUrl = '';
    if (product['avatar'] is Map && product['avatar']['url'] != null) {
      extractedUrl = product['avatar']['url'].toString();
    } else {        
      extractedUrl = product['image_url'] ?? product['image'] ?? json['image_url'] ?? json['image'] ?? '';
    }
    
    if (extractedUrl.isNotEmpty && !extractedUrl.startsWith('http')) {
      String path = extractedUrl;
      if (path.startsWith('/')) path = path.substring(1);
      if (!path.startsWith('storage/') && !path.startsWith('images/')) {
         path = 'storage/$path';
      }
      extractedUrl = 'https://buysawa.com/$path';
    }

    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? json['orderable_id'] ?? product['id'] ?? '').toString(),
      productName: product['name'] ?? product['title'] ?? product['product_name'] ?? json['product_name'] ?? json['name'] ?? json['title'] ?? '',
      productImage: extractedUrl,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
