class DonorModel {
  final String name;
  final double amount;
  final bool isAnonymous;
  final DateTime? date;

  DonorModel({
    required this.name,
    required this.amount,
    this.isAnonymous = false,
    this.date,
  });

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    final bool isAnon = json['is_anonymous'] == true || json['is_anonymous'] == 1 || json['is_anonymous'] == '1';
    return DonorModel(
      name: isAnon ? '' : (json['donor_name']?.toString() ?? 'فاعل خير'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isAnonymous: isAnon,
      date: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
