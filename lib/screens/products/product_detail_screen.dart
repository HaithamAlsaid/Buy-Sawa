import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_buy_provider.dart';
import '../../widgets/auth_bottom_sheet.dart';
import '../deals/deals_screen.dart';
import 'cart_screen.dart';

//Mock specs per product category
Map<String, String> _specsFor(ProductModel p) {
  if (p.category == 'Electronics' && p.name.contains('Sony')) {
    return {
      'Battery Life': '30 Hours',
      'Noise Cancellation': 'Adaptive ANC',
      'Connectivity': 'Bluetooth 5.2',
      'Quick Charge': '3 min = 3 hrs',
    };
  } else if (p.category == 'Shoes') {
    return {
      'Material': 'Mesh + Rubber',
      'Sole': 'Air/Boost Unit',
      'Weight': '~310g',
      'Origin': 'Vietnam',
    };
  } else if (p.name.contains('Watch')) {
    return {
      'Display': '45mm OLED',
      'Chip': 'S9 SiP',
      'Water Resistance': '50 meters',
      'Battery': '18 Hours',
    };
  }
  return {
    'Condition': 'Brand New',
    'Warranty': '1 Year',
    'Availability': 'In Stock',
    'Shipping': 'Free',
  };
}

const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];

// ───────────────────────────────────────────────────────────────

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const _teal = Color(0xFF00A9A5);

  bool _addedToCart = false;
  bool _startingGroup = false;
  bool _isWishlisted = false;
  String? _selectedSize;
  bool _specsExpanded = false;

  // Actions 

  void _addToCart() {
    HapticFeedback.lightImpact();
    context.read<CartProvider>().add(widget.product);
    setState(() => _addedToCart = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.product.name} added to cart',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
      ),
    );
  }

  void _shareProduct() {
    final p = widget.product;
    Share.share(
      'Check out ${p.name} on BuySawa for just ${p.price.toInt()} AED! 🛍️\n'
      'Use my referral code HAITHAM25 to get 15 AED bonus!\n'
      'Shop now: https://buysawa.com/p/${p.id}',
      subject: 'Check out ${p.name} on BuySawa!',
    );
  }

  Future<void> _startGroupBuy() async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      AuthBottomSheet.show(context);
      return;
    }
    setState(() => _startingGroup = true);
    context.read<GroupBuyProvider>().startNewGroup(
      productId: widget.product.id,
      productName: widget.product.name,
    );
    if (!mounted) return;
    setState(() => _startingGroup = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🎉 Group Deal Created! Share your code from the Deals tab.',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DealsScreen()),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final specs = _specsFor(product);
    final discountPct = product.originalPrice != null
        ? (((product.originalPrice! - product.price) / product.originalPrice!) *
                  100)
              .toInt()
        : 0;

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
                    isWishlisted: _isWishlisted,
                    onBack: () => Navigator.pop(context),
                    onWishlist: () =>
                        setState(() => _isWishlisted = !_isWishlisted),
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
                          product.name,
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
                          discountPct: discountPct,
                        ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 22)),

                        // Size selector
                        _SizeSelector(
                          selected: _selectedSize,
                          onSelect: (s) => setState(() => _selectedSize = s),
                        ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.15),
                        SizedBox(height: R.pad(context, 22)),

                        SizedBox(height: R.pad(context, 22)),

                        // Product Details
                        _SectionTitle(title: 'Product Details'),
                        SizedBox(height: R.pad(context, 10)),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: R.sp(context, 13),
                            height: 1.65,
                            color: const Color(0xFF475569),
                          ),
                        ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.15),

                        SizedBox(height: R.pad(context, 24)),

                        // Specifications
                        _SectionTitle(title: 'Specifications'),
                        SizedBox(height: R.pad(context, 10)),
                        _SpecsTable(
                          specs: specs,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

                        // View all specs
                        if (!_specsExpanded) ...[
                          SizedBox(height: R.pad(context, 8)),
                          GestureDetector(
                            onTap: () => setState(() => _specsExpanded = true),
                            child: Text(
                              'View all technical specifications →',
                              style: TextStyle(
                                fontSize: R.sp(context, 12),
                                color: _teal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
  final bool isWishlisted;
  final VoidCallback onBack;
  final VoidCallback onWishlist;
  final VoidCallback onShare;

  const _HeroSection({
    required this.product,
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

  // Color filters to tint the SAME product image
  final List<Color?> _colorFilters = [
    null, // Original (White/Light)
    Colors.black.withOpacity(0.65), // Black tint
    Colors.grey.shade700.withOpacity(0.65), // Gray tint
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _colorFilters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Image Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: _colorFilters.length,
            itemBuilder: (context, index) {
              final filter = _colorFilters[index];
              final imageWidget = Image.network(
                widget.product.imageUrl,
                fit: BoxFit.contain,
                color: filter,
                colorBlendMode: filter != null ? BlendMode.srcATop : null,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  size: R.icon(context, 80),
                  color: const Color(0xFF94A3B8),
                ),
              );

              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    R.pad(context, 40),
                    R.pad(context, 16),
                    R.pad(context, 40),
                    R.pad(context, 40),
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
              left: R.pad(context, 16),
              top: 0,
              bottom: 0,
              child: Center(
                child: _CircleBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _prevPage,
                ),
              ),
            ),

          // Right Arrow
          if (_currentIndex < _colorFilters.length - 1)
            Positioned(
              right: R.pad(context, 16),
              top: 0,
              bottom: 0,
              child: Center(
                child: _CircleBtn(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: _nextPage,
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

          // Page Indicators
          Positioned(
            bottom: R.pad(context, 10),
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _colorFilters.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: R.pad(context, 4)),
                  height: R.pad(context, 6),
                  width: _currentIndex == index
                      ? R.pad(context, 20)
                      : R.pad(context, 6),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF00A9A5)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(R.r(context, 3)),
                  ),
                ),
              ),
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
            'Featured',
            style: TextStyle(
              color: const Color(0xFF00A9A5),
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
  final int discountPct;
  const _PriceRow({required this.product, required this.discountPct});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${product.price.toInt()}',
          style: TextStyle(
            fontSize: R.sp(context, 28),
            fontWeight: FontWeight.w900,
            color: const Color(0xFF00A9A5),
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
        if (product.originalPrice != null) ...[
          SizedBox(width: R.pad(context, 10)),
          Padding(
            padding: EdgeInsets.only(bottom: R.pad(context, 4)),
            child: Text(
              '${product.originalPrice!.toInt()}',
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

// ── Size selector ───────────────────────────────────────────────
class _SizeSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _SizeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Size',
              style: TextStyle(
                fontSize: R.sp(context, 14),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Size Guide',
              style: TextStyle(
                fontSize: R.sp(context, 12),
                color: const Color(0xFF00A9A5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: R.pad(context, 10)),
        Row(
          children: _sizes.map((s) {
            final isSelected = selected == s;
            return Padding(
              padding: EdgeInsets.only(right: R.pad(context, 8)),
              child: GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: R.pad(context, 48),
                  height: R.pad(context, 40),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00A9A5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(R.r(context, 12)),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00A9A5)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: R.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
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
                  color: Color(0xFF00A9A5),
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
            color: Colors.black.withOpacity(0.06),
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
                  color: addedToCart
                      ? AppColors.success
                      : const Color(0xFF00A9A5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(context, 16)),
                ),
              ),
              child: Text(
                addedToCart ? '✓ Added' : 'Add to Cart',
                style: TextStyle(
                  color: addedToCart
                      ? AppColors.success
                      : const Color(0xFF00A9A5),
                  fontWeight: FontWeight.w800,
                  fontSize: R.sp(context, 14),
                ),
              ),
            ),
          ),
          SizedBox(width: R.pad(context, 12)),

          // Start group buy
          Expanded(
            child: ElevatedButton.icon(
              onPressed: startingGroup ? null : onGroupBuy,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: R.pad(context, 15)),
                backgroundColor: const Color(0xFF00A9A5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(context, 16)),
                ),
              ),
              icon: startingGroup
                  ? const SizedBox()
                  : Icon(
                      Icons.flash_on_rounded,
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
                      'Start Group Buy',
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
              color: Colors.black.withOpacity(0.06),
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
