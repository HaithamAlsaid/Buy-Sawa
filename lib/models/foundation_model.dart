class FoundationModel {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String slug;
  final String code;
  final String registrationNumber;
  final int activeCampaignsCount;

  FoundationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.slug,
    required this.code,
    required this.registrationNumber,
    required this.activeCampaignsCount,
  });

  factory FoundationModel.fromJson(Map<String, dynamic> json) {
    return FoundationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? 'https://via.placeholder.com/150',
      slug: json['slug']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      activeCampaignsCount: int.tryParse(json['active_campaigns_count']?.toString() ?? '0') ?? 0,
    );
  }
}
