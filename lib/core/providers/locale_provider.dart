import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._prefs);

  final SharedPreferences _prefs;

  static const Locale _portuguese = Locale('pt');
  static const Locale _english = Locale('en');

  Locale _locale = _portuguese;

  Locale get locale => _locale;

  static Future<LocaleProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = LocaleProvider(prefs);
    await provider._loadLocale();
    return provider;
  }

  Future<void> _loadLocale() async {
    final raw = _prefs.getString(AppConstants.keyLocale);
    switch (raw) {
      case 'en':
        _locale = _english;
      case 'pt':
      default:
        _locale = _portuguese;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale.languageCode == 'en' ? _english : _portuguese;
    await _prefs.setString(AppConstants.keyLocale, _locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    await setLocale(_locale.languageCode == 'pt' ? _english : _portuguese);
  }
}