import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/localization/app_localizations.dart';
import '../main/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _nextPage() {
    if (_currentIndex < 1) { // Only 2 slides now
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Map<String, dynamic>> _slides = [
      {
        'tag': l10n.onboarding1Tag,
        'title': l10n.onboarding1Title,
        'desc': l10n.onboarding1Desc,
      },
      {
        'tag': l10n.onboarding2Tag,
        'title': l10n.onboarding2Title,
        'desc': l10n.onboarding2Desc,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7F7), // Light teal background
      body: Stack(
        children: [
          // Graphic Area
          SafeArea(
            child: Column(
              children: [
                // Top Bar: Buy SAWA Logo removed as requested. Only Skip on the right.
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.pad(context, 20), vertical: R.pad(context, 10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Aligns content to the right
                    children: [
                      GestureDetector(
                        onTap: _finishOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.skip,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Graphic Graphics changing per page
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Controlled by bottom buttons
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return _buildSlideGraphic(index);
                    },
                    onPageChanged: (idx) {
                      setState(() {
                        _currentIndex = idx;
                      });
                    },
                  ),
                ),
                
                // Space for bottom card
                SizedBox(height: MediaQuery.of(context).size.height * 0.40),
              ],
            ),
          ),

          // Bottom White Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.43,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                R.pad(context, 30),
                R.pad(context, 40),
                R.pad(context, 30),
                R.pad(context, 30),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F0ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _slides[_currentIndex]['tag'],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ).animate(key: ValueKey('tag$_currentIndex')).fadeIn().slideY(begin: 0.2),
                  
                  const Spacer(),
                  
                  // Title
                  Text(
                    _slides[_currentIndex]['title'],
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ).animate(key: ValueKey('title$_currentIndex')).fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    _slides[_currentIndex]['desc'],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.8, // Taller line height for bullets
                    ),
                  ).animate(key: ValueKey('desc$_currentIndex')).fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  
                  const Spacer(),
                  
                  // Bottom Row: Dots and Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          2,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? AppColors.primary
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Button
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: _currentIndex == 1 ? 28 : 32,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: _currentIndex == 1 ? const Color(0xFFFBBF24) : AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: (_currentIndex == 1 ? const Color(0xFFFBBF24) : AppColors.primary).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentIndex == 1 ? l10n.startShopping : l10n.next,
                                style: TextStyle(
                                  color: _currentIndex == 1 ? const Color(0xFF0F172A) : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (_currentIndex < 1) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                              ] else ...[
                                const SizedBox(width: 10),
                                const Icon(Icons.shopping_bag_rounded, color: Color(0xFF0F172A), size: 22),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Graphic Builders ---
  Widget _buildSlideGraphic(int index) {
    if (index == 0) {
      // Welcome Graphic
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Element (White box)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15))
                ],
              ),
              child: const Center(
                child: Text('👋', style: TextStyle(fontSize: 60)),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            
            // Decorative elements
            Positioned(
              top: 10,
              left: 30,
              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 40).animate().fadeIn(delay: 300.ms).scale(),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 35).animate().fadeIn(delay: 500.ms).scale(),
            ),
            Positioned(
              top: 40,
              right: 30,
              child: _buildPill('Buy SAWA', Colors.white, textColor: AppColors.primary),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              child: _buildPill('VIP', AppColors.primary, textColor: Colors.white),
            ),
          ],
        ),
      );
    } else {
      // Features Graphic
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Element (App Logo basically)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))
                ],
              ),
              child: const Icon(Icons.shopping_cart_checkout_rounded, size: 60, color: Colors.white),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            
            // Feature Icons floating around
            Positioned(
              top: 5,
              left: 25,
              child: _buildFeatureBadge(Icons.groups_rounded, Colors.orange),
            ),
            Positioned(
              bottom: 5,
              right: 25,
              child: _buildFeatureBadge(Icons.local_shipping_rounded, Colors.green),
            ),
            Positioned(
              top: 45,
              right: 15,
              child: _buildFeatureBadge(Icons.security_rounded, Colors.purple),
            ),
            Positioned(
              bottom: 45,
              left: 15,
              child: _buildFeatureBadge(Icons.discount_rounded, Colors.pink),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPill(String text, Color color, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ]
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildFeatureBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)
        ]
      ),
      child: Icon(icon, color: color, size: 28),
    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack);
  }
}
