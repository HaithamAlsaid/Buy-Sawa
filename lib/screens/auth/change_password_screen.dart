import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  
  bool _obsCurrent = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      _currentCtrl.text, 
      _newCtrl.text, 
      _confirmCtrl.text,
    );
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to change password'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          isAr ? 'تغيير كلمة المرور' : 'Change Password',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'قم بإنشاء كلمة مرور جديدة لتأمين حسابك.' : 'Create a new password to secure your account.',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: R.sp(context, 14),
                  height: 1.5,
                ),
              ),
              SizedBox(height: R.pad(context, 24)),
              
              _buildLabel(isAr ? 'كلمة المرور الحالية' : 'Current Password'),
              _buildField(_currentCtrl, _obsCurrent, () => setState(() => _obsCurrent = !_obsCurrent)),
              SizedBox(height: R.pad(context, 20)),
              
              _buildLabel(isAr ? 'كلمة المرور الجديدة' : 'New Password'),
              _buildField(_newCtrl, _obsNew, () => setState(() => _obsNew = !_obsNew), isNew: true),
              SizedBox(height: R.pad(context, 20)),
              
              _buildLabel(isAr ? 'تأكيد كلمة المرور الجديدة' : 'Confirm New Password'),
              _buildField(_confirmCtrl, _obsConfirm, () => setState(() => _obsConfirm = !_obsConfirm), isConfirm: true),
              SizedBox(height: R.pad(context, 32)),
              
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 50),
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
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
                          isAr ? 'حفظ التغييرات' : 'Save Changes',
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.pad(context, 8)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(context, 13),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, bool obs, VoidCallback toggle, {bool isNew = false, bool isConfirm = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obs,
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (isNew && val.length < 6) return 'Password too short';
        if (isConfirm && val != _newCtrl.text) return 'Passwords do not match';
        return null;
      },
      style: TextStyle(fontSize: R.sp(context, 14)),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF94A3B8),
            size: 20,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
