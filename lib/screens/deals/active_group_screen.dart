import 'package:buysawa/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/product_service.dart';
import '../../models/group_buy_model.dart';
import '../../models/product_model.dart';
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
  bool _isLoadingMembers = true;
  bool _isLoadingShared = true;
  bool _isSharing = false;

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _sharedProducts = [];
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadSharedProducts();
    if (widget.group.expiresAt != null) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ─── GET /api/v1/groups/{id}/members ─────────────────────────
  Future<void> _loadMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final token = await SecureStorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiService.groupMembersEndpoint(widget.group.id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final rawList = body['data'] is List ? body['data'] as List : [];
        if (mounted) {
          setState(() {
            _members = rawList.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingMembers = false);
  }

  // ─── DELETE /api/v1/groups/{id}/products/{productId} ────────
  Future<void> _removeSharedProduct(String spId) async {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    // Optimistic UI update
    final backup = List<Map<String, dynamic>>.from(_sharedProducts);
    setState(() {
      _sharedProducts.removeWhere((sp) {
        final pivotId = sp['id']?.toString();
        final prodId = sp['product']?['id']?.toString() ?? sp['product_id']?.toString() ?? sp['id']?.toString();
        return pivotId == spId || prodId == spId;
      });
    });

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.delete(
        Uri.parse(ApiService.removeGroupProductEndpoint(widget.group.id, spId)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200 && res.statusCode != 204) {
        // Rollback on failure
        setState(() => _sharedProducts = backup);
        if (mounted) {
          String errorMsg = isAr ? 'حدث خطأ أثناء الحذف' : 'Failed to remove product';
          try {
            final errorBody = jsonDecode(res.body);
            if (errorBody['message'] != null) {
              errorMsg = errorBody['message'].toString();
            }
          } catch (_) {}
          
          errorMsg += ' (ID: $spId)';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: const Color(0xFFEF4444)),
          );
        }
      }
    } catch (_) {
      // Rollback on error
      setState(() => _sharedProducts = backup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isAr ? 'تحقق من الاتصال بالإنترنت' : 'Check your internet connection'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  // ─── GET /api/v1/groups/{id}/products ────────────────────────
  Future<void> _loadSharedProducts() async {
    setState(() => _isLoadingShared = true);
    try {
      final token = await SecureStorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiService.groupProductsEndpoint(widget.group.id)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final rawList = body['data'] is List ? body['data'] as List : [];
        if (mounted) {
          setState(() {
            _sharedProducts = rawList.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingShared = false);
  }

  // ─── POST /api/v1/groups/{id}/products/share ─────────────────
  Future<void> _shareProductInGroup(String productId, {String? variantId, String? note}) async {
    setState(() => _isSharing = true);
    try {
      final token = await SecureStorageService.getToken();
      final body = <String, dynamic>{'product_id': productId};
      if (variantId != null) body['product_variant_id'] = variantId;
      if (note != null && note.isNotEmpty) body['note'] = note;

      final res = await http.post(
        Uri.parse(ApiService.shareProductInGroupEndpoint(widget.group.id)),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        await _loadSharedProducts(); // refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).locale.languageCode == 'ar'
                ? 'تم مشاركة المنتج في الجروب!'
                : 'Product shared in group!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        final respBody = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(respBody['message']?.toString() ?? 'Failed to share product'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error'), backgroundColor: Color(0xFFEF4444)),
        );
      }
    }
    if (mounted) setState(() => _isSharing = false);
  }

  // ─── Share product picker bottom sheet ───────────────────────
  Future<void> _showShareProductSheet() async {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    // fetch products
    final products = await ProductService.getProducts();
    if (!mounted) return;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'لا توجد منتجات' : 'No products found')),
      );
      return;
    }

    String? selectedProductId;
    final noteCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      isAr ? 'شارك منتج في الجروب' : 'Share Product in Group',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              // Note field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    hintText: isAr ? 'أضف تعليق (اختياري)...' : 'Add a note (optional)...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Product list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = products[i];
                    final isSelected = selectedProductId == p.id;
                    return GestureDetector(
                      onTap: () => setSheetState(() {
                        selectedProductId = p.id;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: p.imageUrl.isNotEmpty
                                  ? Image.network(p.imageUrl, width: 52, height: 52, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _productIconPlaceholder())
                                  : _productIconPlaceholder(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? (p.arabicName.isNotEmpty ? p.arabicName : p.name) : p.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.price.toStringAsFixed(0)} AED',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Share button
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: selectedProductId == null
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              _shareProductInGroup(
                                selectedProductId!,
                                note: noteCtrl.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: const Color(0xFFB2DFDB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isAr ? 'شارك في الجروب' : 'Share in Group',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
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

  Widget _productIconPlaceholder() => Container(
    width: 52, height: 52,
    color: const Color(0xFFF1F5F9),
    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 24),
  );

  // ─── Leave group ─────────────────────────────────────────────
  Future<void> _leaveGroup() async {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? 'مغادرة الجروب' : 'Leave Group', style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(isAr ? 'هل أنت متأكد أنك تريد مغادرة هذا الجروب؟' : 'Are you sure you want to leave this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
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
        Navigator.pop(context);
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
        final msg = body['message'] ?? (isAr ? 'حدث خطأ، حاول مرة أخرى' : 'Something went wrong');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.toString()), backgroundColor: const Color(0xFFEF4444)),
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

  // ─── Navigate to product details ─────────────────────────────
  Future<void> _openProductDetails() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    final product = await ProductService.getProductById(widget.group.productId);
    if (!mounted) return;
    Navigator.pop(context);
    if (product != null) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product, groupId: widget.group.id),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found'), backgroundColor: Color(0xFFEF4444)),
      );
    }
  }

  //  Share group link 
  void _shareGroup() {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    final group = widget.group;
    final link = 'https://buysawa.com/groups/join?code=${group.code}';
    final msg = isAr
        ? 'انضم إلى جروب ${group.arabicOwnerName} واحصل على خصم ${group.discountPercent}%!\nاستخدم الكود: ${group.code}\n$link'
        : 'Join ${group.ownerName}\'s group and get ${group.discountPercent}% off!\nUse code: ${group.code}\n$link';
    Share.share(msg);
  }

  // Build 
  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    final group = widget.group;

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
              decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: const Icon(Icons.keyboard_arrow_left_rounded, color: AppColors.textDark),
            ),
          ),
        ),
        title: Text(
          isAr ? 'تفاصيل المجموعة' : 'Group Details',
          style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _shareGroup,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                child: const Icon(Icons.share_outlined, color: AppColors.textDark, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadMembers();
          await _loadSharedProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Members Row ──────────────────────────────────
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _members.isEmpty
                            ? []
                            : _members.asMap().entries.map((e) {
                                final m = e.value;
                                final name = m['name']?.toString() ?? m['user']?['name']?.toString() ?? m['username']?.toString() ?? 'User';
                                final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
                                final colors = [const Color(0xFF00897B), const Color(0xFFF5A623), const Color(0xFFD81B60), const Color(0xFF7E57C2), const Color(0xFF43A047)];
                                final color = colors[e.key % colors.length];
                                final isOwner = m['is_owner'] == true || m['role'] == 'owner';
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _buildMemberAvatar(initials, name, color, isOwner: isOwner),
                                );
                              }).toList(),
                      ),
                    ),

              const SizedBox(height: 24),

              // ── Timer Pill ───────────────────────────────────
              if (group.expiresAt != null)
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
                        _formatExpiry(group.expiresAt!),
                        style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),



              // ── Shared Products Section ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      isAr ? 'منتجات مشتركة في الجروب' : 'Shared Products',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _isSharing ? null : _showShareProductSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isSharing
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              isAr ? 'شارك منتج' : 'Share',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _sharedProducts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFFCBD5E1)),
                                const SizedBox(height: 8),
                                Text(
                                  isAr ? 'لا توجد منتجات مشتركة بعد' : 'No shared products yet',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  isAr ? 'شارك منتج مع أعضاء الجروب!' : 'Share a product with group members!',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _sharedProducts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final sp = _sharedProducts[i];
                            final pName = sp['product']?['name']?.toString() ?? sp['name']?.toString() ?? 'Product';
                            final pPrice = sp['product']?['price']?.toString() ?? sp['price']?.toString() ?? '';
                            final sharedBy = sp['shared_by']?['name']?.toString() ?? sp['user']?['name']?.toString() ?? '';
                            final note = sp['note']?.toString() ?? '';
                            String imageUrl = sp['product']?['image_url']?.toString() ?? sp['product']?['image']?.toString() ?? sp['image_url']?.toString() ?? sp['image']?.toString() ?? '';
                            if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                              if (imageUrl.startsWith('/')) {
                                imageUrl = 'https://buysawa.com$imageUrl';
                              } else {
                                imageUrl = 'https://buysawa.com/storage/$imageUrl';
                              }
                            }
                            final pivotId = sp['id']?.toString();
                            final prodId = sp['product_id']?.toString() ?? sp['product']?['id']?.toString() ?? pivotId;
                            return GestureDetector(
                              onTap: prodId == null ? null : () {
                                HapticFeedback.lightImpact();
                                final stubProduct = ProductModel(
                                  id: prodId,
                                  name: pName,
                                  arabicName: pName,
                                  category: 'Deal',
                                  price: double.tryParse(pPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
                                  rating: 5.0,
                                  reviewCount: 0,
                                  imageUrl: imageUrl,
                                  description: '',
                                  arabicDescription: '',
                                );
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(product: stubProduct, groupId: widget.group.id),
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(imageUrl, width: 52, height: 52, fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _productIconPlaceholder())
                                          : _productIconPlaceholder(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(pName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          if (pPrice.isNotEmpty)
                                            Text('$pPrice AED', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                                          if (note.isNotEmpty)
                                            Text(note, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          if (sharedBy.isNotEmpty)
                                            Text('${isAr ? 'بواسطة' : 'by'} $sharedBy', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                    if (pivotId != null)
                                      IconButton(
                                        onPressed: () => _removeSharedProduct(pivotId),
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    if (pivotId != null) const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

              const SizedBox(height: 24),

              // ── Leave Button (Hidden if Owner)
              if (!_members.any((m) => (m['is_current_user'] == true || m['id'] == 'my_id') && (m['is_owner'] == true || m['role'] == 'owner')))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isLeaving ? null : _leaveGroup,
                      icon: _isLeaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                          : const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                      label: Text(
                        isAr ? 'مغادرة المجموعة' : 'Leave Group',
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupDealCheckoutScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isAr ? 'الدفع' : 'Checkout',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatExpiry(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    
    if (d > 0) {
      return '${d}d ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} left';
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
            ),
            if (isOwner)
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Color(0xFFF5A623), shape: BoxShape.circle),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
