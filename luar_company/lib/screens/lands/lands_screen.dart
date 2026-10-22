import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/land_provider.dart';
import '../../core/providers/comparison_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/favorite_actions.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/land_card.dart';
import '../../widgets/loading_widget.dart';

class LandsScreen extends StatefulWidget {
  const LandsScreen({super.key});

  @override
  State<LandsScreen> createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilterIndex = 0;
  String _sortOption = 'recent';
  bool _showSortOptions = false;
  bool _routeArgumentApplied = false;
  String? _favoritesUserId;

  List<String> _filterLabels(AppLocalizations l10n) => landFilterLabels(l10n);

  List<String> get _filterKeys => landFilterKeys;

  static const List<String> _sortKeys = [
    'recent',
    'priceAsc',
    'priceDesc',
    'areaDesc',
  ];

  String _sortLabel(AppLocalizations l10n, String key) => switch (key) {
    'priceAsc' => l10n.menorPreco,
    'priceDesc' => l10n.maiorPreco,
    'areaDesc' => l10n.maiorArea,
    _ => l10n.maisRecentes,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routeArgumentApplied) {
      _routeArgumentApplied = true;
      _applyRouteArgument();
      _loadLands();
    }
    _syncFavorites();
  }

  /// Garante que os favoritos carregados correspondem ao utilizador atual.
  ///
  /// O `watch` regista a dependência: quando a sessão é carregada (ou muda de
  /// utilizador) este método volta a correr e os favoritos são recarregados.
  void _syncFavorites() {
    final userId =
        context.watch<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
    if (userId == _favoritesUserId) return;
    _favoritesUserId = userId;

    // Adiado para fora do build: `ensureLoaded` notifica os listeners, o que
    // dentro do build causaria "markNeedsBuild called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoriteProvider>().ensureLoaded(userId);
    });
  }

  void _applyRouteArgument() {
    final filterType = ModalRoute.of(context)?.settings.arguments;
    if (filterType is String) {
      final index = _filterKeys.indexOf(filterType);
      if (index != -1) {
        _selectedFilterIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLands() {
    final provider = context.read<LandProvider>();
    final filters = <String, dynamic>{};
    if (_filterKeys[_selectedFilterIndex].isNotEmpty) {
      filters['type'] = _filterKeys[_selectedFilterIndex];
    }
    provider.loadLands(filters: filters.isNotEmpty ? filters : null);
  }

  void _loadMore() {
    final provider = context.read<LandProvider>();
    if (provider.hasMore && !provider.isLoading) {
      final filters = <String, dynamic>{};
      if (_filterKeys[_selectedFilterIndex].isNotEmpty) {
        filters['type'] = _filterKeys[_selectedFilterIndex];
      }
      provider.loadMore(filters: filters.isNotEmpty ? filters : null);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
    _loadLands();
  }

  void _onSortSelected(String sort) {
    setState(() {
      _sortOption = sort;
      _showSortOptions = false;
    });
  }

  List<LandModel> _sortLands(List<LandModel> list) {
    final sorted = List<LandModel>.from(list);
    switch (_sortOption) {
      case 'priceAsc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'areaDesc':
        sorted.sort((a, b) => b.area.compareTo(a.area));
        break;
      case 'recent':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }

  String _landTypeLabel(AppLocalizations l10n, LandType type) {
    return switch (type) {
      LandType.urban => l10n.urbano,
      LandType.agricultural => l10n.agricola,
      LandType.industrial => l10n.industrial,
      LandType.commercial => l10n.comercial,
      LandType.lot => l10n.lote,
      LandType.farm => l10n.fazenda,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Text(
          l10n.terrenos,
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
        ),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.gridMaxWidth(context),
          ),
          child: Column(
            children: [
              _buildFilterBar(),
              _buildSortBar(),
              if (_showSortOptions) _buildSortDropdown(),
              Expanded(
                child: Consumer<LandProvider>(
                  builder: (_, provider, _) {
                    if (provider.isLoading && provider.lands.isEmpty) {
                      return _buildShimmerGrid();
                    }

                    if (provider.error != null && provider.lands.isEmpty) {
                      return _buildErrorState(provider);
                    }

                    if (provider.lands.isEmpty) {
                      return _buildEmptyState();
                    }

                    final sorted = _sortLands(provider.lands);
                    return _buildLandGrid(sorted, provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final labels = _filterLabels(l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.borderStrong)),
      ),
      // Altura intrínseca (sem fixa) — evita corte de chips com fontes grandes.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < labels.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _onFilterSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedFilterIndex == index
                        ? AppColors.navy
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFilterIndex == index
                          ? AppColors.navy
                          : palette.textMuted,
                    ),
                  ),
                  child: Text(
                    labels[index],
                    maxLines: 1,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _selectedFilterIndex == index
                          ? AppColors.white
                          : palette.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.sort_rounded, size: 20, color: palette.textSecondary),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSortOptions = !_showSortOptions;
              });
            },
            child: Row(
              children: [
                Text(
                  _sortLabel(l10n, _sortOption),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showSortOptions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: palette.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _sortKeys.map((key) {
          final isSelected = _sortOption == key;
          return InkWell(
            onTap: () => _onSortSelected(key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _sortLabel(l10n, key),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? palette.textTitle
                            : palette.textBody,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.gold,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: Responsive.maxGridCellExtent,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const PropertyCardShimmer(),
    );
  }

  Widget _buildErrorState(LandProvider provider) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.algoCorreuMal,
              style: AppTextStyles.h6.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? l10n.erroDesconhecido,
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadLands,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                l10n.tentarNovamente,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
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
                Icons.landscape_rounded,
                size: 48,
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.nenhumTerrenoEncontrado,
              style: AppTextStyles.h5.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.terrenoCategoriaVazio,
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

  Widget _buildLandGrid(List<LandModel> lands, LandProvider provider) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final comparison = context.watch<ComparisonProvider>();
    final favorites = context.watch<FavoriteProvider>();
    final userId =
        context.read<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
    return RefreshIndicator(
      onRefresh: () async => _loadLands(),
      color: AppColors.gold,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: Responsive.maxGridCellExtent,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((_, index) {
                final land = lands[index];
                return LandCard(
                  imageUrl: land.images.isNotEmpty ? land.images.first : '',
                  title: land.title,
                  location: '${land.neighborhood}, ${land.city}',
                  area: land.area,
                  price: land.price,
                  badgeLabel: _landTypeLabel(l10n, land.type),
                  features: land.features,
                  agentVerified: land.agentVerified,
                  isCompared: comparison.isSelected(land.id),
                  onCompareTap: () => _toggleComparison(comparison, land),
                  isFavorite: favorites.isFavorite(userId, landId: land.id),
                  onFavoriteTap: () => toggleFavoriteWithFeedback(
                    context,
                    favorites,
                    userId,
                    landId: land.id,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.landDetail,
                    arguments: land.id,
                  ),
                );
              }, childCount: lands.length),
            ),
          ),
          if (provider.isLoading && provider.lands.isNotEmpty)
            const SliverPadding(
              padding: EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                ),
              ),
            ),
          if (!provider.hasMore && provider.lands.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.todosTerrenosCarregados,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleComparison(ComparisonProvider comparison, LandModel land) {
    final l10n = AppLocalizations.of(context);
    final wasSelected = comparison.isSelected(land.id);

    if (!wasSelected && comparison.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.limiteComparacao),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    comparison.toggleLand(land);

    if (!wasSelected && comparison.canCompare) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.imovelAdicionadoComparacao(comparison.count)),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
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
}
