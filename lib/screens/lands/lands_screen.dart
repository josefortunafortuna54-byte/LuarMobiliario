import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/providers/land_provider.dart';
import '../../core/utils/routes.dart';
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
  String _sortOption = 'Mais recentes';
  bool _showSortOptions = false;

  static const List<String> _filterLabels = [
    'Todos',
    'Urbanos',
    'Agrícolas',
    'Industriais',
    'Comerciais',
    'Lotes',
    'Fazendas',
  ];

  static const List<String> _filterKeys = [
    '',
    'urban',
    'agricultural',
    'industrial',
    'commercial',
    'lot',
    'farm',
  ];

  static const List<String> _sortLabels = [
    'Mais recentes',
    'Menor preço',
    'Maior preço',
    'Maior área',
  ];

  @override
  void initState() {
    super.initState();
    _loadLands();
    _scrollController.addListener(_onScroll);
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
      case 'Menor preço':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Maior preço':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Maior área':
        sorted.sort((a, b) => b.area.compareTo(a.area));
        break;
      case 'Mais recentes':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }

  String _landTypeLabel(LandType type) {
    return switch (type) {
      LandType.urban => 'Urbano',
      LandType.agricultural => 'Agrícola',
      LandType.industrial => 'Industrial',
      LandType.commercial => 'Comercial',
      LandType.lot => 'Lote',
      LandType.farm => 'Fazenda',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          'Terrenos',
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
          if (_showSortOptions) _buildSortDropdown(),
          Expanded(
            child: Consumer<LandProvider>(
              builder: (_, provider, __) {
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
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final isSelected = _selectedFilterIndex == index;
          return Center(
            child: GestureDetector(
              onTap: () => _onFilterSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.navy : AppColors.gray300,
                  ),
                ),
                child: Text(
                  _filterLabels[index],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.gray600,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.sort_rounded, size: 20, color: AppColors.gray500),
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
                  _sortOption,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showSortOptions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _sortLabels.map((label) {
          final isSelected = _sortOption == label;
          return InkWell(
            onTap: () => _onSortSelected(label),
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
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.navy : AppColors.gray700,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const PropertyCardShimmer(),
    );
  }

  Widget _buildErrorState(LandProvider provider) {
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
              'Algo correu mal',
              style: AppTextStyles.h6.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Erro desconhecido',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadLands,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Tentar novamente',
                  style: AppTextStyles.buttonMedium.copyWith(color: AppColors.white)),
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
              child: const Icon(
                Icons.landscape_rounded,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum terreno encontrado',
              style: AppTextStyles.h5.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Não encontrámos terrenos nesta categoria. Tente outro filtro.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandGrid(List<LandModel> lands, LandProvider provider) {
    return RefreshIndicator(
      onRefresh: () async => _loadLands(),
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
              delegate: SliverChildBuilderDelegate(
                (_, index) {
                  final land = lands[index];
                  return LandCard(
                    imageUrl:
                        land.images.isNotEmpty ? land.images.first : '',
                    title: land.title,
                    location: '${land.neighborhood}, ${land.city}',
                    area: land.area,
                    price: land.price,
                    badgeLabel: _landTypeLabel(land.type),
                    features: land.features,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.landDetail,
                      arguments: land.id,
                    ),
                  );
                },
                childCount: lands.length,
              ),
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
                    'Todos os terrenos carregados',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray400,
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
