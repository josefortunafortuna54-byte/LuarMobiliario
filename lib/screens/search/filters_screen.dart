import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/saved_search_provider.dart';
import '../../core/providers/search_provider.dart';
import '../../core/repositories/location_repository.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';

/// Ecrã "Filtros" alinhado com o design de referência: transação, localização,
/// preço, tipo de imóvel (grelha de ícones), finalidade e detalhes.
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  static const double _priceCap = 50000000;
  static const double _areaCap = 10000;

  String? _transactionType;
  String? _propertyType;
  String? _landType;
  String? _purpose;
  String? _province;
  String? _municipality;
  double _minPrice = 0;
  double _maxPrice = _priceCap;
  double _minArea = 0;
  double _maxArea = _areaCap;
  int? _bedrooms;
  int? _bathrooms;
  int? _garage;

  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  List<String> _municipalities = [];

  static const List<String> _provinces = [
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
    _transactionType = provider.transactionType;
    _propertyType = provider.propertyType;
    _landType = provider.landType;
    _purpose = provider.purpose;
    _province = provider.province;
    _municipality = provider.municipality;
    _minPrice = provider.minPrice ?? 0;
    _maxPrice = provider.maxPrice ?? _priceCap;
    _minArea = provider.minArea ?? 0;
    _maxArea = provider.maxArea ?? _areaCap;
    _bedrooms = provider.bedrooms;
    _bathrooms = provider.bathrooms;
    _garage = provider.garage;

    _minPriceController = TextEditingController(
      text: _minPrice > 0 ? formatPriceRaw(_minPrice) : '',
    );
    _maxPriceController = TextEditingController(
      text: provider.maxPrice != null ? formatPriceRaw(_maxPrice) : '',
    );

    _loadMunicipalities();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// Municípios vêm da tabela `locations`; sem rede o ecrã continua útil
  /// (província, preço e tipos continuam operacionais).
  Future<void> _loadMunicipalities() async {
    try {
      final municipalities = await LocationRepository().fetchMunicipalities();
      if (!mounted) return;
      setState(() => _municipalities = municipalities);
    } catch (_) {
      // Offline / sem backend: mantém apenas a opção "Todos".
    }
  }

  double? _parsePrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final value = double.tryParse(digits);
    if (value == null || value <= 0 || value >= _priceCap) return null;
    return value;
  }

  void _toggleTransaction(String value) {
    setState(() {
      _transactionType = _transactionType == value ? null : value;
    });
  }

  void _selectCategory(String key, bool isLand) {
    setState(() {
      if (isLand) {
        _landType = _landType == key ? null : key;
        if (_landType != null) _propertyType = null;
      } else {
        _propertyType = _propertyType == key ? null : key;
        if (_propertyType != null) _landType = null;
      }
    });
  }

  /// Snapshot dos filtros ainda em edição nesta folha (mais a pesquisa por
  /// texto e a ordenação do provider) para guardar como pesquisa.
  Map<String, dynamic> _stagedFilters() {
    final provider = context.read<SearchProvider>();
    return {
      if (provider.query.isNotEmpty) 'query': provider.query,
      if (_transactionType != null) 'transactionType': _transactionType,
      if (_propertyType != null) 'propertyType': _propertyType,
      if (_landType != null) 'landType': _landType,
      if (_purpose != null) 'purpose': _purpose,
      if (_province != null) 'province': _province,
      if (_municipality != null) 'municipality': _municipality,
      if (_parsePrice(_minPriceController.text) != null)
        'minPrice': _parsePrice(_minPriceController.text),
      if (_parsePrice(_maxPriceController.text) != null)
        'maxPrice': _parsePrice(_maxPriceController.text),
      if (_minArea > 0) 'minArea': _minArea,
      if (_maxArea < _areaCap) 'maxArea': _maxArea,
      if (_bedrooms != null) 'bedrooms': _bedrooms,
      if (_bathrooms != null) 'bathrooms': _bathrooms,
      if (_garage != null) 'garage': _garage,
      'sortOption': provider.sortOption,
    };
  }

  /// Pede o nome e guarda o snapshot atual dos filtros em
  /// `saved_searches` (apenas com sessão iniciada).
  Future<void> _saveSearch() async {
    final l10n = AppLocalizations.of(context);
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.palette.surface,
        title: Text(l10n.guardarPesquisa, style: AppTextStyles.h6),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.nomePesquisa,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(l10n.guardar),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;

    final provider = context.read<SavedSearchProvider>();
    final saved = await provider.save(
      userId: userId,
      name: name,
      filters: _stagedFilters(),
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          saved != null ? l10n.pesquisaGuardadaComSucesso : l10n.erroAoGuardar,
        ),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _transactionType = null;
      _propertyType = null;
      _landType = null;
      _purpose = null;
      _province = null;
      _municipality = null;
      _minPrice = 0;
      _maxPrice = _priceCap;
      _minArea = 0;
      _maxArea = _areaCap;
      _bedrooms = null;
      _bathrooms = null;
      _garage = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    final provider = context.read<SearchProvider>();
    provider.applyFilters(
      propertyType: _propertyType,
      landType: _landType,
      purpose: _purpose,
      transactionType: _transactionType,
      province: _province,
      municipality: _municipality,
      minPrice: _parsePrice(_minPriceController.text),
      maxPrice: _parsePrice(_maxPriceController.text),
      minArea: _minArea > 0 ? _minArea : null,
      maxArea: _maxArea < _areaCap ? _maxArea : null,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      garage: _garage,
    );
    provider.search();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.filtros,
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.gold),
            tooltip: l10n.pesquisasGuardadas,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.savedSearches),
          ),
          if (context.watch<AuthProvider>().user != null)
            IconButton(
              icon: const Icon(Icons.save_alt, color: AppColors.gold),
              tooltip: l10n.guardarPesquisa,
              onPressed: _saveSearch,
            ),
          TextButton(
            onPressed: _clearAll,
            child: Text(
              l10n.limparTudo,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: l10n.tipoTransacao),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _GoldChip(
                  label: l10n.comprar,
                  selected: _transactionType == 'sale',
                  onTap: () => _toggleTransaction('sale'),
                ),
                _GoldChip(
                  label: l10n.arrendar,
                  selected: _transactionType == 'rent',
                  onTap: () => _toggleTransaction('rent'),
                ),
                _GoldChip(
                  label: l10n.todos,
                  selected: _transactionType == null,
                  onTap: () => setState(() => _transactionType = null),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.provincia),
            const SizedBox(height: 10),
            _DropdownField<String>(
              value: _province,
              hint: l10n.todos,
              items: _provinces,
              onChanged: (value) => setState(() => _province = value),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.municipio),
            const SizedBox(height: 10),
            _DropdownField<String>(
              value: _municipality,
              hint: l10n.todos,
              items: _municipalities,
              onChanged: (value) => setState(() => _municipality = value),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.preco),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PriceField(
                    controller: _minPriceController,
                    label: l10n.minimo,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriceField(
                    controller: _maxPriceController,
                    label: l10n.maximo,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.tipoImovel),
            const SizedBox(height: 10),
            _buildCategoryGrid(l10n),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.finalidade),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _GoldChip(
                    label: l10n.residencial,
                    selected: _purpose == 'residential',
                    onTap: () => setState(() {
                      _purpose = _purpose == 'residential'
                          ? null
                          : 'residential';
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GoldChip(
                    label: l10n.comercial,
                    selected: _purpose == 'commercial',
                    onTap: () => setState(() {
                      _purpose = _purpose == 'commercial' ? null : 'commercial';
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.areaM2),
            const SizedBox(height: 10),
            _RangeField(
              min: _minArea,
              max: _maxArea,
              cap: _areaCap,
              unit: 'm²',
              onChanged: (values) => setState(() {
                _minArea = values.start;
                _maxArea = values.end;
              }),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.quartosLabel),
            const SizedBox(height: 10),
            _OptionsRow(
              options: AppConstants.bedroomOptions,
              selectedIndex: _bedrooms != null ? _bedrooms! - 1 : null,
              onSelected: (i) {
                setState(() {
                  _bedrooms = _bedrooms == i + 1 ? null : i + 1;
                });
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.casasDeBanhoLabel),
            const SizedBox(height: 10),
            _OptionsRow(
              options: AppConstants.bedroomOptions,
              selectedIndex: _bathrooms != null ? _bathrooms! - 1 : null,
              onSelected: (i) {
                setState(() {
                  _bathrooms = _bathrooms == i + 1 ? null : i + 1;
                });
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.garagemLabel),
            const SizedBox(height: 10),
            _OptionsRow(
              options: AppConstants.parkingOptions,
              selectedIndex: _garage != null ? _garage! - 1 : null,
              onSelected: (i) {
                setState(() {
                  _garage = _garage == i + 1 ? null : i + 1;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
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
                  l10n.aplicarFiltros,
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grelha de tipos (imóveis + terrenos) no estilo dos ícones do design.
  Widget _buildCategoryGrid(AppLocalizations l10n) {
    final categories = [
      ...propertyCategories.map((c) => (category: c, isLand: false)),
      ...landCategories.map((c) => (category: c, isLand: true)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: categories.map((entry) {
        final key = entry.category.key;
        final selected = entry.isLand
            ? _landType == key
            : _propertyType == key;
        final label = entry.isLand
            ? landCategoryLabel(key, l10n)
            : propertyCategoryLabel(key, l10n);

        return _IconTile(
          icon: entry.category.icon,
          label: label,
          selected: selected,
          onTap: () => _selectCategory(key, entry.isLand),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: context.palette.textTitle,
      ),
    );
  }
}

/// Chip com estado selecionado dourado (design de referência).
class _GoldChip extends StatelessWidget {
  const _GoldChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? AppColors.gold : palette.inputFill,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.gold : palette.borderStrong,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? AppColors.navy : palette.textBody,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected
          ? AppColors.gold.withValues(alpha: 0.16)
          : palette.inputFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.gold : palette.borderStrong,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.gold : palette.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyTiny.copyWith(
                  color: selected ? AppColors.gold : palette.textBody,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.borderStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(color: palette.textMuted),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item as String, style: AppTextStyles.bodyMedium),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTextStyles.bodyMedium.copyWith(color: palette.textTitle),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: palette.textMuted),
        prefixIcon: Icon(icon, size: 18, color: palette.textMuted),
        suffixText: 'Kz',
        suffixStyle: AppTextStyles.bodySmall.copyWith(color: palette.textMuted),
        filled: true,
        fillColor: palette.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}

class _RangeField extends StatelessWidget {
  const _RangeField({
    required this.min,
    required this.max,
    required this.cap,
    required this.unit,
    required this.onChanged,
  });

  final double min;
  final double max;
  final double cap;
  final String unit;
  final ValueChanged<RangeValues> onChanged;

  String _label(double value, bool isMax) {
    if (!isMax && value == 0) return 'Min';
    if (isMax && value >= cap) return 'Max';
    return '${formatPriceRaw(value)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _label(min, false),
              style: AppTextStyles.bodySmall.copyWith(color: palette.textBody),
            ),
            Text(
              _label(max, true),
              style: AppTextStyles.bodySmall.copyWith(color: palette.textBody),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(min, max),
          min: 0,
          max: cap,
          divisions: 100,
          activeColor: AppColors.gold,
          inactiveColor: palette.borderStrong,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
                color: isSelected ? AppColors.gold : palette.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.gold : palette.borderStrong,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                options[i],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.navy : palette.textBody,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
