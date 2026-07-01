import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Request permission (especially for iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized){
      debugPrint('User granted permission for notifications');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Get the FCM Token
    try {
      String? token = await _messaging.getToken();
      debugPrint('====================================');
      debugPrint('FCM TOKEN: $token');
      debugPrint('====================================');
      
      // TODO: Send this token to your backend via API
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }

    // 3. Listen to token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
      // TODO: Send new token to backend
    });

    // 4. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification?.title}');
      }
    });
  }
}
