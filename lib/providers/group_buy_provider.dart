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
        _groups = rawList.map((e) => GroupBuyModel.fromJson(e as Map<String, dynamic>)).toList();
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
