import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class AddProductsBottomSheet extends StatefulWidget {
  const AddProductsBottomSheet({super.key});

  static Future<List<Map<String, dynamic>>?> show(BuildContext context) {
    return showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddProductsBottomSheet(),
    );
  }

  @override
  State<AddProductsBottomSheet> createState() => _AddProductsBottomSheetState();
}

class _AddProductsBottomSheetState extends State<AddProductsBottomSheet> {
  int _selectedFilter = 2; // Default 'Top Brands'

  final List<Map<String, dynamic>> _dummyProducts = [
    {'name': 'PowerBank 20k mAh', 'price': '99', 'code': 'PB20K', 'icon': Icons.image_outlined, 'isAdded': false},
    {'name': 'Sony WH-1000XM5', 'price': '1299', 'code': 'SONYXM5', 'icon': Icons.headphones_rounded, 'isAdded': false},
    {'name': 'Glow Serum Set', 'price': '189', 'code': 'GLOW01', 'icon': Icons.spa_outlined, 'isAdded': false},
    {'name': 'Nike Air Max \'24', 'price': '549', 'code': 'AIRMAX24', 'icon': Icons.directions_run_rounded, 'isAdded': false},
    {'name': 'Apple Watch Series 9', 'price': '1899', 'code': 'AW9-45', 'icon': Icons.watch_rounded, 'isAdded': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1), // Slate 300
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).addItemsToPool,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, _dummyProducts.where((p) => p['isAdded'] == true).toList()),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9), // Slate 100
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate 50
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchProductCode,
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14), // Slate 400
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip(0, AppLocalizations.of(context).filterPriceHigh),
                const SizedBox(width: 8),
                _buildFilterChip(1, AppLocalizations.of(context).filterPriceLow),
                const SizedBox(width: 8),
                _buildFilterChip(2, AppLocalizations.of(context).filterTopBrands),
                const SizedBox(width: 8),
                _buildFilterChip(3, AppLocalizations.of(context).filterNew),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Product List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _dummyProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = _dummyProducts[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
                  ),
                  child: Row(
                    children: [
                      // Image Placeholder
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          product['icon'] as IconData,
                          color: const Color(0xFF94A3B8),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${product['price']} ${AppLocalizations.of(context).aed}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9), // Slate 100
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product['code'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Add Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            product['isAdded'] = !(product['isAdded'] as bool);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: (product['isAdded'] as bool) ? AppColors.success : AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon((product['isAdded'] as bool) ? Icons.check_rounded : Icons.add_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                (product['isAdded'] as bool) ? AppLocalizations.of(context).addedToCart : AppLocalizations.of(context).addBtn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0), // Slate 200
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569), // Slate 600
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
