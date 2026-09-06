// ─────────────────────────────────────────────────────────────────────────────
// ApiService — BuySawa backend endpoints (buysawa.com)
// Base URL: https://buysawa.com/api/v1
// Source: Buysawa.postman_collection.json (complete)
// ─────────────────────────────────────────────────────────────────────────────
//users/auth/register
class ApiService {
  static const String baseUrl = 'https://buysawa.com/api/v1';

  // ─── Auth 
  static const String registerEndpoint = '$baseUrl/users/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String logoutEndpoint = '$baseUrl/auth/logout';
  static const String meEndpoint = '$baseUrl/auth/me';

  // ─── Social Login (Google OAuth) 
  static const String googleRedirectEndpoint =
      '$baseUrl/auth/providers/google/redirect?client=mobile';

  // ─── MFA 
  static const String mfaSetupEndpoint = '$baseUrl/auth/mfa/setup';
  static const String mfaConfirmEndpoint = '$baseUrl/auth/mfa/confirm';
  static const String mfaVerifyEndpoint = '$baseUrl/auth/mfa/verify';
  static const String mfaDisableEndpoint = '$baseUrl/auth/mfa/disable';

  // ─── Password 
  static const String forgotPasswordEndpoint = '$baseUrl/auth/password/forgot';
  static const String changePasswordEndpoint = '$baseUrl/auth/password/change';

  // ─── Email Verification 
  static const String emailResendEndpoint = '$baseUrl/auth/email/resend';

  // ─── Profile
  static const String profileEndpoint = '$baseUrl/profile/details';
  static const String avatarEndpoint = '$baseUrl/profile/details/avatar';

  // ─── Notifications
  static const String notificationsEndpoint = '$baseUrl/profile/notifications';
  static const String notificationsUnreadEndpoint =
      '$baseUrl/profile/notifications/unread-count';
  static const String notificationsReadAllEndpoint =
      '$baseUrl/profile/notifications/read-all';
  static String notificationReadEndpoint(dynamic id) =>
      '$baseUrl/profile/notifications/$id/read';
  static String notificationDeleteEndpoint(dynamic id) =>
      '$baseUrl/profile/notifications/$id';

  // ─── Wallet
  static const String walletEndpoint = '$baseUrl/user/wallet';
  static const String walletTransactionsEndpoint = '$baseUrl/user/wallet/transactions';
  static const String walletTopUpEndpoint = '$baseUrl/user/wallet/top-up';

  // ─── Categories 

  // ─── Favorites 
  static const String favoritesEndpoint = '$baseUrl/profile/favorites';
  static String removeFavoriteEndpoint(dynamic id) =>
      '$baseUrl/profile/favorites/$id';

  // ─── Addresses 
  static const String addressesEndpoint = '$baseUrl/profile/addresses';
  static String addressEndpoint(dynamic id) => '$baseUrl/profile/addresses/$id';
  static String addressDefaultEndpoint(dynamic id) =>
      '$baseUrl/profile/addresses/$id/default';

  // ─── Products 
  static const String productsEndpoint = '$baseUrl/products';
  static String productDetailEndpoint(dynamic id) => '$baseUrl/products/$id';
  static String productVariationsEndpoint(dynamic id) =>
      '$baseUrl/products/$id/variations';
  static String productVariationEndpoint(dynamic id, dynamic vid) =>
      '$baseUrl/products/$id/variations/$vid';
  static String productAccessoriesEndpoint(dynamic id) =>
      '$baseUrl/products/$id/accessories';

  // ─── Cart 
  static const String cartEndpoint = '$baseUrl/cart';
  static const String cartItemsEndpoint = '$baseUrl/cart/items';
  static String cartItemEndpoint(dynamic id) => '$baseUrl/cart/items/$id';
  static const String cartTransferWishlistEndpoint =
      '$baseUrl/cart/transfer-wishlist';

  // ─── Wishlists (typo in API: "whishlists") 
  static const String wishlistsEndpoint = '$baseUrl/whishlists';
  static String wishlistEndpoint(dynamic id) => '$baseUrl/whishlists/$id';
  static String wishlistShareEndpoint(dynamic id) =>
      '$baseUrl/whishlists/$id/share';
  static String wishlistItemsEndpoint(dynamic id) =>
      '$baseUrl/whishlists/$id/items';
  static String wishlistItemEndpoint(dynamic id, dynamic itemId) =>
      '$baseUrl/whishlists/$id/items/$itemId';
  static String sharedWishlistEndpoint(String token) =>
      '$baseUrl/whishlists/shared/$token';

  // ─── Orders 
  static const String ordersEndpoint = '$baseUrl/orders';
  static String orderEndpoint(dynamic id) => '$baseUrl/orders/$id';
  static const String checkoutEndpoint = '$baseUrl/orders/checkout';
  static String cancelOrderEndpoint(dynamic id) => '$baseUrl/orders/$id/cancel';
  static String reorderEndpoint(dynamic id) => '$baseUrl/orders/$id/reorder';

  // ─── Payments
  static const String paymentMethodsEndpoint = '$baseUrl/payments/methods';
  static const String paymentsEndpoint = '$baseUrl/payments';
  static String paymentEndpoint(dynamic id) => '$baseUrl/payments/$id';
  static String retryPaymentEndpoint(dynamic id) =>
      '$baseUrl/payments/$id/retry';

  // ─── Currencies 
  static const String currenciesEndpoint = '$baseUrl/currencies';
  static const String currentCurrencyEndpoint = '$baseUrl/currencies/current';
  static const String switchCurrencyEndpoint = '$baseUrl/currencies/switch';

  // ─── Countries
  static const String countriesEndpoint = '$baseUrl/countries';
  static const String phoneCodesEndpoint = '$baseUrl/countries-phone-codes';

  // ─── Comparisons 
  static String compareEndpoint(dynamic id1, dynamic id2, String modelKey) =>
      '$baseUrl/comparisons/compare/$id1/$id2?model_key=$modelKey';

  // ─── Support 
  static const String supportTypesEndpoint = '$baseUrl/support/types';
  static const String supportTicketsEndpoint = '$baseUrl/support/tickets';
  static String supportTicketEndpoint(dynamic id) =>
      '$baseUrl/support/tickets/$id';
  static String supportTicketReplyEndpoint(dynamic id) =>
      '$baseUrl/support/tickets/$id/reply';

  // ─── Contact Us 
  static const String contactPurposesEndpoint = '$baseUrl/contact-us/purposes';
  static const String contactUsEndpoint = '$baseUrl/contact-us/submit';

  // ─── Settings 
  static const String platformSettingsEndpoint = '$baseUrl/settings';
  static const String settingsGroupedEndpoint = '$baseUrl/settings/grouped';
  static const String userSettingsEndpoint = '$baseUrl/settings/user';
  static const String userSettingsGrouped = '$baseUrl/settings/user/grouped';
  static String userSettingEndpoint(String key) =>
      '$baseUrl/settings/user/$key';
  static const String userSettingsResetEndpoint =
      '$baseUrl/settings/user/reset';

  // ─── Lang 
  static const String langEndpoint = '$baseUrl/lang';
  static const String langCurrentEndpoint = '$baseUrl/lang/current';
  static const String langSwitchEndpoint = '$baseUrl/lang/switch';

  // ─── Headers Helper 
  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
