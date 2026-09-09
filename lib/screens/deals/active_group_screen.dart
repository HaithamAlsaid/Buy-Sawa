import 'package:buysawa/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../models/group_buy_model.dart';
import '../../core/services/product_service.dart';
import '../products/product_detail_screen.dart';
import 'group_deal_checkout_screen.dart';

class ActiveGroupScreen extends StatefulWidget {
  final GroupBuyModel group;

  const ActiveGroupScreen({super.key, required this.group});

  @override
  State<ActiveGroupScreen> createState() => _ActiveGroupScreenState();
}

class _ActiveGroupScreenState extends State<ActiveGroupScreen> {
  bool _isLeaving = false;

  Future<void> _leaveGroup() async {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'مغادرة الجروب' : 'Leave Group',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد أنك تريد مغادرة هذا الجروب؟'
              : 'Are you sure you want to leave this group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAr ? 'مغادرة' : 'Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLeaving = true);

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.delete(
        Uri.parse(ApiService.leaveGroupEndpoint(widget.group.id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 204) {
        Navigator.pop(context); // Go back to groups list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'تم مغادرة الجروب بنجاح' : 'Left the group successfully'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        final body = jsonDecode(res.body);
        final msg = body['message'] ?? (isAr ? 'حدث خطأ، حاول مرة أخرى' : 'Something went wrong, try again');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.toString()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'تحقق من الاتصال بالإنترنت' : 'Check your internet connection'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLeaving = false);
    }
  }

  Future<void> _openProductDetails() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final product = await ProductService.getProductById(widget.group.productId);
    
    if (!mounted) return;
    Navigator.pop(context); // hide loading

    if (product != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
            groupId: widget.group.id,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not found'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _shareGroup() {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    final group = widget.group;

    // Build the invite link with the group code
    final inviteLink = 'https://buysawa.com/groups/join?code=${group.code}';

    final shareText = isAr
        ? 'دعوتك للانضمام لجروب "${group.arabicProductName}" على تطبيق Buy Sawa!\n'
          'كود الجروب: ${group.code}\n'
          'اضغط على الرابط للانضمام مباشرة:\n$inviteLink'
        : 'Join my group "${group.productName}" on Buy Sawa and get a discount!\n'
          'Group Code: ${group.code}\n'
          'Tap the link to join:\n$inviteLink';

    Share.share(
      shareText,
      subject: isAr ? 'دعوة للانضمام للجروب' : 'Group Invite - Buy Sawa',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).locale.languageCode == 'ar'
              ? 'تفاصيل المجموعة'
              : 'Group Details',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          // Share button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _shareGroup,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.share_outlined,
                  color: AppColors.textDark,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Members Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMemberAvatar('YO', 'You', const Color(0xFF00897B), isOwner: true),
                  const SizedBox(width: 16),
                  _buildMemberAvatar('AH', 'Ahmed', const Color(0xFFF5A623)),
                  const SizedBox(width: 16),
                  _buildMemberAvatar('LA', 'Layla', const Color(0xFFD81B60)),
                  const SizedBox(width: 16),
                  _buildMemberAvatar('OM', 'Omar', const Color(0xFF7E57C2)),
                  const SizedBox(width: 16),
                  _buildMemberAvatar('SA', 'Sara', const Color(0xFF43A047)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Timer Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: Color(0xFFE65100), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Expires in 47:59:11',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Product Area with Tooltip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // The Product Item
                  GestureDetector(
                    onTap: _openProductDetails,
                    child: Container(
                      margin: const EdgeInsets.only(top: 24), // Space for tooltip
                      padding: const EdgeInsets.all(8), // Make tap target slightly larger
                      decoration: BoxDecoration(
                        color: Colors.transparent, // For tap area
                      ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107), // Yellow bg
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.headphones_rounded,
                            size: 40,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).locale.languageCode == 'ar' ? widget.group.arabicProductName : widget.group.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '1,299',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: AppColors.primary, // Teal
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context).aed,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ), // Close GestureDetector
                  // The Tooltip
                  Positioned(
                    top: -12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B), // Slate 800
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_active_outlined, color: Color(0xFFF5A623), size: 14),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).locale.languageCode == 'ar' ? 'انضم أحمد للمجموعة!' : 'Ahmed joined the group!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Leave Button at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLeaving ? null : _leaveGroup,
                  icon: _isLeaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)),
                        )
                      : const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  label: Text(
                    AppLocalizations.of(context).locale.languageCode == 'ar' ? 'مغادرة المجموعة' : 'Leave Group',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupDealCheckoutScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623), // Solid Orange
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).locale.languageCode == 'ar' ? 'الدفع' : 'Checkout',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(String initials, String name, Color color, {bool isOwner = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            if (isOwner)
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5A623),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
