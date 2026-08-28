import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/category_model.dart';
import '../../core/localization/app_localizations.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveWrapper(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  R.pad(context, 24),
                  R.pad(context, 24),
                  R.pad(context, 24),
                  R.pad(context, 16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (Navigator.canPop(context)) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.only(right: R.pad(context, 12)),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: R.icon(context, 20), color: const Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                    Text(
                      AppLocalizations.of(context).categories,
                      style: TextStyle(
                        fontSize: R.sp(context, 28),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context).categoriesCount,
                      style: TextStyle(
                        fontSize: R.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              
              //Categories Grid 
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    top: R.pad(context, 32),
                    left: R.pad(context, 24),
                    right: R.pad(context, 24),
                    bottom: R.pad(context, 100),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.70, // Slightly more height to prevent text clipping
                    crossAxisSpacing: R.pad(context, 16),
                    mainAxisSpacing: R.pad(context, 24),
                  ),
                  itemCount: mockCategories.length,
                  itemBuilder: (context, index) {
                    final cat = mockCategories[index];
                    return _CategoryGridItem(category: cat)
                        .animate(delay: (index * 30).ms)
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final CategoryModel category;

  const _CategoryGridItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: category),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(context, 18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(R.r(context, 18)),
                child: category.imagePath != null
                    ? Image.asset(
                        category.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            category.icon,
                            color: category.iconColor,
                            size: R.icon(context, 30),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          category.icon,
                          color: category.iconColor,
                          size: R.icon(context, 30),
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: R.pad(context, 10)),
          Text(
            AppLocalizations.of(context).locale.languageCode == 'ar' 
                ? category.arabicName 
                : category.name,
            style: TextStyle(
              fontSize: R.sp(context, 12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
