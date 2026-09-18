import 'dart:convert';
import 'package:buysawa/core/services/product_service.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import '../../core/services/secure_storage_service.dart' as ss;
import 'package:buysawa/screens/deals/widgets/share_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_buy_provider.dart';
import '../../widgets/auth_bottom_sheet.dart';
import '../deals/deals_screen.dart';
import 'cart_screen.dart';
import '../../core/services/secure_storage_service.dart' as secure_storage;
import '../../core/services/favourite_service.dart';
import '../../core/services/referral_service.dart';
import '../../widgets/cached_image.dart';

// ───────────────────────────────────────────────────────────────


class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final String? groupId;
  final String? referralCode;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.groupId,
    this.referralCode,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const _teal = AppColors.primary;

  bool _addedToCart = false;
  bool _startingGroup = false;
  bool _isWishlisted = false;
  String? _selectedSize;
  bool _specsExpanded = false;
  ProductVariationModel? _selectedVariation;
  late final PageController _pageCtrl;
  int _currentImageIndex = 0;
  ProductModel? _fullProduct;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _checkIfFavourite();
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      // Fetch product details and variations in parallel
      final token = await ss.SecureStorageService.getToken();
      final results = await Future.wait([
        ProductService.getProductById(widget.product.id),
        http.get(
          Uri.parse(ApiService.productVariationsEndpoint(widget.product.id)),
          headers: ApiService.headers(token: token),
        ).timeout(const Duration(seconds: 10)),
      ]);

      if (!mounted) return;

      final p = results[0] as ProductModel?;
      final variationsRes = results[1] as http.Response;

      List<ProductVariationModel> fetchedVariations = [];
      if (variationsRes.statusCode == 200) {
        final body = jsonDecode(variationsRes.body);
        final rawList = body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);
        fetchedVariations = rawList
            .map((e) => ProductVariationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (p != null) {
        setState(() {
          _fullProduct = fetchedVariations.isNotEmpty
              ? p.copyWith(variations: fetchedVariations, isVariable: true)
              : p;
        });
      }
    } catch (_) {}
  }

  void _checkIfFavourite() async {
    final favs = await FavouriteService.getFavourites();
    if (mounted) {
      final isFav = favs.any((f) {
        final id =
            (f['favoritable_id'] ??
                    f['product_id'] ??
                    f['model_id'] ??
                    f['id'] ??
                    '')
                .toString();
        return id == widget.product.id;
      });
      setState(() {
        _isWishlisted = isFav;
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // Actions

  void _addToCart() {
    final l10n = AppLocalizations.of(context);
    if (widget.product.isVariable && _selectedVariation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.locale.languageCode == 'ar'
                ? 'برجاء اختيار تفاصيل المنتج أولاً'
                : 'Please select an option first',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    context.read<CartProvider>().add(
      widget.product,
      variantId: _selectedVariation?.id,
      variation: _selectedVariation,
      groupId: widget.groupId,
      referralCode: widget.referralCode,
    );
    setState(() => _addedToCart = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${l10n.locale.languageCode == 'ar' ? widget.product.arabicName : widget.product.name} ${l10n.addedToCart}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: l10n.viewCart,
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleWishlist() async {
    final oldState = _isWishlisted;
    setState(() => _isWishlisted = !_isWishlisted);

    bool success;
    if (_isWishlisted) {
      success = await FavouriteService.addFavourite(widget.product.id);
    } else {
      success = await FavouriteService.removeFavourite(widget.product.id);
    }

    if (!success && mounted) {
      setState(() => _isWishlisted = oldState);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isSharing = false;

  Future<void> _shareProduct() async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      AuthBottomSheet.show(context);
      return;
    }

    if (_isSharing) return;
    setState(() => _isSharing = true);

    final token = await secure_storage.SecureStorageService.getToken();
    final service = ReferralService();
    final tokenOrUrl = await service.shareProduct(
      widget.product.id,
      token ?? '',
    );

    if (mounted) {
      setState(() => _isSharing = false);
    }

    final p = widget.product;
    String shareUrl = 'https://buysawa.com/p/${p.id}';

    if (tokenOrUrl != null && tokenOrUrl != 'success') {
      if (tokenOrUrl.startsWith('http')) {
        shareUrl = tokenOrUrl;
      } else {
        shareUrl = 'https://buysawa.com/share/$tokenOrUrl';
      }
    }

    Share.share(
      'Check out ${p.name} on BuySawa for just ${p.price.toInt()} AED! 🛍️\n'
      'Shop now: $shareUrl',
      subject: 'Check out ${p.name} on BuySawa!',
    );
  }

  Future<void> _startGroupBuy() async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      AuthBottomSheet.show(context);
      return;
    }

    // Instead of creating a new group directly, we let the user choose which group to share to.
    ShareBottomSheet.show(context, widget.product);
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final product = _fullProduct ?? widget.product;
    final specs = product.attributes;
    final l10n = AppLocalizations.of(context);
    final discountPct = (_selectedVariation != null && _selectedVariation!.comparePrice != null && _selectedVariation!.comparePrice! > _selectedVariation!.price)
        ? (((_selectedVariation!.comparePrice! - _selectedVariation!.price) / _selectedVariation!.comparePrice!) * 100).toInt()
        : (product.originalPrice != null && product.originalPrice! > product.price
            ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100).toInt()
            : 0);

    // Sizes only for relevant categories

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F5),
      body: Stack(
        children: [
          // ────────────────────────────────────────────────────
          // Scrollable content
          // ────────────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── Hero image area ──
              SliverAppBar(
                expandedHeight: R.h(context, 0.38),
                backgroundColor: const Color(0xFFEAF5F5),
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroSection(
                    product: product,
                    variation: _selectedVariation,
                    isWishlisted: _isWishlisted,
                    onBack: () => Navigator.pop(context),
                    onWishlist: _toggleWishlist,
                    onShare: _shareProduct,
                  ),
                ),
              ),

              // ── White content card ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(R.r(context, 30)),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.pad(context, 20),
                      R.pad(context, 20),
                      R.pad(context, 20),
                      R.pad(context, 130), // space for bottom bar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge + rating row
                        _BadgeRatingRow(
                              product: product,
                              discountPct: discountPct,
                            )
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 10)),

                        // Product name
                        Text(
                          AppLocalizations.of(context).locale.languageCode ==
                                  'ar'
                              ? product.arabicName
                              : product.name,
                          style: TextStyle(
                            fontSize: R.sp(context, 22),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 10)),

                        // Price row
                        _PriceRow(
                          product: product,
                          variation: _selectedVariation,
                          discountPct: discountPct,
                        ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 16)),

                        // Promotional Subtle Text
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: R.pad(context, 12),
                            vertical: R.pad(context, 8),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4), // Very light green
                            borderRadius: BorderRadius.circular(
                              R.r(context, 8),
                            ),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '✨',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(width: R.pad(context, 6)),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).shareProductDesc,
                                      style: TextStyle(
                                        fontSize: R.sp(context, 12),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: R.pad(context, 4)),
                              Row(
                                children: [
                                  const Text(
                                    '👥',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(width: R.pad(context, 6)),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).startGroupBuyDesc,
                                      style: TextStyle(
                                        fontSize: R.sp(context, 12),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 22)),

                        // Variation selector (if variable)
                        if (product.isVariable && product.variations.isNotEmpty) ...[
                          _VariationSelector(
                            variations: product.variations,
                            selected: _selectedVariation,
                            onSelect: (v) => setState(() => _selectedVariation = v),
                          ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.15),
                          SizedBox(height: R.pad(context, 22)),
                        ],

                        // Product Details
                        _SectionTitle(title: l10n.productDetails),
                        SizedBox(height: R.pad(context, 10)),
                        Text(
                          AppLocalizations.of(context).locale.languageCode ==
                                  'ar'
                              ? (product.arabicDescription.isNotEmpty
                                    ? product.arabicDescription
                                    : 'لا يوجد وصف متاح لهذا المنتج.')
                              : (product.description.isNotEmpty
                                    ? product.description
                                    : 'No description available for this product.'),
                          style: TextStyle(
                            fontSize: R.sp(context, 13),
                            height: 1.65,
                            color: const Color(0xFF475569),
                          ),
                        ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 24)),

                        // Specifications + Product Type
                        if (specs != null && specs.isNotEmpty || true) ...[ // always show type
                          _SectionTitle(title: l10n.specifications),
                          SizedBox(height: R.pad(context, 10)),

                          //Product Type Badge
                          Container(
                            padding: EdgeInsets.all(R.pad(context, 14)),
                            margin: EdgeInsets.only(bottom: R.pad(context, 8)),
                            decoration: BoxDecoration(
                              color: product.isVariable
                                  ? const Color(0xFFF0F4FF)
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(R.r(context, 10)),
                              border: Border.all(
                                color: product.isVariable
                                    ? const Color(0xFFBFD0FF)
                                    : const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  product.isVariable
                                      ? Icons.tune_rounded
                                      : Icons.inventory_2_outlined,
                                  size: R.icon(context, 18),
                                  color: product.isVariable
                                      ? const Color(0xFF3B5FDD)
                                      : const Color(0xFF16A34A),
                                ),
                                SizedBox(width: R.pad(context, 10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).locale.languageCode == 'ar'
                                          ? 'نوع المنتج'
                                          : 'Product Type',
                                      style: TextStyle(
                                        fontSize: R.sp(context, 11),
                                        color: const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      product.isVariable
                                          ? (AppLocalizations.of(context).locale.languageCode == 'ar'
                                              ? 'متعدد الخيارات'
                                              : 'Variable Product')
                                          : (AppLocalizations.of(context).locale.languageCode == 'ar'
                                              ? 'منتج بسيط'
                                              : 'Simple Product'),
                                      style: TextStyle(
                                        fontSize: R.sp(context, 13),
                                        fontWeight: FontWeight.w800,
                                        color: product.isVariable
                                            ? const Color(0xFF3B5FDD)
                                            : const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 290.ms).slideY(begin: 0.15),

                          if (specs != null && specs.isNotEmpty) ...[ 
                            _SpecsTable(
                              specs: specs,
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

                            // View all specs
                            if (!_specsExpanded) ...[
                              SizedBox(height: R.pad(context, 8)),
                              GestureDetector(
                                onTap: () => setState(() => _specsExpanded = true),
                                child: Text(
                                  l10n.viewAllSpecs,
                                  style: TextStyle(
                                    fontSize: R.sp(context, 12),
                                    color: _teal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                          SizedBox(height: R.pad(context, 24)),
                        ],



                        SizedBox(height: R.pad(context, 24)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ────────────────────────────────────────────────────
          // Fixed bottom action bar
          // ────────────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomBar(
              addedToCart: _addedToCart,
              startingGroup: _startingGroup,
              onAddToCart: _addToCart,
              onGroupBuy: _startGroupBuy,
            ).animate().slideY(begin: 1, delay: 500.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────

// ── Hero Section with Color Carousel ────────────────────────────
class _HeroSection extends StatefulWidget {
  final ProductModel product;
  final ProductVariationModel? variation;
  final bool isWishlisted;
  final VoidCallback onBack;
  final VoidCallback onWishlist;
  final VoidCallback onShare;

  const _HeroSection({
    required this.product,
    this.variation,
    required this.isWishlisted,
    required this.onBack,
    required this.onWishlist,
    required this.onShare,
  });

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> get _images {
    // If a variation has its own image, show it first
    final variationImg = widget.variation?.imageUrl?.trim();
    final mainImg = widget.product.imageUrl.trim();
    final alternates = widget.product.alternateImages ?? [];

    final List<String> all = [];
    if (variationImg != null && variationImg.isNotEmpty) {
      all.add(variationImg);
    } else if (mainImg.isNotEmpty) {
      all.add(mainImg);
    }
    for (final img in alternates) {
      final trimmed = img.trim();
      if (trimmed.isNotEmpty && !all.contains(trimmed)) {
        all.add(trimmed);
      }
    }
    return all.isEmpty ? [''] : all;
  }

  String _resolveUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://buysawa.com${url.startsWith('/') ? '' : '/'}$url';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    return SafeArea(
      child: Column(
        children: [
          // Main Large Image 
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final url = _resolveUrl(images[index]);
                    final Widget imageWidget = url.isEmpty
                        ? Icon(
                            Icons.image_outlined,
                            size: R.icon(context, 80),
                            color: const Color(0xFF94A3B8),
                          )
                        : CachedImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          );

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          R.pad(context, 40),
                          R.pad(context, 16),
                          R.pad(context, 40),
                          R.pad(context, 8),
                        ),
                        child: index == 0
                            ? Hero(
                                tag: 'product_${widget.product.id}',
                                child: imageWidget,
                              )
                            : imageWidget,
                      ),
                    );
                  },
                ),

                // Left Arrow
                if (_currentIndex > 0)
                  Positioned(
                    left: R.pad(context, 8),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _CircleBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  ),

                // Right Arrow
                if (_currentIndex < images.length - 1)
                  Positioned(
                    right: R.pad(context, 8),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _CircleBtn(
                        icon: Icons.arrow_forward_ios_rounded,
                        onTap: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  ),

                // Back button
                Positioned(
                  top: R.pad(context, 12),
                  left: R.pad(context, 16),
                  child: _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: widget.onBack,
                  ),
                ),

                // Wishlist + share
                Positioned(
                  top: R.pad(context, 12),
                  right: R.pad(context, 16),
                  child: Row(
                    children: [
                      _CircleBtn(
                        icon: widget.isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: widget.isWishlisted ? Colors.red : null,
                        onTap: widget.onWishlist,
                      ),
                      SizedBox(width: R.pad(context, 8)),
                      _CircleBtn(icon: Icons.share_outlined, onTap: widget.onShare),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Thumbnails Strip (like website) ────────────────────
          if (images.length > 1)
            Container(
              height: R.pad(context, 72),
              padding: EdgeInsets.symmetric(
                horizontal: R.pad(context, 12),
                vertical: R.pad(context, 8),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: R.pad(context, 8)),
                itemBuilder: (context, index) {
                  final url = _resolveUrl(images[index]);
                  final isSelected = _currentIndex == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: R.pad(context, 56),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(R.r(context, 10)),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(R.r(context, 9)),
                        child: url.isEmpty
                            ? const Icon(Icons.image_outlined, color: Colors.grey)
                            : CachedImage(
                                imageUrl: url,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Badge + Rating
class _BadgeRatingRow extends StatelessWidget {
  final ProductModel product;
  final int discountPct;
  const _BadgeRatingRow({required this.product, required this.discountPct});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Featured badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.pad(context, 10),
            vertical: R.pad(context, 4),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5F5),
            borderRadius: BorderRadius.circular(R.r(context, 20)),
          ),
          child: Text(
            AppLocalizations.of(context).locale.languageCode == 'ar'
                ? 'مميّز'
                : 'Featured',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: R.sp(context, 11),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Star rating
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: const Color(0xFFF5A623),
              size: R.icon(context, 17),
            ),
            SizedBox(width: R.pad(context, 4)),
            Text(
              '${product.rating}',
              style: TextStyle(
                fontSize: R.sp(context, 13),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(width: R.pad(context, 4)),
            Text(
              '(${product.reviewCount > 999 ? '${(product.reviewCount / 1000).toStringAsFixed(1)}k' : product.reviewCount})',
              style: TextStyle(
                fontSize: R.sp(context, 12),
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Price row ───────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final ProductModel product;
  final ProductVariationModel? variation;
  final int discountPct;
  const _PriceRow({required this.product, this.variation, required this.discountPct});

  @override
  Widget build(BuildContext context) {
    final displayPrice = variation != null ? variation!.price : product.price;
    final displayOriginalPrice = variation != null ? variation!.comparePrice : product.originalPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${displayPrice.toInt()}',
          style: TextStyle(
            fontSize: R.sp(context, 28),
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: R.pad(context, 4),
            left: R.pad(context, 4),
          ),
          child: Text(
            'AED',
            style: TextStyle(
              fontSize: R.sp(context, 12),
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (displayOriginalPrice != null && displayOriginalPrice > displayPrice) ...[
          SizedBox(width: R.pad(context, 10)),
          Padding(
            padding: EdgeInsets.only(bottom: R.pad(context, 4)),
            child: Text(
              '${displayOriginalPrice.toInt()}',
              style: TextStyle(
                fontSize: R.sp(context, 14),
                decoration: TextDecoration.lineThrough,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: R.pad(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: R.pad(context, 8),
              vertical: R.pad(context, 3),
            ),
            margin: EdgeInsets.only(bottom: R.pad(context, 4)),
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623),
              borderRadius: BorderRadius.circular(R.r(context, 10)),
            ),
            child: Text(
              '-$discountPct%',
              style: TextStyle(
                color: Colors.white,
                fontSize: R.sp(context, 11),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Variation selector ───────────────────────────────────────────────
class _VariationSelector extends StatelessWidget {
  final List<ProductVariationModel> variations;
  final ProductVariationModel? selected;
  final ValueChanged<ProductVariationModel> onSelect;
  const _VariationSelector({required this.variations, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).locale.languageCode == 'ar'
                  ? 'اختر النسخة'
                  : 'Select Option',
              style: TextStyle(
                fontSize: R.sp(context, 14),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        SizedBox(height: R.pad(context, 10)),
        Wrap(
          spacing: R.pad(context, 8),
          runSpacing: R.pad(context, 8),
          children: variations.map((v) {
            final isSelected = selected?.id == v.id;
            return GestureDetector(
              onTap: () => onSelect(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: R.pad(context, 12), vertical: R.pad(context, 10)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(R.r(context, 12)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  v.name,
                  style: TextStyle(
                    fontSize: R.sp(context, 13),
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Section title ───────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: R.sp(context, 15),
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

// ── Specs table ─────────────────────────────────────────────────
class _SpecsTable extends StatelessWidget {
  final Map<String, String> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries.toList();
    return Column(
      children: entries.map((e) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: R.pad(context, 6)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: R.pad(context, 7),
                height: R.pad(context, 7),
                margin: EdgeInsets.only(
                  top: R.pad(context, 5),
                  right: R.pad(context, 10),
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  e.key,
                  style: TextStyle(
                    fontSize: R.sp(context, 13),
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ':',
                style: TextStyle(
                  color: const Color(0xFFCBD5E1),
                  fontSize: R.sp(context, 13),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: R.sp(context, 13),
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Bottom action bar ───────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final bool addedToCart;
  final bool startingGroup;
  final VoidCallback onAddToCart;
  final VoidCallback onGroupBuy;

  const _BottomBar({
    required this.addedToCart,
    required this.startingGroup,
    required this.onAddToCart,
    required this.onGroupBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        R.pad(context, 20),
        R.pad(context, 14),
        R.pad(context, 20),
        R.pad(context, 16) + R.safeBottom(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.r(context, 24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to cart
          Expanded(
            child: OutlinedButton(
              onPressed: addedToCart ? null : onAddToCart,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: R.pad(context, 15)),
                side: BorderSide(
                  color: addedToCart ? AppColors.success : AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(context, 16)),
                ),
              ),
              child: Text(
                addedToCart
                    ? '✓ ${AppLocalizations.of(context).addedToCart}'
                    : AppLocalizations.of(context).addToCart,
                style: TextStyle(
                  color: addedToCart ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: R.sp(context, 14),
                ),
              ),
            ),
          ),
          SizedBox(width: R.pad(context, 12)),

          // Share to Group
          Expanded(
            child: ElevatedButton.icon(
              onPressed: startingGroup ? null : onGroupBuy,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: R.pad(context, 15)),
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(context, 16)),
                ),
              ),
              icon: startingGroup
                  ? const SizedBox()
                  : Icon(
                      Icons.ios_share_rounded,
                      color: const Color(0xFFF5A623),
                      size: R.icon(context, 18),
                    ),
              label: startingGroup
                  ? SizedBox(
                      width: R.icon(context, 20),
                      height: R.icon(context, 20),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).locale.languageCode == 'ar'
                          ? 'مشاركة في جروب'
                          : 'Share to Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(context, 13),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle icon button ──────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: R.pad(context, 40),
        height: R.pad(context, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color ?? const Color(0xFF0F172A),
          size: R.icon(context, 19),
        ),
      ),
    );
  }
}

//Reviews Section
