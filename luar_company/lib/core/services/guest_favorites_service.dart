import 'package:shared_preferences/shared_preferences.dart';

/// Favoritos locais de um utilizador sem conta (convidado).
///
/// Guarda apenas os ids dos imóveis/terrenos marcados como favoritos no
/// dispositivo. Serve de fallback quando não existe sessão autenticada, para
/// que o separador Favoritos funcione em modo convidado.
class GuestFavorites {
  GuestFavorites._();

  static const String _propertiesKey = 'guest_favorite_property_ids';
  static const String _landsKey = 'guest_favorite_land_ids';

  static Future<List<String>> propertyIds() => _read(_propertiesKey);

  static Future<List<String>> landIds() => _read(_landsKey);

  static Future<bool> toggleProperty(String id) => _toggle(_propertiesKey, id);

  static Future<bool> toggleLand(String id) => _toggle(_landsKey, id);

  static Future<bool> isPropertyFavorite(String id) async =>
      (await _read(_propertiesKey)).contains(id);

  static Future<bool> isLandFavorite(String id) async =>
      (await _read(_landsKey)).contains(id);

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_propertiesKey);
      await prefs.remove(_landsKey);
    } catch (_) {
      // Favoritos são opcionais: falha silenciosa.
    }
  }

  static Future<List<String>> _read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key) ?? <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  static Future<bool> _toggle(String key, String id) async {
    if (id.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(key) ?? <String>[];
      final added = !ids.contains(id);
      if (added) {
        ids.insert(0, id);
      } else {
        ids.remove(id);
      }
      await prefs.setStringList(key, ids);
      return added;
    } catch (_) {
      return false;
    }
  }
}
