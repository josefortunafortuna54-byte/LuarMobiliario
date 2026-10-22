import 'package:flutter/material.dart';
import 'package:luar_company/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/navigation.dart';
import 'core/utils/routes.dart';

class LuarCompanyApp extends StatelessWidget {
  const LuarCompanyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: const [Locale('pt'), Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      navigatorKey: AppNavigator.navigatorKey,
      navigatorObservers: [AppNavigator.routeObserver],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: onGenerateRoute,
      builder: (context, child) {
        // Proteção global: escala de texto limitada (1.0–1.3) para evitar
        // overflow de texto com fontes grandes do sistema, mantendo
        // acessibilidade razoável.
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.3,
            ),
          ),
          child: _OfflineBanner(child: child),
        );
      },
    );
  }
}

/// Sobreposição global com aviso de sem ligação (Fase 8 — conectividade).
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();

    return Stack(
      children: [
        ?child,
        if (!connectivity.isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: AppColors.error,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    AppLocalizations.of(context).semLigacao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
