import 'package:buysawa/screens/orders/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/order_model.dart';
import '../../core/utils/responsive.dart';
import '../../core/localization/app_localizations.dart';
import '../main/main_screen.dart'; // Correct main screen

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel? order;

  const OrderSuccessScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.pad(context, 24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Animated Checkmark ─────────────────────────────────────
              Container(
                width: R.pad(context, 100),
                height: R.pad(context, 100),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: R.pad(context, 70),
                    height: R.pad(context, 70),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: R.icon(context, 40),
                    ),
                  ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ),
              ).animate().fade(duration: 400.ms).scale(duration: 400.ms),

              SizedBox(height: R.pad(context, 32)),

              // ── Title ──────────────────────────────────────────────────
              Text(
                isAr ? 'تم تقديم الطلب بنجاح!' : 'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(context, 22),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: isAr ? 0 : -0.5,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: R.pad(context, 12)),

              // ── Subtitle ───────────────────────────────────────────────
              Text(
                isAr
                    ? 'شكراً لتسوقك معنا، سنقوم بمعالجة طلبك قريباً.'
                    : 'Thank you for shopping with us, your order will be processed soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(context, 15),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: R.pad(context, 32)),

              // ── Order Info Card 
              if (order != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(R.pad(context, 20)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(R.r(context, 16)),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isAr ? 'رقم الطلب' : 'Order Number',
                        style: TextStyle(
                          fontSize: R.sp(context, 13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: R.pad(context, 8)),
                      Text(
                        '#${order!.id}',
                        style: TextStyle(
                          fontSize: R.sp(context, 20),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: R.pad(context, 48)),

              // ── Actions 
              // View Orders Button
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 54),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Home, and push My Orders on top
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                            );
                          });
                          return const MainScreen();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(context, 16)),
                    ),
                  ),
                  child: Text(
                    isAr ? 'تتبع الطلب' : 'Track Order',
                    style: TextStyle(
                      fontSize: R.sp(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fade(delay: 700.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: R.pad(context, 16)),

              // Continue Shopping Button
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 54),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(context, 16)),
                    ),
                  ),
                  child: Text(
                    isAr ? 'العودة للتسوق' : 'Continue Shopping',
                    style: TextStyle(
                      fontSize: R.sp(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fade(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
