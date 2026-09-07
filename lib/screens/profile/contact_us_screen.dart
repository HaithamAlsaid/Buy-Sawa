import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_bottom_sheet.dart';
import '../../core/services/contact_us_service.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  List<Map<String, dynamic>> _purposes = [];
  int? _selectedPurposeId;
  bool _loadingPurposes = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchPurposes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isGuest && auth.user != null) {
        if (auth.user!.fullName.isNotEmpty) _nameCtrl.text = auth.user!.fullName;
        if (auth.user!.email.isNotEmpty) _emailCtrl.text = auth.user!.email;
        if (auth.user!.phone.isNotEmpty) _phoneCtrl.text = auth.user!.phone;
      }
    });
  }

  Future<void> _fetchPurposes() async {
    final list = await ContactUsService.getPurposes();
    if (mounted) {
      setState(() {
        _purposes = list;
        if (_purposes.isNotEmpty) {
          _selectedPurposeId = _purposes.first['id'];
        }
        _loadingPurposes = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final msg = _messageCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (msg.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty || (_purposes.isNotEmpty && _selectedPurposeId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).locale.languageCode == 'ar' ? 'يرجى تعبئة جميع الحقول' : 'Please fill all fields'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _sending = true);
    
    final success = await ContactUsService.submitMessage(
      fullName: name,
      email: email,
      phone: phone,
      purposeId: _selectedPurposeId,
      message: msg,
    );
    
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (success) {
        _messageCtrl.clear();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? AppLocalizations.of(context).messageSent : (AppLocalizations.of(context).locale.languageCode == 'ar' ? 'فشل الإرسال' : 'Failed to send')),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: R.pad(context, 8), bottom: R.pad(context, 8)),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF94A3B8), // Slate 400
              fontSize: R.sp(context, 12),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: R.pad(context, 16), vertical: R.pad(context, 16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(R.r(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: R.sp(context, 14),
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: maxLines == 1 ? EdgeInsets.zero : EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
        SizedBox(height: R.pad(context, 20)),
      ],
    );
  }

  Widget _buildDropdown() {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: R.pad(context, 8), bottom: R.pad(context, 8)),
          child: Text(
            isAr ? 'سبب التواصل' : 'PURPOSE',
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: R.sp(context, 12),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: R.pad(context, 16), vertical: R.pad(context, 3)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(R.r(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedPurposeId,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF94A3B8)),
              items: _purposes.map((p) {
                return DropdownMenuItem<int>(
                  value: p['id'],
                  child: Text(
                    isAr ? (p['title_ar'] ?? p['title_en'] ?? '') : (p['title_en'] ?? p['title_ar'] ?? ''),
                    style: TextStyle(fontSize: R.sp(context, 14), color: const Color(0xFF0F172A)),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPurposeId = val);
              },
            ),
          ),
        ),
        SizedBox(height: R.pad(context, 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';

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
          AppLocalizations.of(context).contactUs,
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
              if (isGuest)
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
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).loginToSend,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: R.sp(context, 14),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: R.pad(context, 20)),
                      SizedBox(
                        width: double.infinity,
                        height: R.pad(context, 48),
                        child: ElevatedButton.icon(
                          onPressed: () => AuthBottomSheet.show(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCBD5E1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(R.r(context, 16)),
                            ),
                          ),
                          icon: Icon(Icons.login, color: Colors.white, size: R.icon(context, 16)),
                          label: Text(
                            AppLocalizations.of(context).login,
                            style: TextStyle(color: Colors.white, fontSize: R.sp(context, 15), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildTextField(isAr ? 'الاسم بالكامل' : 'FULL NAME', _nameCtrl),
                _buildTextField(isAr ? 'البريد الإلكتروني' : 'EMAIL ADDRESS', _emailCtrl, keyboardType: TextInputType.emailAddress),
                _buildTextField(isAr ? 'رقم الهاتف' : 'PHONE NUMBER', _phoneCtrl, keyboardType: TextInputType.phone),
                if (_loadingPurposes)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                else if (_purposes.isNotEmpty)
                  _buildDropdown(),
                _buildTextField(AppLocalizations.of(context).yourMessage, _messageCtrl, maxLines: 4),
                
                SizedBox(
                  width: double.infinity,
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
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(Icons.send_rounded, color: Colors.white, size: R.icon(context, 16)),
                    label: Text(
                      AppLocalizations.of(context).sendMessage,
                      style: TextStyle(color: Colors.white, fontSize: R.sp(context, 15), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],

              SizedBox(height: R.pad(context, 32)),

              // ── Direct Contact Label ─────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: R.pad(context, 8),
                  bottom: R.pad(context, 12),
                ),
                child: Text(
                  AppLocalizations.of(context).orReachDirectly.toUpperCase(),
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
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                ),
                child: Column(
                  children: [
                    _ContactItem(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFFF97316),
                      iconBgColor: const Color(0xFFFFF7ED),
                      title: AppLocalizations.of(context).callUs.toUpperCase(),
                      subtitle: '800-SAWA',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _ContactItem(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      iconBgColor: const Color(0xFFF0F9FF),
                      title: AppLocalizations.of(context).emailUs.toUpperCase(),
                      subtitle: 'help@buysawa.app',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 40)),

              // ── Support Footer ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headset_mic_outlined, color: const Color(0xFF94A3B8), size: R.icon(context, 18)),
                  SizedBox(width: R.pad(context, 8)),
                  Text(
                    AppLocalizations.of(context).supportAvailable,
                    style: TextStyle(color: const Color(0xFF94A3B8), fontSize: R.sp(context, 13), fontWeight: FontWeight.w500),
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
        padding: EdgeInsets.symmetric(horizontal: R.pad(context, 16), vertical: R.pad(context, 16)),
        child: Row(
          children: [
            Container(
              width: R.pad(context, 40),
              height: R.pad(context, 40),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: iconColor, size: R.icon(context, 20))),
            ),
            SizedBox(width: R.pad(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: R.sp(context, 10), color: const Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                  SizedBox(height: R.pad(context, 2)),
                  Text(subtitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.sp(context, 15), color: const Color(0xFF0F172A))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: R.icon(context, 20)),
          ],
        ),
      ),
    );
  }
}
