import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class HowToBenefitScreen extends StatelessWidget {
  const HowToBenefitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isAr ? 'كيف تستفيد من باي سوا؟' : 'How to benefit from Buy Sawa?',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0F2D3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    isAr
                        ? 'أهلاً بك في عالم التوفير والمكافآت!'
                        : 'Welcome to the world of savings and rewards!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr
                        ? 'باي سوا مش مجرد تطبيق تسوق، ده نظام متكامل مصمم عشان يوفر فلوسك ويرجعلك كاش باك على مشترياتك.'
                        : 'Buy Sawa is not just a shopping app, it\'s an integrated system designed to save your money and give you cashback.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              isAr ? 'أهم المميزات وكيفية الاستفادة:' : 'Top Features & How to Use Them:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              icon: Icons.workspace_premium_rounded,
              iconColor: Colors.amber,
              title: isAr ? '1. باقات التوفير (VIP Plans)' : '1. VIP Savings Plans',
              description: isAr
                  ? 'اشترك في باقة تدفع فيها مبلغ محدد (مثلاً 500)، وهينزلك في محفظتك رصيد أكبر (مثلاً 600)! تقدر تستخدم الرصيد ده في شراء أي منتج أو التبرع بيه.'
                  : 'Subscribe to a plan by paying a specific amount (e.g. 500), and get a larger credit in your wallet (e.g. 600)! Use it to shop or donate.',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.primary,
              title: isAr ? '2. المحفظة الإلكترونية' : '2. E-Wallet',
              description: isAr
                  ? 'رصيدك في المحفظة هو فلوسك الحقيقية. لو اشتريت منتج بـ 100 ومعاك 50 في المحفظة، هتدفع 50 بس والباقي هيتخصم من المحفظة تلقائياً.'
                  : 'Your wallet balance is real money. If you buy a product for 100 and have 50 in your wallet, you only pay 50 and the rest is deducted automatically.',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.groups_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: isAr ? '3. الشراء الجماعي (Group Buy)' : '3. Group Buy',
              description: isAr
                  ? 'شارك المنتجات مع أصحابك واشتروا مع بعض عشان تاخدوا خصومات ضخمة بتوصل لـ 50% على أسعار الجملة!'
                  : 'Share products with friends and buy together to get huge discounts up to 50% off wholesale prices!',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.volunteer_activism_rounded,
              iconColor: const Color(0xFFEF4444),
              title: isAr ? '4. التبرع السلس' : '4. Seamless Donation',
              description: isAr
                  ? 'تقدر تتبرع بجزء من رصيد محفظتك لحملات التبرع الموثوقة الموجودة في التطبيق بضغطة زر وبدون رسوم إضافية.'
                  : 'You can donate a portion of your wallet balance to trusted campaigns available in the app with one click and no extra fees.',
            ),

            _buildFeatureCard(
              context,
              icon: Icons.share_rounded,
              iconColor: const Color(0xFF0EA5E9),
              title: isAr ? '5. اربح من دعوة أصدقائك' : '5. Refer & Earn',
              description: isAr
                  ? 'شارك روابط المنتجات مع أصحابك أو ادعهم لتحميل التطبيق، واكسب رصيد إضافي في محفظتك على كل شخص يشترك أو يشتري عن طريقك!'
                  : 'Share product links with your friends or invite them to download the app, and earn extra wallet credit for everyone who joins or buys through you!',
            ),
            _buildFeatureCard(
              context,
              icon: Icons.local_shipping_rounded,
              iconColor: const Color(0xFFF97316),
              title: isAr ? '6. شحن سريع ومضمون' : '6. Fast & Secure Delivery',
              description: isAr
                  ? 'استمتع بتجربة توصيل سريعة وموثوقة لجميع مشترياتك، مع إمكانية تتبع طلباتك خطوة بخطوة من التطبيق.'
                  : 'Enjoy a fast and reliable delivery experience for all your purchases, with the ability to track your orders step by step from the app.',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
