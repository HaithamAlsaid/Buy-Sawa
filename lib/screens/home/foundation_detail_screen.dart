import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/donation_service.dart';
import '../../models/donation_campaign_model.dart';
import '../../models/foundation_model.dart';
import '../../widgets/cached_image.dart';
import 'widgets/campaign_detail_sheet.dart';

class FoundationDetailScreen extends StatefulWidget {
  final FoundationModel foundation;

  const FoundationDetailScreen({super.key, required this.foundation});

  @override
  State<FoundationDetailScreen> createState() => _FoundationDetailScreenState();
}

class _FoundationDetailScreenState extends State<FoundationDetailScreen> {
  static const _teal = Color(0xFF008982);
  static const _dark = Color(0xFF0F2D3A);

  late Future<List<DonationCampaignModel>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch all active campaigns and filter by foundation locally
    _campaignsFuture = DonationService.getActiveCampaigns().then(
      (campaigns) => campaigns
          .where((c) => c.foundationName == widget.foundation.name)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = widget.foundation;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l.locale.languageCode == 'ar' ? 'ملف الجمعية' : 'Foundation Profile',
          style: const TextStyle(color: _dark, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header Section
            _buildHeader(context, f),
            
            const SizedBox(height: 16),
            
            // About Section
            if (f.description.isNotEmpty)
              _buildAboutSection(context, f, l),

            const SizedBox(height: 16),

            // Campaigns Section
            _buildCampaignsSection(context, l),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FoundationModel f) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedImage(
              imageUrl: f.logoUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            f.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _dark,
            ),
          ),
          if (f.code.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              f.code,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                f.activeCampaignsCount.toString(),
                AppLocalizations.of(context).locale.languageCode == 'ar' ? 'الحملات' : 'Campaigns',
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _buildStatColumn(
                f.registrationNumber.isNotEmpty ? f.registrationNumber : '---',
                AppLocalizations.of(context).locale.languageCode == 'ar' ? 'رقم التسجيل' : 'Registration',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, FoundationModel f, AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language, color: _teal, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l.locale.languageCode == 'ar' ? 'رسالة المؤسسة' : 'About Foundation',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            f.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsSection(BuildContext context, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            l.locale.languageCode == 'ar' ? 'الحملات التابعة' : 'Associated Campaigns',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _dark,
            ),
          ),
        ),
        FutureBuilder<List<DonationCampaignModel>>(
          future: _campaignsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: _teal)),
              );
            }
            final campaigns = snapshot.data ?? [];
            if (campaigns.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    l.locale.languageCode == 'ar'
                        ? 'لا توجد حملات نشطة لهذه الجمعية حالياً'
                        : 'No active campaigns for this foundation currently',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: campaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _CampaignCard(campaign: campaigns[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

// Reusing a simplified CampaignCard for the profile list
class _CampaignCard extends StatelessWidget {
  final DonationCampaignModel campaign;

  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final _teal = const Color(0xFF008982);
    final _dark = const Color(0xFF0F2D3A);
    final progress = campaign.progressPercentage;

    return GestureDetector(
      onTap: () {
        CampaignDetailSheet.show(context, campaign);
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedImage(
                imageUrl: campaign.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: TextStyle(
                      fontSize: 16,
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

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_teal),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.locale.languageCode == 'ar' ? 'المحصل' : 'Collected',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${campaign.collectedAmount.toStringAsFixed(0)} ${l.aed}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _teal,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l.locale.languageCode == 'ar' ? 'الهدف' : 'Target',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${campaign.targetAmount.toStringAsFixed(0)} ${l.aed}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _dark,
                            ),
                          ),
                        ],
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
