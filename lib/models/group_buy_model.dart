class GroupBuyModel {
  final String id;
  final String code;
  final String ownerName;
  final int memberCount;
  final int maxMembers;
  final bool isActive;
  final String productId;
  final String productName;
  final int discountPercent;
  final DateTime? expiresAt;

  GroupBuyModel({
    required this.id,
    required this.code,
    required this.ownerName,
    required this.memberCount,
    required this.maxMembers,
    required this.isActive,
    required this.productId,
    required this.productName,
    required this.discountPercent,
    this.expiresAt,
  });

  double get progressPercent => memberCount / maxMembers;
}

final List<GroupBuyModel> mockGroupBuys = [
  GroupBuyModel(
    id: 'gb1',
    code: 'GB-X72A',
    ownerName: 'هيثم الصياد',
    memberCount: 5,
    maxMembers: 10,
    isActive: true,
    productId: 'p1',
    productName: 'Sony WH-1000XM5',
    discountPercent: 15,
    expiresAt: DateTime.now().add(const Duration(hours: 36)),
  ),
  GroupBuyModel(
    id: 'gb2',
    code: 'GB-K91B',
    ownerName: 'Weekend Buyers',
    memberCount: 3,
    maxMembers: 10,
    isActive: true,
    productId: 'p3',
    productName: 'Nike Air Max 270',
    discountPercent: 10,
    expiresAt: DateTime.now().add(const Duration(hours: 12)),
  ),
  GroupBuyModel(
    id: 'gb3',
    code: 'GB-M44Z',
    ownerName: 'Beauty Box Crew',
    memberCount: 4,
    maxMembers: 10,
    isActive: false,
    productId: 'p5',
    productName: 'Glow Serum Premium',
    discountPercent: 12,
    expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
  ),
  GroupBuyModel(
    id: 'gb4',
    code: 'GB-R22F',
    ownerName: 'Gaming Squad',
    memberCount: 8,
    maxMembers: 10,
    isActive: true,
    productId: 'p6',
    productName: 'PlayStation 5 Pro',
    discountPercent: 20,
    expiresAt: DateTime.now().add(const Duration(hours: 48)),
  ),
  GroupBuyModel(
    id: 'gb5',
    code: 'GB-L99P',
    ownerName: 'Tech Geeks',
    memberCount: 2,
    maxMembers: 5,
    isActive: true,
    productId: 'p7',
    productName: 'MacBook Air M3',
    discountPercent: 10,
    expiresAt: DateTime.now().add(const Duration(hours: 72)),
  ),
  GroupBuyModel(
    id: 'gb6',
    code: 'GB-Q11A',
    ownerName: 'Fitness Junkies',
    memberCount: 9,
    maxMembers: 15,
    isActive: true,
    productId: 'p8',
    productName: 'Adjustable Dumbbells Set',
    discountPercent: 25,
    expiresAt: DateTime.now().add(const Duration(hours: 5)),
  ),
  GroupBuyModel(
    id: 'gb7',
    code: 'GB-P55M',
    ownerName: 'Home Chefs',
    memberCount: 1,
    maxMembers: 10,
    isActive: true,
    productId: 'p9',
    productName: 'Ninja Air Fryer',
    discountPercent: 15,
    expiresAt: DateTime.now().add(const Duration(hours: 96)),
  ),
  GroupBuyModel(
    id: 'gb8',
    code: 'GB-C33X',
    ownerName: 'Coffee Lovers',
    memberCount: 10,
    maxMembers: 10,
    isActive: false,
    productId: 'p10',
    productName: 'Nespresso Vertuo',
    discountPercent: 20,
    expiresAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];
