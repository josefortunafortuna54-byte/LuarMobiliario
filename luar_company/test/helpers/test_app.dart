import 'package:flutter/material.dart';
import 'package:luar_company/l10n/app_localizations.dart';

/// Wraps a widget in a [MaterialApp] configured with the app's localization
/// delegates and Portuguese as the default test locale, matching production
/// defaults.
Widget testApp({required Widget home, Locale locale = const Locale('pt')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
