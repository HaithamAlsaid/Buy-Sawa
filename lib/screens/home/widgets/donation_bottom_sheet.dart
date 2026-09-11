import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/donation_campaign_model.dart';
import '../../../widgets/cached_image.dart';

class DonationBottomSheet extends StatefulWidget {
  final DonationCampaignModel campaign;
  const DonationBottomSheet({super.key, required this.campaign});

  @override
  State<DonationBottomSheet> createState() => _DonationBottomSheetState();
}

class _DonationBottomSheetState extends State<DonationBottomSheet> {
  final List<double> _predefinedAmounts = [25, 50, 100, 250, 500];
  double _selectedAmount = 100;
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedPaymentMethod = 'credit_card';
  bool _isAnonymous = false;
  bool _isLoading = false;

  static const _teal = Color(0xFF008982);
  static const _dark = Color(0xFF0F2D3A);

  void _onAmountSelected(double amount) {
    setState(() {
      _selectedAmount = amount;
      _customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String val) {
    final amount = double.tryParse(val);
    setState(() => _selectedAmount = (amount != null && amount > 0) ? amount : 0);
  }

  bool get _canDonate =>
      _selectedAmount > 0 &&
      !_isLoading &&
      (_isAnonymous ||
          (_nameController.text.trim().isNotEmpty &&
              _phoneController.text.trim().isNotEmpty &&
              _emailController.text.trim().isNotEmpty));

  Future<void> _processDonation() async {
    final l = AppLocalizations.of(context);
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.enterValidAmount)));
      return;
    }
    if (!_isAnonymous &&
        (_nameController.text.trim().isEmpty ||
            _phoneController.text.trim().isEmpty ||
            _emailController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.enterNameAndPhone)));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.donationSuccess),
            backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: _teal, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required Widget leading,
    required String label,
    String? subtitle,
  }) {
    final selected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? _teal.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _teal : Colors.grey[200]!,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: selected ? _teal : _dark)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: _teal, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campaign Info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedImage(
                        imageUrl: widget.campaign.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.campaign.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(widget.campaign.foundationName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                // Amount label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.selectDonationAmount,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _dark)),
                    Text('${_selectedAmount.toInt()} ${l.aed}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _teal)),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick amounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _predefinedAmounts.map((amount) {
                    final isSelected = amount == _selectedAmount &&
                        _customAmountController.text.isEmpty;
                    return GestureDetector(
                      onTap: () => _onAmountSelected(amount),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? _teal : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? _teal : Colors.grey[200]!,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _teal.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text('${amount.toInt()}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : _dark)),
                            Text(l.aed,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Custom amount
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.grey[200]!, width: 1.5),
                  ),
                  child: TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: _onCustomAmountChanged,
                    decoration: InputDecoration(
                      hintText: l.customAmountHint,
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(l.aed,
                            style: const TextStyle(
                                color: _teal,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                // Donor Info
                Text(l.donorInfo,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _dark)),
                const SizedBox(height: 12),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isAnonymous
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        hint: l.fullNameHint,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        hint: l.email,
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _phoneController,
                        hint: l.phoneHint,
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
                    ],
                  ),
                  secondChild: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility_off_outlined,
                            color: _teal, size: 18),
                        const SizedBox(width: 8),
                        Text(l.anonymousNote,
                            style: const TextStyle(
                                color: _teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Anonymous toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.donateAnonymously,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _dark)),
                    Switch(
                      value: _isAnonymous,
                      onChanged: (val) =>
                          setState(() => _isAnonymous = val),
                      activeColor: _teal,
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(),
                ),

                // Payment Method
                Text(l.paymentMethod,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _dark)),
                const SizedBox(height: 12),

                _buildPaymentOption(
                  id: 'wallet',
                  leading: Icon(Icons.account_balance_wallet_rounded,
                      color: _selectedPaymentMethod == 'wallet'
                          ? _teal
                          : Colors.grey),
                  label: l.myWallet,
                  subtitle: l.myWalletBalance,
                ),
                const SizedBox(height: 8),

                _buildPaymentOption(
                  id: 'credit_card',
                  leading: Icon(Icons.credit_card_rounded,
                      color: _selectedPaymentMethod == 'credit_card'
                          ? _teal
                          : Colors.grey),
                  label: l.creditDebitCard,
                  subtitle: l.cardsAccepted,
                ),
                const SizedBox(height: 8),

                _buildPaymentOption(
                  id: 'tabby',
                  leading: _PaymentLogo(
                    text: 'tabby',
                    color: const Color(0xFF3DBFA8),
                    selected: _selectedPaymentMethod == 'tabby',
                  ),
                  label: 'Tabby',
                  subtitle: l.tabbySubtitle,
                ),
                const SizedBox(height: 8),

                _buildPaymentOption(
                  id: 'tamara',
                  leading: _PaymentLogo(
                    text: 'tamara',
                    color: const Color(0xFF231F20),
                    selected: _selectedPaymentMethod == 'tamara',
                  ),
                  label: 'Tamara',
                  subtitle: l.tamaraSubtitle,
                ),

                const SizedBox(height: 24),

                // Donate Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canDonate ? _processDonation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      disabledBackgroundColor: Colors.grey[200],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
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
                            l.donateBtn(_selectedAmount.toInt()),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  final String text;
  final Color color;
  final bool selected;

  const _PaymentLogo(
      {required this.text, required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: 0.12)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: selected ? color : Colors.grey[600],
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
