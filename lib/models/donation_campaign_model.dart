class DonationCampaignModel {
  final String id;
  final String slug;
  final String title;
  final String description;
  final double targetAmount;
  final double collectedAmount;
  final DateTime? endDate;
  final String foundationName;
  final String imageUrl;

  DonationCampaignModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.collectedAmount,
    this.endDate,
    required this.foundationName,
    required this.imageUrl,
  });

  factory DonationCampaignModel.fromJson(Map<String, dynamic> json) {
    return DonationCampaignModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      collectedAmount: (json['collected_amount'] as num?)?.toDouble() ?? 0.0,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      foundationName: (json['foundation'] is Map && json['foundation']['name'] != null)
          ? json['foundation']['name'].toString()
          : (json['foundation_name']?.toString() ?? ''),
      imageUrl: json['image_url']?.toString() ?? 'https://via.placeholder.com/600x300?text=Donation',
    );
  }

  // Calculate percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    final percent = collectedAmount / targetAmount;
    return percent > 1.0 ? 1.0 : percent; // Cap at 100%
  }

  // Calculate remaining days
  int? get remainingDays {
    if (endDate == null) return null;
    final now = DateTime.now();
    final difference = endDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }
}
