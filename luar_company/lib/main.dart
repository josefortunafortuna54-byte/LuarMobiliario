import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/playback_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('[Luar] Notification initialization failed: $e');
  }

  final themeProvider = await ThemeProvider.load();
  final localeProvider = await LocaleProvider.load();
  final playbackProvider = await PlaybackProvider.load();
  final connectivityService = ConnectivityService();
  await connectivityService.init();

  runApp(
    withAppProviders(
      themeProvider: themeProvider,
      localeProvider: localeProvider,
      playbackProvider: playbackProvider,
      connectivityService: connectivityService,
      child: const LuarCompanyApp(),
    ),
  );
}
