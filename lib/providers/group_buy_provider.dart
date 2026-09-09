import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/group_buy_model.dart';
import '../core/services/api_service.dart';
import '../core/services/secure_storage_service.dart';

class GroupBuyProvider extends ChangeNotifier {
  List<GroupBuyModel> _groups = [];
  bool _isLoading = false;

  List<GroupBuyModel> get myGroups => _groups;
  List<GroupBuyModel> get activeGroups => _groups.where((g) => g.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiService.groupsEndpoint),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final rawList = body['data'] is List ? body['data'] as List : (body is List ? body : []);
        
        if (rawList.isEmpty) {
          // ⚠️ Fallback for testing UI changes while backend is empty
          _groups = [
            GroupBuyModel(
              id: 'gb_mock_1',
              code: 'GB-X72A',
              ownerName: 'Haitham Alsaid',
              arabicOwnerName: 'هيثم الصياد',
              memberCount: 5,
              maxMembers: 10,
              isActive: true,
              productId: 'p_1',
              productName: 'Sony WH-1000XM5',
              arabicProductName: 'سوني سماعات بلوتوث',
              discountPercent: 20,
              expiresAt: DateTime.now().add(const Duration(hours: 47)),
            ),
          ];
        } else {
          _groups = rawList.map((e) => GroupBuyModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Keep existing groups on error
    }

    _isLoading = false;
    notifyListeners();
  }

  // Preview before joining
  Future<GroupBuyModel?> getGroupInvitation(String code) async {
    try {
      final token = await SecureStorageService.getToken();
      final res = await http.get(
        Uri.parse(ApiService.groupInvitationEndpoint(code)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'] ?? body;
        return GroupBuyModel.fromJson(data as Map<String, dynamic>);
      }
    } catch (_) {}
    
    // ⚠️ Mock fallback for UI testing
    if (code == 'GB-X72A') {
      return GroupBuyModel(
        id: 'gb_mock_1',
        code: 'GB-X72A',
        ownerName: 'Haitham Alsaid',
        arabicOwnerName: 'هيثم الصياد',
        memberCount: 5,
        maxMembers: 10,
        isActive: true,
        productId: 'p_1',
        productName: 'Sony WH-1000XM5',
        arabicProductName: 'سوني سماعات بلوتوث',
        discountPercent: 20,
        expiresAt: DateTime.now().add(const Duration(hours: 47)),
      );
    }
    
    return null;
  }

  // Actual join
  Future<bool> joinGroupById(String groupId) async {
    try {
      final token = await SecureStorageService.getToken();
      final res = await http.post(
        Uri.parse(ApiService.joinGroupEndpoint(groupId)),
        headers: ApiService.headers(token: token),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchGroups(); // refresh list
        return true;
      }
    } catch (_) {}
    return false;
  }
}
