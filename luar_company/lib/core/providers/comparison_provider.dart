import 'package:flutter/foundation.dart';

import '../models/comparison_entry.dart';
import '../models/land_model.dart';
import '../models/property_model.dart';

/// Estado da comparação (Luar Compare).
///
/// Mantém as entradas selecionadas (imóveis e/ou terrenos) para comparação
/// (máximo de 3), permitindo adicionar, remover e limpar. Os dados são
/// mantidos em memória durante a sessão — a persistência opcional pode ser
/// adicionada no futuro.
class ComparisonProvider extends ChangeNotifier {
  ComparisonProvider();

  /// Número máximo de entradas que podem ser comparadas simultaneamente.
  static const int maxItems = 3;

  final List<ComparisonEntry> _items = [];

  List<ComparisonEntry> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isFull => _items.length >= maxItems;
  bool get canCompare => _items.length >= 2;

  /// Verifica se uma entrada já está selecionada para comparação.
  bool isSelected(String id) {
    return _items.any((e) => e.id == id);
  }

  bool _add(ComparisonEntry entry) {
    if (isSelected(entry.id)) return false;
    if (isFull) return false;

    _items.add(entry);
    notifyListeners();
    return true;
  }

  /// Adiciona um imóvel à lista de comparação.
  ///
  /// Retorna `true` se foi adicionado com sucesso, `false` se já estava na
  /// lista ou se o limite foi atingido.
  bool add(PropertyModel property) => _add(ComparisonEntry.fromProperty(property));

  /// Adiciona um terreno à lista de comparação.
  bool addLand(LandModel land) => _add(ComparisonEntry.fromLand(land));

  /// Remove uma entrada da lista de comparação.
  ///
  /// Retorna `true` se a entrada foi removida.
  bool remove(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    _items.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Alterna a seleção de um imóvel.
  ///
  /// Retorna o novo estado (`true` se ficou selecionado).
  bool toggle(PropertyModel property) {
    if (isSelected(property.id)) {
      remove(property.id);
      return false;
    }
    return add(property);
  }

  /// Alterna a seleção de um terreno.
  bool toggleLand(LandModel land) {
    if (isSelected(land.id)) {
      remove(land.id);
      return false;
    }
    return addLand(land);
  }

  /// Remove todas as entradas da comparação.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Calcula o preço por metro quadrado de uma entrada.
  ///
  /// Retorna `null` quando a área é inválida (<= 0) para evitar
  /// cálculos enganadores.
  static double? pricePerSquareMeter(ComparisonEntry entry) {
    if (entry.area <= 0) return null;
    return entry.price / entry.area;
  }

  /// Encontra a entrada mais barata da lista (por preço total).
  ComparisonEntry? get cheapest {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.price <= b.price ? a : b);
  }

  /// Encontra a entrada com maior área da lista.
  ComparisonEntry? get largest {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.area >= b.area ? a : b);
  }

  /// Encontra a entrada com menor preço por metro quadrado.
  /// Ignora entradas com área inválida.
  ComparisonEntry? get bestValue {
    ComparisonEntry? best;
    double? bestPrice;

    for (final e in _items) {
      final ppm = pricePerSquareMeter(e);
      if (ppm == null) continue;
      if (bestPrice == null || ppm < bestPrice) {
        bestPrice = ppm;
        best = e;
      }
    }

    return best;
  }
}
