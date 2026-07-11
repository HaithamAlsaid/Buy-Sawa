import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _productsKey = 'cached_products';
  static const String _categoriesKey = 'cached_categories';
  static const String _activeGroupsKey = 'cached_active_groups';
  static const String _allGroupsKey = 'cached_all_groups';

  //حفظ البيانات (Save to Cache) 
  
  static Future<void> saveProducts(List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(jsonList));
  }

  static Future<void> saveCategories(List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(jsonList));
  }

  static Future<void> saveActiveGroups(List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeGroupsKey, jsonEncode(jsonList));
  }

  static Future<void> saveAllGroups(List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_allGroupsKey, jsonEncode(jsonList));
  }

  //استرجاع البيانات (Load from Cache)

  static Future<List<dynamic>?> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_productsKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  static Future<List<dynamic>?> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_categoriesKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  static Future<List<dynamic>?> getCachedActiveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_activeGroupsKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  static Future<List<dynamic>?> getCachedAllGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_allGroupsKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  // مسح الكاش (Clear Cache) 
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_activeGroupsKey);
    await prefs.remove(_allGroupsKey);
  }
}
