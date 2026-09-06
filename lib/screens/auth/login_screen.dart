import 'package:buysawa/core/constants/app_colors.dart';
import 'package:buysawa/core/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'mfa_verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      // Check if MFA is required
      final errorMsg = auth.errorMessage ?? '';
      if (errorMsg.toLowerCase().contains('mfa') || 
          errorMsg.toLowerCase().contains('two factor') ||
          errorMsg.toLowerCase().contains('2fa') ||
          errorMsg.toLowerCase().contains('verification code')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MfaVerifyScreen()),
        );
        return;
      }
      
      // Show the real error message from the server
      final finalMsg = errorMsg.isNotEmpty ? errorMsg :
          (AppLocalizations.of(context).locale.languageCode == 'ar'
              ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
              : 'Invalid email or password');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(finalMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _googleLogin() async {
    // Open Google OAuth via server redirect
    final uri = Uri.parse(ApiService.googleRedirectEndpoint);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Google login. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color topTeal = AppColors.primary;
    const Color bottomTeal = AppColors.primaryDark;
    const Color orangeColor = Color(0xFFF5A623);

    final screenH = R.screenH(context);
    final screenW = R.screenW(context);
    final isTablet = R.isTablet(context);
    final headerH = screenH * 0.36;
    final contentW = R.contentWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── 1. Full-width teal gradient background ────────
          Container(
            height: headerH,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(R.r(context, 42)),
                bottomRight: Radius.circular(R.r(context, 42)),
              ),
              gradient: const LinearGradient(
                colors: [topTeal, bottomTeal],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── 2. Decorative circle (top right) ─────────────
          Positioned(
            top: R.pad(context, -60),
            right: isTablet
                ? (screenW - contentW) / 2 - R.pad(context, 50)
                : R.pad(context, -50),
            child: Container(
              width: R.pad(context, 220),
              height: R.pad(context, 220),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          //3 Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: R.pad(context, 14),
                  right: isTablet
                      ? (screenW - contentW) / 2 + R.pad(context, 20)
                      : R.pad(context, 20),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: R.pad(context, 36),
                    height: R.pad(context, 36),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: R.icon(context, 20),
                    ),
                  ),
                ),
              ),
            ),
          ),

          //4. Header text
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerH,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: R.sp(context, 36),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Buy SA',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'W',
                            style: TextStyle(color: orangeColor),
                          ),
                          TextSpan(
                            text: 'A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.pad(context, 12)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.pad(context, 48),
                      ),
                      child: Text(
                        AppLocalizations.of(context).loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.sp(context, 13.5),
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //5. White card
          Positioned(
            top: headerH - R.pad(context, 70),
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isTablet ? (screenW - contentW) / 2 : R.pad(context, 24),
                0,
                isTablet ? (screenW - contentW) / 2 : R.pad(context, 24),
                R.pad(context, 24) + R.safeBottom(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(context, 24)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      R.pad(context, 20),
                      R.pad(context, 28),
                      R.pad(context, 20),
                      R.pad(context, 28),
                    ),
                    child: Form(
                      key: _formKey,
                      onChanged: () => setState(() {}),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Subtitle inside the card!
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${AppLocalizations.of(context).welcomeBack} ',
                                  style: TextStyle(
                                    fontSize: R.sp(context, 24),
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                TextSpan(
                                  text: '👋',
                                  style: TextStyle(fontSize: R.sp(context, 24)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.pad(context, 4)),
                          Text(
                            AppLocalizations.of(context).signInToContinue,
                            style: TextStyle(
                              fontSize: R.sp(context, 13),
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: R.pad(context, 24)),

                          // Email
                          Text(
                            AppLocalizations.of(context).email,
                            style: _labelStyle(context),
                          ),
                          SizedBox(height: R.pad(context, 8)),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: R.sp(context, 14)),
                            decoration: _field(
                              context,
                              hint: 'you@example.com',
                              icon: Icons.mail_outline_rounded,
                            ),
                          ),
                          SizedBox(height: R.pad(context, 16)),

                          // Password
                          Text(
                            AppLocalizations.of(context).password,
                            style: _labelStyle(context),
                          ),
                          SizedBox(height: R.pad(context, 8)),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: TextStyle(fontSize: R.sp(context, 14)),
                            decoration: _field(
                              context,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: R.icon(context, 20),
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          SizedBox(height: R.pad(context, 10)),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => _showForgotPasswordSheet(context),
                              child: Text(
                                AppLocalizations.of(context).forgotPassword,
                                style: TextStyle(
                                  fontSize: R.sp(context, 13),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: R.pad(context, 22)),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: R.pad(context, 48),
                            child: ElevatedButton(
                              onPressed: _isFormValid && !_loading
                                  ? _login
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: const Color(
                                  0xFFCBD5E1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    R.r(context, 14),
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      width: R.icon(context, 22),
                                      height: R.icon(context, 22),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context).login,
                                      style: TextStyle(
                                        fontSize: R.sp(context, 16),
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: R.pad(context, 22)),

                          // OR divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFFE2E8F0)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: R.pad(context, 14),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                            context,
                                          ).locale.languageCode ==
                                          'ar'
                                      ? 'أو'
                                      : 'OR',
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: R.sp(context, 11),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFFE2E8F0)),
                              ),
                            ],
                          ),
                          SizedBox(height: R.pad(context, 16)),

                          // Google button
                          SizedBox(
                            width: double.infinity,
                            height: R.pad(context, 48),
                            child: OutlinedButton(
                              onPressed: _loading ? null : _googleLogin,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    R.r(context, 14),
                                  ),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    width: R.icon(context, 22),
                                    height: R.icon(context, 22),
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.g_mobiledata_rounded,
                                      color: Colors.blue,
                                      size: R.icon(context, 28),
                                    ),
                                  ),
                                  SizedBox(width: R.pad(context, 10)),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).continueWithGoogle,
                                    style: TextStyle(
                                      fontSize: R.sp(context, 14),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: R.pad(context, 32)),

                  // Create Account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).dontHaveAccount} ',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: R.sp(context, 13),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).createAccount,
                          style: TextStyle(
                            color: orangeColor,
                            fontSize: R.sp(context, 13),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordSheet(BuildContext context) {
    final emailCtrl = TextEditingController();
    bool sending = false;
    bool sent = false;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  R.pad(context, 24),
                  R.pad(context, 28),
                  R.pad(context, 24),
                  R.pad(context, 36),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: R.pad(context, 24)),

                    if (!sent) ...[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset_rounded,
                            color: AppColors.primary, size: 28),
                      ),
                      SizedBox(height: R.pad(context, 16)),
                      Text(
                        l10n.forgotPassword,
                        style: TextStyle(
                          fontSize: R.sp(context, 20),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: R.pad(context, 6)),
                      Text(
                        l10n.locale.languageCode == 'ar'
                            ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور'
                            : 'Enter your email and we\'ll send you a reset link',
                        style: TextStyle(
                          fontSize: R.sp(context, 13),
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: R.pad(context, 24)),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: R.sp(context, 14)),
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: R.sp(context, 14)),
                          prefixIcon: const Icon(Icons.mail_outline_rounded,
                              color: Color(0xFF94A3B8), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      SizedBox(height: R.pad(context, 20)),
                      SizedBox(
                        width: double.infinity,
                        height: R.pad(context, 50),
                        child: ElevatedButton(
                          onPressed: sending
                              ? null
                              : () async {
                                  if (emailCtrl.text.trim().isEmpty) return;
                                  setSheetState(() => sending = true);
                                  
                                  final auth = context.read<AuthProvider>();
                                  final success = await auth.forgotPassword(emailCtrl.text.trim());
                                  
                                  if (!context.mounted) return;
                                  
                                  if (success) {
                                    setSheetState(() {
                                      sending = false;
                                      sent = true;
                                    });
                                  } else {
                                    setSheetState(() => sending = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(auth.errorMessage ?? 'Failed to send reset link'),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: const Color(0xFFCBD5E1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: sending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  l10n.locale.languageCode == 'ar'
                                      ? 'إرسال رابط الاستعادة'
                                      : 'Send Reset Link',
                                  style: TextStyle(
                                    fontSize: R.sp(context, 15),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mark_email_read_rounded,
                                  color: AppColors.success, size: 40),
                            ),
                            SizedBox(height: R.pad(context, 20)),
                            Text(
                              l10n.locale.languageCode == 'ar'
                                  ? 'تم إرسال الرابط!'
                                  : 'Link Sent!',
                              style: TextStyle(
                                fontSize: R.sp(context, 22),
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: R.pad(context, 8)),
                            Text(
                              l10n.locale.languageCode == 'ar'
                                  ? 'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور'
                                  : 'Check your email and follow the instructions to reset your password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: R.sp(context, 13),
                                color: const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: R.pad(context, 28)),
                            SizedBox(
                              width: double.infinity,
                              height: R.pad(context, 50),
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  l10n.ok,
                                  style: TextStyle(
                                    fontSize: R.sp(context, 15),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  TextStyle _labelStyle(BuildContext context) => TextStyle(
    fontSize: R.sp(context, 13),
    fontWeight: FontWeight.w700,
    color: const Color(0xFF334155),
  );

  InputDecoration _field(
    BuildContext context, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF94A3B8),
        fontSize: R.sp(context, 14),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF94A3B8),
        size: R.icon(context, 20),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: R.pad(context, 16),
        vertical: R.pad(context, 14),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.r(context, 12)),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.r(context, 12)),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.r(context, 12)),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
