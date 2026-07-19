import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'SupabaseService has not been initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  static Future<void> initialize() async {
    if (!EnvConfig.isConfigured) {
      throw StateError(
        'Supabase configuration missing. Check your .env file.',
      );
    }

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  static void dispose() {
    _client?.dispose();
    _client = null;
  }
}
