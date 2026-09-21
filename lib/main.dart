import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/message_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/providers/land_provider.dart';
import 'core/providers/property_provider.dart';
import 'core/providers/partner_provider.dart';
import 'core/providers/search_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('[Luar] Supabase initialization failed: $e');
  }

  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => LandProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
      ],
      child: const LuarCompanyApp(),
    ),
  );
}
