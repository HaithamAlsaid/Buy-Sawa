import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../core/services/favourite_service.dart';
import '../../models/product_model.dart';
import '../products/product_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Map<String, dynamic>> _favourites = [];
  bool _loading = true;
  final Set<dynamic> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() => _loading = true);
    final data = await FavouriteService.getFavourites();
    if (mounted) {
      setState(() {
        _favourites = data;
        _loading = false;
      });
    }
  }

  Future<void> _removeFavourite(Map<String, dynamic> item) async {
    // Extract the product/favourite id
    final favId = item['id']?.toString() ?? '';
    if (favId.isEmpty) return;

    setState(() => _removingIds.add(favId));

    final success = await FavouriteService.removeFavourite(favId);

    if (mounted) {
      setState(() => _removingIds.remove(favId));
      if (success) {
        setState(() {
          _favourites.removeWhere((e) => e['id']?.toString() == favId);
        });
        final name = _productName(item, isAr: AppLocalizations.of(context).locale.languageCode == 'ar');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).removedFromFav(name)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Safely extract the product name — returns Arabic name if locale is AR
  String _productName(Map<String, dynamic> item, {bool isAr = false}) {
    final product = item['product'] as Map<String, dynamic>?;
    if (isAr) {
      return product?['arabic_name'] ??
          product?['name_ar'] ??
          product?['name'] ??
          product?['title'] ??
          item['arabic_name'] ??
          item['name'] ??
          item['title'] ??
          '';
    }
    return product?['name'] ??
        product?['title'] ??
        item['name'] ??
        item['title'] ??
        '';
  }

  /// Safely extract image URL
  String _imageUrl(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>?;
    return product?['image_url'] ??
        product?['image'] ??
        product?['thumbnail'] ??
        item['image_url'] ??
        item['image'] ??
        '';
  }

  /// Safely extract price
  double _price(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>?;
    final raw = product?['price'] ?? item['price'];
    return (raw as num?)?.toDouble() ?? 0.0;
  }

  /// Safely extract original price
  double? _originalPrice(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>?;
    final raw = product?['original_price'] ?? item['original_price'];
    return (raw as num?)?.toDouble();
  }

  /// Safely extract rating
  double _rating(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>?;
    final raw = product?['rating'] ?? product?['average_rating'] ?? item['rating'];
    return (raw as num?)?.toDouble() ?? 0.0;
  }

  /// Build a ProductModel from the favourite map (best-effort)
  ProductModel _toProductModel(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>? ?? item;
    return ProductModel(
      id: (product['id'] ?? item['product_id'] ?? '').toString(),
      name: _productName(item),
      arabicName: product['arabic_name'] ?? product['name'] ?? _productName(item),
      category: product['category'] ?? '',
      price: _price(item),
      originalPrice: _originalPrice(item),
      rating: _rating(item),
      reviewCount: (product['review_count'] as int?) ?? 0,
      imageUrl: _imageUrl(item),
      description: product['description'] ?? '',
      arabicDescription: product['arabic_description'] ?? product['description'] ?? '',
      hasGroupDeal: product['has_group_deal'] as bool? ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Teal Header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                R.pad(context, 20),
                R.pad(context, 50),
                R.pad(context, 20),
                R.pad(context, 28),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(R.r(context, 32)),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -40,
                    top: -20,
                    child: Container(
                      width: R.pad(context, 120),
                      height: R.pad(context, 120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    bottom: -10,
                    child: Container(
                      width: R.pad(context, 150),
                      height: R.pad(context, 150),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: R.pad(context, 40),
                          height: R.pad(context, 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: Colors.white,
                            size: R.icon(context, 24),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loading ? '' : l10n.items(_favourites.length),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: R.sp(context, 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: R.pad(context, 2)),
                          Text(
                            l10n.myFavourites,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: R.sp(context, 22),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: R.pad(context, 40),
                        height: R.pad(context, 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: R.icon(context, 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavourites,
                      color: AppColors.primary,
                      child: _favourites.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 120),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite_border_rounded,
                                        color: const Color(0xFF94A3B8),
                                        size: R.icon(context, 64),
                                      ),
                                      SizedBox(height: R.pad(context, 16)),
                                      Text(
                                        l10n.noFavouritesYet,
                                        style: TextStyle(
                                          fontSize: R.sp(context, 16),
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: R.pad(context, 16),
                                vertical: R.pad(context, 20),
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: R.pad(context, 12),
                                mainAxisSpacing: R.pad(context, 16),
                                childAspectRatio: 0.68,
                              ),
                              itemCount: _favourites.length,
                              itemBuilder: (context, index) {
                                final item = _favourites[index];
                                final favId = item['id']?.toString() ?? '';
                                final isRemoving = _removingIds.contains(favId);
                                final name = _productName(item, isAr: isAr);
                                final price = _price(item);
                                final originalPrice = _originalPrice(item);
                                final rating = _rating(item);
                                final imageUrl = _imageUrl(item);

                                final priceFormatted = price
                                    .toStringAsFixed(0)
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]},',
                                    );
                                final originalPriceFormatted = originalPrice
                                    ?.toStringAsFixed(0)
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]},',
                                    );

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                          product: _toProductModel(item),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Opacity(
                                    opacity: isRemoving ? 0.5 : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(R.r(context, 20)),
                                        border: Border.all(
                                          color: const Color(0xFFF1F5F9),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(R.r(context, 20)),
                                                ),
                                                child: imageUrl.isNotEmpty
                                                    ? Image.network(
                                                        imageUrl,
                                                        height: R.pad(context, 130),
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(
                                                          height: R.pad(context, 130),
                                                          color: const Color(0xFFF1F5F9),
                                                          child: const Icon(Icons.image_not_supported_outlined),
                                                        ),
                                                      )
                                                    : Container(
                                                        height: R.pad(context, 130),
                                                        color: const Color(0xFFF1F5F9),
                                                        child: const Icon(Icons.image_not_supported_outlined),
                                                      ),
                                              ),
                                              // Remove heart button
                                              Positioned(
                                                top: R.pad(context, 8),
                                                right: R.pad(context, 8),
                                                child: GestureDetector(
                                                  onTap: isRemoving
                                                      ? null
                                                      : () => _removeFavourite(item),
                                                  child: Container(
                                                    padding: EdgeInsets.all(R.pad(context, 6)),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: isRemoving
                                                        ? SizedBox(
                                                            width: R.icon(context, 16),
                                                            height: R.icon(context, 16),
                                                            child: const CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Color(0xFFF43F5E),
                                                            ),
                                                          )
                                                        : Icon(
                                                            Icons.favorite_rounded,
                                                            color: const Color(0xFFF43F5E),
                                                            size: R.icon(context, 16),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(R.pad(context, 12)),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: R.sp(context, 14),
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  if (rating > 0)
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color: const Color(0xFFF5A623),
                                                          size: R.icon(context, 16),
                                                        ),
                                                        SizedBox(width: R.pad(context, 4)),
                                                        Text(
                                                          rating.toStringAsFixed(1),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: R.sp(context, 12),
                                                            color: const Color(0xFF0F172A),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(height: R.pad(context, 6)),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        priceFormatted,
                                                        style: TextStyle(
                                                          color: AppColors.primary,
                                                          fontSize: R.sp(context, 16),
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                      SizedBox(width: R.pad(context, 6)),
                                                      if (originalPriceFormatted != null)
                                                        Text(
                                                          originalPriceFormatted,
                                                          style: TextStyle(
                                                            color: const Color(0xFF94A3B8),
                                                            fontSize: R.sp(context, 11),
                                                            fontWeight: FontWeight.w500,
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
