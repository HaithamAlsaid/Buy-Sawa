enum TransactionType { cashback, referral, purchase, groupReward }

class TransactionModel {
  final String id;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String arabicSubtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.subtitle,
    required this.arabicSubtitle,
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
    arabicTitle: 'استرداد نقدي · سماعات سوني',
    subtitle: 'Today · 14:22 · Cashback',
    arabicSubtitle: 'اليوم · 14:22 · استرداد نقدي',
    amount: 65,
    type: TransactionType.cashback,
    date: DateTime.now(),
  ),
  TransactionModel(
    id: 't2',
    title: 'Referral Bonus · Ahmed joined',
    arabicTitle: 'مكافأة دعوة · انضم أحمد',
    subtitle: 'Yesterday · Referral',
    arabicSubtitle: 'أمس · دعوة',
    amount: 25,
    type: TransactionType.referral,
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TransactionModel(
    id: 't3',
    title: 'Order #SW-29412',
    arabicTitle: 'طلب #SW-29412',
    subtitle: 'Jun 2 · Purchase',
    arabicSubtitle: '2 يونيو · شراء',
    amount: -549,
    type: TransactionType.purchase,
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  TransactionModel(
    id: 't4',
    title: 'Group Deal Reward · Weekend S...',
    arabicTitle: 'مكافأة صفقة جماعية · عروض العطلة...',
    subtitle: 'Jun 4 · Group',
    arabicSubtitle: '4 يونيو · صفقة جماعية',
    amount: 120,
    type: TransactionType.groupReward,
    date: DateTime.now().subtract(const Duration(days: 5)),
  ),
  TransactionModel(
    id: 't5',
    title: 'Cashback · Glow Serum',
    arabicTitle: 'استرداد نقدي · سيروم نضارة',
    subtitle: 'May 30 · Cashback',
    arabicSubtitle: '30 مايو · استرداد نقدي',
    amount: 18,
    type: TransactionType.cashback,
    date: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
