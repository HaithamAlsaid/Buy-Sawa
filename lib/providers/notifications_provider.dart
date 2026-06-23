// ─────────────────────────────────────────────────────────────────────────────
// NotificationsProvider — يجيب الإشعارات من الـ API
// الـ Backend هو المسؤول عن إرسال الإشعارات الحقيقية
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/services/api_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'order' | 'cashback' | 'group' | 'promo' | 'referral'
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'promo',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _token;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isEmpty => _notifications.isEmpty;

  // عدد الإشعارات الغير مقروءة
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// تحديد التوكن لما يسجل المستخدم
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      fetchNotifications();
    } else {
      _notifications = [];
      notifyListeners();
    }
  }

  /// جلب الإشعارات من الـ API
  /// GET /api/v1/notifications
  Future<void> fetchNotifications() async {
    if (_token == null) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse(ApiService.notificationsEndpoint),
            headers: ApiService.headers(token: _token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List;
        _notifications =
            data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
        _hasError = false;
      } else {
        _hasError = true;
      }
    } catch (_) {
      // لو الـ API مش جاهز، هتظهر الشاشة فاضية
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديد إشعار كـ مقروء
  /// PUT /api/v1/notifications/{id}/read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    // بنعلم الـ Backend
    try {
      await http.put(
        Uri.parse('${ApiService.notificationsEndpoint}/$id/read'),
        headers: ApiService.headers(token: _token),
      );
    } catch (_) {
      // في حالة فشل الـ API, التغيير اتعمل محلياً
    }
  }

  /// تحديد كل الإشعارات كـ مقروءة
  /// PUT /api/v1/notifications/read-all
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      await http.put(
        Uri.parse('${ApiService.notificationsEndpoint}/read-all'),
        headers: ApiService.headers(token: _token),
      );
    } catch (_) {
      // التغيير اتعمل محلياً
    }
  }
}
