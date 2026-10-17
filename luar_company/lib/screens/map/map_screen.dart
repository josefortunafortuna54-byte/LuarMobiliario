import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/property_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';

/// Mapa interativo com os imóveis (painel 3 do design de referência):
/// pesquisa no topo, pins no mapa, cartão do imóvel no fundo e botão
/// para recentrar a vista.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _luanda = LatLng(-8.8383, 13.2344);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _query = '';
  PropertyModel? _selected;
  LatLng? _focusCenter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? focusId;
    if (args is Map<String, dynamic>) {
      final lat = (args['latitude'] as num?)?.toDouble();
      final lng = (args['longitude'] as num?)?.toDouble();
      focusId = args['propertyId'] as String?;
      if (lat != null && lng != null && (lat != 0 || lng != 0)) {
        _focusCenter = LatLng(lat, lng);
      }
    }

    final provider = context.read<PropertyProvider>();
    if (provider.properties.isEmpty) {
      try {
        await provider.loadProperties();
      } catch (_) {
        // O estado de erro é tratado pela lista vazia.
      }
    }
    if (!mounted) return;

    setState(() {
      _properties =
          provider.properties
              .where((p) => p.latitude != 0 || p.longitude != 0)
              .toList();
      if (focusId != null) {
        for (final property in _properties) {
          if (property.id == focusId) _selected = property;
        }
      }
      if (_selected != null) {
        _focusCenter = LatLng(_selected!.latitude, _selected!.longitude);
      }
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_focusCenter != null) {
        _mapController.move(_focusCenter!, 15);
      } else {
        _fitAll();
      }
    });
  }

  List<PropertyModel> get _visible {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _properties;
    return _properties.where((p) {
      return p.title.toLowerCase().contains(query) ||
          p.city.toLowerCase().contains(query) ||
          p.municipality.toLowerCase().contains(query) ||
          p.neighborhood.toLowerCase().contains(query);
    }).toList();
  }

  void _fitAll() {
    final items = _visible;
    if (items.isEmpty) {
      _mapController.move(_focusCenter ?? _luanda, 12);
      return;
    }
    if (items.length == 1) {
      final only = items.first;
      _mapController.move(LatLng(only.latitude, only.longitude), 15);
      return;
    }
    final bounds = LatLngBounds.fromPoints([
      for (final p in items) LatLng(p.latitude, p.longitude),
    ]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.fromLTRB(
          48,
          140,
          48,
          _selected != null ? 240 : 120,
        ),
        maxZoom: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _focusCenter ?? _luanda,
              initialZoom: _focusCenter != null ? 15 : 11,
              minZoom: 5,
              maxZoom: 19,
              onTap: (_, _) {
                if (_selected != null) setState(() => _selected = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.luarcompany.luar_company',
              ),
              MarkerLayer(markers: _buildMarkers()),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap'),
              ),
            ],
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    label: l10n.voltar,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildSearchField(l10n, palette)),
                ],
              ),
            ),
          ),
          if (!_isLoading && _visible.isEmpty)
            _buildEmptyBanner(l10n, palette),
          Positioned(
            right: 14,
            bottom: _selected != null ? 210 : 24,
            child: _CircleButton(
              icon: Icons.center_focus_strong_rounded,
              label: l10n.recentrar,
              onTap: _fitAll,
            ),
          ),
          if (_selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: _buildPropertyCard(_selected!, l10n, palette),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, AppPalette palette) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium.copyWith(color: palette.textTitle),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: palette.textMuted,
          ),
          hintText: l10n.pesquisarTudo,
          prefixIcon: Icon(Icons.search_rounded, color: palette.textMuted),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyBanner(AppLocalizations l10n, AppPalette palette) {
    return Positioned(
      left: 24,
      right: 24,
      top: MediaQuery.of(context).padding.top + 76,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.borderStrong),
        ),
        child: Text(
          l10n.semImoveisNoMapa,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: palette.textSecondary),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return [
      for (final property in _visible)
        Marker(
          point: LatLng(property.latitude, property.longitude),
          width: 34,
          height: 34,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => setState(() => _selected = property),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _selected?.id == property.id ? 30 : 22,
              height: _selected?.id == property.id ? 30 : 22,
              decoration: BoxDecoration(
                color:
                    _selected?.id == property.id
                        ? AppColors.gold
                        : property.transactionType != TransactionType.sale
                        ? AppColors.navy
                        : AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selected?.id == property.id
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.9),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildPropertyCard(
    PropertyModel property,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    final location = _displayLocation(property);
    final image = property.images.isNotEmpty ? property.images.first : null;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.propertyDetail,
        arguments: property.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.borderStrong),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 88,
                height: 88,
                child: image == null
                    ? Container(
                        color: palette.surfaceAlt,
                        child: Icon(
                          Icons.apartment_rounded,
                          color: palette.textMuted,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        errorWidget: (_, _, _) => Container(
                          color: palette.surfaceAlt,
                          child: Icon(
                            Icons.apartment_rounded,
                            color: palette.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPrice(property.price),
                    style: AppTextStyles.h6.copyWith(
                      color: palette.textTitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.isEmpty
                        ? property.title
                        : '${property.title} • $location',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (property.bedrooms > 0) ...[
                        const Icon(
                          Icons.king_bed_outlined,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${property.bedrooms}',
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: palette.textBody,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (property.bathrooms > 0) ...[
                        const Icon(
                          Icons.bathroom_outlined,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${property.bathrooms}',
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: palette.textBody,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (property.area > 0) ...[
                        const Icon(
                          Icons.square_foot_outlined,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatArea(property.area),
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: palette.textBody,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  static String _displayLocation(PropertyModel property) {
    final parts = [
      property.neighborhood,
      property.municipality,
      property.city,
    ].where((part) => part.isNotEmpty).toList();
    final deduped = <String>[];
    for (final part in parts) {
      if (!deduped.contains(part)) deduped.add(part);
    }
    return deduped.join(', ');
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.black.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(icon, size: 20, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
