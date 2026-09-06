import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  String? _qrUrl;
  bool _isLoadingQr = true;
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
  }

  Future<void> _fetchQrCode() async {
    final auth = context.read<AuthProvider>();
    final qrUrl = await auth.setupMfa();
    if (mounted) {
      setState(() {
        _qrUrl = qrUrl;
        _isLoadingQr = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_codeCtrl.text.length < 6) return;
    
    final auth = context.read<AuthProvider>();
    final success = await auth.confirmMfa(_codeCtrl.text);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Two-Factor Authentication Enabled Successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Invalid verification code'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isAr ? 'الأمان المزدوج (MFA)' : 'Two-Factor Auth',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.pad(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(R.pad(context, 16)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 40),
            ),
            SizedBox(height: R.pad(context, 16)),
            Text(
              isAr ? 'قم بتفعيل الأمان المزدوج لحماية حسابك' : 'Enable Two-Factor Authentication',
              style: TextStyle(
                fontSize: R.sp(context, 18),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.pad(context, 12)),
            Text(
              isAr 
                ? 'استخدم تطبيق مثل Google Authenticator لمسح الكود التالي، ثم أدخل الـ 6 أرقام لتأكيد التفعيل.'
                : 'Use an app like Google Authenticator to scan this QR code, then enter the 6-digit pin.',
              style: TextStyle(
                fontSize: R.sp(context, 14),
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.pad(context, 32)),
            
            // QR Code Container
            Container(
              width: R.pad(context, 200),
              height: R.pad(context, 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _isLoadingQr 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _qrUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(_qrUrl!, fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.qr_code_2_rounded, size: 100, color: Color(0xFFCBD5E1)),
                      ),
                    )
                  : const Center(child: Icon(Icons.error_outline, color: AppColors.error)),
            ),
            
            SizedBox(height: R.pad(context, 32)),
            
            // Code Input
            TextFormField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: R.sp(context, 24), letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                hintStyle: const TextStyle(color: Color(0xFFCBD5E1), letterSpacing: 8),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            SizedBox(height: R.pad(context, 24)),
            
            SizedBox(
              width: double.infinity,
              height: R.pad(context, 50),
              child: ElevatedButton(
                onPressed: (loading || _isLoadingQr) ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        isAr ? 'تأكيد وتفعيل' : 'Confirm & Enable',
                        style: TextStyle(
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
