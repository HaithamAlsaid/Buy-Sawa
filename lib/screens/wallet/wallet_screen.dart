import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../models/transaction_model.dart';
import '../../providers/wallet_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ResponsiveWrapper(
        child: Stack(
          children: [
            // Teal Background
            Container(
              height: R.pad(context, 220),
              color: AppColors.primary,
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar replacement
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.pad(context, 24),
                      R.pad(context, 20),
                      R.pad(context, 24),
                      R.pad(context, 24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (AppLocalizations.of(context).locale.languageCode == 'en')
                          Text(
                            'My',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: R.sp(context, 14),
                            ),
                          ),
                        Text(
                          AppLocalizations.of(context).wallet,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.sp(context, 32),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balance Card
                  Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.pad(context, 20),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: R.pad(context, 140),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2230),
                            borderRadius: BorderRadius.circular(
                              R.r(context, 24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Right circle decoration
                              Positioned(
                                right: R.pad(context, -50),
                                top: R.pad(context, -30),
                                bottom: R.pad(context, -30),
                                child: Container(
                                  width: R.pad(context, 180),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B3931),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: EdgeInsets.all(R.pad(context, 24)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).availableBalance.toUpperCase(),
                                      style: TextStyle(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: R.sp(context, 11),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: R.pad(context, 8)),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: wallet.balance
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                color: const Color(0xFFF5A623),
                                                fontSize: R.sp(context, 40),
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' ${AppLocalizations.of(context).aed}',
                                              style: TextStyle(
                                                color: const Color(0xFF94A3B8),
                                                fontSize: R.sp(context, 14),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  SizedBox(height: R.pad(context, 32)),

                  // Transaction Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.pad(context, 24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).transactionHistory,
                          style: TextStyle(
                            fontSize: R.sp(context, 16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).seeAll,
                          style: TextStyle(
                            fontSize: R.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: R.pad(context, 16)),

                  // Transactions List
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: R.pad(context, 20),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(R.r(context, 24)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: wallet.transactions.isEmpty
                          ? _NoTransactions()
                          : ListView.separated(
                              padding: EdgeInsets.only(
                                top: R.pad(context, 8),
                                bottom: R.pad(context, 100),
                              ),
                              itemCount: wallet.transactions.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (_, i) {
                                return _TransactionTile(
                                      tx: wallet.transactions[i],
                                    )
                                    .animate(delay: (i * 50).ms)
                                    .fadeIn()
                                    .slideX(begin: 0.05, end: 0);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Transaction Tile ──────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('MMM d').format(tx.date);

    final now = DateTime.now();
    final diff = now.difference(tx.date).inDays;
    String dayStr = fmtDate;
    if (diff == 0 && now.day == tx.date.day) {
      dayStr = AppLocalizations.of(context).today;
    } else if (diff == 1 || (diff == 0 && now.day != tx.date.day)) {
      dayStr = AppLocalizations.of(context).yesterday;
    }

    final timeStr = DateFormat('HH:mm').format(tx.date);
    final typeName = tx.type.toString().split('.').last;
    final formattedType = typeName[0].toUpperCase() + typeName.substring(1);
    final subtitle = AppLocalizations.of(context).locale.languageCode == 'ar'
        ? tx.arabicSubtitle
        : '$dayStr · $timeStr · $formattedType';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tx.isCredit
                  ? const Color(0xFFE8FAF2)
                  : const Color(0xFFFFEEEF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: tx.isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).locale.languageCode == 'ar'
                      ? tx.arabicTitle
                      : tx.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tx.isCredit ? '+' : '−'}${tx.amount.toInt()} ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: tx.isCredit ? AppColors.success : AppColors.textDark,
                  ),
                ),
                TextSpan(
                  text: AppLocalizations.of(context).aed,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textLight,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).transactionHistory, // Re-using this since there isn't a specific no-transactions string
              style: TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
