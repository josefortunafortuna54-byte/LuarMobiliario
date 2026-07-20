import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/models/land_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/property_card.dart';
import '../../widgets/land_card.dart';

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
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final auth = context.read<AuthProvider>();
    final favorites = context.read<FavoriteProvider>();
    final userId = auth.user?.id;
    if (userId == null) return;

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

  Future<void> _onRefresh() async {
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Favoritos',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.gray400,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'Imóveis'),
            Tab(text: 'Terrenos'),
          ],
        ),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && _isLoadingDetails) {
            return const Center(
              child: LoadingWidget(message: 'Carregando favoritos...'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [_buildPropertiesTab(), _buildLandsTab()],
          );
        },
      ),
    );
  }

  Widget _buildPropertiesTab() {
    if (_favoriteProperties.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Sem favoritos',
        subtitle: 'Adicione imóveis aos seus favoritos para vê-los aqui.',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: _favoriteProperties.length,
            itemBuilder: (context, index) {
              final property = _favoriteProperties[index];
              final imageUrl = property.images.isNotEmpty
                  ? property.images.first
                  : '';
              final listingType =
                  property.transactionType == TransactionType.sale
                  ? PropertyListingType.venda
                  : PropertyListingType.arrendamento;
              final location = [
                property.neighborhood,
                property.municipality,
                property.city,
              ].where((s) => s.isNotEmpty).join(', ');

              return PropertyCard(
                imageUrl: imageUrl,
                title: property.title,
                location: location,
                price: property.price,
                listingType: listingType,
                bedrooms: property.bedrooms,
                bathrooms: property.bathrooms,
                area: property.area,
                onTap: () {},
                onDetailsTap: () {},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLandsTab() {
    if (_favoriteLands.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Sem favoritos',
        subtitle: 'Adicione terrenos aos seus favoritos para vê-los aqui.',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemCount: _favoriteLands.length,
            itemBuilder: (context, index) {
              final land = _favoriteLands[index];
              final imageUrl = land.images.isNotEmpty ? land.images.first : '';
              final location = [
                land.neighborhood,
                land.municipality,
                land.city,
              ].where((s) => s.isNotEmpty).join(', ');

              return LandCard(
                imageUrl: imageUrl,
                title: land.title,
                location: location,
                area: land.area,
                price: land.price,
                badgeLabel: land.type.name.toUpperCase(),
                features: land.features,
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
