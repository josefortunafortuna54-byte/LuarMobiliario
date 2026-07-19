import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
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
    } catch (e) {
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
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
    } catch (e) {
      throw Exception('Failed to save token to database: $e');
    }
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required String userId,
  }) async {
    try {
      final response = await _client
          .from(AppConstants.notificationsTable)
          .select('fcm_token')
          .eq('user_id', userId)
          .single();

      final fcmToken = response['fcm_token'] as String?;
      if (fcmToken == null) return;

      final projectId = EnvConfig.fcmProjectId;
      if (projectId.isEmpty) return;

      await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvConfig.fcmSenderId}',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': {
              'type': 'notification',
              'timestamp': DateTime.now().toIso8601String(),
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'high_importance_channel',
                'priority': 'high',
              },
            },
            'apns': {
              'headers': {
                'apns-priority': '10',
              },
            },
          },
        }),
      );
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {}

  void _handleBackgroundMessage(RemoteMessage message) {}

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      throw Exception('Failed to delete FCM token: $e');
    }
  }
}
