class GroupBuyModel {
  final String id;
  final String code;
  final String ownerName;
  final String arabicOwnerName;
  final int memberCount;
  final int maxMembers;
  final bool isActive;
  final String productId;
  final String productName;
  final String arabicProductName;
  final int discountPercent;
  final DateTime? expiresAt;

  GroupBuyModel({
    required this.id,
    required this.code,
    required this.ownerName,
    required this.arabicOwnerName,
    required this.memberCount,
    required this.maxMembers,
    required this.isActive,
    required this.productId,
    required this.productName,
    required this.arabicProductName,
    required this.discountPercent,
    this.expiresAt,
  });

  double get progressPercent => memberCount / maxMembers;

  factory GroupBuyModel.fromJson(Map<String, dynamic> json) {
    final parsedExpiry = _parseExpiry(json);
    final isTimeExpired = parsedExpiry != null && parsedExpiry.isBefore(DateTime.now());
    
    return GroupBuyModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? json['name']?.toString() ?? '',
      arabicOwnerName: json['arabic_owner_name']?.toString() ?? json['owner_name']?.toString() ?? json['name']?.toString() ?? '',
      memberCount: (json['member_count'] as num?)?.toInt() ?? (json['members_count'] as num?)?.toInt() ?? 0,
      maxMembers: (json['max_members'] as num?)?.toInt() ?? 10,
      isActive: _parseIsActive(json) && !isTimeExpired,
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? json['product']?['name']?.toString() ?? '',
      arabicProductName: json['arabic_product_name']?.toString() ?? json['product']?['arabic_name']?.toString() ?? json['product_name']?.toString() ?? '',
      discountPercent: (json['discount_percent'] as num?)?.toInt() ?? (json['cashback_percent'] as num?)?.toInt() ?? 0,
      expiresAt: parsedExpiry,
    );
  }

  static DateTime? _parseExpiry(Map<String, dynamic> json) {
    if (json['expires_at'] != null) return DateTime.tryParse(json['expires_at'].toString());
    if (json['expire_at'] != null) return DateTime.tryParse(json['expire_at'].toString());
    if (json['end_time'] != null) return DateTime.tryParse(json['end_time'].toString());
    if (json['created_at'] != null) {
      final created = DateTime.tryParse(json['created_at'].toString());
      if (created != null) return created.add(const Duration(hours: 24));
    }
    return null;
  }

  static bool _parseIsActive(Map<String, dynamic> json) {
    // If it has an explicit is_active boolean or integer
    if (json['is_active'] != null) {
      if (json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1') return true;
      if (json['is_active'] == false || json['is_active'] == 0 || json['is_active'] == '0') return false;
    }
    // Check status field
    final status = json['status']?.toString().toLowerCase();
    if (status == 'active' || status == 'open' || status == 'pending') return true;
    if (status == 'expired' || status == 'closed' || status == 'completed') return false;
    
    // Default to true if not explicitly expired
    return true;
  }
}


