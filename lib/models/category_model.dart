import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

final List<CategoryModel> mockCategories = [
  CategoryModel(id: 'c1', name: 'Electronics', icon: Icons.phone_android_rounded,
      iconColor: const Color(0xFF094B43), bgColor: const Color(0xFFE8F7F6)),
  CategoryModel(id: 'c2', name: 'Shoes', icon: Icons.directions_run_rounded,
      iconColor: const Color(0xFFF5A623), bgColor: const Color(0xFFFFF4E0)),
  CategoryModel(id: 'c3', name: 'Accessories', icon: Icons.shopping_bag_rounded,
      iconColor: const Color(0xFF9B59B6), bgColor: const Color(0xFFF5EEF8)),
  CategoryModel(id: 'c4', name: 'Furniture', icon: Icons.weekend_rounded,
      iconColor: const Color(0xFF2DCE89), bgColor: const Color(0xFFE8FAF2)),
  CategoryModel(id: 'c5', name: 'Watches', icon: Icons.watch_rounded,
      iconColor: const Color(0xFFF5A623), bgColor: const Color(0xFFFFF4E0)),
  CategoryModel(id: 'c6', name: 'Men', icon: Icons.person_rounded,
      iconColor: const Color(0xFF3498DB), bgColor: const Color(0xFFEBF5FB)),
  CategoryModel(id: 'c7', name: 'Women', icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFFE91E8C), bgColor: const Color(0xFFFCE4F1)),
  CategoryModel(id: 'c8', name: 'Audio', icon: Icons.headphones_rounded,
      iconColor: const Color(0xFF094B43), bgColor: const Color(0xFFE8F7F6)),
  CategoryModel(id: 'c9', name: 'Laptops', icon: Icons.laptop_rounded,
      iconColor: const Color(0xFF5D6D7E), bgColor: const Color(0xFFEAECEE)),
  CategoryModel(id: 'c10', name: 'Cameras', icon: Icons.camera_alt_rounded,
      iconColor: const Color(0xFFE91E8C), bgColor: const Color(0xFFFCE4F1)),
  CategoryModel(id: 'c11', name: 'Gaming', icon: Icons.sports_esports_rounded,
      iconColor: const Color(0xFFE74C3C), bgColor: const Color(0xFFFDEDEC)),
  CategoryModel(id: 'c12', name: 'Sports', icon: Icons.fitness_center_rounded,
      iconColor: const Color(0xFF2DCE89), bgColor: const Color(0xFFE8FAF2)),
  CategoryModel(id: 'c13', name: 'Kids', icon: Icons.child_care_rounded,
      iconColor: const Color(0xFFE91E8C), bgColor: const Color(0xFFFCE4F1)),
];
