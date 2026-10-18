import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/repositories/land_repository.dart';
import '../../core/repositories/property_repository.dart';
import '../../core/services/view_history_service.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/land_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/property_card.dart';

/// Favoritos e Histórico (painel 5 do design de referência).
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<PropertyModel> _favoriteProperties = [];
  List<LandModel> _favoriteLands = [];
  List<_HistoryItem> _history = [];
  bool _isLoadingDetails = false;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadFavorites();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_isLoadingHistory) {
      _loadHistory();
    }
  }

  Future<void> _loadFavorites() async {
    final auth = context.read<AuthProvider>();
    final favorites = context.read<FavoriteProvider>();
    final userId = auth.user?.id ?? FavoriteProvider.guestUserId;

    await favorites.loadFavorites(userId);

    if (!mounted) return;
    setState(() => _isLoadingDetails = true);

    final properties = await favorites.getFavoriteProperties();
    final lands = await favorites.getFavoriteLands();

    if (!mounted) return;
    setState(() {
      _favoriteProperties = properties;
      _favoriteLands = lands;
      _isLoadingDetails = false;
    });
  }

  Future<void> _loadHistory() async {
    if (_isLoadingHistory) return;
    setState(() => _isLoadingHistory = true);

    final entries = await ViewHistory.entries();
    final propertyIds = [
      for (final e in entries)
        if (ViewHistory.propertyIdOf(e) != null) ViewHistory.propertyIdOf(e)!,
    ];
    final landIds = [
      for (final e in entries)
        if (ViewHistory.landIdOf(e) != null) ViewHistory.landIdOf(e)!,
    ];

    final properties = propertyIds.isEmpty
        ? <PropertyModel>[]
        : await _safeProperties(propertyIds);
    final lands = landIds.isEmpty ? <LandModel>[] : await _safeLands(landIds);

    final propertyById = {for (final p in properties) p.id: p};
    final landById = {for (final l in lands) l.id: l};

    final items = <_HistoryItem>[];
    for (final entry in entries) {
      final pid = ViewHistory.propertyIdOf(entry);
      if (pid != null && propertyById.containsKey(pid)) {
        items.add(_HistoryItem.property(propertyById[pid]!));
        continue;
      }
      final lid = ViewHistory.landIdOf(entry);
      if (lid != null && landById.containsKey(lid)) {
        items.add(_HistoryItem.land(landById[lid]!));
      }
    }

    if (!mounted) return;
    setState(() {
      _history = items;
      _isLoadingHistory = false;
    });
  }

  Future<List<PropertyModel>> _safeProperties(List<String> ids) async {
    try {
      return await PropertyRepository().fetchByIds(ids);
    } catch (_) {
      return [];
    }
  }

  Future<List<LandModel>> _safeLands(List<String> ids) async {
    try {
      return await LandRepository().fetchByIds(ids);
    } catch (_) {
      return [];
    }
  }

  Future<void> _removeFavorite(PropertyModel? property, LandModel? land) async {
    final userId =
        context.read<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
    final favorites = context.read<FavoriteProvider>();

    if (property != null) {
      setState(
        () => _favoriteProperties.removeWhere((p) => p.id == property.id),
      );
      await favorites.toggleFavorite(userId, propertyId: property.id);
    } else if (land != null) {
      setState(() => _favoriteLands.removeWhere((l) => l.id == land.id));
      await favorites.toggleFavorite(userId, landId: land.id);
    }
    if (mounted) await _loadFavorites();
  }

  bool _isFavorite(PropertyModel? property, LandModel? land) {
    final userId =
        context.watch<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
    final favorites = context.watch<FavoriteProvider>();
    if (property != null) {
      return favorites.isFavorite(userId, propertyId: property.id);
    }
    if (land != null) {
      return favorites.isFavorite(userId, landId: land.id);
    }
    return false;
  }

  Future<void> _onRefresh() async {
    await Future.wait([_loadFavorites(), _loadHistory()]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.favoritos,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: palette.textMuted,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelLarge,
          tabs: [
            Tab(text: l10n.favoritos),
            Tab(text: l10n.historico),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFavoritesTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final l10n = AppLocalizations.of(context);
    if (_favoriteProperties.isEmpty && _favoriteLands.isEmpty) {
      if (_isLoadingDetails) {
        return Center(child: LoadingWidget(message: l10n.carregandoFavoritos));
      }
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: l10n.semFavoritos,
        subtitle: l10n.adicioneImoveisFavoritos,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteProperties.length + _favoriteLands.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index < _favoriteProperties.length) {
            final property = _favoriteProperties[index];
            return _buildPropertyRow(property, isFavoriteTab: true);
          }
          final land = _favoriteLands[index - _favoriteProperties.length];
          return _buildLandRow(land, isFavoriteTab: true);
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    final l10n = AppLocalizations.of(context);
    if (_isLoadingHistory && _history.isEmpty) {
      return Center(child: LoadingWidget(message: l10n.carregando));
    }
    if (_history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: l10n.semHistorico,
        subtitle: l10n.historicoDesc,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _history[index];
          if (item.property != null) {
            return _buildPropertyRow(item.property!, isFavoriteTab: false);
          }
          return _buildLandRow(item.land!, isFavoriteTab: false);
        },
      ),
    );
  }

  Widget _buildPropertyRow(
    PropertyModel property, {
    required bool isFavoriteTab,
  }) {
    final l10n = AppLocalizations.of(context);
    final location = [
      property.neighborhood,
      property.municipality,
      property.city,
    ].where((s) => s.isNotEmpty).toSet().join(', ');
    final isFavorite = _isFavorite(property, null);

    String? statusLabel;
    Color? statusColor;
    if (!property.isAvailable) {
      statusLabel = switch (property.transactionType) {
        TransactionType.sale => l10n.vendido,
        TransactionType.rent => l10n.arrendado,
        TransactionType.renew => l10n.renovado,
      };
      statusColor = property.transactionType == TransactionType.sale
          ? AppColors.error
          : AppColors.gold;
    }

    void open() => Navigator.of(
      context,
    ).pushNamed(AppRoutes.propertyDetail, arguments: property.id);

    return PropertyCard(
      variant: PropertyCardVariant.horizontal,
      imageUrl: property.images.isNotEmpty ? property.images.first : '',
      title: property.title,
      location: location,
      price: property.price,
      listingType: property.transactionType == TransactionType.sale
          ? PropertyListingType.venda
          : PropertyListingType.arrendamento,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      area: property.area,
      agentVerified: property.agentVerified,
      statusLabel: statusLabel,
      statusColor: statusColor,
      isFavorite: isFavorite,
      onFavoriteTap: isFavoriteTab
          ? () => _removeFavorite(property, null)
          : () => _toggleFavoriteFromHistory(property),
      onTap: open,
      onDetailsTap: open,
    );
  }

  Widget _buildLandRow(LandModel land, {required bool isFavoriteTab}) {
    final l10n = AppLocalizations.of(context);
    final location = [
      land.neighborhood,
      land.municipality,
      land.city,
    ].where((s) => s.isNotEmpty).toSet().join(', ');
    final isFavorite = _isFavorite(null, land);

    String? statusLabel;
    Color? statusColor;
    if (!land.isAvailable) {
      statusLabel = switch (land.transactionType) {
        LandTransactionType.sale => l10n.vendido,
        LandTransactionType.rent => l10n.arrendado,
        LandTransactionType.renew => l10n.renovado,
      };
      statusColor = land.transactionType == LandTransactionType.sale
          ? AppColors.error
          : AppColors.gold;
    }

    void open() => Navigator.of(
      context,
    ).pushNamed(AppRoutes.landDetail, arguments: land.id);

    return LandCard(
      variant: PropertyCardVariant.horizontal,
      imageUrl: land.images.isNotEmpty ? land.images.first : '',
      title: land.title,
      location: location,
      area: land.area,
      price: land.price,
      badgeLabel: land.type.name.toUpperCase(),
      agentVerified: land.agentVerified,
      statusLabel: statusLabel,
      statusColor: statusColor,
      isFavorite: isFavorite,
      onFavoriteTap: isFavoriteTab
          ? () => _removeFavorite(null, land)
          : () => _toggleLandFavoriteFromHistory(land),
      onTap: open,
      onDetailsTap: open,
    );
  }

  /// No histórico o coração alterna o favorito sem sair do ecrã.
  Future<void> _toggleFavoriteFromHistory(PropertyModel property) async {
    final userId =
        context.read<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
    await context.read<FavoriteProvider>().toggleFavorite(
      userId,
      propertyId: property.id,
    );
    if (mounted) await _loadFavorites();
  }

  Future<void> _toggleLandFavoriteFromHistory(LandModel land) async {
    final userId =
        context.read<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
    await context.read<FavoriteProvider>().toggleFavorite(
      userId,
      landId: land.id,
    );
    if (mounted) await _loadFavorites();
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.h5, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
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
}

/// Entrada do histórico: imóvel ou terreno.
class _HistoryItem {
  const _HistoryItem.property(this.property) : land = null;
  const _HistoryItem.land(this.land) : property = null;

  final PropertyModel? property;
  final LandModel? land;
}
