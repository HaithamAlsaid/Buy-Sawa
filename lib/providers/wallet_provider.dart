import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 150.00;
  final List<TransactionModel> _transactions = List.from(mockTransactions);

  double get balance => _balance;
  List<TransactionModel> get transactions => _transactions;

  void addCashback(double amount, String label) {
    _balance += amount;
    _transactions.insert(0, TransactionModel(
      id: DateTime.now().toString(),
      title: 'Cashback · $label',
      arabicTitle: 'استرداد نقدي · $label',
      subtitle: 'Just now · Cashback',
      arabicSubtitle: 'الآن · استرداد نقدي',
      amount: amount,
      type: TransactionType.cashback,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void addReferralBonus(double amount, String friendName) {
    _balance += amount;
    _transactions.insert(0, TransactionModel(
      id: DateTime.now().toString(),
      title: 'Referral Bonus · $friendName joined',
      arabicTitle: 'مكافأة دعوة · انضم $friendName',
      subtitle: 'Just now · Referral',
      arabicSubtitle: 'الآن · دعوة',
      amount: amount,
      type: TransactionType.referral,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void deduct(double amount, String orderId) {
    _balance -= amount;
    _transactions.insert(0, TransactionModel(
      id: DateTime.now().toString(),
      title: 'Order #$orderId',
      arabicTitle: 'طلب #$orderId',
      subtitle: 'Just now · Purchase',
      arabicSubtitle: 'الآن · شراء',
      amount: -amount,
      type: TransactionType.purchase,
      date: DateTime.now(),
    ));
    notifyListeners();
  }
}
