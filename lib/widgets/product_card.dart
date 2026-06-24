import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import '../models/product_model.dart';
import '../screens/products/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        width: R.pad(context, 175),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(context, 16)),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(context, 16))),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.background,
                        child: Center(
                          child: Icon(Icons.image_rounded,
                            color: AppColors.textLight, size: R.icon(context, 40)),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(R.pad(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                    style: TextStyle(
                      fontSize: R.sp(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: R.pad(context, 4)),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                        color: AppColors.accent, size: R.icon(context, 14)),
                      SizedBox(width: R.pad(context, 2)),
                      Text('${product.rating}',
                        style: TextStyle(
                          fontSize: R.sp(context, 12), fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                      Text(' (${product.reviewCount})',
                        style: TextStyle(
                          fontSize: R.sp(context, 11), color: AppColors.textGray)),
                    ],
                  ),
                  SizedBox(height: R.pad(context, 6)),
                  Row(
                    children: [
                      Text(
                        '${product.price.toInt()} AED',
                        style: TextStyle(
                          fontSize: R.sp(context, 15), fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                      ),
                      if (product.originalPrice != null) ...[
                        SizedBox(width: R.pad(context, 6)),
                        Text(
                          '${product.originalPrice!.toInt()}',
                          style: TextStyle(
                            fontSize: R.sp(context, 12), color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

