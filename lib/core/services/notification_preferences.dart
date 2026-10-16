import 'package:shared_preferences/shared_preferences.dart';

/// Categorias de notificação que o utilizador pode ligar/desligar.
enum NotificationCategory { messages, bookings, listings, promotions, system }

/// Preferências de notificação guardadas localmente (por dispositivo).
///
/// Mantém uma cache em memória para permitir leituras síncronas no caminho
/// quente (o handler de mensagens em primeiro plano é síncrono). O valor por
/// omissão é `true` — categorias nunca configuradas continuam ativas.
class NotificationPreferences {
  NotificationPreferences._();

  static final NotificationPreferences instance = NotificationPreferences._();

  static const String _prefix = 'notif_pref_';

  final Map<NotificationCategory, bool> _cache = {};

  bool isEnabled(NotificationCategory category) => _cache[category] ?? true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final category in NotificationCategory.values) {
      _cache[category] = prefs.getBool('$_prefix${category.name}') ?? true;
    }
  }

  Future<void> setEnabled(NotificationCategory category, bool enabled) async {
    _cache[category] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix${category.name}', enabled);
  }

  /// Mapeia o valor do campo `category` de uma notificação para uma categoria
  /// conhecida. Valores desconhecidos/ausentes caem em [system].
  static NotificationCategory fromPayload(String? value) {
    return NotificationCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => NotificationCategory.system,
    );
  }
}
