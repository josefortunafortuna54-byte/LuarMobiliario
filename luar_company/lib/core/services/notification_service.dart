import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../utils/navigation.dart';
import '../utils/routes.dart';
import 'notification_preferences.dart';
import 'supabase_service.dart';

/// Handler de mensagens em segundo plano (tem de ser top-level).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // O sistema mostra a notificação automaticamente; nada a fazer aqui.
if (kDebugMode) {   debugPrint('[Luar] Mensagem em segundo plano: ${message.messageId}'); }
}

class NotificationService {
  // Acesso lazy: o cliente só é resolvido quando usado, para a app não
  // crashar no arranque quando o Supabase não está configurado (ex.: testes
  // de integração sem --dart-define).
  SupabaseClient get _client => SupabaseService.client;

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<Map<String, dynamic>> _tapController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Emitido quando o utilizador toca numa notificação (com os dados).
  Stream<Map<String, dynamic>> get onNotificationTap => _tapController.stream;

  bool _firebaseInitialized = false;

  /// Rota de uma notificação de arranque frio, guardada até o Navigator
  /// estar pronto (a navegação direta falhava porque o splash ainda estava
  /// montado e o delay fixo de 500ms competia com a transição do splash).
  ({String name, Object? arguments})? _pendingRoute;

  Future<void> initialize() async {
    await NotificationPreferences.instance.load();

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
if (kDebugMode) {         debugPrint(
          '[Luar] Firebase não configurado. Notificações push desativadas.',
        ); }
      }
    } catch (e) {
      _firebaseInitialized = false;
if (kDebugMode) {       debugPrint('[Luar] Firebase initialization failed: $e'); }
    }

    if (!_firebaseInitialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // O token FCM pode ser rotacionado pelo Google; regrista o novo
        // sempre que isso acontece para a entrega push não ficar obsoleta.
        FirebaseMessaging.instance.onTokenRefresh.listen((
          String token,
        ) {
          final userId = _client.auth.currentUser?.id;
          if (userId != null) saveTokenToDatabase(userId);
        });

        // App aberto a partir de uma notificação (cold start). Guarda a rota
        // até o splash terminar e chamar [consumePendingNavigation].
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) {
          _queueRoute(initial.data['route']?.toString());
        }
      }
    } catch (e) {
if (kDebugMode) {       debugPrint('[Luar] Firebase messaging setup failed: $e'); }
    }
  }

  static String _appIdFromSenderId(String senderId) {
    final digits = senderId.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '1:0:android:unknown';
    final shortDigits = digits.length <= 16 ? digits : digits.substring(0, 16);
    return '1:$digits:android:$shortDigits';
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _tapController.add({'route': payload});
          _navigateToRoute(payload);
        }
      },
    );
  }

  Future<String?> getToken() async {
    if (!_firebaseInitialized) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
if (kDebugMode) {       debugPrint('[Luar] Failed to get FCM token: $e'); }
      return null;
    }
  }

  Stream<String> get onTokenRefresh =>
      _firebaseInitialized
          ? FirebaseMessaging.instance.onTokenRefresh
          : const Stream<String>.empty();

  /// Regista o token do dispositivo na tabela `device_tokens` (upsert).
  Future<void> saveTokenToDatabase(String userId) async {
    if (!_firebaseInitialized) return;
    try {
      final token = await getToken();
      if (token == null) return;

      await _client.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': _platform,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');

      // Limpa tokens antigos deste mesmo utilizador/plataforma (a chave
      // única é o token — sem isto, a rotação acumulava linhas mortas que
      // a Edge Function tentaria entregar).
      await _client
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('platform', _platform)
          .neq('token', token);
    } catch (e) {
if (kDebugMode) {       debugPrint('[Luar] Failed to save token: $e'); }
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required String userId,
    String? route,
    NotificationCategory? category,
  }) async {
    try {
      await _client.rpc(
        'send_notification',
        params: {'p_user_id': userId, 'p_title': title, 'p_body': body},
      );

      if (!_firebaseInitialized) return;

      await _client.functions.invoke(
        'send-notification',
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
          'route': ?route,
          'category': ?category?.name,
        },
      );
    } catch (e) {
if (kDebugMode) {       debugPrint('[Luar] Failed to send notification: $e'); }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final category = NotificationPreferences.fromPayload(
      message.data['category']?.toString(),
    );

    // Respeita a preferência do utilizador por categoria.
    if (!NotificationPreferences.instance.isEnabled(category)) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: _androidDetails(category),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['route']?.toString(),
    );
  }

  /// Canal Android por categoria — permite ao utilizador gerir cada tipo
  /// separadamente nas definições do sistema, além do interruptor in-app.
  AndroidNotificationDetails _androidDetails(NotificationCategory category) {
    const importance = Importance.high;
    const priority = Priority.high;
    const visibility = NotificationVisibility.private;

    return switch (category) {
      NotificationCategory.messages => const AndroidNotificationDetails(
        'luar_messages',
        'Mensagens',
        channelDescription: 'Novas mensagens de conversa',
        importance: importance,
        priority: priority,
        visibility: visibility,
      ),
      NotificationCategory.bookings => const AndroidNotificationDetails(
        'luar_bookings',
        'Agendamentos',
        channelDescription: 'Atualizações de agendamentos e visitas',
        importance: importance,
        priority: priority,
        visibility: visibility,
      ),
      NotificationCategory.listings => const AndroidNotificationDetails(
        'luar_listings',
        'Anúncios',
        channelDescription: 'Novos anúncios e destaques',
        importance: importance,
        priority: priority,
        visibility: visibility,
      ),
      NotificationCategory.promotions => const AndroidNotificationDetails(
        'luar_promotions',
        'Promoções',
        channelDescription: 'Novidades e promoções',
        importance: importance,
        priority: priority,
        visibility: visibility,
      ),
      NotificationCategory.system => const AndroidNotificationDetails(
        'luar_company_channel',
        'Luar Company Notificações',
        channelDescription: 'Notificações gerais da aplicação',
        importance: importance,
        priority: priority,
        visibility: visibility,
      ),
    };
  }

  void _handleNotificationTap(RemoteMessage message) {
    _tapController.add(message.data.map((k, v) => MapEntry(k, v)));
    _navigateToRoute(message.data['route']?.toString());
  }

  /// Valida o payload contra as rotas conhecidas ([AppRoutes.parse]) e
  /// navega. Payloads desconhecidos/inesperificados são ignorados.
  void _navigateToRoute(String? route) {
    final parsed = AppRoutes.parse(route);
    if (parsed == null) {
      if (route != null && route.isNotEmpty) {
if (kDebugMode) {         debugPrint('[Luar] Rota de notificação rejeitada: $route'); }
      }
      return;
    }
    AppNavigator.navigatorKey.currentState?.pushNamed(
      parsed.name,
      arguments: parsed.arguments,
    );
  }

  /// Guarda a rota de uma notificação de arranque frio.
  void _queueRoute(String? route) {
    final parsed = AppRoutes.parse(route);
    if (parsed != null) _pendingRoute = parsed;
  }

  /// Existe uma rota de notificação de arranque frio por consumir?
  /// O splash usa isto para saltar o ecrã de boas-vindas e ir direto
  /// para o destino da notificação.
  bool get hasPendingNavigation => _pendingRoute != null;

  /// Empurra a rota pendente (cold start), se existir. Chamado pelo splash
  /// depois de navegar para o home, quando o Navigator já está pronto.
  void consumePendingNavigation() {
    final pending = _pendingRoute;
    if (pending == null) return;
    _pendingRoute = null;
    AppNavigator.navigatorKey.currentState?.pushNamed(
      pending.name,
      arguments: pending.arguments,
    );
  }

  Future<void> deleteToken() async {
    if (!_firebaseInitialized) return;
    try {
      // Remove primeiro a linha em device_tokens (a Edge Function deixa de
      // enviar para este dispositivo); precisa do token antes de o apagar.
      final token = await getToken();
      if (token != null) {
        await _client.from('device_tokens').delete().eq('token', token);
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
if (kDebugMode) {       debugPrint('[Luar] Failed to delete token: $e'); }
    }
  }
}
