// GroupBuyService — deprecated, all logic moved to GroupBuyProvider
// This file is kept for backward compatibility only
import '../../models/group_buy_model.dart';

class GroupBuyService {
  static Future<List<GroupBuyModel>> getActiveGroups() async => [];
  static Future<List<GroupBuyModel>> getAllGroups() async => [];
  static Future<bool> joinGroup(String code) async => false;
  static Future<GroupBuyModel?> startGroup({
    required String productId,
    required String productName,
  }) async => null;
}
