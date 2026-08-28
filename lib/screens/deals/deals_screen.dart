import 'dart:async';
import 'package:buysawa/models/group_buy_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/group_buy_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_bottom_sheet.dart';
import '../../core/localization/app_localizations.dart';
import 'start_group_screen.dart';
import 'active_group_screen.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final _codeCtrl = TextEditingController();
  Timer? _timer;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Rebuild every minute to update countdown timers
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _joinGroup(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      Navigator.pop(context);
      AuthBottomSheet.show(context);
      return;
    }
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final groupProvider = context.read<GroupBuyProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final invalidMsg = AppLocalizations.of(context).groupCodeInvalid(code);

    final found = await groupProvider.tryJoinGroup(code);
    if (!mounted) return;
    navigator.pop();
    _codeCtrl.clear();

    if (found) {
      final joinedGroup = groupProvider.myGroups.firstWhere(
        (g) => g.code == code,
      );
      navigator.push(
        MaterialPageRoute(
          builder: (context) => ActiveGroupScreen(group: joinedGroup),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(invalidMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showJoinDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).joinGroup,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).enterGroupCode,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. GB-X72A',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _joinGroup(ctx),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).joinGroup,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupBuyProvider>();

    final allGroups = groupProvider.myGroups;
    final activeCount = allGroups.where((g) => g.isActive).length;
    final expiredCount = allGroups.length - activeCount;

    final displayedGroups = allGroups.where((g) {
      if (_selectedTab == 1) return g.isActive;
      if (_selectedTab == 2) return !g.isActive;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 75,
        backgroundColor: AppColors.primary,

        automaticallyImplyLeading: Navigator.canPop(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).myDeals.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.of(context).activeGroupBuys,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 4),
            child: GestureDetector(
              onTap: _showJoinDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).joinBtn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── How it works banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StartGroupScreen(),
                  ),
                );
              },
              child: DottedBorder(
                options: const RoundedRectDottedBorderOptions(
                  color: AppColors.primary, // Teal border color
                  strokeWidth: 1.5,
                  dashPattern: [4, 4],
                  radius: Radius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).startGroupBuy,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).enjoyDiscounts,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // ── Tabs Header ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab(
                  0,
                  AppLocalizations.of(context).allGroupsTab,
                  null,
                  allGroups.length,
                ),
                const SizedBox(width: 16),
                _buildTab(
                  1,
                  AppLocalizations.of(context).activeTab(activeCount),
                  AppColors.success,
                  activeCount,
                ),
                const SizedBox(width: 16),
                _buildTab(
                  2,
                  AppLocalizations.of(context).expiredTab(expiredCount),
                  AppColors.error,
                  expiredCount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Filtered Groups List ────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: displayedGroups.length,
              itemBuilder: (context, index) {
                return _buildGroupCard(displayedGroups[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, Color? dotColor, int count) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            if (index == 0) ...[
              Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
            ] else if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              index == 0 ? title : title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(GroupBuyModel g) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActiveGroupScreen(group: g)),
        );
      },
      child:
          Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_offer_outlined,
                          color: Color(0xFFF5A623),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Middle Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(
                                            context,
                                          ).locale.languageCode ==
                                          'ar'
                                      ? g.arabicOwnerName
                                      : g.ownerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    g.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Bottom row
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_outlined,
                                  size: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${g.memberCount} ${AppLocalizations.of(context).locale.languageCode == 'ar' ? 'أعضاء' : 'members'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Status pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: g.isActive
                                        ? const Color(0xFFE8FAF2)
                                        : const Color(0xFFFFEEEF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: g.isActive
                                              ? AppColors.success
                                              : AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        g.isActive
                                            ? (AppLocalizations.of(
                                                        context,
                                                      ).locale.languageCode ==
                                                      'ar'
                                                  ? 'نشط'
                                                  : 'ACTIVE')
                                            : (AppLocalizations.of(
                                                        context,
                                                      ).locale.languageCode ==
                                                      'ar'
                                                  ? 'منتهي'
                                                  : 'EXPIRED'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: g.isActive
                                              ? AppColors.success
                                              : AppColors.error,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Right arrow
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCBD5E1),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideY(
                begin: 0.05,
                end: 0,
                duration: const Duration(milliseconds: 300),
              ),
    );
  }
}
