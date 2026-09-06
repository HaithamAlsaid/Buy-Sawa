import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../core/localization/app_localizations.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late TextEditingController _nameCtrl;
  String _birthdate = '';
  bool _saving = false;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).locale.languageCode == 'ar' 
                ? 'جاري رفع الصورة...' : 'Uploading image...'),
            backgroundColor: AppColors.primary,
          ),
        );
        
        final success = await context.read<AuthProvider>().uploadAvatar(_pickedImage!);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).locale.languageCode == 'ar' 
                    ? 'تم تحديث الصورة بنجاح' : 'Image updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.read<AuthProvider>().errorMessage ?? 'Failed to upload image'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
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
              child: Text(AppLocalizations.of(context).cancel),
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
              child: Text(AppLocalizations.of(context).confirm),
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
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(name, _birthdate);
    
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).changesSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to update profile'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final l10n = AppLocalizations.of(context);
    
    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.loginToViewProfile)),
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
          l10n.editProfile,
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
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: R.pad(context, 96),
                        height: R.pad(context, 96),
                        decoration: BoxDecoration(
                          color: AppColors.primary, // Teal
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: _pickedImage != null
                              ? DecorationImage(
                                  image: FileImage(_pickedImage!),
                                  fit: BoxFit.cover,
                                )
                              : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(user.avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (_pickedImage == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty))
                            ? Center(
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: R.icon(context, 48),
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: R.pad(context, 32),
                          height: R.pad(context, 32),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5A623), // Orange edit color
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: context.watch<AuthProvider>().isLoading
                                ? SizedBox(
                                    width: R.pad(context, 16),
                                    height: R.pad(context, 16),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: R.icon(context, 16),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: R.pad(context, 32)),

              // ── 1. Full Name ────────────────────────────────────────────────
              _buildSingleCard(
                context,
                child: _InfoEditRow(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  iconBgColor: const Color(0xFFE8F7F6),
                  label: l10n.fullName.toUpperCase(),
                  value: _nameCtrl.text,
                  onTap: _editNameDialog,
                  trailingIcon: Icons.edit_rounded,
                  trailingColor: AppColors.primary,
                ),
              ),

              SizedBox(height: R.pad(context, 16)),

              // ── 2. Phone Number ──────────────────────────────────────────────
              _buildSingleCard(
                context,
                child: _InfoEditRow(
                  icon: Icons.phone_rounded,
                  iconColor: AppColors.primary,
                  iconBgColor: const Color(0xFFE8F7F6),
                  label: l10n.phone.toUpperCase(),
                  value: user.phone,
                  onTap: null, // Usually read-only
                  trailingIcon: Icons.lock_outline_rounded,
                  trailingColor: const Color(0xFFCBD5E1),
                ),
              ),

              SizedBox(height: R.pad(context, 16)),

              // ── 3. Email ───────────────────────────────────────────────────
              _buildSingleCard(
                context,
                child: _InfoEditRow(
                  icon: Icons.email_outlined,
                  iconColor: AppColors.primary,
                  iconBgColor: const Color(0xFFE8F7F6),
                  label: l10n.email.toUpperCase(),
                  value: user.email,
                  onTap: null, // Usually read-only
                  trailingIcon: Icons.lock_outline_rounded,
                  trailingColor: const Color(0xFFCBD5E1),
                ),
              ),

              SizedBox(height: R.pad(context, 16)),

              // ── 4. Address ─────────────────────────────────────────────────
              _buildSingleCard(
                context,
                child: _InfoEditRow(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.primary,
                  iconBgColor: const Color(0xFFE8F7F6),
                  label: AppLocalizations.of(context).locale.languageCode == 'ar' ? 'العنوان' : 'ADDRESS',
                  value: 'Manage your addresses',
                  onTap: () {
                    // Navigate to address screen later
                  },
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  trailingColor: const Color(0xFFCBD5E1),
                ),
              ),
              // (End of single cards)

              SizedBox(height: R.pad(context, 40)),

              // ── Save Changes Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 50),
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Teal
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
                          l10n.saveChanges,
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

  Widget _buildSingleCard(BuildContext context, {required Widget child}) {
    return Container(
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
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: child,
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
