// ─────────────────────────────────────────────────────────────────────────────
// AddressModel — بيانات العنوان من الـ API
// ─────────────────────────────────────────────────────────────────────────────

class AddressModel {
  final String id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String? postalCode;
  final String? phoneCode;
  final String? phoneNumber;
  final bool isDefault;
  final String? instructions;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
    this.phoneCode,
    this.phoneNumber,
    this.isDefault = false,
    this.instructions,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AddressModel(
      id: (data['id'] ?? '').toString(),
      label: data['label'] ?? data['name'] ?? 'Address',
      addressLine1: data['address_line_1'] ?? data['address'] ?? '',
      addressLine2: data['address_line_2']?.toString(),
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postal_code']?.toString(),
      phoneCode: data['phone_code']?.toString(),
      phoneNumber: data['phone_number']?.toString(),
      isDefault: data['is_default'] == true || data['is_default'] == 1,
      instructions: data['instructions']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  String get fullAddress {
    final parts = [addressLine1, if (addressLine2 != null) addressLine2!, city, state, country];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  String get phone => '${phoneCode ?? ''} ${phoneNumber ?? ''}'.trim();
}
