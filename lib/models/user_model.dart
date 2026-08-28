class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String birthdate;
  final String referralCode;
  final String? avatarUrl;
  final double walletBalance;
  final int friendsReferred;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthdate,
    required this.referralCode,
    this.avatarUrl,
    this.walletBalance = 0,
    this.friendsReferred = 0,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (fullName.length >= 2) return fullName.substring(0, 2).toUpperCase();
    return fullName.toUpperCase();
  }

  /// Safe parser — handles int/String ids, name/full_name, missing fields
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Laravel returns id as int — handle both
      id: json['id']?.toString() ?? '',
      // Backend may use 'name' or 'full_name'
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      birthdate: (json['birthdate'] ?? json['date_of_birth'] ?? '').toString(),
      referralCode: (json['referral_code'] ?? '').toString(),
      // Avatar might be full URL or relative path
      avatarUrl: json['avatar_url'] ?? json['avatar'] ?? json['profile_image'],
      walletBalance:
          (json['wallet_balance'] ?? json['balance'] as num?)?.toDouble() ?? 0.0,
      friendsReferred:
          (json['friends_referred'] ?? json['referrals_count'] ?? 0) as int? ?? 0,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? birthdate,
    String? avatarUrl,
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      friendsReferred: friendsReferred ?? this.friendsReferred,
    );
  }
}
