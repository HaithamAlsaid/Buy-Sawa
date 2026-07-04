import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String arabicName;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? imagePath;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.imagePath,
  });
}

final List<CategoryModel> mockCategories = [
  CategoryModel(
    id: 'c1', name: 'Electronics', arabicName: 'الإلكترونيات',
    icon: Icons.headphones_rounded,
    iconColor: const Color(0xFF277895), bgColor: const Color(0xFFE8F7F6),
    imagePath: 'assets/images/categories/cat_electronics.png',
  ),
  CategoryModel(
    id: 'c2', name: 'Fashion', arabicName: 'الأزياء',
    icon: Icons.checkroom_rounded,
    iconColor: const Color(0xFF4CAF50), bgColor: const Color(0xFFE8F5E9),
    imagePath: 'assets/images/categories/cat_fashion.png',
  ),
  CategoryModel(
    id: 'c3', name: 'Home & Living', arabicName: 'المنزل والمعيشة',
    icon: Icons.weekend_rounded,
    iconColor: const Color(0xFF9B59B6), bgColor: const Color(0xFFF5EEF8),
    imagePath: 'assets/images/categories/cat_home.png',
  ),
  CategoryModel(
    id: 'c4', name: 'Beauty', arabicName: 'العناية والجمال',
    icon: Icons.face_retouching_natural_rounded,
    iconColor: const Color(0xFFE91E63), bgColor: const Color(0xFFFCE4EC),
    imagePath: 'assets/images/categories/cat_beauty.png',
  ),
  CategoryModel(
    id: 'c5', name: 'Sports', arabicName: 'الرياضة',
    icon: Icons.sports_basketball_rounded,
    iconColor: const Color(0xFFFF9800), bgColor: const Color(0xFFFFF3E0),
    imagePath: 'assets/images/categories/cat_sports.png',
  ),
  CategoryModel(
    id: 'c6', name: 'Kids & Toys', arabicName: 'الأطفال والألعاب',
    icon: Icons.toys_rounded,
    iconColor: const Color(0xFF03A9F4), bgColor: const Color(0xFFE1F5FE),
    imagePath: 'assets/images/categories/cat_kids.png',
  ),
  CategoryModel(
    id: 'c7', name: 'Groceries', arabicName: 'البقالة',
    icon: Icons.shopping_basket_rounded,
    iconColor: const Color(0xFF8BC34A), bgColor: const Color(0xFFF1F8E9),
    imagePath: 'assets/images/categories/cat_groceries.png',
  ),
  CategoryModel(
    id: 'c8', name: 'Shoes', arabicName: 'الأحذية',
    icon: Icons.do_not_step_rounded,
    iconColor: const Color(0xFF795548), bgColor: const Color(0xFFEFEBE9),
    imagePath: 'assets/images/categories/cat_shoes.png',
  ),
  CategoryModel(
    id: 'c9', name: 'Watches', arabicName: 'الساعات',
    icon: Icons.watch_rounded,
    iconColor: const Color(0xFF607D8B), bgColor: const Color(0xFFECEFF1),
    imagePath: 'assets/images/categories/cat_watches.png',
  ),
  CategoryModel(
    id: 'c10', name: 'Gaming', arabicName: 'ألعاب الفيديو',
    icon: Icons.sports_esports_rounded,
    iconColor: const Color(0xFF673AB7), bgColor: const Color(0xFFEDE7F6),
    imagePath: 'assets/images/categories/cat_gaming.png',
  ),
  CategoryModel(
    id: 'c11', name: 'Cameras', arabicName: 'الكاميرات',
    icon: Icons.camera_alt_rounded,
    iconColor: const Color(0xFF3498DB), bgColor: const Color(0xFFEBF5FB),
    imagePath: null,
  ),
  CategoryModel(
    id: 'c12', name: 'Accessories',
    icon: Icons.shopping_bag_rounded,
    iconColor: const Color(0xFF9B59B6), bgColor: const Color(0xFFF5EEF8),
    imagePath: null, arabicName: '',
  ),
];
