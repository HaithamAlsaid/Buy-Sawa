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

  static Future<bool> subscribeToPlan(int planId) async {
    try {
      final token = await SecureStorageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/monthly-plans/$planId/subscribe'),
        headers: ApiService.headers(token: token),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error subscribing to plan: $e');
      return false;
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
}
