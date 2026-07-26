import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import 'supabase_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _client = SupabaseService.client;

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      }
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (_) {
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<void> saveTokenToDatabase(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return;

      await _client.from(AppConstants.notificationsTable).upsert({
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required String userId,
  }) async {
    try {
      await _client.rpc('send_notification', params: {
        'p_user_id': userId,
        'p_title': title,
        'p_body': body,
      });
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {}

  void _handleBackgroundMessage(RemoteMessage message) {}

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }
}
