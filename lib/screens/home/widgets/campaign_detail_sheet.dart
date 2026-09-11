import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/donation_campaign_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/cached_image.dart';
import '../../../screens/auth/login_screen.dart';
import 'donation_bottom_sheet.dart';
import 'package:provider/provider.dart';

class CampaignDetailSheet extends StatelessWidget {
  final DonationCampaignModel campaign;
  const CampaignDetailSheet({super.key, required this.campaign});

  static void show(BuildContext context, DonationCampaignModel campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CampaignDetailSheet(campaign: campaign),
    );
  }

  static const _teal = Color(0xFF008982);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final screenH = MediaQuery.of(context).size.height;
    final progress = campaign.progressPercentage;
    final remaining = campaign.targetAmount - campaign.collectedAmount;

    return Container(
      height: screenH * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ── Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign Hero Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedImage(
                      imageUrl: campaign.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Foundation badge + days left
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          campaign.foundationName,
                          style: const TextStyle(
                            color: _teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (campaign.remainingDays != null)
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${campaign.remainingDays} ${l.daysLeft}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2D3A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    campaign.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress stats card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4FFFE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _teal.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Collected
                            Expanded(
                              child: _StatBox(
                                label: l.collected,
                                value:
                                    '${campaign.collectedAmount.toInt()} ${l.aed}',
                                color: _teal,
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[200]),
                            // Remaining
                            Expanded(
                              child: _StatBox(
                                label: 'المتبقي',
                                value:
                                    '${remaining.toInt()} ${l.aed}',
                                color: Colors.orange,
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[200]),
                            // Target
                            Expanded(
                              child: _StatBox(
                                label: l.target,
                                value:
                                    '${campaign.targetAmount.toInt()} ${l.aed}',
                                color: Colors.grey[600]!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}% مكتملة',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _teal,
                                  ),
                                ),
                                Text(
                                  '${campaign.remainingDays ?? 0} ${l.daysLeft}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                    Colors.grey[200],
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        _teal),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom sticky "Donate Now" button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[100]!, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    bool isLoggedIn = false;
                    try {
                      final auth = context.read<AuthProvider>();
                      isLoggedIn = auth.isLoggedIn;
                    } catch (_) {}

                    if (!isLoggedIn) {
                      Navigator.pop(context); // close this sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                      return;
                    }

                    // Open donation payment sheet on top
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) =>
                          DonationBottomSheet(campaign: campaign),
                    );
                  },
                  icon: const Icon(Icons.favorite_rounded, size: 20),
                  label: Text(
                    l.donateNow,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
