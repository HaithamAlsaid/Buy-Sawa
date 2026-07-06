import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_bottom_sheet.dart';
import '../../widgets/language_picker_sheet.dart';
import 'faqs_screen.dart';
import 'contact_us_screen.dart';
import 'profile_details_screen.dart';
import 'favourites_screen.dart';
import 'delete_account_screen.dart';
import '../../core/localization/app_localizations.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isGuest) {
      return _GuestProfileView();
    }
    return _LoggedInProfileView();
  }
}

// ── Guest View ────────────────────────────────────────────────────────────────
class _GuestProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: R.pad(context, 250),
                      height: R.pad(context, 250),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.pad(context, 20),
                      R.pad(context, 24) + MediaQuery.of(context).padding.top,
                      R.pad(context, 20),
                      R.pad(context, 32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: Colors.white.withOpacity(0.6),
                            strokeWidth: 1.5,
                            dashPattern: const [4, 4],
                            radius: Radius.circular(R.r(context, 38)),
                          ),
                          child: SizedBox(
                            width: R.pad(context, 76),
                            height: R.pad(context, 76),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: R.icon(context, 38),
                            ),
                          ),
                        ),
                        SizedBox(height: R.pad(context, 16)),
                        Text(
                          AppLocalizations.of(context).welcomeBack,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.sp(context, 22),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: R.pad(context, 6)),
                        Text(
                          AppLocalizations.of(context).loginSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: R.sp(context, 13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: R.pad(context, 20)),
                        GestureDetector(
                          onTap: () => AuthBottomSheet.show(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.pad(context, 24),
                              vertical: R.pad(context, 10),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                R.r(context, 24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  color: AppColors.primary,
                                  size: R.icon(context, 16),
                                ),
                                SizedBox(width: R.pad(context, 6)),
                                Text(
                                  AppLocalizations.of(context).login,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: R.sp(context, 14),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: R.pad(context, 20),
                  vertical: R.pad(context, 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: R.pad(context, 8),
                        bottom: R.pad(context, 12),
                      ),
                      child: Text(
                        AppLocalizations.of(context).accountTitle,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: R.sp(context, 12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(R.r(context, 24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _GuestMenuItem(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF7C4DFF),
                            iconBgColor: const Color(0xFFF1EEFF),
                            label: AppLocalizations.of(context).faqs,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FaqsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.headset_mic_outlined,
                            iconColor: const Color(0xFFF97316),
                            iconBgColor: const Color(0xFFFFF7ED),
                            label: AppLocalizations.of(context).contactUs,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactUsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.favorite_border_rounded,
                            iconColor: const Color(0xFFF43F5E),
                            iconBgColor: const Color(0xFFFFF1F2),
                            label: AppLocalizations.of(context).myFavourites,
                            onTap: () {
                              AuthBottomSheet.show(context);
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF0EA5E9),
                            iconBgColor: const Color(0xFFF0F9FF),
                            label: AppLocalizations.of(context).language,
                            onTap: () => LanguagePickerSheet.show(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.pad(context, 32)),
                    Center(
                      child: Text(
                        'Buy SAWA - v1.0.0',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: R.sp(context, 11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final VoidCallback onTap;

  const _GuestMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.r(context, 24)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.pad(context, 16),
          vertical: R.pad(context, 16),
        ),
        child: Row(
          children: [
            Container(
              width: R.pad(context, 40),
              height: R.pad(context, 40),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: R.icon(context, 20)),
              ),
            ),
            SizedBox(width: R.pad(context, 14)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: R.sp(context, 15),
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: R.icon(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logged-in View ────────────────────────────────────────────────────────────
class _LoggedInProfileView extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    if (context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // Header (Teal background, orange avatar with initials, and username)
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: R.pad(context, 250),
                      height: R.pad(context, 250),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.pad(context, 20),
                      R.pad(context, 24) + MediaQuery.of(context).padding.top,
                      R.pad(context, 20),
                      R.pad(context, 32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar orange circle
                        Container(
                          width: R.pad(context, 76),
                          height: R.pad(context, 76),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5A623), // Orange
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: R.sp(context, 24),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: R.pad(context, 16)),
                        Text(
                          user.fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: R.sp(context, 22),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Settings Items List
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: R.pad(context, 20),
                  vertical: R.pad(context, 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: R.pad(context, 8),
                        bottom: R.pad(context, 12),
                      ),
                      child: Text(
                        'ACCOUNT',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: R.sp(context, 12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(R.r(context, 24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _GuestMenuItem(
                            icon: Icons.person_outline_rounded,
                            iconColor: AppColors.primary,
                            iconBgColor: const Color(0xFFE8F7F6),
                            label: AppLocalizations.of(context).profile,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileDetailsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF7C4DFF),
                            iconBgColor: const Color(0xFFF1EEFF),
                            label: AppLocalizations.of(context).faqs,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FaqsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.headset_mic_outlined,
                            iconColor: const Color(0xFFF97316),
                            iconBgColor: const Color(0xFFFFF7ED),
                            label: AppLocalizations.of(context).contactUs,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactUsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.favorite_border_rounded,
                            iconColor: const Color(0xFFF43F5E),
                            iconBgColor: const Color(0xFFFFF1F2),
                            label: AppLocalizations.of(context).myFavourites,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FavouritesScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF0EA5E9),
                            iconBgColor: const Color(0xFFF0F9FF),
                            label: AppLocalizations.of(context).language,
                            onTap: () => LanguagePickerSheet.show(context),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _GuestMenuItem(
                            icon: Icons.delete_outline_rounded,
                            iconColor: const Color(0xFFEF4444),
                            iconBgColor: const Color(0xFFFFEEEF),
                            label: AppLocalizations.of(context).deleteAccount,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DeleteAccountScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.pad(context, 32)),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: R.pad(context, 50),
                      child: OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(
                            color: Color(0xFFFEE2E2),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              R.r(context, 16),
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFEF4444),
                          size: R.icon(context, 18),
                        ),
                        label: Text(
                          AppLocalizations.of(context).logout,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(context, 15),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: R.pad(context, 24)),
                    Center(
                      child: Text(
                        'Buy SAWA - v1.0.0',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: R.sp(context, 11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
