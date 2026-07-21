abstract final class AppConstants {
  static const String appName = 'Luar Mobiliario';
  static const String appTagline = 'Seu novo lar começa aqui';
  static const String appVersion = '1.0.0';

  // ── Supabase (via .env) ───────────────────────────────────────────
  // Valores carregados de EnvConfig - nao hardcode aqui

  // ── Contact ────────────────────────────────────────────────────────

  static const String whatsappNumber = '244923456789';
  static const String whatsappMessage =
      'Olá! Vim pelo app e gostaria de mais informações.';
  static const String supportEmail = 'geral@luarcompany.ao';
  static const String supportPhone = '+244 923 456 789';

  // ── Social Media ───────────────────────────────────────────────────

  static const String instagramUrl = 'https://instagram.com/luarcompany';
  static const String facebookUrl = 'https://facebook.com/luarcompany';
  static const String linkedinUrl = 'https://linkedin.com/company/luarcompany';
  static const String youtubeUrl = 'https://youtube.com/@luarcompany';

  // ── Storage Buckets (Supabase) ─────────────────────────────────────

  static const String propertyImagesBucket = 'property-images';
  static const String avatarBucket = 'avatars';
  static const String documentBucket = 'documents';
  static const String avatarsBucket = 'avatars';
  static const String productsBucket = 'products';

  // ── Database Tables ─────────────────────────────────────────────────
  static const String usersTable = 'users';
  static const String partnersTable = 'partners';
  static const String notificationsTable = 'notifications';
  static const String propertiesTable = 'properties';
  static const String landsTable = 'lands';

  // ── Firebase (via .env) ───────────────────────────────────────────
  // Valores carregados de EnvConfig - nao hardcode aqui

  // ── Pagination ─────────────────────────────────────────────────────

  static const int defaultPageSize = 20;
  static const int maxImageUploads = 10;

  // ── Animation Durations ────────────────────────────────────────────

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ── Spacing ────────────────────────────────────────────────────────

  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingXxxl = 64.0;

  // ── Border Radius ──────────────────────────────────────────────────

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Shadows ────────────────────────────────────────────────────────

  static const double shadowSm = 2.0;
  static const double shadowMd = 4.0;
  static const double shadowLg = 8.0;
  static const double shadowXl = 16.0;

  // ── Property Transaction Types ─────────────────────────────────────

  static const List<String> transactionTypes = ['Venda', 'Arrendamento'];

  static const List<String> propertyTypes = [
    'Casa',
    'Apartamento',
    'Terreno',
    'Fazenda',
    'Armazém',
    'Escritório',
    'Loja',
    'Condomínio',
  ];

  static const List<String> bedroomOptions = ['1', '2', '3', '4', '5+'];

  static const List<String> parkingOptions = ['1', '2', '3', '4+'];

  // ── Regex Patterns ─────────────────────────────────────────────────

  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  static const String phoneRegex = r'^(\+244\s?)?9[1-9]\d{7}$';

  // ── Shared Preferences Keys ────────────────────────────────────────

  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserLogged = 'user_logged';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
}
