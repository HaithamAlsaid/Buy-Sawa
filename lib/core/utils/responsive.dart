import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// Responsive Utility
/// Handles scaling for: small phones, normal phones, large
/// phones, and tablets — both Android & iOS.
///
/// Design base: 390 × 844 pt (iPhone 14)
///
/// Usage:
///   R.sp(context, 16)      → scaled font size
///   R.h(context, 0.4)      → 40% of screen height
///   R.w(context, 1.0)      → 100% of screen width (capped on tablet)
///   R.pad(context, 24)     → scaled horizontal padding
///   R.isTablet(context)    → true if width >= 600
///   R.contentWidth(context)→ usable content width (max 520 on tablet)
/// ─────────────────────────────────────────────────────────────
class R {
  R._();

  // ── Design reference dimensions 
  static const double _baseW = 390.0;

  // ── Breakpoints 
  static const double _tabletBreak = 600.0;
  static const double _smallPhoneBreak = 360.0;

  // ── Screen helpers
  static double screenW(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenH(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isTablet(BuildContext context) =>
      screenW(context) >= _tabletBreak;

  static bool isSmallPhone(BuildContext context) =>
      screenW(context) < _smallPhoneBreak;

  /// Max usable content width — centered on tablets
  static double contentWidth(BuildContext context) =>
      isTablet(context) ? 520.0 : screenW(context);

  // ── Scale factor 
  /// Width-based scale (for fonts & horizontal spacing)
  static double _scaleW(BuildContext context) {
    final w = screenW(context).clamp(320.0, 520.0);
    return w / _baseW;
  }


  // ── Font size 
  /// Scaled font size. Pass your design font size (at 390px base).
  static double sp(BuildContext context, double size) {
    final scale = _scaleW(context);
    // Clamp to avoid too-small or too-large text
    return (size * scale).clamp(size * 0.78, size * 1.22);
  }

  // ── Spacing / Padding 
  /// Scaled spacing value (horizontal/vertical).
  /// Handles negative values safely (e.g. for Positioned offsets).
  static double pad(BuildContext context, double value) {
    final scaled = value * _scaleW(context);
    if (value < 0) {
      // For negative values, bounds are flipped to keep clamp valid
      return scaled.clamp(value * 1.3, value * 0.75);
    }
    return scaled.clamp(value * 0.75, value * 1.3);
  }

  // ── Height percentage 
  /// Percentage of screen height (0.0 – 1.0).
  static double h(BuildContext context, double percent) =>
      screenH(context) * percent;

  // ── Width percentage
  /// Percentage of usable content width (0.0 – 1.0).
  static double w(BuildContext context, double percent) =>
      contentWidth(context) * percent;

  // ── Radius 
  /// Scaled border radius.
  static double r(BuildContext context, double value) {
    return (value * _scaleW(context)).clamp(value * 0.8, value * 1.2);
  }

  // ── Icon size 
  static double icon(BuildContext context, double size) =>
      (size * _scaleW(context)).clamp(size * 0.8, size * 1.2);

  // ── Safe area top 
  static double safeTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;
}

/// ─────────────────────────────────────────────────────────────
/// ResponsiveWrapper — centers content on tablets
/// Wrap your Scaffold body with this on any screen.
/// ─────────────────────────────────────────────────────────────
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    if (!isTablet) return child;

    return Container(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
