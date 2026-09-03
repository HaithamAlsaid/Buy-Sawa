import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _confirmPassCtrl.text.isNotEmpty;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).locale.languageCode == 'ar'
                ? 'كلمات المرور غير متطابقة'
                : 'Passwords do not match',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      passwordConfirmation: _confirmPassCtrl.text,
      referralCode: _referralCtrl.text.trim().isEmpty
          ? null
          : _referralCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      // Show the real error message from the server
      final errorMsg = auth.errorMessage ?? 
          (AppLocalizations.of(context).locale.languageCode == 'ar'
              ? 'فشل التسجيل. يرجى المحاولة مرة أخرى.'
              : 'Registration failed. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF5A623);

    final screenW = R.screenW(context);
    final isTablet = R.isTablet(context);
    final contentW = R.contentWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Back button + Title) ────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.pad(context, 24),
                vertical: R.pad(context, 16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: R.pad(context, 40),
                      height: R.pad(context, 40),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0F172A),
                        size: R.icon(context, 18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).createAccount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  SizedBox(width: R.pad(context, 40)), // Spacer for symmetry
                ],
              ),
            ),

            // ── Scrollable Content ────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? (screenW - contentW) / 2 : R.pad(context, 24),
                  R.pad(context, 16),
                  isTablet ? (screenW - contentW) / 2 : R.pad(context, 24),
                  R.pad(context, 24) + R.safeBottom(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Subtitle
                    Text(
                      AppLocalizations.of(context).joinSawa,
                      style: TextStyle(
                        fontSize: R.sp(context, 24),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: R.pad(context, 8)),
                    Text(
                      AppLocalizations.of(context).joinSawaSubtitle,
                      style: TextStyle(
                        fontSize: R.sp(context, 13),
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: R.pad(context, 24)),

                    // White Card
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
                            // Full Name
                            Text(
                              AppLocalizations.of(context).fullName.toUpperCase(),
                              style: _labelStyle(context).copyWith(
                                fontSize: R.sp(context, 11),
                                letterSpacing: 0.5,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            SizedBox(height: R.pad(context, 8)),
                            TextFormField(
                              controller: _nameCtrl,
                              style: TextStyle(fontSize: R.sp(context, 14)),
                              decoration: _field(
                                context,
                                hint: 'full name',
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            SizedBox(height: R.pad(context, 16)),

                            // Email
                            Text(AppLocalizations.of(context).email, style: _labelStyle(context)),
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
                            Text(AppLocalizations.of(context).password, style: _labelStyle(context)),
                            SizedBox(height: R.pad(context, 8)),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              style: TextStyle(fontSize: R.sp(context, 14)),
                              decoration: _field(
                                context,
                                hint: 'Min. 8 characters',
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
                            SizedBox(height: R.pad(context, 16)),

                            // Confirm Password
                            Text(
                              AppLocalizations.of(context).locale.languageCode == 'ar'
                                  ? 'تأكيد كلمة المرور'
                                  : 'Confirm Password',
                              style: _labelStyle(context),
                            ),
                            SizedBox(height: R.pad(context, 8)),
                            TextFormField(
                              controller: _confirmPassCtrl,
                              obscureText: _obscureConfirm,
                              style: TextStyle(fontSize: R.sp(context, 14)),
                              decoration: _field(
                                context,
                                hint: 'Re-enter password',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF94A3B8),
                                    size: R.icon(context, 20),
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                            ),
                            SizedBox(height: R.pad(context, 28)),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: R.pad(context, 48),
                              child: ElevatedButton(
                                onPressed: _isFormValid && !_loading
                                    ? _register
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
                                        AppLocalizations.of(context).register,
                                        style: TextStyle(
                                          fontSize: R.sp(context, 16),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: R.pad(context, 32)),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).alreadyHaveAccount} ',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: R.sp(context, 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).login,
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
      ),
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
