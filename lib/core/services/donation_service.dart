import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/donation_campaign_model.dart';
import '../../models/foundation_model.dart';
import '../../models/donor_model.dart';
import '../../models/donation_record_model.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class DonationService {
  // ─── Campaigns ──────────────────────────────────────────
  static Future<List<DonationCampaignModel>> getActiveCampaigns() async {
    try {
      final res = await http
          .get(Uri.parse(ApiService.donationCampaignsEndpoint), headers: ApiService.headers())
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final items = (decoded is List) ? decoded : (decoded['data'] as List? ?? []);
        return items.map((e) => DonationCampaignModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error getActiveCampaigns: $e');
    }
    return [];
  }

  static Future<DonationCampaignModel?> getCampaignDetails(String slug) async {
    try {
      final res = await http.get(Uri.parse(ApiService.donationCampaignDetailEndpoint(slug)), headers: ApiService.headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return DonationCampaignModel.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      print('Error getCampaignDetails: $e');
    }
    return null;
  }

  static Future<List<DonorModel>> getCampaignDonors(String slug) async {
    try {
      final res = await http.get(Uri.parse(ApiService.donationCampaignDonorsEndpoint(slug)), headers: ApiService.headers());
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final items = (decoded is List) ? decoded : (decoded['data'] as List? ?? []);
        return items.map((e) => DonorModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error getCampaignDonors: $e');
    }
    return [];
  }

  // ─── Foundations ──────────────────────────────────────────
  static Future<List<FoundationModel>> getFoundations() async {
    try {
      final res = await http
          .get(Uri.parse(ApiService.donationFoundationsEndpoint), headers: ApiService.headers())
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final items = (decoded is List) ? decoded : (decoded['data'] as List? ?? []);
        return items.map((e) => FoundationModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error getFoundations: $e');
    }
    return [];
  }

  // ─── Checkout ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkoutDonation({
    required String campaignId,
    required double amount,
    required bool isAnonymous,
    String? donorName,
    String? donorPhone,
    String? donorEmail,
    String? notes,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      final body = {
        'campaign_id': campaignId,
        'amount': amount,
        'payment_gateway': 'paymob',
        'is_anonymous': isAnonymous ? 1 : 0,
        if (!isAnonymous && donorName != null && donorName.isNotEmpty) 'donor_name': donorName,
        if (!isAnonymous && donorPhone != null && donorPhone.isNotEmpty) 'donor_phone': donorPhone,
        if (!isAnonymous && donorEmail != null && donorEmail.isNotEmpty) 'donor_email': donorEmail,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final res = await http.post(
        Uri.parse(ApiService.donationCheckoutEndpoint),
        headers: ApiService.headers(token: token),
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(res.body)};
      } else {
        return {'success': false, 'error': jsonDecode(res.body)['message'] ?? 'Checkout failed'};
      }
    } catch (e) {
      print('Error checkoutDonation: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── Status ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getDonationStatus(dynamic id) async {
    try {
      final res = await http.get(Uri.parse(ApiService.donationStatusEndpoint(id)), headers: ApiService.headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error getDonationStatus: $e');
    }
    return null;
  }

  // ─── Profile Donations ───────────────────────────────────
  static Future<List<DonationRecordModel>> getMyDonations() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return [];
      
      final res = await http.get(Uri.parse(ApiService.myDonationsEndpoint), headers: ApiService.headers(token: token));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final items = (decoded is List) ? decoded : (decoded['data'] as List? ?? []);
        return items.map((e) => DonationRecordModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error getMyDonations: $e');
    }
    return [];
  }
}
