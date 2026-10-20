import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/models/property_model.dart';
import '../../core/repositories/land_repository.dart';
import '../../core/repositories/property_repository.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';

/// Marcador unificado do mapa (imóvel ou terreno).
class _MapPin {
  const _MapPin({
    required this.id,
    required this.title,
    required this.price,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.isLand,
    required this.location,
    this.bedrooms,
    this.bathrooms,
  });

  final String id;
  final String title;
  final double price;
  final double area;
  final double latitude;
  final double longitude;
  final String? image;
  final bool isLand;
  final String location;
  final int? bedrooms;
  final int? bathrooms;

  String get detailRoute =>
      isLand ? AppRoutes.landDetail : AppRoutes.propertyDetail;
}

/// Mapa interativo com imóveis e terrenos (painel 3 do design de referência):
/// pesquisa no topo, pins (com clusters) no mapa, cartão do anúncio no fundo
/// e botão para recentrar a vista.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.propertyRepository, this.landRepository});

  /// Repositórios opcionais para injeção em testes.
  final PropertyRepository? propertyRepository;
  final LandRepository? landRepository;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _luanda = LatLng(-8.8383, 13.2344);
  static const int _pageSize = 50;
  static const int _maxPages = 40;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late final PropertyRepository _propertyRepository =
      widget.propertyRepository ?? PropertyRepository();
  late final LandRepository _landRepository =
      widget.landRepository ?? LandRepository();

  List<_MapPin> _pins = [];
  bool _isLoading = true;
  String _query = '';
  _MapPin? _selected;
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

    final pins = <_MapPin>[];
    await _fetchProperties(pins);
    await _fetchLands(pins);
    if (!mounted) return;

    setState(() {
      _pins = pins;
      if (focusId != null) {
        for (final pin in _pins) {
          if (pin.id == focusId) _selected = pin;
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

  Future<void> _fetchProperties(List<_MapPin> out) async {
    final repository = _propertyRepository;
    var page = 0;
    while (page < _maxPages) {
      final batch = await repository.fetchProperties(
        page: page,
        pageSize: _pageSize,
      );
      final slice = slicePage(batch, _pageSize);
      out.addAll(slice.items.where(_hasCoords).map(_pinFromProperty));
      if (!slice.hasMore) break;
      page++;
    }
  }

  Future<void> _fetchLands(List<_MapPin> out) async {
    final repository = _landRepository;
    var page = 0;
    while (page < _maxPages) {
      final batch = await repository.fetchLands(
        page: page,
        pageSize: _pageSize,
      );
      final slice = slicePage(batch, _pageSize);
      out.addAll(slice.items.where(_hasCoords).map(_pinFromLand));
      if (!slice.hasMore) break;
      page++;
    }
  }

  static bool _hasCoords(dynamic listing) {
    final lat = (listing.latitude as num).toDouble();
    final lng = (listing.longitude as num).toDouble();
    return lat != 0 || lng != 0;
  }

  static _MapPin _pinFromProperty(PropertyModel property) {
    return _MapPin(
      id: property.id,
      title: property.title,
      price: property.price,
      area: property.area,
      latitude: property.latitude,
      longitude: property.longitude,
      image: property.images.isNotEmpty ? property.images.first : null,
      isLand: false,
      location: _locationLabel(
        property.neighborhood,
        property.municipality,
        property.city,
      ),
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
    );
  }

  static _MapPin _pinFromLand(LandModel land) {
    return _MapPin(
      id: land.id,
      title: land.title,
      price: land.price,
      area: land.area,
      latitude: land.latitude,
      longitude: land.longitude,
      image: land.images.isNotEmpty ? land.images.first : null,
      isLand: true,
      location: _locationLabel(land.neighborhood, land.municipality, land.city),
    );
  }

  static String _locationLabel(String a, String b, String c) {
    final parts = [a, b, c].where((part) => part.isNotEmpty).toList();
    final deduped = <String>[];
    for (final part in parts) {
      if (!deduped.contains(part)) deduped.add(part);
    }
    return deduped.join(', ');
  }

  List<_MapPin> get _visible {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _pins;
    return _pins.where((pin) {
      return pin.title.toLowerCase().contains(query) ||
          pin.location.toLowerCase().contains(query);
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
      for (final pin in items) LatLng(pin.latitude, pin.longitude),
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
              MarkerClusterLayerWidget(options: _clusterOptions()),
              const SimpleAttributionWidget(source: Text('© OpenStreetMap')),
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
          if (!_isLoading && _visible.isEmpty) _buildEmptyBanner(l10n, palette),
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
              child: _buildPinCard(_selected!, palette),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
        ],
      ),
    );
  }

  MarkerClusterLayerOptions _clusterOptions() {
    return MarkerClusterLayerOptions(
      maxClusterRadius: 48,
      size: const Size(40, 40),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(50),
      maxZoom: 16,
      markers: _buildMarkers(),
      builder: (context, markers) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${markers.length}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
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
      for (final pin in _visible)
        Marker(
          point: LatLng(pin.latitude, pin.longitude),
          width: 34,
          height: 34,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => setState(() => _selected = pin),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _selected?.id == pin.id ? 30 : 22,
              height: _selected?.id == pin.id ? 30 : 22,
              decoration: BoxDecoration(
                color: _selected?.id == pin.id
                    ? AppColors.gold
                    : pin.isLand
                    ? AppColors.navyLight
                    : AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selected?.id == pin.id
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

  Widget _buildPinCard(_MapPin pin, AppPalette palette) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed(pin.detailRoute, arguments: pin.id),
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
                child: pin.image == null
                    ? Container(
                        color: palette.surfaceAlt,
                        child: Icon(
                          pin.isLand
                              ? Icons.landscape_rounded
                              : Icons.apartment_rounded,
                          color: palette.textMuted,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: pin.image!,
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        errorWidget: (_, _, _) => Container(
                          color: palette.surfaceAlt,
                          child: Icon(
                            pin.isLand
                                ? Icons.landscape_rounded
                                : Icons.apartment_rounded,
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
                    formatPrice(pin.price),
                    style: AppTextStyles.h6.copyWith(color: palette.textTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pin.location.isEmpty
                        ? pin.title
                        : '${pin.title} • ${pin.location}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (pin.bedrooms != null && pin.bedrooms! > 0) ...[
                        const Icon(
                          Icons.king_bed_outlined,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${pin.bedrooms}',
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: palette.textBody,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (pin.bathrooms != null && pin.bathrooms! > 0) ...[
                        const Icon(
                          Icons.bathroom_outlined,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${pin.bathrooms}',
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: palette.textBody,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (pin.area > 0) ...[
                        const Icon(
                          Icons.square_foot_outlined,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatArea(pin.area),
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
            Icon(Icons.chevron_right_rounded, color: palette.textMuted),
          ],
        ),
      ),
    );
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
