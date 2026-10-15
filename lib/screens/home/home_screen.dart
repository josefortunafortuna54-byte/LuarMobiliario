import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/land_provider.dart';
import '../../core/providers/property_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/whatsapp_util.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/land_card.dart';
import '../../widgets/property_card.dart';
import '../../widgets/search_widget.dart';
import '../../widgets/settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.embedded = false, this.onSelectTab});

  /// Quando embutido num shell com barra de navegação própria, esconde a
  /// barra inferior interna.
  final bool embedded;

  /// Permite ao shell tratar a navegação por separadores (ex.: Descobrir).
  final ValueChanged<int>? onSelectTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _logoTapCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadFeatured();
      context.read<LandProvider>().loadFeatured();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<PropertyProvider>().loadFeatured(),
      context.read<LandProvider>().loadFeatured(),
    ]);
  }

  Future<void> _openWhatsApp() async {
    await WhatsAppUtil.open();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final padding = Responsive.horizontalPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: palette.surface,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.contentMaxWidth(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(padding),
                    _buildCategoriesSection(padding, isDesktop),
                    _buildFeaturedPropertiesSection(padding, isDesktop),
                    _buildFeaturedLandsSection(padding, isDesktop),
                    _buildServicesSection(padding, isDesktop),
                    _buildWhyChooseUsSection(padding),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildWhatsAppFAB(),
    );
  }

  Widget _buildHeroBanner(double padding) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(padding, 28, padding, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _logoTapCount++;
                  if (_logoTapCount >= 5) {
                    _logoTapCount = 0;
                    Navigator.of(context).pushNamed(AppRoutes.adminLogin);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('logo.png', fit: BoxFit.cover),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showSettingsSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            l10n.homeHeroTitle,
            style: AppTextStyles.h2White.copyWith(
              fontSize: Responsive.fontSize(context, 32),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeHeroSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 24),
          SearchWidget(
            hintText: l10n.homeSearchHint,
            onSearch: (query) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.search, arguments: query);
            },
            onFilterTap: () {
              Navigator.of(context).pushNamed(AppRoutes.properties);
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              if (widget.onSelectTab != null) {
                widget.onSelectTab!(1);
              } else {
                Navigator.of(context).pushNamed(AppRoutes.discover);
              }
            },
            icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
            label: Text(l10n.descobrir),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: BorderSide(
                color: AppColors.white.withValues(alpha: 0.4),
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(double padding, bool isDesktop) {
    final l10n = AppLocalizations.of(context);
    final categories = [
      ...propertyCategories.map(
        (c) => _CategoryData(
          icon: c.icon,
          title: propertyCategoryLabel(c.key, l10n),
          count: 0,
          filterType: c.key,
        ),
      ),
      ...landCategories.map(
        (c) => _CategoryData(
          icon: c.icon,
          title: landCategoryLabel(c.key, l10n),
          count: 0,
          filterType: c.key,
          isLand: true,
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.categorias, style: AppTextStyles.h5),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.properties);
                  },
                  child: Text(
                    l10n.verTodas,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (isDesktop)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories
                    .map(
                      (cat) => SizedBox(
                        width: 120,
                        child: _buildCategoryItem(
                          icon: cat.icon,
                          title: cat.title,
                          count: cat.count,
                          filterType: cat.filterType,
                          isLand: cat.isLand,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return SizedBox(
                    width: 100,
                    child: _buildCategoryItem(
                      icon: cat.icon,
                      title: cat.title,
                      count: cat.count,
                      filterType: cat.filterType,
                      isLand: cat.isLand,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required int count,
    String? filterType,
    bool isLand = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLand) {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.lands, arguments: filterType);
        } else {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.properties, arguments: filterType);
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: AppColors.gold),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPropertiesSection(double padding, bool isDesktop) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, _) {
        final l10n = AppLocalizations.of(context);
        final featured = propertyProvider.featuredProperties;
        final isLoading = propertyProvider.isLoading && featured.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.imoveisDestaque, style: AppTextStyles.h5),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.properties);
                    },
                    child: Text(
                      l10n.verTodos,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
              )
            else if (featured.isEmpty)
              _buildEmptyState(
                icon: Icons.apartment_rounded,
                message: l10n.nenhumImovelDestaque,
                padding: padding,
              )
            else if (isDesktop)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: featured
                      .take(4)
                      .map(
                        (property) => SizedBox(
                          width: 280,
                          child: _buildPropertyCard(property),
                        ),
                      )
                      .toList(),
                ),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final property = featured[index];
                    return SizedBox(
                      width: 300,
                      child: _buildPropertyCard(property),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    final imageUrl = property.images.isNotEmpty ? property.images.first : '';

    final locationParts = [
      property.neighborhood,
      property.municipality,
      property.city,
    ].where((p) => p.isNotEmpty).join(', ');

    final listingType = property.transactionType == TransactionType.sale
        ? PropertyListingType.venda
        : PropertyListingType.arrendamento;

    return PropertyCard(
      imageUrl: imageUrl,
      title: property.title,
      location: locationParts.isNotEmpty ? locationParts : property.address,
      price: property.price,
      listingType: listingType,
      variant: PropertyCardVariant.vertical,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      area: property.area,
      agentVerified: property.agentVerified,
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.propertyDetail, arguments: property.id);
      },
      onDetailsTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.propertyDetail, arguments: property.id);
      },
    );
  }

  Widget _buildFeaturedLandsSection(double padding, bool isDesktop) {
    return Consumer<LandProvider>(
      builder: (context, landProvider, _) {
        final l10n = AppLocalizations.of(context);
        final featured = landProvider.featuredLands;
        final isLoading = landProvider.isLoading && featured.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.terrenosDestaque, style: AppTextStyles.h5),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.lands);
                    },
                    child: Text(
                      l10n.verTodos,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
              )
            else if (featured.isEmpty)
              _buildEmptyState(
                icon: Icons.landscape_rounded,
                message: l10n.nenhumTerrenoDestaque,
                padding: padding,
              )
            else if (isDesktop)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: featured
                      .take(4)
                      .map(
                        (land) =>
                            SizedBox(width: 280, child: _buildLandCard(land)),
                      )
                      .toList(),
                ),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final land = featured[index];
                    return SizedBox(width: 300, child: _buildLandCard(land));
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLandCard(LandModel land) {
    final imageUrl = land.images.isNotEmpty ? land.images.first : '';

    final locationParts = [
      land.neighborhood,
      land.municipality,
      land.city,
    ].where((p) => p.isNotEmpty).join(', ');

    final badgeLabel = _landTypeLabel(land.type);

    return LandCard(
      imageUrl: imageUrl,
      title: land.title,
      location: locationParts.isNotEmpty ? locationParts : land.address,
      area: land.area,
      price: land.price,
      badgeLabel: badgeLabel,
      features: land.features.take(3).toList(),
      agentVerified: land.agentVerified,
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.landDetail, arguments: land.id);
      },
    );
  }

  String _landTypeLabel(LandType type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      LandType.urban => l10n.urbano,
      LandType.agricultural => l10n.agricola,
      LandType.industrial => l10n.industrial,
      LandType.commercial => l10n.comercial,
      LandType.lot => l10n.lote,
      LandType.farm => l10n.fazenda,
    };
  }

  Widget _buildServicesSection(double padding, bool isDesktop) {
    final l10n = AppLocalizations.of(context);
    final services = [
      _ServiceData(
        icon: Icons.shopping_cart_outlined,
        title: l10n.servicoCompra,
        description: l10n.servicoCompraDesc,
      ),
      _ServiceData(
        icon: Icons.sell_outlined,
        title: l10n.servicoVenda,
        description: l10n.servicoVendaDesc,
      ),
      _ServiceData(
        icon: Icons.key_outlined,
        title: l10n.servicoArrendamento,
        description: l10n.servicoArrendamentoDesc,
      ),
      _ServiceData(
        icon: Icons.business_center_outlined,
        title: l10n.servicoConsultoria,
        description: l10n.servicoConsultoriaDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Text(l10n.servicos, style: AppTextStyles.h5),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: services
                  .map(
                    (service) =>
                        SizedBox(width: 150, child: _buildServiceCard(service)),
                  )
                  .toList(),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemCount: services.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                return SizedBox(width: 150, child: _buildServiceCard(service));
              },
            ),
          ),
      ],
    );
  }

  Widget _buildServiceCard(_ServiceData service) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, size: 22, color: AppColors.gold),
            ),
            const Spacer(),
            Text(
              service.title,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: palette.textTitle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              service.description,
              style: AppTextStyles.bodyTiny.copyWith(
                color: palette.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUsSection(double padding) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final benefits = [
      _BenefitData(
        icon: Icons.workspace_premium_outlined,
        title: l10n.beneficioExperiencia,
        description: l10n.beneficioExperienciaDesc,
      ),
      _BenefitData(
        icon: Icons.handshake_outlined,
        title: l10n.beneficioAtendimento,
        description: l10n.beneficioAtendimentoDesc,
      ),
      _BenefitData(
        icon: Icons.description_outlined,
        title: l10n.beneficioDocumentacao,
        description: l10n.beneficioDocumentacaoDesc,
      ),
      _BenefitData(
        icon: Icons.trending_up_rounded,
        title: l10n.beneficioPrecos,
        description: l10n.beneficioPrecosDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.porqueEscolher, style: AppTextStyles.h5),
              const SizedBox(height: 8),
              Text(
                l10n.confiancaMercado,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...benefits.map((benefit) => _buildBenefitItem(benefit, padding)),
      ],
    );
  }

  Widget _buildBenefitItem(_BenefitData benefit, double padding) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(benefit.icon, size: 26, color: AppColors.gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.title,
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: palette.textTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    benefit.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    double padding = 24,
  }) {
    final palette = context.palette;
    return Container(
      height: 140,
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: palette.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: palette.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppFAB() {
    return FloatingActionButton(
      onPressed: _openWhatsApp,
      backgroundColor: AppColors.whatsapp,
      elevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.chat_rounded, color: AppColors.white, size: 28),
    );
  }

}

class _CategoryData {
  final IconData icon;
  final String title;
  final int count;
  final String? filterType;
  final bool isLand;

  const _CategoryData({
    required this.icon,
    required this.title,
    required this.count,
    this.filterType,
    this.isLand = false,
  });
}

class _ServiceData {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _BenefitData {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
