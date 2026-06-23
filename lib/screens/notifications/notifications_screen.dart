import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

// ── Notification Model 
class _NotifItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isUnread;

  const _NotifItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isUnread = false,
  });
}

//Mock Notifications
final _mockNotifs = [
  _NotifItem(
    title: 'Ahmed joined your Group Cart',
    subtitle: "You're 1 member away from a 15% group discount.",
    time: 'Just now',
    icon: Icons.group_rounded,
    iconBg: const Color(0xFFE8F5E9),
    iconColor: const Color(0xFF43A047),
    isUnread: true,
  ),
  _NotifItem(
    title: 'Cashback credited · 65 AED',
    subtitle: 'Your Sony WH-1000XM5 cashback is now in your wallet.',
    time: '2h ago',
    icon: Icons.card_giftcard_rounded,
    iconBg: const Color(0xFFFFF3E0),
    iconColor: const Color(0xFFF5A623),
    isUnread: true,
  ),
  _NotifItem(
    title: 'Order #SW-29412 is out for delivery',
    subtitle: 'Expected today between 4 – 7 PM.',
    time: '5h ago',
    icon: Icons.local_shipping_rounded,
    iconBg: const Color(0xFFE8F5E9),
    iconColor: const Color(0xFF1BA8A0),
    isUnread: true,
  ),
  _NotifItem(
    title: 'Flash Sale starts in 1 hour',
    subtitle: 'Up to 60% off Beauty essentials. Set a reminder.',
    time: 'Yesterday',
    icon: Icons.local_offer_rounded,
    iconBg: const Color(0xFFFCE4EC),
    iconColor: const Color(0xFFE91E63),
  ),
  _NotifItem(
    title: 'Layla shared a product with you',
    subtitle: 'Check out Apple Watch Series 9 — Share & Earn 5%.',
    time: 'Yesterday',
    icon: Icons.notifications_rounded,
    iconBg: const Color(0xFFEDE7F6),
    iconColor: const Color(0xFF7E57C2),
  ),
  _NotifItem(
    title: 'Referral bonus · 25 AED',
    subtitle: 'Ahmed completed his first order — bonus added.',
    time: 'Yesterday',
    icon: Icons.card_giftcard_rounded,
    iconBg: const Color(0xFFFFF3E0),
    iconColor: const Color(0xFFF5A623),
  ),
];

// ── Notifications Screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<bool> _read;

  @override
  void initState() {
    super.initState();
    _read = List.generate(_mockNotifs.length, (i) => !_mockNotifs[i].isUnread);
  }

  void _markAllRead() => setState(() => _read = List.filled(_mockNotifs.length, true));

  @override
  Widget build(BuildContext context) {
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Row(
                      children: [
                        Icon(Icons.done_all_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text('Read all',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _mockNotifs.length,
                itemBuilder: (context, i) {
                  final n = _mockNotifs[i];
                  final isRead = _read[i];
                  return _NotifCard(
                    item: n,
                    isRead: isRead,
                    onTap: () => setState(() => _read[i] = true),
                  )
                      .animate(delay: (i * 60).ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.08, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Card ──────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  final bool isRead;
  final VoidCallback onTap;

  const _NotifCard({
    required this.item,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEFF3)),
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
                    color: item.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                if (!isRead)
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
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isRead
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF555555),
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
