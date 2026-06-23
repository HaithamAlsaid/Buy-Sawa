enum TransactionType { cashback, referral, purchase, groupReward }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
  });

  bool get isCredit => amount > 0;
}

final List<TransactionModel> mockTransactions = [
  TransactionModel(
    id: 't1',
    title: 'Cashback · Sony Headphones',
    subtitle: 'Today · 14:22 · Cashback',
    amount: 65,
    type: TransactionType.cashback,
    date: DateTime.now(),
  ),
  TransactionModel(
    id: 't2',
    title: 'Referral Bonus · Ahmed joined',
    subtitle: 'Yesterday · Referral',
    amount: 25,
    type: TransactionType.referral,
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TransactionModel(
    id: 't3',
    title: 'Order #SW-29412',
    subtitle: 'Jun 2 · Purchase',
    amount: -549,
    type: TransactionType.purchase,
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  TransactionModel(
    id: 't4',
    title: 'Group Deal Reward · Weekend S...',
    subtitle: 'Jun 4 · Group',
    amount: 120,
    type: TransactionType.groupReward,
    date: DateTime.now().subtract(const Duration(days: 5)),
  ),
  TransactionModel(
    id: 't5',
    title: 'Cashback · Glow Serum',
    subtitle: 'May 30 · Cashback',
    amount: 18,
    type: TransactionType.cashback,
    date: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
