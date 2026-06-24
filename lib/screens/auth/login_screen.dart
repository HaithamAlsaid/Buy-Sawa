import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login('google@example.com', '123456');
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color topTeal = Color.fromARGB(255, 50, 158, 208);
    const Color bottomTeal = Color.fromARGB(255, 42, 126, 185);
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
                color: const Color.fromARGB(255, 43, 184, 184).withOpacity(0.35),
              ),
            ),
          ),

          // ── 3. Close button ───────────────────────────────
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
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        color: Colors.white, size: R.icon(context, 20)),
                  ),
                ),
              ),
            ),
          ),

          // ── 4. Header text ────────────────────────────────
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
                              style: TextStyle(color: Colors.white)),
                          TextSpan(
                              text: 'W',
                              style: TextStyle(color: orangeColor)),
                          TextSpan(
                              text: 'A',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(height: R.pad(context, 12)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.pad(context, 48)),
                      child: Text(
                        'Login to unlock cashback, group deals & VIP perks',
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

          // ── 5. White card ─────────────────────────────────
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
                                  text: 'Welcome back ',
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
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: R.sp(context, 13),
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: R.pad(context, 24)),

                          // Email
                          Text('Email Address', style: _labelStyle(context)),
                          SizedBox(height: R.pad(context, 8)),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: R.sp(context, 14)),
                            decoration: _field(context,
                                hint: 'you@example.com',
                                icon: Icons.mail_outline_rounded),
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
                              onTap: () {},
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: R.sp(context, 13),
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromARGB(255, 57, 149, 210),
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
                              onPressed: _isFormValid && !_loading ? _login : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 73, 190, 226),
                                disabledBackgroundColor: const Color(0xFFCBD5E1),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(R.r(context, 14))),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      width: R.icon(context, 22),
                                      height: R.icon(context, 22),
                                      child: const CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5))
                                  : Text('Login',
                                      style: TextStyle(
                                          fontSize: R.sp(context, 16),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: R.pad(context, 22)),

                          // OR divider
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0))),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: R.pad(context, 14)),
                                child: Text('OR',
                                    style: TextStyle(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: R.sp(context, 11),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1)),
                              ),
                              const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0))),
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
                                    color: Color(0xFFE2E8F0), width: 1.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        R.r(context, 14))),
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
                                        size: R.icon(context, 28)),
                                  ),
                                  SizedBox(width: R.pad(context, 10)),
                                  Text('Continue with Google',
                                      style: TextStyle(
                                          fontSize: R.sp(context, 14),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A))),
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
                      Text("Don't have an account? ",
                          style: TextStyle(
                              color: const Color(0xFF64748B),
                          fontSize: R.sp(context, 13))),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen())),
                        child: Text('Create Account',
                            style: TextStyle(
                                color: orangeColor,
                                fontSize: R.sp(context, 13),
                                fontWeight: FontWeight.w800)),
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
          color: const Color(0xFF94A3B8), fontSize: R.sp(context, 14)),
      prefixIcon: Icon(icon,
          color: const Color(0xFF94A3B8), size: R.icon(context, 20)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
          horizontal: R.pad(context, 16), vertical: R.pad(context, 14)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(context, 12)),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(context, 12)),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(context, 12)),
          borderSide:
              const BorderSide(color: Color(0xFF00A9A5), width: 1.5)),
    );
  }
}
