import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, required this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchCtrl;
  List<ProductModel>? _products;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _products = [];
      });
      return;
    }
    setState(() => _isLoading = true);
    final results = await ProductService.getProducts(query: query.trim());
    if (mounted) {
      setState(() {
        _products = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch,
            autofocus: widget.initialQuery.isEmpty,
            decoration: InputDecoration(
              hintText: isAr ? 'ابحث عن منتج...' : 'Search products...',
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                onPressed: () {
                  _searchCtrl.clear();
                  _performSearch('');
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _products == null
              ? Center(
                  child: Text(
                    isAr ? 'ابدأ البحث الآن' : 'Start searching now',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                )
              : _products!.isEmpty
                  ? Center(
                      child: Text(
                        isAr ? 'لا توجد نتائج' : 'No results found',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
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
                      itemCount: _products!.length,
                      itemBuilder: (context, i) {
                        return ProductCard(product: _products![i])
                            .animate(delay: ((i % 10) * 20).ms)
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
    );
  }
}
