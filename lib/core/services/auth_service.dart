// ─────────────────────────────────────────────────────────────────────────────
// AuthService — شغال بـ Mock Data دلوقتي
// لما يجهز الـ API: شيل الـ mock وفك تعليق الـ http calls
// ─────────────────────────────────────────────────────────────────────────────
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import 'secure_storage_service.dart';

class AuthResult {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? error;
  const AuthResult({this.success = false, this.token, this.user, this.error});
}

class AuthService {
  // ─── Token Management ────────────────────────────────────────
  static Future<String?> getToken() => SecureStorageService.getToken();

  static Future<void> saveToken(String token) => SecureStorageService.saveToken(token);

  static Future<void> clearToken() => SecureStorageService.clearToken();

  // ─── Login ───────────────────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<AuthResult> login(String email, String password) async {
  //   final res = await http.post(
  //     Uri.parse(ApiService.loginEndpoint),
  //     headers: ApiService.headers(),
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body);
  //     final token = data['token'];
  //     final user = UserModel.fromJson(data['user']);
  //     await saveToken(token);
  //     return AuthResult(success: true, token: token, user: user);
  //   }
  //   return AuthResult(success: false, error: jsonDecode(res.body)['message']);
  // }

  // MOCK (remove when API is ready):
  static Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (email.isNotEmpty && password.length >= 6) {
      const mockToken = 'mock_token_12345';
      await saveToken(mockToken);
      return AuthResult(
        success: true,
        token: mockToken,
        user: UserModel(
          id: 'u1',
          fullName: 'هيثم الصيد',
          email: email,
          phone: '+971 50 123 4567',
          birthdate: '15 / 04 / 1992',
          referralCode: 'HAITHAM25',
          walletBalance: 150.00,
          friendsReferred: 3,
        ),
      );
    }
    return const AuthResult(success: false, error: 'Invalid email or password');
  }

  //Register 
  // REAL API (uncomment when API is ready):
  // static Future<AuthResult> register({
  //   required String fullName,
  //   required String email,
  //   required String password,
  //   required String phone,
  //   String? referralCode,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse(ApiService.registerEndpoint),
  //     headers: ApiService.headers(),
  //     body: jsonEncode({
  //       'full_name': fullName,
  //       'email': email,
  //       'password': password,
  //       'phone': phone,
  //       if (referralCode != null && referralCode.isNotEmpty)
  //         'referral_code': referralCode,
  //     }),
  //   );
  //   if (res.statusCode == 201) {
  //     final data = jsonDecode(res.body);
  //     final token = data['token'];
  //     final user = UserModel.fromJson(data['user']);
  //     await saveToken(token);
  //     return AuthResult(success: true, token: token, user: user);
  //   }
  //   return AuthResult(success: false, error: jsonDecode(res.body)['message']);
  // }

  // MOCK (remove when API is ready):
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? referralCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    const mockToken = 'mock_token_new_user';
    await saveToken(mockToken);
    return AuthResult(
      success: true,
      token: mockToken,
      user: UserModel(
        id: 'u_new_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        email: email,
        phone: phone,
        birthdate: '',
        referralCode: 'SAWA${DateTime.now().millisecond}',
        walletBalance: referralCode != null && referralCode.isNotEmpty ? 15.0 : 0.0,
        friendsReferred: 0,
      ),
    );
  }

  // ─── Logout ──────────────────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<void> logout() async {
  //   final token = await getToken();
  //   await http.post(
  //     Uri.parse(ApiService.logoutEndpoint),
  //     headers: ApiService.headers(token: token),
  //   );
  //   await clearToken();
  // }

  // MOCK (remove when API is ready):
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await clearToken();
  }

  // ─── Update Profile ──────────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<UserModel?> updateProfile({required String fullName, required String birthdate}) async {
  //   final token = await getToken();
  //   final res = await http.put(
  //     Uri.parse(ApiService.profileEndpoint),
  //     headers: ApiService.headers(token: token),
  //     body: jsonEncode({'fullName': fullName, 'birthdate': birthdate}),
  //   );
  //   if (res.statusCode == 200) return UserModel.fromJson(jsonDecode(res.body)['user']);
  //   return null;
  // }

  // MOCK:
  static Future<bool> updateProfile({
    required String fullName,
    required String birthdate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
