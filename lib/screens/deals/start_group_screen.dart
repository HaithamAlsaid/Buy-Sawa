import 'dart:convert';
import 'package:buysawa/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import '../../providers/group_buy_provider.dart';
import '../../models/group_buy_model.dart';
import 'active_group_screen.dart';

class StartGroupScreen extends StatefulWidget {
  const StartGroupScreen({super.key});

  @override
  State<StartGroupScreen> createState() => _StartGroupScreenState();
}

class _StartGroupScreenState extends State<StartGroupScreen> {
  final _nameCtrl = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ─── POST /api/v1/groups ─────────────────────────────────────
  Future<void> _createGroup() async {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    setState(() => _isCreating = true);
    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.groupsEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode({'name': _nameCtrl.text.trim()}),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final respBody = jsonDecode(res.body);
        final data = respBody['data'] ?? respBody;
        final group = GroupBuyModel.fromJson(data as Map<String, dynamic>);
        
        // Refresh the provider so it shows up in DealsScreen right away
        if (mounted) {
          Provider.of<GroupBuyProvider>(context, listen: false).fetchGroups();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ActiveGroupScreen(group: group)),
        );
      } else {
        final respBody = jsonDecode(res.body);
        final msg = respBody['message']?.toString() ??
            (isAr ? 'فشل إنشاء الجروب' : 'Failed to create group');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } catch (e, stack) {
      debugPrint('❌ Create group error: $e');
      debugPrint('Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    final hasName = _nameCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: const Icon(Icons.keyboard_arrow_left_rounded, color: AppColors.textDark),
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).startGroupBuy,
          style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'أنشئ مجموعة شراء جماعي واحصل على كاش باك أكبر مع أصدقائك!'
                          : 'Create a group buy and get more cashback with your friends!',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Group name label
            Text(
              AppLocalizations.of(context).groupName,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: isAr ? 'مثال: جروب الأجهزة' : 'e.g. Gaming Setup Group',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (!hasName || _isCreating) ? null : _createGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasName ? const Color(0xFFF5A623) : const Color(0xFFF6D8A6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      AppLocalizations.of(context).createGroupInvite,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
