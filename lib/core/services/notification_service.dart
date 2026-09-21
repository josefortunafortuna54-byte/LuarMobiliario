import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../config/env_config.dart';
import 'supabase_service.dart';

class NotificationService {
  final SupabaseClient _client = SupabaseService.client;

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _firebaseInitialized = false;

  Future<void> initialize() async {
    try {
      if (EnvConfig.fcmSenderId.isNotEmpty &&
          EnvConfig.fcmProjectId.isNotEmpty &&
          EnvConfig.fcmApiKey.isNotEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: EnvConfig.fcmApiKey,
            appId: EnvConfig.fcmAppId.isNotEmpty
                ? EnvConfig.fcmAppId
                : _appIdFromSenderId(EnvConfig.fcmSenderId),
            messagingSenderId: EnvConfig.fcmSenderId,
            projectId: EnvConfig.fcmProjectId,
          ),
        );
        _firebaseInitialized = true;
      } else {
        debugPrint('[Luar] Firebase não configurado. Notificações push desativadas.');
      }
    } catch (e) {
      _firebaseInitialized = false;
      debugPrint('[Luar] Firebase initialization failed: $e');
    }

    if (!_firebaseInitialized) return;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _initLocalNotifications();

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      }
    } catch (e) {
      debugPrint('[Luar] Firebase messaging setup failed: $e');
    }
  }

  static String _appIdFromSenderId(String senderId) {
    final digits = senderId.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '1:0:android:unknown';
    final shortDigits = digits.length <= 16 ? digits : digits.substring(0, 16);
    return '1:$digits:android:$shortDigits';
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);
  }

  Future<String?> getToken() async {
    if (!_firebaseInitialized) return null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      debugPrint('[Luar] Failed to get FCM token: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh =>
      _firebaseInitialized
          ? FirebaseMessaging.instance.onTokenRefresh
          : const Stream<String>.empty();

  Future<void> saveTokenToDatabase(String userId) async {
    if (!_firebaseInitialized) return;
    try {
      final token = await getToken();
      if (token == null) return;

      await _client.from(AppConstants.notificationsTable).upsert({
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[Luar] Failed to save token: $e');
    }
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

      if (!_firebaseInitialized) return;

      // Envio real via FCM (edge function send-notification).
      // A função entrega o push nos tokens FCM registados do utilizador.
      await _client.functions.invoke(
        'send-notification',
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
        },
      );
    } catch (e) {
      debugPrint('[Luar] Failed to send notification: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'luar_company_channel',
          'Luar Company Notificações',
          channelDescription: 'Notificações da aplicação Luar Company',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // handled by Firebase default handler or onMessageOpenedApp
  }

  Future<void> deleteToken() async {
    if (!_firebaseInitialized) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('[Luar] Failed to delete token: $e');
    }
  }
}
