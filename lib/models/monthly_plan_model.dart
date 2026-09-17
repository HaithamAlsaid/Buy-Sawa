class MonthlyPlanModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double additionalGiftPrice;
  final double totalOrderAmount;

  MonthlyPlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.additionalGiftPrice,
    required this.totalOrderAmount,
  });

  factory MonthlyPlanModel.fromJson(Map<String, dynamic> json) {
    return MonthlyPlanModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      additionalGiftPrice: (json['additional_gift_price'] ?? 0).toDouble(),
      totalOrderAmount: (json['total_order_amount'] ?? 0).toDouble(),
    );
  }
}
