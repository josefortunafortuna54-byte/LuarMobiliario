import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum ThemePreference { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs);

  final SharedPreferences _prefs;

  ThemePreference _preference = ThemePreference.dark;

  ThemePreference get preference => _preference;

  ThemeMode get themeMode => switch (_preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  bool get isDarkMode {
    final brightness = WidgetsBinding
        .instance.platformDispatcher.platformBrightness;
    return switch (_preference) {
      ThemePreference.light => false,
      ThemePreference.dark => true,
      ThemePreference.system => brightness == Brightness.dark,
    };
  }

  static Future<ThemeProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = ThemeProvider(prefs);
    await provider._loadPreference();
    return provider;
  }

  Future<void> _loadPreference() async {
    final raw = _prefs.getString(AppConstants.keyThemeMode);
    switch (raw) {
      case 'light':
        _preference = ThemePreference.light;
      case 'dark':
        _preference = ThemePreference.dark;
      case 'system':
        _preference = ThemePreference.system;
      default:
        _preference = ThemePreference.dark;
    }
  }

  Future<void> setPreference(ThemePreference value) async {
    if (_preference == value) return;
    _preference = value;
    await _prefs.setString(AppConstants.keyThemeMode, value.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setPreference(isDarkMode ? ThemePreference.light : ThemePreference.dark);
  }
}