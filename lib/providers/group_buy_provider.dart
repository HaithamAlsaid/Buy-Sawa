import 'package:flutter/material.dart';
import '../models/group_buy_model.dart';

class GroupBuyProvider extends ChangeNotifier {
  final List<GroupBuyModel> _groups = List.from(mockGroupBuys);

  List<GroupBuyModel> get myGroups => _groups;
  List<GroupBuyModel> get activeGroups =>
      _groups.where((g) => g.isActive).toList();

  void joinGroup(String code) {
    final idx = _groups.indexWhere((g) => g.code == code);
    if (idx >= 0 && _groups[idx].isActive) {
      final g = _groups[idx];
      _groups[idx] = GroupBuyModel(
        id: g.id, code: g.code, ownerName: g.ownerName,
        memberCount: g.memberCount + 1, maxMembers: g.maxMembers,
        isActive: g.isActive, productId: g.productId,
        productName: g.productName, discountPercent: g.discountPercent,
        expiresAt: g.expiresAt,
      );
      notifyListeners();
    }
  }

  Future<bool> tryJoinGroup(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final idx = _groups.indexWhere((g) => g.code == code);
    if (idx >= 0 && _groups[idx].isActive) {
      final g = _groups[idx];
      _groups[idx] = GroupBuyModel(
        id: g.id, code: g.code, ownerName: g.ownerName,
        memberCount: g.memberCount + 1, maxMembers: g.maxMembers,
        isActive: g.isActive, productId: g.productId,
        productName: g.productName, discountPercent: g.discountPercent,
        expiresAt: g.expiresAt,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void startNewGroup({required String productId, required String productName}) {
    final newGroup = GroupBuyModel(
      id: 'gb_${DateTime.now().millisecond}',
      code: 'GB-${DateTime.now().millisecond.toString().substring(0, 3).toUpperCase()}',
      ownerName: 'My Squad',
      memberCount: 1,
      maxMembers: 10,
      isActive: true,
      productId: productId,
      productName: productName,
      discountPercent: 15,
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
    _groups.insert(0, newGroup);
    notifyListeners();
  }
}
