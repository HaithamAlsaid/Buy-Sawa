import 'package:buysawa/core/constants/app_colors.dart';
import 'package:buysawa/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/language_picker_sheet.dart';
import '../../widgets/buysawa_logo.dart';
import '../main/main_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final localeProvider = context.read<LocaleProvider>();
    final isGuest = context.read<AuthProvider>().isGuest;
    final showOnboarding = localeProvider.isFirstLaunch && isGuest;

    if (localeProvider.isFirstLaunch) {
      localeProvider.markLaunched();
      if (!mounted) return;
      await LanguagePickerSheet.show(context);
    }
    if (!mounted) return;

    final Widget nextScreen = showOnboarding
        ? const OnboardingScreen()
        : const MainScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // ── Background Decorative Blobs
            Positioned(
              top: -90,
              right: -70,
              child: _GlowBlob(
                size: 280,
                opacity: 0.05,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              top: 80,
              right: 30,
              child: _GlowBlob(
                size: 110,
                opacity: 0.05,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              bottom: 120,
              left: -90,
              child: _GlowBlob(
                size: 320,
                opacity: 0.04,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              bottom: 220,
              right: -50,
              child: _GlowBlob(
                size: 180,
                opacity: 0.10,
                color: const Color(0xFFF5A623),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: -50,
              child: _GlowBlob(
                size: 150,
                opacity: 0.08,
                color: const Color(0xFFF5A623),
              ),
            ),

            // Main Content
            Center(
              child:
                  AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, child) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF5A623,
                                ).withOpacity(0.15 + _pulseCtrl.value * 0.15),
                                blurRadius: 50 + _pulseCtrl.value * 30,
                                spreadRadius: 2 + _pulseCtrl.value * 4,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                        child: AppLogo(size: 180, borderRadius: 44),
                      )
                      .animate()
                      // Step 1: Start at the bottom, shoot up to the top
                      .slideY(
                        begin: 4.0,
                        end: -2.5,
                        duration: 800.ms,
                        curve: Curves.easeOutCirc,
                      )
                      // Step 2: Bounce back down to the center
                      .then()
                      .slideY(
                        begin: 0.0,
                        end: 2.5,
                        duration: 1000.ms,
                        curve: Curves.elasticOut,
                      )
                      .fade(begin: 0.0, end: 1.0, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}

//Glow Blob
class _GlowBlob extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _GlowBlob({
    required this.size,
    required this.opacity,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity),
    ),
  );
}

//Animated Loading Dots
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final raw = (_ctrl.value - delay) % 1.0;
            final t = raw < 0 ? raw + 1.0 : raw;
            final scale = 0.5 + (0.5 * (t < 0.5 ? t * 2 : (1.0 - t) * 2));
            final opacity = 0.3 + (0.7 * (t < 0.5 ? t * 2 : (1.0 - t) * 2));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
