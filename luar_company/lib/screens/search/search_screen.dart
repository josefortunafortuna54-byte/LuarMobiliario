import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/comparison_provider.dart';
import '../../core/providers/search_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/property_card.dart';
import '../../widgets/land_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/search_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = context.read<SearchProvider>();
      provider.setFilter(query: value);
      provider.search();
    });
  }

  /// Abre o ecrã "Filtros" (design de referência) como rota própria.
  void _openFilters() {
    Navigator.of(context).pushNamed(AppRoutes.filters);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          l10n.pesquisar,
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
        ),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.mapa,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.map),
            icon: const Icon(Icons.map_outlined, color: AppColors.gold),
          ),
          Consumer<SearchProvider>(
            builder: (_, provider, _) {
              if (provider.activeFilterCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  provider.clearFilters();
                  _searchController.clear();
                },
                child: Text(
                  l10n.limparTudo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SearchWidget(
              controller: _searchController,
              hintText: l10n.pesquisarTudo,
              autofocus: false,
              onChanged: _onSearchChanged,
              onSearch: (value) {
                _debounce?.cancel();
                final provider = context.read<SearchProvider>();
                provider.setFilter(query: value);
                provider.search();
              },
              onFilterTap: _openFilters,
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (_, provider, _) {
                return Column(
                  children: [
                    if (provider.activeFilterCount > 0)
                      _buildActiveFilters(provider),
                    if (!provider.isLoading && provider.results.isNotEmpty)
                      _buildSortBar(provider),
                    Expanded(child: _buildResults(provider)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(SearchProvider provider) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final chips = <_FilterChipData>[];

    if (provider.query.isNotEmpty) {
      chips.add(
        _FilterChipData('"${provider.query}"', () {
          provider.removeFilter('query');
          _searchController.clear();
          provider.search();
        }),
      );
    }
    if (provider.transactionType != null) {
      chips.add(
        _FilterChipData(
          provider.transactionType == 'sale'
              ? l10n.venda
              : provider.transactionType == 'rent'
                  ? l10n.arrendamento
                  : l10n.renovar,
          () => _removeFilter(provider, 'transactionType'),
        ),
      );
    }
    if (provider.propertyType != null) {
      chips.add(
        _FilterChipData(
          provider.propertyType!,
          () => _removeFilter(provider, 'propertyType'),
        ),
      );
    }
    if (provider.landType != null) {
      chips.add(
        _FilterChipData(
          provider.landType!,
          () => _removeFilter(provider, 'landType'),
        ),
      );
    }
    if (provider.province != null) {
      chips.add(
        _FilterChipData(
          provider.province!,
          () => _removeFilter(provider, 'province'),
        ),
      );
    }
    if (provider.city != null) {
      chips.add(
        _FilterChipData(
          provider.city!,
          () => _removeFilter(provider, 'city'),
        ),
      );
    }
    if (provider.municipality != null) {
      chips.add(
        _FilterChipData(
          provider.municipality!,
          () => _removeFilter(provider, 'municipality'),
        ),
      );
    }
    if (provider.purpose != null) {
      chips.add(
        _FilterChipData(
          provider.purpose == 'residential'
              ? l10n.residencial
              : l10n.comercial,
          () => _removeFilter(provider, 'purpose'),
        ),
      );
    }
    if (provider.minPrice != null) {
      chips.add(
        _FilterChipData(
          l10n.minPreco(provider.minPrice!.toStringAsFixed(0)),
          () => _removeFilter(provider, 'minPrice'),
        ),
      );
    }
    if (provider.maxPrice != null) {
      chips.add(
        _FilterChipData(
          l10n.maxPreco(provider.maxPrice!.toStringAsFixed(0)),
          () => _removeFilter(provider, 'maxPrice'),
        ),
      );
    }
    if (provider.bedrooms != null) {
      chips.add(
        _FilterChipData(
          '${provider.bedrooms} ${l10n.quartos}',
          () => _removeFilter(provider, 'bedrooms'),
        ),
      );
    }
    if (provider.bathrooms != null) {
      chips.add(
        _FilterChipData(
          '${provider.bathrooms} ${l10n.wc}',
          () => _removeFilter(provider, 'bathrooms'),
        ),
      );
    }
    if (provider.garage != null) {
      chips.add(
        _FilterChipData(
          '${provider.garage} ${l10n.garagem}',
          () => _removeFilter(provider, 'garage'),
        ),
      );
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final chip = chips[index];
          return Center(
            child: Chip(
              label: Text(
                chip.label,
                style: AppTextStyles.bodyTiny.copyWith(
                  color: palette.textTitle,
                  fontWeight: FontWeight.w500,
                ),
              ),
              deleteIcon: Icon(Icons.close, size: 16, color: palette.textTitle),
              onDeleted: chip.onRemove,
              backgroundColor: AppColors.goldLight.withValues(alpha: 0.25),
              side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  void _removeFilter(SearchProvider provider, String filter) {
    provider.removeFilter(filter);
    provider.search();
  }

  void _toggleComparison(
    BuildContext context,
    ComparisonProvider comparison,
    PropertyModel property,
  ) {
    final l10n = AppLocalizations.of(context);
    final wasSelected = comparison.isSelected(property.id);

    if (!wasSelected && comparison.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.limiteComparacao),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    comparison.toggle(property);

    if (!wasSelected && comparison.canCompare) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.imovelAdicionadoComparacao(comparison.count),
          ),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: l10n.comparar,
            textColor: AppColors.white,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.comparison);
            },
          ),
        ),
      );
    }
  }

  Widget _buildResults(SearchProvider provider) {
    if (provider.isLoading) {
      return _buildShimmerGrid();
    }

    if (provider.error != null && provider.results.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.results.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResultsGrid(provider);
  }

  Widget _buildSortBar(SearchProvider provider) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton<String>(
            initialValue: provider.sortOption,
            onSelected: provider.setSort,
            itemBuilder: (_) => [
              _sortMenuItem('recent', l10n.maisRecentes, Icons.schedule),
              _sortMenuItem(
                'priceAsc',
                l10n.menorPreco,
                Icons.arrow_upward_rounded,
              ),
              _sortMenuItem(
                'priceDesc',
                l10n.maiorPreco,
                Icons.arrow_downward_rounded,
              ),
              _sortMenuItem('areaDesc', l10n.maiorArea, Icons.crop_square),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded, size: 18, color: palette.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.ordenar,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _sortMenuItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildErrorState(SearchProvider provider) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.algoCorreuMal,
              style: AppTextStyles.h5.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.erroAoCarregar,
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.search,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tentarNovamente),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const PropertyCardShimmer(),
    );
  }

  Widget _buildEmptyState() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.nenhumResultado,
              style: AppTextStyles.h5.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.ajustarFiltros,
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGrid(SearchProvider provider) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final properties = provider.propertyResults;
    final lands = provider.landResults;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400 &&
            provider.hasMore &&
            !provider.isLoadingMore) {
          provider.loadMore();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (properties.isNotEmpty) ...[
            Text(
              l10n.contarImoveis(properties.length),
              style: AppTextStyles.h6.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 12),
            Consumer<ComparisonProvider>(
              builder: (context, comparison, _) {
                return Column(
                  children: properties.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PropertyCard(
                        imageUrl: p.images.isNotEmpty ? p.images.first : '',
                        title: p.title,
                        location: '${p.neighborhood}, ${p.city}',
                        price: p.price,
                        listingType: p.transactionType.listingType,
                        bedrooms: p.bedrooms,
                        bathrooms: p.bathrooms,
                        area: p.area,
                        isCompared: comparison.isSelected(p.id),
                        agentVerified: p.agentVerified,
                        onCompareTap: () => _toggleComparison(
                          context,
                          comparison,
                          p,
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.propertyDetail,
                          arguments: p.id,
                        ),
                      ),
                    ),
                  ).toList(),
                );
              },
            ),
          ],
          if (lands.isNotEmpty) ...[
            Text(
              l10n.terrenosCount(lands.length),
              style: AppTextStyles.h6.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 12),
            ...lands.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LandCard(
                  imageUrl: l.images.isNotEmpty ? l.images.first : '',
                  title: l.title,
                  location: '${l.neighborhood}, ${l.city}',
                  area: l.area,
                  price: l.price,
                  badgeLabel: l.type.name.toUpperCase(),
                  features: l.features,
                  agentVerified: l.agentVerified,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.landDetail,
                    arguments: l.id,
                  ),
                ),
              ),
            ),
          ],
          if (properties.isEmpty && lands.isEmpty) _buildEmptyState(),
          if (provider.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _FilterChipData {
  final String label;
  final VoidCallback onRemove;
  const _FilterChipData(this.label, this.onRemove);
}
