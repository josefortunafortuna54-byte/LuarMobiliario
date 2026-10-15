import 'package:flutter/foundation.dart';

import '../models/property_model.dart';

/// Estado da comparação de imóveis (Luar Compare).
///
/// Mantém a lista de imóveis selecionados para comparação (máximo de 3),
/// permitindo adicionar, remover e limpar. Os dados são mantidos em memória
/// durante a sessão — a persistência opcional pode ser adicionada no futuro.
class ComparisonProvider extends ChangeNotifier {
  ComparisonProvider();

  /// Número máximo de imóveis que podem ser comparados simultaneamente.
  static const int maxItems = 3;

  final List<PropertyModel> _items = [];

  List<PropertyModel> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isFull => _items.length >= maxItems;
  bool get canCompare => _items.length >= 2;

  /// Verifica se um imóvel já está selecionado para comparação.
  bool isSelected(String propertyId) {
    return _items.any((p) => p.id == propertyId);
  }

  /// Adiciona um imóvel à lista de comparação.
  ///
  /// Retorna `true` se o imóvel foi adicionado com sucesso,
  /// `false` se já estava na lista ou se o limite foi atingido.
  bool add(PropertyModel property) {
    if (isSelected(property.id)) return false;
    if (isFull) return false;

    _items.add(property);
    notifyListeners();
    return true;
  }

  /// Remove um imóvel da lista de comparação.
  ///
  /// Retorna `true` se o imóvel foi removido.
  bool remove(String propertyId) {
    final index = _items.indexWhere((p) => p.id == propertyId);
    if (index == -1) return false;

    _items.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Alterna a seleção de um imóvel.
  ///
  /// Retorna o novo estado (`true` se ficou selecionado).
  /// Se o limite foi atingido e o imóvel não está selecionado, retorna `false`.
  bool toggle(PropertyModel property) {
    if (isSelected(property.id)) {
      remove(property.id);
      return false;
    }
    return add(property);
  }

  /// Remove todos os imóveis da comparação.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Calcula o preço por metro quadrado de um imóvel.
  ///
  /// Retorna `null` quando a área é inválida (<= 0) para evitar
  /// cálculos enganadores.
  static double? pricePerSquareMeter(PropertyModel property) {
    if (property.area <= 0) return null;
    return property.price / property.area;
  }

  /// Encontra o imóvel mais barato da lista (por preço total).
  PropertyModel? get cheapest {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.price <= b.price ? a : b);
  }

  /// Encontra o imóvel com maior área da lista.
  PropertyModel? get largest {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.area >= b.area ? a : b);
  }

  /// Encontra o imóvel com menor preço por metro quadrado.
  /// Ignora imóveis com área inválida.
  PropertyModel? get bestValue {
    PropertyModel? best;
    double? bestPrice;

    for (final p in _items) {
      final ppm = pricePerSquareMeter(p);
      if (ppm == null) continue;
      if (bestPrice == null || ppm < bestPrice) {
        bestPrice = ppm;
        best = p;
      }
    }

    return best;
  }
}
