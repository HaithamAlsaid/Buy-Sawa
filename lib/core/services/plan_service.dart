import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buysawa/core/services/api_service.dart';
import '../../models/monthly_plan_model.dart';
import 'secure_storage_service.dart';

class PlanService {
  static Future<List<MonthlyPlanModel>> getMonthlyPlans() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/monthly-plans'),
        headers: ApiService.headers(),
      );
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          final List plans = data['data'];
          return plans.map((e) => MonthlyPlanModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching monthly plans: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> subscribeToPlan(int planId) async {
    try {
      final token = await SecureStorageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/monthly-plans/$planId/subscribe'),
        headers: ApiService.headers(token: token),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }

      // Parse server error message
      try {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? body['error'] ?? body['msg'];
        return {'success': false, 'error': _resolveErrorMessage(msg?.toString())};
      } catch (_) {
        return {'success': false};
      }
    } catch (e) {
      print('Error subscribing to plan: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>?> getMySubscription() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiService.myMonthlySubscriptionEndpoint),
        headers: ApiService.headers(token: token),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API returns { "data": { ... } } or just the object
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error fetching my subscription: $e');
      return null;
    }
  }

  /// Maps raw server error keys to human-readable messages.
  static String? _resolveErrorMessage(String? raw) {
    if (raw == null) return null;

    final isAr = ApiService.currentLocale == 'ar';

    // Known error key mappings [ar, en]
    final Map<String, List<String>> errorMap = {
      'insufficient_funds': [
        'رصيد محفظتك غير كافٍ للاشتراك في هذه الباقة. يرجى شحن المحفظة أولاً.',
        'Your wallet balance is insufficient. Please top up your wallet first.',
      ],
      'already_subscribed': [
        'أنت مشترك بالفعل في باقة نشطة.',
        'You are already subscribed to an active plan.',
      ],
      'plan_not_found': [
        'الباقة المطلوبة غير موجودة.',
        'The requested plan was not found.',
      ],
      'unauthenticated': [
        'يرجى تسجيل الدخول أولاً.',
        'Please login first.',
      ],
    };

    // Check if raw message contains any known key
    for (final entry in errorMap.entries) {
      if (raw.toLowerCase().contains(entry.key)) {
        return isAr ? entry.value[0] : entry.value[1];
      }
    }

    // If unknown key, clean it up (remove leading numbers and underscores)
    final cleaned = raw
        .replaceAll(RegExp(r'^\d+_'), '')
        .replaceAll('_', ' ')
        .replaceAll('.', ' ');
    return cleaned;
  }
}
