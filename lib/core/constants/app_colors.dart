import 'package:flutter/material.dart';

class AppColors {
  // Primary Elegant Dark Green
  static const Color primary = Color.fromARGB(255, 9, 95, 95);
  static const Color primaryDark = Color(0xFF042626);
  static const Color primaryLight = Color(0xFFE6F0EF);

  // Accent Orange/Amber
  static const Color accent = Color.fromARGB(255, 175, 119, 29);
  static const Color accentLight = Color(0xFFFFF4E0);

  // Background
  static const Color background = Color(0xFFF2F4F7);
  static const Color white = Color(0xFFFFFFFF);

  // Text
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFBDBDBD);

  // Status
  static const Color success = Color(0xFF2DCE89);
  static const Color successLight = Color(0xFFE8FAF2);
  static const Color error = Color(0xFFFF4757);
  static const Color errorLight = Color(0xFFFFEEEF);
  static const Color warning = Color(0xFFFFC107);

  // Card / Border
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFFF0F0F0);

  // Avatar Orange
  static const Color avatarOrange = Color(0xFFF5A623);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1BA8A0), Color(0xFF158E87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF2D2D3A), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
