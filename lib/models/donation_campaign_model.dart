class DonationCampaignModel {
  final String id;
  final String slug;
  final String title;
  final String arabicTitle;
  final String description;
  final String arabicDescription;
  final double targetAmount;
  final double collectedAmount;
  final DateTime? endDate;
  final int? daysFromApi;
  final String foundationName;
  final String imageUrl;

  DonationCampaignModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.arabicDescription,
    required this.targetAmount,
    required this.collectedAmount,
    this.endDate,
    this.daysFromApi,
    required this.foundationName,
    required this.imageUrl,
  });

  factory DonationCampaignModel.fromJson(Map<String, dynamic> json) {
    var imgUrl = json['cover_image_url'] ?? json['image_url'] ?? json['image'] ?? json['banner_url'] ?? '';
    if (imgUrl.isNotEmpty && !imgUrl.toString().startsWith('http')) {
      String path = imgUrl.toString();
      if (path.startsWith('/')) path = path.substring(1);
      imgUrl = 'https://buysawa.com/$path';
    }

    final t = json['title']?.toString() ?? '';
    final d = json['description']?.toString() ?? '';

    return DonationCampaignModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: t,
      arabicTitle: json['title_ar']?.toString() ?? json['arabic_title']?.toString() ?? t,
      description: d,
      arabicDescription: json['description_ar']?.toString() ?? json['arabic_description']?.toString() ?? d,
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      collectedAmount: ((json['raised_amount'] ?? json['collected_amount']) as num?)?.toDouble() ?? 0.0,
      endDate: json['ends_at'] != null 
          ? DateTime.tryParse(json['ends_at'].toString()) 
          : (json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null),
      daysFromApi: json['days_remaining'] as int?,
      foundationName: (json['foundation'] is Map && json['foundation']['name'] != null)
          ? (json['foundation']['name_ar'] ?? json['foundation']['name']).toString()
          : (json['foundation_name']?.toString() ?? ''),
      imageUrl: imgUrl.toString(),
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
    if (daysFromApi != null) return daysFromApi;
    if (endDate == null) return null;
    final now = DateTime.now();
    final difference = endDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }
}
