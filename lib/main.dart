import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/comparison_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/message_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/providers/discover_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/providers/land_provider.dart';
import 'core/providers/property_provider.dart';
import 'core/providers/report_provider.dart';
import 'core/providers/partner_provider.dart';
import 'core/providers/playback_provider.dart';
import 'core/providers/saved_search_provider.dart';
import 'core/providers/search_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('[Luar] dotenv load failed: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Limites do cache de imagens em memória (Fase 8 — desempenho).
  PaintingBinding.instance.imageCache
    ..maximumSizeBytes = 64 * 1024 * 1024
    ..maximumSize = 120;

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('[Luar] Supabase initialization failed: $e');
  }

  await NotificationService().initialize();

  final themeProvider = await ThemeProvider.load();
  final localeProvider = await LocaleProvider.load();
  final playbackProvider = await PlaybackProvider.load();
  final connectivityService = ConnectivityService();
  await connectivityService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
        ChangeNotifierProvider(create: (_) => LandProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SavedSearchProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ComparisonProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: playbackProvider),
        ChangeNotifierProvider.value(value: connectivityService),
      ],
      child: const LuarCompanyApp(),
    ),
  );
}
