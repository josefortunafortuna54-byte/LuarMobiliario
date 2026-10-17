import 'package:shared_preferences/shared_preferences.dart';

/// Entrada do histórico: um imóvel (`p:<id>`) ou um terreno (`l:<id>`).
typedef HistoryEntry = String;

/// Histórico local de imóveis vistos — alimenta o separador "Histórico"
/// do ecrã Favoritos (design de referência, painel 5).
class ViewHistory {
  ViewHistory._();

  static const String _key = 'view_history_ids';
  static const int _maxEntries = 60;
  static const String propertyPrefix = 'p:';
  static const String landPrefix = 'l:';

  /// Regista a visita a um imóvel (o mais recente fica em primeiro).
  static Future<void> recordProperty(String id) => _record('$propertyPrefix$id');

  /// Regista a visita a um terreno.
  static Future<void> recordLand(String id) => _record('$landPrefix$id');

  static Future<void> _record(String entry) async {
    if (entry.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_key) ?? <String>[];
      ids.remove(entry);
      ids.insert(0, entry);
      if (ids.length > _maxEntries) {
        ids.removeRange(_maxEntries, ids.length);
      }
      await prefs.setStringList(_key, ids);
    } catch (_) {
      // Histórico é opcional: falha silenciosa.
    }
  }

  /// Devolve as entradas por ordem decrescente de visita.
  static Future<List<HistoryEntry>> entries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? <HistoryEntry>[];
    } catch (_) {
      return <HistoryEntry>[];
    }
  }

  static String? propertyIdOf(HistoryEntry entry) =>
      entry.startsWith(propertyPrefix) ? entry.substring(2) : null;

  static String? landIdOf(HistoryEntry entry) =>
      entry.startsWith(landPrefix) ? entry.substring(2) : null;
}
