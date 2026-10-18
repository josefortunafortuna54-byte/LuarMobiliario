import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'booking_provider.dart';
import 'comparison_provider.dart';
import 'locale_provider.dart';
import 'message_provider.dart';
import 'notification_settings_provider.dart';
import 'admin_provider.dart';
import 'discover_provider.dart';
import 'favorite_provider.dart';
import 'land_provider.dart';
import 'property_provider.dart';
import 'report_provider.dart';
import 'partner_provider.dart';
import 'playback_provider.dart';
import 'review_provider.dart';
import 'saved_search_provider.dart';
import 'search_provider.dart';
import 'theme_provider.dart';
import '../services/connectivity_service.dart';

/// Monta a árvore de providers da app.
///
/// Centraliza aqui o que era uma lista inline no `main()`: mantém o bootstrap
/// legível e permite aos testes reutilizarem/montarem subconjuntos dos
/// providers sem replicarem a ordem de criação.
Widget withAppProviders({
  required Widget child,
  required ThemeProvider themeProvider,
  required LocaleProvider localeProvider,
  required PlaybackProvider playbackProvider,
  required ConnectivityService connectivityService,
}) {
  return MultiProvider(
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
      ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ChangeNotifierProvider(
        create: (_) => NotificationSettingsProvider()..load(),
      ),
      ChangeNotifierProvider.value(value: themeProvider),
      ChangeNotifierProvider.value(value: localeProvider),
      ChangeNotifierProvider.value(value: playbackProvider),
      ChangeNotifierProvider.value(value: connectivityService),
    ],
    child: child,
  );
}
