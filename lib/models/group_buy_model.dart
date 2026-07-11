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
    return GroupBuyModel(
      id: json['id'] as String,
      code: json['code'] as String,
      ownerName: json['owner_name'] as String,
      arabicOwnerName: json['arabic_owner_name'] as String? ?? json['owner_name'] as String,
      memberCount: json['member_count'] as int,
      maxMembers: json['max_members'] as int,
      isActive: json['is_active'] as bool,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      arabicProductName: json['arabic_product_name'] as String? ?? json['product_name'] as String,
      discountPercent: json['discount_percent'] as int,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }
}

final List<GroupBuyModel> mockGroupBuys = [
  GroupBuyModel(
    id: 'gb1',
    code: 'GB-X72A',
    ownerName: 'Haitham Alsaid',
    arabicOwnerName: 'هيثم الصياد',
    memberCount: 5,
    maxMembers: 10,
    isActive: true,
    productId: 'p1',
    productName: 'Sony WH-1000XM5',
    arabicProductName: 'سوني WH-1000XM5',
    discountPercent: 15,
    expiresAt: DateTime.now().add(const Duration(hours: 36)),
  ),
  GroupBuyModel(
    id: 'gb2',
    code: 'GB-K91B',
    ownerName: 'Weekend Buyers',
    arabicOwnerName: 'مشتريات العطلة',
    memberCount: 3,
    maxMembers: 10,
    isActive: true,
    productId: 'p3',
    productName: 'Nike Air Max 270',
    arabicProductName: 'نايك إير ماكس 270',
    discountPercent: 10,
    expiresAt: DateTime.now().add(const Duration(hours: 12)),
  ),
  GroupBuyModel(
    id: 'gb3',
    code: 'GB-M44Z',
    ownerName: 'Beauty Box Crew',
    arabicOwnerName: 'طاقم صندوق الجمال',
    memberCount: 4,
    maxMembers: 10,
    isActive: false,
    productId: 'p5',
    productName: 'Glow Serum Premium',
    arabicProductName: 'سيروم نضارة فاخر',
    discountPercent: 12,
    expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
  ),
  GroupBuyModel(
    id: 'gb4',
    code: 'GB-R22F',
    ownerName: 'Gaming Squad',
    arabicOwnerName: 'فريق الألعاب',
    memberCount: 8,
    maxMembers: 10,
    isActive: true,
    productId: 'p6',
    productName: 'PlayStation 5 Pro',
    arabicProductName: 'بلايستيشن 5 برو',
    discountPercent: 20,
    expiresAt: DateTime.now().add(const Duration(hours: 48)),
  ),
  GroupBuyModel(
    id: 'gb5',
    code: 'GB-L99P',
    ownerName: 'Tech Geeks',
    arabicOwnerName: 'مهوسو التقنية',
    memberCount: 2,
    maxMembers: 5,
    isActive: true,
    productId: 'p7',
    productName: 'MacBook Air M3',
    arabicProductName: 'ماك بوك اير M3',
    discountPercent: 10,
    expiresAt: DateTime.now().add(const Duration(hours: 72)),
  ),
  GroupBuyModel(
    id: 'gb6',
    code: 'GB-Q11A',
    ownerName: 'Fitness Junkies',
    arabicOwnerName: 'مدمنو اللياقة',
    memberCount: 9,
    maxMembers: 15,
    isActive: true,
    productId: 'p8',
    productName: 'Adjustable Dumbbells Set',
    arabicProductName: 'مجموعة أثقال قابلة للتعديل',
    discountPercent: 25,
    expiresAt: DateTime.now().add(const Duration(hours: 5)),
  ),
  GroupBuyModel(
    id: 'gb7',
    code: 'GB-P55M',
    ownerName: 'Home Chefs',
    arabicOwnerName: 'طهاة المنزل',
    memberCount: 1,
    maxMembers: 10,
    isActive: true,
    productId: 'p9',
    productName: 'Ninja Air Fryer',
    arabicProductName: 'قلاية نينجا',
    discountPercent: 15,
    expiresAt: DateTime.now().add(const Duration(hours: 96)),
  ),
  GroupBuyModel(
    id: 'gb8',
    code: 'GB-C33X',
    ownerName: 'Coffee Lovers',
    arabicOwnerName: 'عشاق القهوة',
    memberCount: 10,
    maxMembers: 10,
    isActive: false,
    productId: 'p10',
    productName: 'Nespresso Vertuo',
    arabicProductName: 'نسبريسو فيرتو',
    discountPercent: 20,
    expiresAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];
