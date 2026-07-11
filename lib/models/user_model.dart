class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String birthdate;
  final String referralCode;
  final double walletBalance;
  final int friendsReferred;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthdate,
    required this.referralCode,
    this.walletBalance = 0,
    this.friendsReferred = 0,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      birthdate: json['birthdate'] as String? ?? '',
      referralCode: json['referral_code'] as String? ?? '',
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      friendsReferred: json['friends_referred'] as int? ?? 0,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? birthdate,
    double? walletBalance,
    int? friendsReferred,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone,
      birthdate: birthdate ?? this.birthdate,
      referralCode: referralCode,
      walletBalance: walletBalance ?? this.walletBalance,
      friendsReferred: friendsReferred ?? this.friendsReferred,
    );
  }
}
