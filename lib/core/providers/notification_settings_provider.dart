import 'package:flutter/foundation.dart';

import '../services/notification_preferences.dart';

/// Expõe as preferências de notificação à UI de forma reativa.
class NotificationSettingsProvider extends ChangeNotifier {
  final NotificationPreferences _preferences = NotificationPreferences.instance;

  bool isEnabled(NotificationCategory category) =>
      _preferences.isEnabled(category);

  Future<void> load() async {
    await _preferences.load();
    notifyListeners();
  }

  Future<void> setEnabled(NotificationCategory category, bool enabled) async {
    await _preferences.setEnabled(category, enabled);
    notifyListeners();
  }
}
