import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty &&
      _passCtrl.text.isNotEmpty;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      phone: _phoneCtrl.text.trim(),
      referralCode: _referralCtrl.text.trim().isEmpty
          ? null
          : _referralCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: AppColors.error,
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
                      'Create Account',
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
                      'Join the SAWA squad 🎉',
                      style: TextStyle(
                        fontSize: R.sp(context, 24),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: R.pad(context, 8)),
                    Text(
                      'Join Buy SAWA for exclusive group deals & cashback!',
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
                              'FULL NAME',
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
                                hint: 'Haitham Alsayed',
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            SizedBox(height: R.pad(context, 16)),

                            // Email
                            Text('Email Address', style: _labelStyle(context)),
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

                            // Phone
                            Text('Mobile Number', style: _labelStyle(context)),
                            SizedBox(height: R.pad(context, 8)),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(fontSize: R.sp(context, 14)),
                              decoration: _field(
                                context,
                                hint: '+971 50 123 4567',
                                icon: Icons.phone_outlined,
                              ),
                            ),
                            SizedBox(height: R.pad(context, 16)),

                            // Password
                            Text('Password', style: _labelStyle(context)),
                            SizedBox(height: R.pad(context, 8)),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              style: TextStyle(fontSize: R.sp(context, 14)),
                              decoration: _field(
                                context,
                                hint: 'Min. 4 characters',
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
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    73,
                                    190,
                                    226,
                                  ),
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
                                        'Sign Up',
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
                          'Already have an account? ',
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
                            'Login',
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
        borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 1.5),
      ),
    );
  }
}
