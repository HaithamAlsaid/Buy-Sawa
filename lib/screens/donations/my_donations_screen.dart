import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/donation_service.dart';
import '../../models/donation_record_model.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  static const _teal = Color(0xFF008982);
  static const _dark = Color(0xFF0F2D3A);
  
  late Future<List<DonationRecordModel>> _myDonationsFuture;

  @override
  void initState() {
    super.initState();
    _myDonationsFuture = DonationService.getMyDonations();
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
          l.locale.languageCode == 'ar' ? 'سجل تبرعاتي' : 'My Donations',
          style: const TextStyle(color: _dark, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: FutureBuilder<List<DonationRecordModel>>(
        future: _myDonationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          
          final donations = snapshot.data ?? [];
          
          if (donations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    l.locale.languageCode == 'ar' ? 'لم تقم بأي تبرعات بعد' : 'No donations yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final item = donations[index];
              final isAr = l.locale.languageCode == 'ar';
              final dateStr = item.createdAt != null 
                  ? DateFormat('dd MMM yyyy').format(item.createdAt!) 
                  : '';
              
              Color statusColor = Colors.green;
              String statusText = item.status;
              if (item.status.toLowerCase() == 'pending') {
                statusColor = Colors.orange;
                statusText = isAr ? 'قيد الانتظار' : 'Pending';
              } else if (item.status.toLowerCase() == 'successful' || item.status.toLowerCase() == 'paid') {
                statusColor = Colors.green;
                statusText = isAr ? 'ناجح' : 'Successful';
              } else if (item.status.toLowerCase() == 'failed') {
                statusColor = Colors.red;
                statusText = isAr ? 'مرفوض' : 'Failed';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DON-${item.id}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.campaignName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _dark),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'المبلغ' : 'Amount',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.donatedAmount(item.amount.toInt().toString()),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _teal),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isAr ? 'التاريخ' : 'Date',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
