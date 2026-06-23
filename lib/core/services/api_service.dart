// ─────────────────────────────────────────────────────────────────────────────
// ApiService — المكان الوحيد الذي يحتوي على baseUrl
// لما يجهز الـ API: غيّر baseUrl بس وكل الأبلكيشن هيشتغل
// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  // ✏️ غيّر السطر ده لما يجهز الـ API
  static const String baseUrl = 'https://api.buysawa.com/v1';

  // ─── Endpoints ──────────────────────────────────────────────
  static const String loginEndpoint       = '$baseUrl/auth/login';
  static const String registerEndpoint    = '$baseUrl/auth/register';
  static const String logoutEndpoint      = '$baseUrl/auth/logout';
  static const String profileEndpoint     = '$baseUrl/auth/profile';

  static const String productsEndpoint    = '$baseUrl/products';
  static const String categoriesEndpoint  = '$baseUrl/categories';

  static const String walletEndpoint      = '$baseUrl/wallet';
  static const String transactionsEndpoint= '$baseUrl/wallet/transactions';

  static const String groupsEndpoint      = '$baseUrl/groups';

  static const String settingsEndpoint       = '$baseUrl/settings';
  static const String notificationsEndpoint  = '$baseUrl/notifications'; // ← الإشعارات الحقيقية

  // ─── Headers Helper ─────────────────────────────────────────
  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
