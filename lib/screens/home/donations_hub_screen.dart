import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/donation_service.dart';
import '../../models/donation_campaign_model.dart';
import '../../models/foundation_model.dart';
import '../../widgets/cached_image.dart';
import 'widgets/campaign_detail_sheet.dart';
import 'foundation_detail_screen.dart';

class DonationsHubScreen extends StatefulWidget {
  const DonationsHubScreen({super.key});

  @override
  State<DonationsHubScreen> createState() => _DonationsHubScreenState();
}

class _DonationsHubScreenState extends State<DonationsHubScreen> {
  static const _teal = Color(0xFF008982);
  static const _dark = Color(0xFF0F2D3A);
  
  FoundationModel? _selectedFoundation;
  
  late Future<List<FoundationModel>> _foundationsFuture;
  late Future<List<DonationCampaignModel>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _foundationsFuture = DonationService.getFoundations();
    _campaignsFuture = DonationService.getActiveCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l.locale.languageCode == 'ar' ? 'مركز التبرعات' : 'Donations Hub',
          style: const TextStyle(color: _dark, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: CustomScrollView(
        slivers: [
          // Foundations Horizontal List
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              child: FutureBuilder<List<FoundationModel>>(
                future: _foundationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildFoundationsShimmer();
                  }
                  final foundations = snapshot.data ?? [];
                  if (foundations.isEmpty) return const SizedBox();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: foundations.length + 1, // +1 for "All"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedFoundation == null;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFoundation = null),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? _teal : Colors.grey[100],
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? _teal : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                l.locale.languageCode == 'ar' ? 'الكل' : 'All',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _dark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final foundation = foundations[index - 1];
                      final isSelected = _selectedFoundation?.id == foundation.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFoundation = foundation),
                        onLongPress: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FoundationDetailScreen(foundation: foundation),
                          ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? _teal : Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? _teal : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedImage(
                                  imageUrl: foundation.logoUrl,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  foundation.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : _dark,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Campaigns Vertical List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: FutureBuilder<List<DonationCampaignModel>>(
              future: _campaignsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildCampaignsShimmer();
                }
                final allCampaigns = snapshot.data ?? [];
                // Filter locally by foundation
                final filteredCampaigns = _selectedFoundation == null
                    ? allCampaigns
                    : allCampaigns.where((c) => c.foundationName == _selectedFoundation!.name).toList();

                if (filteredCampaigns.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        l.locale.languageCode == 'ar' ? 'لا توجد حملات حالياً' : 'No campaigns available',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final campaign = filteredCampaigns[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCampaignCard(context, campaign, l),
                      );
                    },
                    childCount: filteredCampaigns.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundationsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: index == 0 ? 60 : 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCampaignsShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
        childCount: 3,
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, DonationCampaignModel campaign, AppLocalizations l) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CampaignDetailSheet(campaign: campaign),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedImage(
                    imageUrl: campaign.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFF5A623)),
                        const SizedBox(width: 4),
                        Text(
                          campaign.remainingDays != null
                              ? '${campaign.remainingDays} ${l.locale.languageCode == 'ar' ? 'أيام متبقية' : 'days left'}'
                              : (l.locale.languageCode == 'ar' ? 'مستمرة' : 'Ongoing'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF5A623),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: dart_ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  campaign.foundationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: campaign.progressPercentage,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(_teal),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(campaign.progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${campaign.collectedAmount.toInt()} AED',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${campaign.targetAmount.toInt()} AED',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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
