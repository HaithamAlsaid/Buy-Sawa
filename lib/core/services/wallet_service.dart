// ─────────────────────────────────────────────────────────────────────────────
// WalletService — شغال بـ Mock Data دلوقتي
// لما يجهز الـ API: شيل الـ mock وفك تعليق الـ http calls
// ─────────────────────────────────────────────────────────────────────────────
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../../models/transaction_model.dart';
// import 'api_service.dart';
// import 'auth_service.dart';

class WalletData {
  final double balance;
  final List<TransactionModel> transactions;
  const WalletData({required this.balance, required this.transactions});
}

class WalletService {
  // ─── Get Wallet ──────────────────────────────────────────────
  // REAL API (uncomment when API is ready):
  // static Future<WalletData?> getWallet() async {
  //   final token = await AuthService.getToken();
  //   final res = await http.get(
  //     Uri.parse(ApiService.walletEndpoint),
  //     headers: ApiService.headers(token: token),
  //   );
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body);
  //     return WalletData(
  //       balance: (data['balance'] as num).toDouble(),
  //       transactions: (data['transactions'] as List)
  //           .map((e) => TransactionModel.fromJson(e))
  //           .toList(),
  //     );
  //   }
  //   return null;
  // }

  // MOCK (remove when API is ready):
  static Future<WalletData> getWallet() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return WalletData(
      balance: 150.00,
      transactions: List.from(mockTransactions),
    );
  }
}
