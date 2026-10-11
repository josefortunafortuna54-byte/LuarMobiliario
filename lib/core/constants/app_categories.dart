import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Fonte única de verdade para as categorias (abas, chips de pesquisa e
/// grelha de categorias da home).
///
/// Sempre que um novo tipo for acrescentado a [PropertyType] ou [LandType]
/// deve ser adicionado aqui. O teste `test/unit/categories_test.dart`
/// garante que existe correspondência 1:1 entre os enums e estas listas.
class AppCategory {
  final String key;
  final IconData icon;
  final bool isLand;

  const AppCategory({
    required this.key,
    required this.icon,
    this.isLand = false,
  });
}

/// Todas as categorias de imóveis (sem a pseudo-categoria "Todos").
const List<AppCategory> propertyCategories = [
  AppCategory(key: 'house', icon: Icons.home_outlined),
  AppCategory(key: 'apartment', icon: Icons.apartment_rounded),
  AppCategory(key: 'office', icon: Icons.business_center_outlined),
  AppCategory(key: 'warehouse', icon: Icons.warehouse_outlined),
  AppCategory(key: 'shop', icon: Icons.storefront_outlined),
  AppCategory(key: 'condo', icon: Icons.apartment_outlined),
];

/// Todas as categorias de terrenos (sem a pseudo-categoria "Todos").
const List<AppCategory> landCategories = [
  AppCategory(key: 'urban', icon: Icons.location_city_rounded, isLand: true),
  AppCategory(
    key: 'agricultural',
    icon: Icons.agriculture_rounded,
    isLand: true,
  ),
  AppCategory(key: 'industrial', icon: Icons.factory_outlined, isLand: true),
  AppCategory(
    key: 'commercial',
    icon: Icons.store_mall_directory_outlined,
    isLand: true,
  ),
  AppCategory(key: 'lot', icon: Icons.grid_view_rounded, isLand: true),
  AppCategory(key: 'farm', icon: Icons.landscape_rounded, isLand: true),
];

/// Chaves de filtro de imóveis, incluindo a pseudo-categoria "Todos" ('').
List<String> get propertyFilterKeys =>
    ['', ...propertyCategories.map((c) => c.key)];

/// Chaves de filtro de terrenos, incluindo a pseudo-categoria "Todos" ('').
List<String> get landFilterKeys => ['', ...landCategories.map((c) => c.key)];

/// Etiquetas de filtro de imóveis (índice 0 = "Todos").
List<String> propertyFilterLabels(AppLocalizations l10n) =>
    [l10n.todos, ...propertyCategories.map((c) => propertyCategoryLabel(c.key, l10n))];

/// Etiquetas de filtro de terrenos (índice 0 = "Todos").
List<String> landFilterLabels(AppLocalizations l10n) =>
    [l10n.todos, ...landCategories.map((c) => landCategoryLabel(c.key, l10n))];

String propertyCategoryLabel(String key, AppLocalizations l10n) =>
    switch (key) {
      'house' => l10n.casas,
      'apartment' => l10n.apartamentos,
      'office' => l10n.escritorios,
      'warehouse' => l10n.armazens,
      'shop' => l10n.lojas,
      'condo' => l10n.condominios,
      _ => l10n.todos,
    };

String landCategoryLabel(String key, AppLocalizations l10n) => switch (key) {
  'urban' => l10n.urbanos,
  'agricultural' => l10n.agricolas,
  'industrial' => l10n.industriais,
  'commercial' => l10n.comerciais,
  'lot' => l10n.lotes,
  'farm' => l10n.fazendas,
  _ => l10n.todos,
};
