import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../models/monthly_plan_model.dart';
import '../../core/services/plan_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

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

  Future<void> _subscribe() async {
    final token = await AuthService.getToken();
    final localizations = AppLocalizations.of(context);
    
    if (token == null) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context); // Close the sheet
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            localizations.locale.languageCode == 'ar'
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

    setState(() => _isLoading = true);
    
    final success = await PlanService.subscribeToPlan(widget.plan.id);
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    final messenger = ScaffoldMessenger.of(context);
    
    if (success) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            localizations.locale.languageCode == 'ar'
                ? 'تم الاشتراك بنجاح في ${widget.plan.name} 🎉'
                : 'Successfully subscribed to ${widget.plan.name} 🎉',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            localizations.locale.languageCode == 'ar'
                ? 'حدث خطأ أثناء الاشتراك. تأكد من رصيد محفظتك.'
                : 'Failed to subscribe. Check your wallet balance.',
          ),
          backgroundColor: Colors.red,
        ),
      );
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
      padding: const EdgeInsets.all(24).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
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
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 48),
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
          
          // Description
          Text(
            isAr
                ? 'استمتع بمميزات حصرية عند الاشتراك في هذه الباقة. سيتم خصم المبلغ من رصيد محفظتك.'
                : 'Enjoy exclusive benefits when you subscribe. The amount will be deducted from your wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Price Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                  isAr ? 'سعر الباقة' : 'Plan Price',
                  '${widget.plan.price} $currency',
                  false,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildPriceRow(
                  isAr ? 'رسوم إضافية' : 'Additional Fee',
                  '${widget.plan.additionalGiftPrice} $currency',
                  false,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildPriceRow(
                  isAr ? 'الإجمالي' : 'Total',
                  '${widget.plan.totalOrderAmount} $currency',
                  true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
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
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
    );
  }

  Widget _buildPriceRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.textDark : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            color: isTotal ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
