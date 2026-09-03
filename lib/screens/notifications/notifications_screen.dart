import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/notifications_provider.dart';

// ── Notifications Screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationsProvider>();
      // Only fetch if empty to avoid reloading unnecessarily, 
      // or we can force reload to get latest. Let's force fetch to ensure it's fresh.
      provider.fetchNotifications();
    });
  }

  void _markAllRead() {
    context.read<NotificationsProvider>().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final notifications = provider.notifications;
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      isAr ? 'الإشعارات' : 'Notifications',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.done_all_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'قراءة الكل' : 'Read all',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 70), // Keep title centered
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────
            Expanded(
              child: provider.isLoading && notifications.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : provider.hasError && notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                isAr ? 'حدث خطأ. اسحب للتحديث.' : 'An error occurred. Pull to refresh.',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    isAr ? 'لا توجد إشعارات' : 'No notifications yet',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: provider.fetchNotifications,
                              color: AppColors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: notifications.length,
                                itemBuilder: (context, i) {
                                  final n = notifications[i];
                                  return _NotifCard(
                                    item: n,
                                    onTap: () {
                                      if (!n.isRead) {
                                        provider.markAsRead(n.id);
                                      }
                                    },
                                  )
                                  .animate(delay: (i * 60).ms)
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: 0.08, end: 0);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Card
class _NotifCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const _NotifCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (item.type.toLowerCase()) {
      case 'order':
        icon = Icons.local_shipping_rounded;
        iconBg = const Color(0xFFE8F5E9);
        iconColor = AppColors.primary;
        break;
      case 'group':
        icon = Icons.group_rounded;
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF43A047);
        break;
      case 'cashback':
      case 'referral':
        icon = Icons.card_giftcard_rounded;
        iconBg = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFF5A623);
        break;
      default:
        icon = Icons.notifications_rounded;
        iconBg = const Color(0xFFEDE7F6);
        iconColor = const Color(0xFF7E57C2);
    }

    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    // Format date properly (e.g., "12 Oct, 10:30 AM")
    final timeString = DateFormat('dd MMM, hh:mm a', isAr ? 'ar' : 'en').format(item.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? const Color(0xFFEEEFF3) : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                if (!item.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.isRead ? const Color(0xFF9E9E9E) : const Color(0xFF555555),
                      height: 1.4,
                    ),
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
