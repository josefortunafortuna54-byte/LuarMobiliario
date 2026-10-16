import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/property_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/property_card.dart';
import '../../widgets/loading_widget.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilterIndex = 0;
  String _sortOption = 'recent';
  bool _showSortOptions = false;
  bool _routeArgumentApplied = false;

  List<String> get _filterKeys => propertyFilterKeys;

  List<String> _filterLabels(AppLocalizations l10n) => propertyFilterLabels(l10n);

  String _sortLabel(String key, AppLocalizations l10n) => switch (key) {
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
    if (_routeArgumentApplied) return;
    _routeArgumentApplied = true;
    _applyRouteArgument();
    _loadProperties();
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

  void _loadProperties() {
    final provider = context.read<PropertyProvider>();
    final filters = <String, dynamic>{};
    if (_filterKeys[_selectedFilterIndex].isNotEmpty) {
      filters['type'] = _filterKeys[_selectedFilterIndex];
    }
    provider.loadProperties(filters: filters.isNotEmpty ? filters : null);
  }

  void _loadMore() {
    final provider = context.read<PropertyProvider>();
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
    _loadProperties();
  }

  List<PropertyModel> _sortProperties(List<PropertyModel> list) {
    final sorted = List<PropertyModel>.from(list);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Text(
          l10n.imoveis,
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSortBar(),
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (_, provider, _) {
                if (provider.isLoading && provider.properties.isEmpty) {
                  return _buildShimmerGrid();
                }

                if (provider.error != null && provider.properties.isEmpty) {
                  return _buildErrorState(provider);
                }

                if (provider.properties.isEmpty) {
                  return _buildEmptyState();
                }

                final sorted = _sortProperties(provider.properties);
                return _buildPropertyGrid(sorted, provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final palette = context.palette;
    final labels = _filterLabels(AppLocalizations.of(context));
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.borderStrong)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final isSelected = _selectedFilterIndex == index;
          return Center(
            child: GestureDetector(
              onTap: () => _onFilterSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.navy : palette.textMuted,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : palette.textBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
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
                      _sortLabel(_sortOption, l10n),
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
        ),
        if (_showSortOptions)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption('recent'),
                _buildSortOption('priceAsc'),
                _buildSortOption('priceDesc'),
                _buildSortOption('areaDesc'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSortOption(String key) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final isSelected = _sortOption == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortOption = key;
          _showSortOptions = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withValues(alpha: 0.08) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected ? AppColors.gold : palette.textMuted,
            ),
            const SizedBox(width: 10),
            Text(
              _sortLabel(key, l10n),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? palette.textTitle : palette.textBody,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildErrorState(PropertyProvider provider) {
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
              onPressed: _loadProperties,
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
                Icons.home_outlined,
                size: 48,
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.nenhumImovelEncontrado,
              style: AppTextStyles.h5.copyWith(color: palette.textTitle),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sicategoria,
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

  Widget _buildPropertyGrid(
    List<PropertyModel> properties,
    PropertyProvider provider,
  ) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async => _loadProperties(),
      color: AppColors.gold,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((_, index) {
                final property = properties[index];
                return PropertyCard(
                  imageUrl: property.images.isNotEmpty
                      ? property.images.first
                      : '',
                  title: property.title,
                  location: '${property.neighborhood}, ${property.city}',
                  price: property.price,
                  listingType: property.transactionType == TransactionType.sale
                      ? PropertyListingType.venda
                      : PropertyListingType.arrendamento,
                  bedrooms: property.bedrooms,
                  bathrooms: property.bathrooms,
                  area: property.area,
                  agentVerified: property.agentVerified,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.propertyDetail,
                    arguments: property.id,
                  ),
                );
              }, childCount: properties.length),
            ),
          ),
          if (provider.isLoading && provider.properties.isNotEmpty)
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
          if (!provider.hasMore && provider.properties.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.todosImoveisCarregados,
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
}
