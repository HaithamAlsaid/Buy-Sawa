class DonationRecordModel {
  final String id;
  final String campaignName;
  final double amount;
  final String status;
  final DateTime? createdAt;
  final String? paymentGateway;

  DonationRecordModel({
    required this.id,
    required this.campaignName,
    required this.amount,
    required this.status,
    this.createdAt,
    this.paymentGateway,
  });

  factory DonationRecordModel.fromJson(Map<String, dynamic> json) {
    return DonationRecordModel(
      id: json['id']?.toString() ?? '',
      campaignName: json['campaign_name']?.toString() ?? (json['campaign']?['title']?.toString() ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      paymentGateway: json['payment_gateway']?.toString(),
    );
  }
}
