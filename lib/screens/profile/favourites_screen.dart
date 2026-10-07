import 'package:buysawa/core/services/product_service.dart';
import 'package:buysawa/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../core/services/favourite_service.dart';
import '../../models/product_model.dart';
import '../../widgets/cached_image.dart';
import '../products/product_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<ProductModel> _favourites = [];
  bool _loading = true;
  final Set<String> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() => _loading = true);
    final data = await FavouriteService.getFavourites();
    
    List<ProductModel> resolvedProducts = [];
    final productProvider = context.read<ProductProvider>();

    for (var item in data) {
      final idStr = (item['favoritable_id'] ?? item['model_id'] ?? item['product_id'] ?? '').toString();
      if (idStr.isEmpty) continue;

      // Try to find in provider first
      try {
        final existing = productProvider.products.firstWhere((p) => p.id == idStr);
        resolvedProducts.add(existing);
        continue;
      } catch (_) {}

      // If not in provider, fetch from API
      try {
        final fetched = await ProductService.getProductById(idStr);
        if (fetched != null) {
          resolvedProducts.add(fetched);
          continue;
        }
      } catch (_) {}

      // Ultimate fallback: create a dummy with just the title
      final favoritable = item['favoritable'] as Map<String, dynamic>? ?? {};
      resolvedProducts.add(ProductModel(
        id: idStr,
        name: favoritable['title'] ?? favoritable['name'] ?? 'Product',
        arabicName: favoritable['title'] ?? favoritable['name'] ?? 'Product',
        category: '',
        price: 0,
        rating: 0,
        reviewCount: 0,
        imageUrl: '',
        description: '',
        arabicDescription: '',
      ));
    }

    if (mounted) {
      setState(() {
        _favourites = resolvedProducts;
        _loading = false;
      });
    }
  }

  Future<void> _removeFavourite(ProductModel product) async {
    setState(() => _removingIds.add(product.id));

    // The backend POST endpoint for favorites acts as a toggle, so calling addFavourite
    // with the product ID will remove it from favorites.
    final success = await FavouriteService.addFavourite(product.id);

    if (mounted) {
      setState(() => _removingIds.remove(product.id));
      if (success) {
        setState(() {
          _favourites.removeWhere((e) => e.id == product.id);
        });
        final name = AppLocalizations.of(context).locale.languageCode == 'ar' ? product.arabicName : product.name;
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
                                final product = _favourites[index];
                                final isRemoving = _removingIds.contains(product.id);
                                final name = isAr ? product.arabicName : product.name;
                                final price = product.price;
                                final originalPrice = product.originalPrice;
                                final rating = product.rating;
                                final imageUrl = product.imageUrl;

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
                                          product: product,
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
                                                    ? CachedImage(
                                                        imageUrl: imageUrl.startsWith('http') 
                                                            ? imageUrl 
                                                            : 'https://buysawa.com${imageUrl.startsWith('/') ? '' : '/'}$imageUrl',
                                                        height: R.pad(context, 130),
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: R.pad(context, 130),
                                                        color: AppColors.background,
                                                        child: Center(
                                                          child: Icon(Icons.image_rounded, color: AppColors.textLight, size: R.icon(context, 40)),
                                                        ),
                                                      ),
                                              ),
                                              // Remove heart button
                                              Positioned(
                                                top: R.pad(context, 8),
                                                right: R.pad(context, 8),
                                                child: GestureDetector(
                                                  onTap: isRemoving
                                                      ? null
                                                      : () => _removeFavourite(product),
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
                                                    name.isEmpty ? product.id : name,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: R.sp(context, 14),
                                                      color: AppColors.textDark,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: R.pad(context, 4)),

                                                  SizedBox(height: R.pad(context, 6)),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${priceFormatted} AED',
                                                        style: TextStyle(
                                                          color: AppColors.primary,
                                                          fontSize: R.sp(context, 15),
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                      if (originalPriceFormatted != null && originalPrice != null && originalPrice > price) ...[
                                                        SizedBox(width: R.pad(context, 6)),
                                                        Text(
                                                          originalPriceFormatted,
                                                          style: TextStyle(
                                                            color: AppColors.textLight,
                                                            fontSize: R.sp(context, 12),
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        ),
                                                      ]
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
