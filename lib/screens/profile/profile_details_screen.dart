import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late TextEditingController _nameCtrl;
  String _birthdate = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _birthdate = user?.birthdate ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdate() async {
    DateTime initialDate = DateTime(1992, 4, 15);
    if (_birthdate.isNotEmpty) {
      try {
        final parts = _birthdate.split('/');
        if (parts.length == 3) {
          final month = int.parse(parts[0].trim());
          final day = int.parse(parts[1].trim());
          final year = int.parse(parts[2].trim());
          initialDate = DateTime(year, month, day);
        }
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedMonth = picked.month.toString().padLeft(2, '0');
      final formattedDay = picked.day.toString().padLeft(2, '0');
      setState(() {
        _birthdate = '$formattedMonth / $formattedDay / ${picked.year}';
      });
    }
  }

  void _editNameDialog() {
    final dialogCtrl = TextEditingController(text: _nameCtrl.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.r(context, 20)),
          ),
          title: Text(
            'Edit Name',
            style: TextStyle(
              fontSize: R.sp(context, 16),
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          content: TextField(
            controller: dialogCtrl,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: TextStyle(fontSize: R.sp(context, 14)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.r(context, 12)),
              ),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = dialogCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _nameCtrl.text = name;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(context, 8)),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    // Call provider update
    context.read<AuthProvider>().updateProfile(name, _birthdate);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view profile details.')),
      );
    }

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
          'Profile',
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
            children: [
              // ── Avatar Area ──────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: R.pad(context, 96),
                      height: R.pad(context, 96),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623), // Orange
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            fontSize: R.sp(context, 32),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: R.pad(context, 32),
                        height: R.pad(context, 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A2B1), // Teal edit color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: R.icon(context, 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 32)),

              // ── Card 1: Personal Info ───────────────────────────────
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
                    // Full Name Row
                    _InfoEditRow(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF00A2B1),
                      iconBgColor: const Color(0xFFE8F7F6),
                      label: 'FULL NAME',
                      value: _nameCtrl.text,
                      onTap: _editNameDialog,
                      trailingIcon: Icons.edit_rounded,
                      trailingColor: const Color(0xFF00A2B1),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    // Birthdate Row
                    _InfoEditRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF00A2B1),
                      iconBgColor: const Color(0xFFE8F7F6),
                      label: 'BIRTHDATE',
                      value: _birthdate.isEmpty ? 'Not Set' : _birthdate,
                      onTap: _selectBirthdate,
                      trailingIcon: Icons.edit_rounded,
                      trailingColor: const Color(0xFF00A2B1),
                      extraTrailingIcon: Icons.calendar_month_outlined,
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 24)),

              // ── Security Label ───────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: R.pad(context, 8),
                    bottom: R.pad(context, 12),
                  ),
                  child: Text(
                    'SECURITY • READ ONLY',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: R.sp(context, 11),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // ── Card 2: Security Read Only ───────────────────────────
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
                    _InfoEditRow(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      iconBgColor: const Color(0xFFF0F9FF),
                      label: 'PHONE NUMBER',
                      value: user.phone,
                      onTap: null, // Read-only
                      trailingIcon: Icons.lock_outline_rounded,
                      trailingColor: const Color(0xFFCBD5E1),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _InfoEditRow(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      iconBgColor: const Color(0xFFF0F9FF),
                      label: 'EMAIL',
                      value: user.email,
                      onTap: null, // Read-only
                      trailingIcon: Icons.lock_outline_rounded,
                      trailingColor: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.pad(context, 40)),

              // ── Save Changes Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 50),
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A2B1), // Teal
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(context, 16)),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: R.pad(context, 20),
                          height: R.pad(context, 20),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.sp(context, 16),
                            fontWeight: FontWeight.w800,
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

class _InfoEditRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData trailingIcon;
  final Color trailingColor;
  final IconData? extraTrailingIcon;

  const _InfoEditRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.onTap,
    required this.trailingIcon,
    required this.trailingColor,
    this.extraTrailingIcon,
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
            // Leading Circle Icon
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
            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(context, 10),
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: R.pad(context, 2)),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.sp(context, 15),
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            // Trailing icon(s)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (extraTrailingIcon != null) ...[
                  Icon(
                    extraTrailingIcon,
                    color: const Color(0xFF64748B),
                    size: R.icon(context, 20),
                  ),
                  SizedBox(width: R.pad(context, 8)),
                ],
                Icon(
                  trailingIcon,
                  color: trailingColor,
                  size: R.icon(context, 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
