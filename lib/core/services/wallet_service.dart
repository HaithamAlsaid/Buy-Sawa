// ─────────────────────────────────────────────────────────────────────────────
// WalletService — Real API Integration
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/transaction_model.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';
import 'package:flutter/foundation.dart';

class WalletData {
  final double balance;
  final List<TransactionModel> transactions;
  const WalletData({required this.balance, required this.transactions});
}

class WalletService {
  // ─── Get Wallet Balance & Transactions ───────────────────────
  static Future<WalletData?> getWallet() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    try {
      // 1. Get Balance
      final balanceRes = await http.get(
        Uri.parse(ApiService.walletEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      // 2. Get Transactions
      final txRes = await http.get(
        Uri.parse(ApiService.walletTransactionsEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (balanceRes.statusCode == 200 && txRes.statusCode == 200) {
        final bData = jsonDecode(balanceRes.body);
        final tData = jsonDecode(txRes.body);
        
        final balance = double.tryParse(bData['balance']?.toString() ?? '0') ?? 0.0;
        
        final rawTx = tData['data'] is List ? tData['data'] : (tData is List ? tData : []);
        final transactions = (rawTx as List)
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return WalletData(
          balance: balance,
          transactions: transactions,
        );
      }
    } catch (e) {
      debugPrint('Wallet fetch error: $e');
    }
    return null;
  }

  // ─── Top Up Wallet ───────────────────────────────────────────
  static Future<bool> topUp({required double amount, required String provider}) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse(ApiService.walletTopUpEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'amount': amount,
          'provider': provider,
        }),
      ).timeout(const Duration(seconds: 15));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Wallet top-up error: $e');
    }
    return false;
  }
}
