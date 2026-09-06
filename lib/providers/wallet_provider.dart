import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../core/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _token;

  double get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void setToken(String? token) {
    _token = token;
    if (token != null) {
      fetchWallet();
    } else {
      _balance = 0.0;
      _transactions.clear();
      notifyListeners();
    }
  }

  Future<void> fetchWallet() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    final data = await WalletService.getWallet();
    if (data != null) {
      _balance = data.balance;
      _transactions = data.transactions;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> topUpWallet(double amount, String provider) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();

    final success = await WalletService.topUp(amount: amount, provider: provider);
    if (success) {
      // Re-fetch wallet to get updated balance and new transaction
      await fetchWallet();
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
