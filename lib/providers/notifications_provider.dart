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
    // Handle standard flat json or Laravel's DatabaseNotification structure
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    
    return NotificationModel(
      id: json['id'].toString(),
      title: (data['title'] ?? json['title'] ?? 'Notification').toString(),
      body: (data['body'] ?? data['message'] ?? json['body'] ?? json['message'] ?? '').toString(),
      type: (data['type'] ?? json['type'] ?? 'promo').toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['read_at'] != null || (json['is_read'] == true),
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
  /// GET /api/v1/profile/notifications
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
        final Map<String, dynamic> body = jsonDecode(response.body);
        final rawList = (body['data'] is List 
            ? body['data'] 
            : (body is List ? body : [])) as List<dynamic>;
            
        _notifications =
            rawList.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
        _hasError = false;
      } else {
        _hasError = true;
      }
    } catch (e) {
      debugPrint('Notifications Error: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديد إشعار كـ مقروء
  /// POST /api/v1/profile/notifications/{id}/read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    // بنعلم الـ Backend
    try {
      await http.post(
        Uri.parse(ApiService.notificationReadEndpoint(id)),
        headers: ApiService.headers(token: _token),
      );
    } catch (_) {
      // في حالة فشل الـ API, التغيير اتعمل محلياً
    }
  }

  /// تحديد كل الإشعارات كـ مقروءة
  /// POST /api/v1/profile/notifications/read-all
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      await http.post(
        Uri.parse(ApiService.notificationsReadAllEndpoint),
        headers: ApiService.headers(token: _token),
      );
    } catch (_) {
      // التغيير اتعمل محلياً
    }
  }
}
