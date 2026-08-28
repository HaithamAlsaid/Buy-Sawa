import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/localization/app_localizations.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirmCtrl = TextEditingController();
  bool _isDeleteEnabled = false;

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _confirmCtrl.text;
    setState(() {
      _isDeleteEnabled = text == 'DELETE';
    });
  }

  void _deleteAccount() async {
    if (!_isDeleteEnabled) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.error),
      ),
    );

    // Call logout/delete
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading

    // Call logout in AuthProvider to reset login status
    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    // Pop back to root profile tab
    Navigator.of(context).popUntil((route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).accountDeleted),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final balanceFormatted = wallet.balance.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(R.pad(context, 8.0)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.textDark,
                size: R.icon(context, 24),
              ),
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).deleteAccount,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.pad(context, 20),
            vertical: R.pad(context, 24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Red Warning Card ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(R.pad(context, 20)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEF), // Light red bg
                  borderRadius: BorderRadius.circular(R.r(context, 24)),
                  border: Border.all(
                    color: const Color(0xFFFECDD3), // Light red border
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning icon in white circle
                    Container(
                      padding: EdgeInsets.all(R.pad(context, 8)),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xFFEF4444),
                        size: R.icon(context, 24),
                      ),
                    ),
                    SizedBox(width: R.pad(context, 14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).deleteAccountPermanent,
                            style: TextStyle(
                              color: const Color(0xFF991B1B), // Dark red
                              fontSize: R.sp(context, 15),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: R.pad(context, 6)),
                          Text(
                            AppLocalizations.of(context).deleteAccountDesc,
                            style: TextStyle(
                              color: const Color(0xFFB91C1C),
                              fontSize: R.sp(context, 13),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 28)),

              // ── YOU WILL LOSE Label ──────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: R.pad(context, 8),
                  bottom: R.pad(context, 12),
                ),
                child: Text(
                  AppLocalizations.of(context).youWillLose,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: R.sp(context, 11),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // ── Loss Card ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(R.pad(context, 20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(context, 24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _LossItem(text: AppLocalizations.of(context).walletBalanceLoss(balanceFormatted)),
                    SizedBox(height: R.pad(context, 16)),
                    _LossItem(text: AppLocalizations.of(context).orderHistoryLoss),
                    SizedBox(height: R.pad(context, 16)),
                    _LossItem(text: AppLocalizations.of(context).savedAddressesLoss),
                    SizedBox(height: R.pad(context, 16)),
                    _LossItem(text: AppLocalizations.of(context).referralBonusLoss),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 28)),

              // ── Confirm Prompt Label ──────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: R.pad(context, 8),
                  bottom: R.pad(context, 12),
                ),
                child: Text(
                  AppLocalizations.of(context).typeDeleteToConfirm,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: R.sp(context, 11),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // ── Text Field ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(context, 16)),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: R.pad(context, 16)),
                child: TextField(
                  controller: _confirmCtrl,
                  style: TextStyle(
                    fontSize: R.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).deleteText,
                    hintStyle: TextStyle(
                      color: const Color(0xFFCBD5E1),
                      fontSize: R.sp(context, 14),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: R.pad(context, 24)),

              // ── Permanently Delete Account Button ────────────────────
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 50),
                child: ElevatedButton.icon(
                  onPressed: _isDeleteEnabled ? _deleteAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFECDD3), // Soft light red background initially
                    disabledBackgroundColor: const Color(0xFFFFE4E6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(context, 16)),
                    ),
                  ),
                  icon: Icon(
                    Icons.delete_forever_rounded,
                    color: _isDeleteEnabled ? const Color(0xFFEF4444) : const Color(0xFFFDA4AF),
                    size: R.icon(context, 20),
                  ),
                  label: Text(
                    AppLocalizations.of(context).permanentlyDeleteAccount,
                    style: TextStyle(
                      color: _isDeleteEnabled ? const Color(0xFFEF4444) : const Color(0xFFFDA4AF),
                      fontSize: R.sp(context, 15),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.pad(context, 16)),

              // ── Cancel Text Button ───────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context).cancel,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: R.sp(context, 15),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LossItem extends StatelessWidget {
  final String text;

  const _LossItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.close_rounded,
          color: const Color(0xFFEF4444),
          size: R.icon(context, 16),
        ),
        SizedBox(width: R.pad(context, 10)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF334155),
              fontSize: R.sp(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
