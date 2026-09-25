import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/monthly_plan_model.dart';
import '../../core/services/plan_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../../providers/wallet_provider.dart';
import '../profile/account_screen.dart';
import '../auth/login_screen.dart';
import '../wallet/wallet_screen.dart';

class PlanSubscribeSheet extends StatefulWidget {
  final MonthlyPlanModel plan;

  const PlanSubscribeSheet({super.key, required this.plan});

  static void show(BuildContext context, MonthlyPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanSubscribeSheet(plan: plan),
    );
  }

  @override
  State<PlanSubscribeSheet> createState() => _PlanSubscribeSheetState();
}

class _PlanSubscribeSheetState extends State<PlanSubscribeSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _subscribe() async {
    final token = await AuthService.getToken();
    final localizations = AppLocalizations.of(context);
    final isAr = localizations.locale.languageCode == 'ar';

    if (token == null) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'يرجى تسجيل الدخول أولاً للاشتراك في باقات VIP'
                : 'Please login first to subscribe to VIP plans',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await PlanService.subscribeToPlan(widget.plan.id);

    if (!mounted) return;

    setState(() => _isLoading = false);

    final messenger = ScaffoldMessenger.of(context);

    if (result['success'] == true) {
      // 1. Refresh wallet balance
      if (mounted) {
        context.read<WalletProvider>().fetchWallet();
      }
      
      // 2. Refresh active plan card if visible
      activeSubscriptionCardKey.currentState?.fetchSubscription();

      Navigator.pop(context, true); // Return true to indicate success
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تم الاشتراك بنجاح في ${widget.plan.name} 🎉'
                : 'Successfully subscribed to ${widget.plan.name} 🎉',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final serverError = result['error'];
      setState(() {
        _errorMessage = serverError ??
            (isAr
                ? 'حدث خطأ أثناء الاشتراك. تأكد من رصيد محفظتك.'
                : 'Failed to subscribe. Please check your wallet balance.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    final currency = isAr ? 'د.إ' : 'AED';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.primary, size: 48),
            ).animate().scale(delay: 100.ms, duration: 300.ms),

            const SizedBox(height: 16),

            // Title
            Text(
              widget.plan.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            // Description from API
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.plan.description.isNotEmpty
                    ? widget.plan.description
                    : (isAr
                        ? 'اشترك واحصل على رصيد يُضاف لمحفظتك فوراً للتسوق أو التبرع.'
                        : 'Subscribe and get wallet credit instantly for shopping or donations.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Price Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    isAr ? 'السعر المدفوع' : 'Amount You Pay',
                    '${widget.plan.price.toStringAsFixed(0)} $currency',
                    false,
                    icon: Icons.payment_rounded,
                    iconColor: const Color(0xFF64748B),
                  ),
                  if (widget.plan.additionalGiftPrice > 0) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),
                    _buildPriceRow(
                      isAr ? 'مبلغ هدية إضافي' : 'Bonus Gift Amount',
                      '+${widget.plan.additionalGiftPrice.toStringAsFixed(0)} $currency',
                      false,
                      icon: Icons.card_giftcard_rounded,
                      iconColor: Colors.green,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  _buildPriceRow(
                    isAr ? 'رصيد المحفظة الذي ستحصل عليه' : 'Wallet Credit You Get',
                    '${widget.plan.totalOrderAmount.toStringAsFixed(0)} $currency',
                    true,
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Real server error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_errorMessage != null && 
                (_errorMessage!.contains('غير كاف') || _errorMessage!.contains('Insufficient') || _errorMessage!.contains('رصيد')))
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close the Subscribe Sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                    label: Text(
                      isAr ? 'شحن المحفظة الآن' : 'Top Up Wallet Now',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isAr ? 'تأكيد الاشتراك' : 'Confirm Subscription',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    bool isTotal, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.textDark : Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
