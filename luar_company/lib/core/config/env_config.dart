/// Configuração de ambiente injetada em tempo de build via `--dart-define`
/// (ou `--dart-define-from-file`). O ficheiro `.env` NÃO é empacotado como
/// asset — os valores são compilados diretamente no binário apenas nos
/// builds de release a partir do ambiente/local.
abstract final class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String fcmSenderId = String.fromEnvironment('FCM_SENDER_ID');
  static const String fcmProjectId = String.fromEnvironment('FCM_PROJECT_ID');
  static const String fcmApiKey = String.fromEnvironment('FCM_API_KEY');
  static const String fcmAppId = String.fromEnvironment('FCM_APP_ID');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
