import 'package:flutter/material.dart';
import 'package:luar_company/l10n/app_localizations.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/empty_state.dart';

/// Aplicação exibida quando o build não tem as variáveis de ambiente
/// necessárias (SUPABASE_URL / SUPABASE_ANON_KEY).
///
/// Evita arrancar a app com um cliente Supabase não inicializado, o que
/// provocaria falhas em todas as chamadas ao backend.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: const Locale('pt'),
      supportedLocales: const [Locale('pt'), Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const ConfigErrorScreen(),
    );
  }
}

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: l10n.configEmFaltaTitulo,
          subtitle: l10n.configEmFaltaDesc,
        ),
      ),
    );
  }
}
