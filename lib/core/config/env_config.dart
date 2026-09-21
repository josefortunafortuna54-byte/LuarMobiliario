import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get fcmSenderId => dotenv.env['FCM_SENDER_ID'] ?? '';
  static String get fcmProjectId => dotenv.env['FCM_PROJECT_ID'] ?? '';
  static String get fcmApiKey => dotenv.env['FCM_API_KEY'] ?? '';
  static String get fcmAppId => dotenv.env['FCM_APP_ID'] ?? '';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
