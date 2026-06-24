import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/product_model.dart';
import '../products/product_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  // Local list of favorite products modeled exactly from the screenshot
  late List<Map<String, dynamic>> _favourites;

  @override
  void initState() {
    super.initState();
    _favourites = [
      {
        'id': 'fav_1',
        'name': 'Sony WH-1000XM5',
        'rating': 4.8,
        'price': 1299.0,
        'originalPrice': 1499.0,
        'isGroupDeal': true,
        'dealLabel': 'Group Deal ',
        'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'description': 'Industry-leading noise canceling with two processors and eight microphones. 30-hour battery life with quick charge.',
      },
      {
        'id': 'fav_2',
        'name': 'Apple Watch Series 9',
        'rating': 4.9,
        'price': 1899.0,
        'originalPrice': 2099.0,
        'isGroupDeal': false,
        'dealLabel': 'Share & Earn ',
        'imageUrl': 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400',
        'description': 'The most powerful Apple Watch yet. Features the new S9 chip, Double Tap gesture, and brighter display.',
      },
      {
        'id': 'fav_3',
        'name': 'Nike Air Max \'24',
        'rating': 4.7,
        'price': 549.0,
        'originalPrice': 699.0,
        'isGroupDeal': true,
        'dealLabel': 'Group Deal %',
        'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'description': 'The Nike Air Max delivers unparalleled comfort with its large Air unit.',
      },
      {
        'id': 'fav_4',
        'name': 'Glow Serum Set',
        'rating': 4.6,
        'price': 189.0,
        'originalPrice': 249.0,
        'isGroupDeal': false,
        'dealLabel': 'Share & Earn ',
        'imageUrl': 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
        'description': 'Advanced brightening serum with vitamin C and hyaluronic acid for glowing skin.',
      },
      {
        'id': 'fav_5',
        'name': 'AirPods Pro 2',
        'rating': 4.8,
        'price': 899.0,
        'originalPrice': 1099.0,
        'isGroupDeal': true,
        'dealLabel': 'Group Deal %',
        'imageUrl': 'https://images.unsplash.com/photo-1606220838315-056192d5e927?w=400',
        'description': 'Active Noise Cancellation reduces unwanted background noise. Adaptive Transparency.',
      },
      {
        'id': 'fav_6',
        'name': 'iPad Air M2',
        'rating': 4.9,
        'price': 2799.0,
        'originalPrice': 3199.0,
        'isGroupDeal': false,
        'dealLabel': 'Share & Earn %',
        'imageUrl': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
        'description': 'iPad Air M2 is supercharged by the Apple M2 chip. Features a Liquid Retina display.',
      },
    ];
  }

  void _removeFavourite(int index, String name) {
    setState(() {
      _favourites.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removed from favourites'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Teal Header 
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                R.pad(context, 20),
                R.pad(context, 50),
                R.pad(context, 20),
                R.pad(context, 28),
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 39, 120, 149),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(R.r(context, 32)),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular background details
                  Positioned(
                    left: -40,
                    top: -20,
                    child: Container(
                      width: R.pad(context, 120),
                      height: R.pad(context, 120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
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
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  // Header Contents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: R.pad(context, 40),
                          height: R.pad(context, 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: Colors.white,
                            size: R.icon(context, 24),
                          ),
                        ),
                      ),
                      // Title Text Column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_favourites.length} items',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: R.sp(context, 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: R.pad(context, 2)),
                          Text(
                            'My Favourites',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: R.sp(context, 22),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      // Heart Circle Icon Button (top right)
                      Container(
                        width: R.pad(context, 40),
                        height: R.pad(context, 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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

            // ── Grid of Products ──────────────────────────────────────
            Expanded(
              child: _favourites.isEmpty
                  ? Center(
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
                            'No favourites yet',
                            style: TextStyle(
                              fontSize: R.sp(context, 16),
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ResponsiveWrapper(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.pad(context, 16),
                          vertical: R.pad(context, 20),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: R.pad(context, 12),
                          mainAxisSpacing: R.pad(context, 16),
                          childAspectRatio: 0.68, // Balanced aspect ratio to fit image, labels, prices
                        ),
                        itemCount: _favourites.length,
                        itemBuilder: (context, index) {
                          final item = _favourites[index];
                          // Format price with comma helper
                          final priceFormatted = item['price']
                              .toStringAsFixed(0)
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              );
                          final originalPriceFormatted = item['originalPrice']
                              ?.toStringAsFixed(0)
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              );

                          return GestureDetector(
                            onTap: () {
                              // Wrap in a ProductModel to push to ProductDetailScreen
                              final product = ProductModel(
                                id: item['id'],
                                name: item['name'],
                                category: item['isGroupDeal'] ? 'Group Deal' : 'Share & Earn',
                                price: item['price'],
                                originalPrice: item['originalPrice'],
                                rating: item['rating'],
                                reviewCount: 150,
                                imageUrl: item['imageUrl'],
                                description: item['description'],
                                hasGroupDeal: item['isGroupDeal'],
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
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
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image + Badge + Heart
                                  Stack(
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(R.r(context, 20)),
                                        ),
                                        child: Image.network(
                                          item['imageUrl'],
                                          height: R.pad(context, 130),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: R.pad(context, 130),
                                            color: const Color(0xFFF1F5F9),
                                            child: const Icon(Icons.image_not_supported_outlined),
                                          ),
                                        ),
                                      ),

                                      // Top Right Heart Badge
                                      Positioned(
                                        top: R.pad(context, 8),
                                        right: R.pad(context, 8),
                                        child: GestureDetector(
                                          onTap: () => _removeFavourite(index, item['name']),
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
                                            child: Icon(
                                              Icons.favorite_rounded,
                                              color: const Color(0xFFF43F5E),
                                              size: R.icon(context, 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Text details
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(R.pad(context, 12)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: R.sp(context, 14),
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const Spacer(),
                                          // Rating row
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: const Color(0xFFF5A623),
                                                size: R.icon(context, 16),
                                              ),
                                              SizedBox(width: R.pad(context, 4)),
                                              Text(
                                                item['rating'].toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: R.sp(context, 12),
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: R.pad(context, 6)),
                                          // Price row
                                          Row(
                                            children: [
                                              Text(
                                                priceFormatted,
                                                style: TextStyle(
                                                  color: const Color(0xFF00A2B1),
                                                  fontSize: R.sp(context, 16),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(width: R.pad(context, 6)),
                                              if (originalPriceFormatted != null)
                                                Text(
                                                  '$originalPriceFormatted AED',
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
