// ─────────────────────────────────────────────────────────────────────────────
// ApiService — السيرفر الحقيقي بتاع BuySawa
// Base URL: http://dxbalpha.com/api/v1
// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  static const String baseUrl = 'https://dxbalpha.com/api/v1';

  // ─── Auth Endpoints ─────────────────────────────────────────
  static const String registerEndpoint  = '$baseUrl/users/auth/register';
  static const String loginEndpoint     = '$baseUrl/auth/login';
  static const String logoutEndpoint    = '$baseUrl/auth/logout';
  static const String meEndpoint        = '$baseUrl/auth/me';

  // ─── Password Endpoints ──────────────────────────────────────
  static const String forgotPasswordEndpoint  = '$baseUrl/auth/password/forgot';
  static const String changePasswordEndpoint  = '$baseUrl/auth/password/change';

  // ─── Profile Endpoints ──────────────────────────────────────
  static const String profileEndpoint   = '$baseUrl/profile/details';
  static const String avatarEndpoint    = '$baseUrl/profile/details/avatar';
  static const String favoritesEndpoint = '$baseUrl/profile/favorites';

  // ─── Products Endpoints ──────────────────────────────────────
  static const String productsEndpoint    = '$baseUrl/products';
  static String productDetailEndpoint(dynamic id) => '$baseUrl/products/$id';
  static String productVariationsEndpoint(dynamic id) => '$baseUrl/products/$id/variations';

  // ─── Contact & Support ──────────────────────────────────────
  static const String contactUsEndpoint     = '$baseUrl/contact-us/submit';
  static const String contactPurposesEndpoint = '$baseUrl/contact-us/purposes';
  static const String supportTicketsEndpoint  = '$baseUrl/support/tickets';

  // Settings 
  static const String settingsEndpoint      = '$baseUrl/settings';
  static const String userSettingsEndpoint  = '$baseUrl/settings/user';

  //Lang
  static const String langEndpoint        = '$baseUrl/lang';
  static const String langSwitchEndpoint  = '$baseUrl/lang/switch';

  // Notifications 
  static const String notificationsEndpoint = '$baseUrl/notifications';

  //  Headers Helper 
  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
