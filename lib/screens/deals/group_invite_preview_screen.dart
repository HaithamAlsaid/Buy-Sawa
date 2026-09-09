import 'package:buysawa/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/group_buy_model.dart';
import '../../../providers/group_buy_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/auth_bottom_sheet.dart';
import 'active_group_screen.dart';

class GroupInvitePreviewScreen extends StatefulWidget {
  final String groupCode;

  const GroupInvitePreviewScreen({super.key, required this.groupCode});

  @override
  State<GroupInvitePreviewScreen> createState() => _GroupInvitePreviewScreenState();
}

class _GroupInvitePreviewScreenState extends State<GroupInvitePreviewScreen> {
  GroupBuyModel? _group;
  bool _isLoading = true;
  bool _isJoining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInvite();
  }

  Future<void> _fetchInvite() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    final provider = context.read<GroupBuyProvider>();
    final group = await provider.getGroupInvitation(widget.groupCode);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (group != null) {
          _group = group;
        } else {
          _error = 'Group not found or invitation expired';
        }
      });
    }
  }

  Future<void> _handleJoin() async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      // Must login first
      AuthBottomSheet.show(context);
      return;
    }

    if (_group == null) return;

    final provider = context.read<GroupBuyProvider>();
    
    // Check if already in group
    final alreadyIn = provider.myGroups.any((g) => g.id == _group!.id);
    if (alreadyIn) {
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveGroupScreen(group: _group!),
        ),
      );
      return;
    }

    setState(() => _isJoining = true);
    
    final success = await provider.joinGroupById(_group!.id);
    
    if (!mounted) return;
    
    setState(() => _isJoining = false);
    
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveGroupScreen(group: _group!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join group'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Loading invitation...'),
                  ],
                )
              : _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(isAr ? 'إغلاق' : 'Close'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_add_rounded, size: 64, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          isAr ? 'دعوة للانضمام' : 'Group Invitation',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${isAr ? 'تم دعوتك للانضمام إلى مجموعة' : 'You have been invited to join group'} "${isAr ? _group!.arabicProductName : _group!.productName}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'الأعضاء' : 'Members',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${_group!.memberCount}/${_group!.maxMembers}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isJoining ? null : _handleJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isJoining
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.watch<AuthProvider>().isGuest 
                                      ? (isAr ? 'تسجيل الدخول للانضمام' : 'Login to Join')
                                      : (isAr ? 'انضمام الآن' : 'Join Now'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            isAr ? 'إلغاء' : 'Cancel',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
