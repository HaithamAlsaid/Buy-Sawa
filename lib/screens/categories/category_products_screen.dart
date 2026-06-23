import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../products/product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    
    // Filter products by category and search query
    var products = productProvider.products
        .where((p) => p.category == widget.category.name)
        .toList();
        
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // slightly off-white for contrast with cards
      body: ResponsiveWrapper(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top App Bar (Back + Search) ────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.pad(context, 20),
                  vertical: R.pad(context, 16),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: R.pad(context, 44),
                        height: R.pad(context, 44),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: R.icon(context, 18),
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(width: R.pad(context, 16)),
                    Expanded(
                      child: Container(
                        height: R.pad(context, 44),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(R.r(context, 22)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: R.pad(context, 16)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: AppColors.textLight,
                              size: R.icon(context, 20),
                            ),
                            SizedBox(width: R.pad(context, 8)),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: TextStyle(fontSize: R.sp(context, 14)),
                                decoration: InputDecoration(
                                  hintText: 'Search in ${widget.category.name}...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: R.sp(context, 14),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
  
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ── Category Banner ────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.pad(context, 20)),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: widget.category.iconColor,
                                borderRadius: BorderRadius.circular(R.r(context, 24)),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                R.pad(context, 24),
                                R.pad(context, 24),
                                R.pad(context, 20),
                                R.pad(context, 24),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.category.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: R.sp(context, 26),
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: R.pad(context, 8)),
                                        Text(
                                          'Smart tech for\nyour smart life',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: R.sp(context, 13),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: R.pad(context, 8)),
                                  Expanded(
                                    flex: 2,
                                    child: products.isNotEmpty
                                        ? Container(
                                            height: R.pad(context, 100),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(R.pad(context, 8)),
                                            child: Image.network(
                                              products.first.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => Icon(
                                                widget.category.icon,
                                                size: R.icon(context, 60),
                                                color: widget.category.iconColor,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            widget.category.icon,
                                            size: R.icon(context, 80),
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: R.pad(context, 16)),
                            // Decorative dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: R.pad(context, 24),
                                  height: R.pad(context, 6),
                                  decoration: BoxDecoration(
                                    color: widget.category.iconColor,
                                    borderRadius: BorderRadius.circular(R.r(context, 3)),
                                  ),
                                ),
                                SizedBox(width: R.pad(context, 6)),
                                Container(
                                  width: R.pad(context, 6),
                                  height: R.pad(context, 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFCBD5E1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: R.pad(context, 6)),
                                Container(
                                  width: R.pad(context, 6),
                                  height: R.pad(context, 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFCBD5E1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: R.pad(context, 24)),
                          ],
                        ),
                      ),
                    ),
  
                    // ── Products Grid ──────────────────────────────────────────
                    if (products.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: R.pad(context, 40)),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: R.icon(context, 64),
                                  color: AppColors.border.withOpacity(0.5),
                                ),
                                SizedBox(height: R.pad(context, 16)),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: R.sp(context, 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: R.pad(context, 20)),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: R.pad(context, 16),
                            mainAxisSpacing: R.pad(context, 16),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _CategoryProductCard(
                                product: products[index],
                                categoryColor: widget.category.iconColor,
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: R.pad(context, 40))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  final ProductModel product;
  final Color categoryColor;

  const _CategoryProductCard({required this.product, required this.categoryColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(context, 16)),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(R.pad(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Center(
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_rounded,
                    color: AppColors.textLight,
                    size: R.icon(context, 40),
                  ),
                ),
              ),
            ),
            SizedBox(height: R.pad(context, 12)),
            // Title
            Text(
              product.name,
              style: TextStyle(
                fontSize: R.sp(context, 15),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: R.pad(context, 4)),
            // Subtitle
            Text(
              product.description,
              style: TextStyle(
                fontSize: R.sp(context, 11),
                color: AppColors.textGray,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: R.pad(context, 8)),
            // Price
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${product.price.toStringAsFixed(2)} AED',
                style: TextStyle(
                  fontSize: R.sp(context, 16),
                  fontWeight: FontWeight.w900,
                  color: categoryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
