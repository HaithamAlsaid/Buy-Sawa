// ─────────────────────────────────────────────────────────────────────────────
// GroupBuyService — شغال بـ Mock Data دلوقتي
// ─────────────────────────────────────────────────────────────────────────────
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../../models/group_buy_model.dart';
// import 'api_service.dart';
// import 'auth_service.dart';

class GroupBuyService {
  // REAL API (uncomment when API is ready):
  // static Future<List<GroupBuyModel>> getActiveGroups() async {
  //   final token = await AuthService.getToken();
  //   final res = await http.get(
  //     Uri.parse('${ApiService.groupsEndpoint}?status=active'),
  //     headers: ApiService.headers(token: token),
  //   );
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body) as List;
  //     return data.map((e) => GroupBuyModel.fromJson(e)).toList();
  //   }
  //   return [];
  // }

  // MOCK:
  static Future<List<GroupBuyModel>> getActiveGroups() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return mockGroupBuys.where((g) => g.isActive).toList();
  }

  static Future<List<GroupBuyModel>> getAllGroups() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return List.from(mockGroupBuys);
  }

  // REAL API (uncomment when API is ready):
  // static Future<GroupBuyModel?> joinGroup(String code) async {
  //   final token = await AuthService.getToken();
  //   final res = await http.post(
  //     Uri.parse('${ApiService.groupsEndpoint}/join'),
  //     headers: ApiService.headers(token: token),
  //     body: jsonEncode({'code': code}),
  //   );
  //   if (res.statusCode == 200) return GroupBuyModel.fromJson(jsonDecode(res.body));
  //   return null;
  // }

  // MOCK:
  static Future<bool> joinGroup(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return mockGroupBuys.any((g) => g.code == code && g.isActive);
  }

  // REAL API (uncomment when API is ready):
  // static Future<GroupBuyModel?> startGroup({required String productId, required String productName}) async {
  //   final token = await AuthService.getToken();
  //   final res = await http.post(
  //     Uri.parse(ApiService.groupsEndpoint),
  //     headers: ApiService.headers(token: token),
  //     body: jsonEncode({'productId': productId, 'productName': productName}),
  //   );
  //   if (res.statusCode == 201) return GroupBuyModel.fromJson(jsonDecode(res.body));
  //   return null;
  // }

  // MOCK:
  static Future<GroupBuyModel> startGroup({
    required String productId,
    required String productName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return GroupBuyModel(
      id: 'gb_${DateTime.now().millisecondsSinceEpoch}',
      code: 'GB-${DateTime.now().millisecond.toString().padLeft(3, '0')}',
      ownerName: 'My Squad',
      memberCount: 1,
      maxMembers: 10,
      isActive: true,
      productId: productId,
      productName: productName,
      discountPercent: 15,
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
  }
}
