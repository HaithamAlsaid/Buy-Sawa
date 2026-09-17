import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.trending;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).locale.languageCode == 'ar'
              ? 'كل المنتجات'
              : 'All Products',
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: products.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context).locale.languageCode == 'ar'
                    ? 'لا توجد منتجات'
                    : 'No products',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                return ProductCard(product: products[i])
                    .animate(delay: ((i % 10) * 20).ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
    );
  }
}
