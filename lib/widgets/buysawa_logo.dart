// ─────────────────────────────────────────────────────────────────────────────
// AppLogo — Smart Logo Widget
//
// ترتيب الأولوية:
//   1. لو الـ API رجع logoUrl  → يعرض Image.network (من الـ Backend)
//   2. لو مفيش URL             → يعرض Image.asset  (من الملف المحلي)
//   3. لو الـ asset مش موجود  → يعرض الـ fallback المرسوم بـ CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 100,
    this.borderRadius = 22,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: settings.hasRemoteLogo
            // ── 1. Logo من الـ Backend (يتحكم فيه الأدمن) ──────────
            ? Image.network(
                settings.logoUrl!,
                width: size,
                height: size,
                fit: fit,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _FallbackLogo(size: size);
                },
                errorBuilder: (_, __, ___) => _LocalAssetLogo(size: size, fit: fit),
              )
            // ── 2. Logo من ملف محلي (fallback) ──────────────────────
            : _LocalAssetLogo(size: size, fit: fit),
      ),
    );
  }
}

/// يجيب اللوجو من الـ assets المحلية
class _LocalAssetLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;
  const _LocalAssetLogo({required this.size, required this.fit});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, __, ___) => _FallbackLogo(size: size),
    );
  }
}

/// لو مفيش أي صورة، بيرسم اللوجو بالكود
class _FallbackLogo extends StatelessWidget {
  final double size;
  const _FallbackLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Icon(
        Icons.swap_calls_rounded,
        color: const Color(0xFF1BA8A0),
        size: size * 0.55,
      ),
    );
  }
}
