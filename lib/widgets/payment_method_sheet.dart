import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class PaymentMethodSheet extends StatefulWidget {
  final double totalAmount;
  const PaymentMethodSheet({super.key, required this.totalAmount});

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  int _selectedIndex = -1;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open payment page')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paymentMethods = [
      {
        'name': 'Tabby',
        'subtitle': AppLocalizations.of(context).payIn4Tabby,
        'logo': 'assets/images/tabby_logo.png',
        'color': const Color(0xFF3DBCA1),
        'icon': Icons.splitscreen_rounded,
        'url': 'https://tabby.ai',
        'tag': AppLocalizations.of(context).popular,
      },
      {
        'name': 'Tamara',
        'subtitle': AppLocalizations.of(context).buyNowPayLaterTamara,
        'logo': 'assets/images/tamara_logo.png',
        'color': const Color(0xFF1D1D1D),
        'icon': Icons.payment_rounded,
        'url': 'https://tamara.co',
        'tag': null,
      },
      {
        'name': AppLocalizations.of(context).creditDebitCard,
        'subtitle': AppLocalizations.of(context).cardsAccepted,
        'logo': null,
        'color': AppColors.primary,
        'icon': Icons.credit_card_rounded,
        'url': null,
        'tag': AppLocalizations.of(context).instant,
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).choosePaymentMethod,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppLocalizations.of(context).totalAmount(widget.totalAmount.toStringAsFixed(0)),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Payment Options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: paymentMethods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final method = paymentMethods[index];
              final isSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (method['color'] as Color).withValues(alpha: 0.06)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (method['color'] as Color)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Logo / Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (method['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name & subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  method['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                if (method['tag'] != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (method['color'] as Color)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      method['tag'] as String,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: method['color'] as Color,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              method['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Radio circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (method['color'] as Color)
                                : const Color(0xFFCBD5E1),
                            width: isSelected ? 6 : 2,
                          ),
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedIndex == -1
                    ? null
                    : () {
                        final method = paymentMethods[_selectedIndex];
                        final url = method['url'] as String?;
                        if (url != null) {
                          _launchUrl(url);
                        } else {
                          // Credit card - show card form (TODO)
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context).locale.languageCode == 'ar' ? 'دفع البطاقة قريباً!' : 'Card payment coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == -1
                      ? const Color(0xFFE2E8F0)
                      : (paymentMethods[_selectedIndex]['color'] as Color),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _selectedIndex == -1
                      ? AppLocalizations.of(context).selectPaymentMethod
                      : (AppLocalizations.of(context).locale.languageCode == 'ar' ? 'المتابعة مع ${paymentMethods[_selectedIndex]['name']}' : 'Continue with ${paymentMethods[_selectedIndex]['name']}'),
                  style: TextStyle(
                    color: _selectedIndex == -1
                        ? const Color(0xFF94A3B8)
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          // Security note
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context).securedBy,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
