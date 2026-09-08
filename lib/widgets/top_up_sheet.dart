import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../providers/wallet_provider.dart';
import '../screens/checkout/payment_webview_screen.dart';

class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key});

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  final TextEditingController _amountCtrl = TextEditingController();
  final List<double> _quickAmounts = [100, 200, 500, 1000];
  String _selectedProvider = 'paymob';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final amountStr = _amountCtrl.text.trim();
    if (amountStr.isEmpty) return;
    final amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);

    final paymentUrl = await context.read<WalletProvider>().topUpWallet(amount, _selectedProvider);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (paymentUrl != null) {
        // Close the sheet first
        Navigator.pop(context);
        
        // Open WebView
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(url: paymentUrl),
          ),
        );
        
        if (success == true && mounted) {
           // Re-fetch wallet since payment succeeded
           await context.read<WalletProvider>().fetchWallet();
           
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).locale.languageCode == 'ar'
                    ? 'تم الشحن بنجاح!'
                    : 'Top-up successful!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).locale.languageCode == 'ar'
                    ? 'تم إلغاء عملية الشحن.'
                    : 'Top-up cancelled.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).locale.languageCode == 'ar'
                  ? 'فشل الاتصال ببوابة الدفع، حاول مرة أخرى.'
                  : 'Failed to connect to payment gateway, please try again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
            Text(
              isAr ? 'شحن المحفظة' : 'Top-up Wallet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isAr ? 'المبلغ' : 'Amount',
                  prefixText: l10n.aed + ' ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Amounts
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: _quickAmounts.map((amt) {
                  return Padding(
                    padding: EdgeInsets.only(right: isAr ? 0 : 8, left: isAr ? 8 : 0),
                    child: ChoiceChip(
                      label: Text('+${amt.toInt()}'),
                      selected: false,
                      onSelected: (_) {
                        _amountCtrl.text = amt.toString();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Provider Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'وسيلة الدفع' : 'Payment Method',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'paymob',
                        child: Text('Credit / Debit Card (Paymob)'),
                      ),
                      DropdownMenuItem(
                        value: 'tabby',
                        child: Text('Tabby'),
                      ),
                      DropdownMenuItem(
                        value: 'tamara',
                        child: Text('Tamara'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedProvider = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isAr ? 'تأكيد الشحن' : 'Confirm Top-up',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
