import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/search_provider.dart';
import '../../core/utils/routes.dart';
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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          'Pesquisar',
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
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
                  'Limpar',
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
              hintText: 'Pesquisar imóveis e terrenos...',
              autofocus: false,
              onSearch: _onSearchChanged,
              onFilterTap: _openFilterSheet,
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
            builder: (_, provider, _) {
                return Column(
                  children: [
                    if (provider.activeFilterCount > 0)
                      _buildActiveFilters(provider),
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
    final chips = <_FilterChipData>[];

    if (provider.query.isNotEmpty) {
      chips.add(
        _FilterChipData('"{provider.query}"', () {
          provider.setFilter(query: '');
          _searchController.clear();
          provider.search();
        }),
      );
    }
    if (provider.transactionType != null) {
      chips.add(
        _FilterChipData(
          provider.transactionType == 'sale' ? 'Venda' : 'Aluguel',
          () => _removeFilter(provider, 'transactionType'),
        ),
      );
    }
    if (provider.propertyType != null) {
      chips.add(
        _FilterChipData(provider.propertyType!, () {
          provider.setFilter(propertyType: null);
          provider.search();
        }),
      );
    }
    if (provider.landType != null) {
      chips.add(
        _FilterChipData(provider.landType!, () {
          provider.setFilter(landType: null);
          provider.search();
        }),
      );
    }
    if (provider.city != null) {
      chips.add(
        _FilterChipData(provider.city!, () {
          provider.setFilter(city: null);
          provider.search();
        }),
      );
    }
    if (provider.minPrice != null) {
      chips.add(
        _FilterChipData(
          'Min: AOA ${provider.minPrice!.toStringAsFixed(0)}',
          () => _removeFilter(provider, 'minPrice'),
        ),
      );
    }
    if (provider.maxPrice != null) {
      chips.add(
        _FilterChipData(
          'Max: AOA ${provider.maxPrice!.toStringAsFixed(0)}',
          () => _removeFilter(provider, 'maxPrice'),
        ),
      );
    }
    if (provider.bedrooms != null) {
      chips.add(
        _FilterChipData(
          '${provider.bedrooms} quartos',
          () => _removeFilter(provider, 'bedrooms'),
        ),
      );
    }
    if (provider.bathrooms != null) {
      chips.add(
        _FilterChipData(
          '${provider.bathrooms} WC',
          () => _removeFilter(provider, 'bathrooms'),
        ),
      );
    }
    if (provider.garage != null) {
      chips.add(
        _FilterChipData(
          '${provider.garage} garagem',
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
                  color: AppColors.navy,
                  fontWeight: FontWeight.w500,
                ),
              ),
              deleteIcon: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.navy,
              ),
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
    switch (filter) {
      case 'transactionType':
        provider.setFilter(transactionType: null);
        break;
      case 'minPrice':
        provider.setFilter(minPrice: null);
        break;
      case 'maxPrice':
        provider.setFilter(maxPrice: null);
        break;
      case 'bedrooms':
        provider.setFilter(bedrooms: null);
        break;
      case 'bathrooms':
        provider.setFilter(bathrooms: null);
        break;
      case 'garage':
        provider.setFilter(garage: null);
        break;
    }
    provider.search();
  }

  Widget _buildResults(SearchProvider provider) {
    if (provider.isLoading) {
      return _buildShimmerGrid();
    }

    if (provider.results.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResultsGrid(provider);
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
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum resultado encontrado',
              style: AppTextStyles.h5.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou pesquisar por outro termo.',
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

  Widget _buildResultsGrid(SearchProvider provider) {
    final properties = provider.propertyResults;
    final lands = provider.landResults;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (properties.isNotEmpty) ...[
          Text(
            'Imóveis (${properties.length})',
            style: AppTextStyles.h6.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          ...properties.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PropertyCard(
                imageUrl: p.images.isNotEmpty ? p.images.first : '',
                title: p.title,
                location: '${p.neighborhood}, ${p.city}',
                price: p.price,
                listingType: p.transactionType == TransactionType.sale
                    ? PropertyListingType.venda
                    : PropertyListingType.arrendamento,
                bedrooms: p.bedrooms,
                bathrooms: p.bathrooms,
                area: p.area,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.propertyDetail,
                  arguments: p.id,
                ),
              ),
            ),
          ),
        ],
        if (lands.isNotEmpty) ...[
          Text(
            'Terrenos (${lands.length})',
            style: AppTextStyles.h6.copyWith(color: AppColors.navy),
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
      ],
    );
  }
}

class _FilterChipData {
  final String label;
  final VoidCallback onRemove;
  const _FilterChipData(this.label, this.onRemove);
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _selectedTransactionType;
  String? _selectedPropertyType;
  String? _selectedLandType;
  String? _selectedCity;
  double _minPrice = 0;
  double _maxPrice = 50000000;
  double _minArea = 0;
  double _maxArea = 10000;
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  int? _selectedGarage;

  final List<String> _cities = [
    'Luanda',
    'Bengo',
    'Benguela',
    'Bié',
    'Cabinda',
    'Cuando-Cubango',
    'Cuanza Norte',
    'Cuanza Sul',
    'Cunene',
    'Huambo',
    'Huíla',
    'Icolo e Bengo',
    'Luanda Norte',
    'Lunda Norte',
    'Lunda Sul',
    'Malanje',
    'Moxico',
    'Namibe',
    'Uíge',
    'Zaire',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<SearchProvider>();
    _selectedTransactionType = provider.transactionType;
    _selectedPropertyType = provider.propertyType;
    _selectedLandType = provider.landType;
    _selectedCity = provider.city;
    _minPrice = provider.minPrice ?? 0;
    _maxPrice = provider.maxPrice ?? 50000000;
    _minArea = provider.minArea ?? 0;
    _maxArea = provider.maxArea ?? 10000;
    _selectedBedrooms = provider.bedrooms;
    _selectedBathrooms = provider.bathrooms;
    _selectedGarage = provider.garage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tipo de Transação'),
                  const SizedBox(height: 10),
                  _buildTransactionChips(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tipo de Imóvel'),
                  const SizedBox(height: 10),
                  _buildPropertyTypeChips(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tipo de Terreno'),
                  const SizedBox(height: 10),
                  _buildLandTypeChips(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Cidade'),
                  const SizedBox(height: 10),
                  _buildCityDropdown(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Faixa de Preço'),
                  const SizedBox(height: 10),
                  _buildPriceRange(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Área (m²)'),
                  const SizedBox(height: 10),
                  _buildAreaRange(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quartos'),
                  const SizedBox(height: 10),
                  _buildOptionsRow(
                    options: AppConstants.bedroomOptions,
                    selectedIndex: _selectedBedrooms != null
                        ? _selectedBedrooms! - 1
                        : null,
                    onSelected: (i) {
                      setState(() {
                        _selectedBedrooms = _selectedBedrooms == i + 1
                            ? null
                            : i + 1;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Casas de Banho'),
                  const SizedBox(height: 10),
                  _buildOptionsRow(
                    options: AppConstants.bedroomOptions,
                    selectedIndex: _selectedBathrooms != null
                        ? _selectedBathrooms! - 1
                        : null,
                    onSelected: (i) {
                      setState(() {
                        _selectedBathrooms = _selectedBathrooms == i + 1
                            ? null
                            : i + 1;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Garagem'),
                  const SizedBox(height: 10),
                  _buildOptionsRow(
                    options: AppConstants.parkingOptions,
                    selectedIndex: _selectedGarage != null
                        ? _selectedGarage! - 1
                        : null,
                    onSelected: (i) {
                      setState(() {
                        _selectedGarage = _selectedGarage == i + 1
                            ? null
                            : i + 1;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.gray300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(
            'Filtros',
            style: AppTextStyles.h5.copyWith(color: AppColors.navy),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTransactionType = null;
                _selectedPropertyType = null;
                _selectedLandType = null;
                _selectedCity = null;
                _minPrice = 0;
                _maxPrice = 50000000;
                _minArea = 0;
                _maxArea = 10000;
                _selectedBedrooms = null;
                _selectedBathrooms = null;
                _selectedGarage = null;
              });
            },
            child: Text(
              'Limpar tudo',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.navy),
    );
  }

  Widget _buildTransactionChips() {
    final types = ['sale', 'rent'];
    final labels = ['Venda', 'Aluguel'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(types.length, (i) {
        final isSelected = _selectedTransactionType == types[i];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTransactionType = isSelected ? null : types[i];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navy : AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.navy : AppColors.gray200,
              ),
            ),
            child: Text(
              labels[i],
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPropertyTypeChips() {
    final types = ['house', 'apartment', 'office', 'warehouse', 'shop'];
    final labels = ['Casa', 'Apartamento', 'Escritório', 'Armazém', 'Loja'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(types.length, (i) {
        final isSelected = _selectedPropertyType == types[i];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPropertyType = isSelected ? null : types[i];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navy : AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.navy : AppColors.gray200,
              ),
            ),
            child: Text(
              labels[i],
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLandTypeChips() {
    final types = [
      'urban',
      'agricultural',
      'industrial',
      'commercial',
      'lot',
      'farm',
    ];
    final labels = [
      'Urbano',
      'Agrícola',
      'Industrial',
      'Comercial',
      'Lote',
      'Fazenda',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(types.length, (i) {
        final isSelected = _selectedLandType == types[i];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLandType = isSelected ? null : types[i];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navy : AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.navy : AppColors.gray200,
              ),
            ),
            child: Text(
              labels[i],
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCity,
          hint: Text(
            'Selecione a cidade',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city, style: AppTextStyles.bodyMedium),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPriceRange() {
    final minLabel = _minPrice == 0
        ? 'Min'
        : 'AOA ${_formatCompact(_minPrice)}';
    final maxLabel = _maxPrice >= 50000000
        ? 'Max'
        : 'AOA ${_formatCompact(_maxPrice)}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minLabel,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            ),
            Text(
              maxLabel,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 50000000,
          divisions: 50,
          activeColor: AppColors.gold,
          inactiveColor: AppColors.gray200,
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAreaRange() {
    final minLabel = _minArea == 0
        ? 'Min'
        : '${_minArea.toStringAsFixed(0)} m²';
    final maxLabel = _maxArea >= 10000
        ? 'Max'
        : '${_maxArea.toStringAsFixed(0)} m²';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minLabel,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            ),
            Text(
              maxLabel,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minArea, _maxArea),
          min: 0,
          max: 10000,
          divisions: 100,
          activeColor: AppColors.gold,
          inactiveColor: AppColors.gray200,
          onChanged: (values) {
            setState(() {
              _minArea = values.start;
              _maxArea = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOptionsRow({
    required List<String> options,
    required int? selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = selectedIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navy : AppColors.gray100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.navy : AppColors.gray200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                options[i],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.white : AppColors.gray700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            final provider = context.read<SearchProvider>();
            provider.setFilter(
              transactionType: _selectedTransactionType,
              propertyType: _selectedPropertyType,
              landType: _selectedLandType,
              city: _selectedCity,
              minPrice: _minPrice > 0 ? _minPrice : null,
              maxPrice: _maxPrice < 50000000 ? _maxPrice : null,
              minArea: _minArea > 0 ? _minArea : null,
              maxArea: _maxArea < 10000 ? _maxArea : null,
              bedrooms: _selectedBedrooms,
              bathrooms: _selectedBathrooms,
              garage: _selectedGarage,
            );
            provider.search();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: AppColors.gold.withValues(alpha: 0.4),
          ),
          child: Text(
            'Aplicar Filtros',
            style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
