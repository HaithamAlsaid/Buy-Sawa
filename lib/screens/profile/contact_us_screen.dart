import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_bottom_sheet.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final msg = _messageCtrl.text.trim();
    if (msg.isEmpty) return;

    setState(() => _sending = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _messageCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent! We\'ll get back to you soon.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;

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
          'Contact Us',
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
              // ── Message Box Label ────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: R.pad(context, 8),
                  bottom: R.pad(context, 12),
                ),
                child: Text(
                  'YOUR MESSAGE',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8), // Slate 400
                    fontSize: R.sp(context, 12),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // ── Message Card ─────────────────────────────────────────
              GestureDetector(
                onTap: isGuest ? () => AuthBottomSheet.show(context) : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(R.pad(context, 20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(context, 24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1,
                    ),
                  ),
                  child: isGuest
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login to send a message',
                              style: TextStyle(
                                color: const Color(0xFF94A3B8),
                                fontSize: R.sp(context, 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: R.pad(context, 50)),
                            SizedBox(
                              width: double.infinity,
                              height: R.pad(context, 48),
                              child: ElevatedButton.icon(
                                onPressed: () => AuthBottomSheet.show(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCBD5E1), // Muted grey
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(R.r(context, 16)),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: R.icon(context, 16),
                                ),
                                label: Text(
                                  'Login to Send',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: R.sp(context, 15),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _messageCtrl,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: R.sp(context, 14),
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type your message here...',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: R.sp(context, 14),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            SizedBox(height: R.pad(context, 12)),
                            SizedBox(
                              height: R.pad(context, 48),
                              child: ElevatedButton.icon(
                                onPressed: _sending ? null : _sendMessage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(R.r(context, 16)),
                                  ),
                                ),
                                icon: _sending
                                    ? SizedBox(
                                        width: R.pad(context, 16),
                                        height: R.pad(context, 16),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: R.icon(context, 16),
                                      ),
                                label: Text(
                                  'Send Message',
                                  style: TextStyle(
                                    color: Colors.white,
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

              SizedBox(height: R.pad(context, 32)),

              // ── Direct Contact Label ─────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: R.pad(context, 8),
                  bottom: R.pad(context, 12),
                ),
                child: Text(
                  'OR REACH US DIRECTLY',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: R.sp(context, 12),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // ── Contact Methods Card ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(context, 24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
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
                    _ContactItem(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFFF97316),
                      iconBgColor: const Color(0xFFFFF7ED),
                      title: 'CALL US',
                      subtitle: '800-SAWA',
                      onTap: () {
                        // Action to call
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _ContactItem(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      iconBgColor: const Color(0xFFF0F9FF),
                      title: 'EMAIL US',
                      subtitle: 'help@buysawa.app',
                      onTap: () {
                        // Action to email
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 40)),

              // ── Support Footer ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    color: const Color(0xFF94A3B8),
                    size: R.icon(context, 18),
                  ),
                  SizedBox(width: R.pad(context, 8)),
                  Text(
                    'Support team available 24/7',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: R.sp(context, 13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.r(context, 24)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.pad(context, 16),
          vertical: R.pad(context, 16),
        ),
        child: Row(
          children: [
            Container(
              width: R.pad(context, 40),
              height: R.pad(context, 40),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: R.icon(context, 20),
                ),
              ),
            ),
            SizedBox(width: R.pad(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(context, 10),
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: R.pad(context, 2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.sp(context, 15),
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: R.icon(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}
