import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/land_provider.dart';
import '../../core/providers/property_provider.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../widgets/land_card.dart';
import '../../widgets/property_card.dart';
import '../../widgets/search_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNav = 0;

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
    final url = Uri.parse(
      'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(AppConstants.whatsappMessage)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.white,
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
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  Widget _buildHeroBanner(double padding) {
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              const Spacer(),
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
            'Encontre o seu\nimóvel ideal',
            style: AppTextStyles.h2White.copyWith(
              fontSize: Responsive.fontSize(context, 32),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Casas, apartamentos, terrenos e mais',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 24),
          SearchWidget(
            hintText: 'Pesquisar por localização, tipo...',
            onSearch: (query) {
              Navigator.of(context).pushNamed(AppRoutes.search, arguments: query);
            },
            onFilterTap: () {
              Navigator.of(context).pushNamed(AppRoutes.properties);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(double padding, bool isDesktop) {
    final categories = [
      _CategoryData(icon: Icons.home_outlined, title: 'Casas', count: 0, filterType: 'house'),
      _CategoryData(
        icon: Icons.apartment_rounded,
        title: 'Apartamentos',
        count: 0,
        filterType: 'apartment',
      ),
      _CategoryData(icon: Icons.landscape_rounded, title: 'Terrenos', count: 0, filterType: null),
      _CategoryData(
        icon: Icons.agriculture_rounded,
        title: 'Fazendas',
        count: 0,
        filterType: null,
      ),
      _CategoryData(
        icon: Icons.warehouse_outlined,
        title: 'Armazéns',
        count: 0,
        filterType: 'warehouse',
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
                Text('Categorias', style: AppTextStyles.h5),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Ver todas',
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
                    .map((cat) => SizedBox(
                          width: 120,
                          child: _buildCategoryItem(
                            icon: cat.icon,
                            title: cat.title,
                            count: cat.count,
                            filterType: cat.filterType,
                          ),
                        ))
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
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.properties, arguments: filterType);
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
                  Text('Imóveis em Destaque', style: AppTextStyles.h5),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.properties);
                    },
                    child: Text(
                      'Ver todos',
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
                message: 'Nenhum imóvel em destaque no momento',
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
                      .map((property) => SizedBox(
                            width: 280,
                            child: _buildPropertyCard(property),
                          ))
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
                  Text('Terrenos em Destaque', style: AppTextStyles.h5),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.lands);
                    },
                    child: Text(
                      'Ver todos',
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
                message: 'Nenhum terreno em destaque no momento',
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
                      .map((land) => SizedBox(
                            width: 280,
                            child: _buildLandCard(land),
                          ))
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
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.landDetail, arguments: land.id);
      },
    );
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

  Widget _buildServicesSection(double padding, bool isDesktop) {
    final services = [
      _ServiceData(
        icon: Icons.shopping_cart_outlined,
        title: 'Compra',
        description: 'Encontre o imóvel dos seus sonhos',
      ),
      _ServiceData(
        icon: Icons.sell_outlined,
        title: 'Venda',
        description: 'Venda com segurança e rapidez',
      ),
      _ServiceData(
        icon: Icons.key_outlined,
        title: 'Arrendamento',
        description: 'Alugue com as melhores condições',
      ),
      _ServiceData(
        icon: Icons.business_center_outlined,
        title: 'Consultoria',
        description: 'Assessoria personalizada',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Text('Serviços', style: AppTextStyles.h5),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: services
                  .map((service) => SizedBox(
                        width: 150,
                        child: _buildServiceCard(service),
                      ))
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
                return SizedBox(
                  width: 150,
                  child: _buildServiceCard(service),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildServiceCard(_ServiceData service) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100, width: 1),
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
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              service.description,
              style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUsSection(double padding) {
    final benefits = [
      _BenefitData(
        icon: Icons.workspace_premium_outlined,
        title: 'Experiência no Mercado',
        description:
            'Mais de 10 anos de atuação no mercado imobiliário angolano',
      ),
      _BenefitData(
        icon: Icons.handshake_outlined,
        title: 'Atendimento Personalizado',
        description: 'Cada cliente recebe atenção dedicada e sob medida',
      ),
      _BenefitData(
        icon: Icons.description_outlined,
        title: 'Documentação Segura',
        description: 'Cuidamos de toda a documentação com rigor e segurança',
      ),
      _BenefitData(
        icon: Icons.trending_up_rounded,
        title: 'Melhores Preços',
        description: 'Negociações transparentes e preços competitivos',
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
              Text('Por que escolher-nos?', style: AppTextStyles.h5),
              const SizedBox(height: 8),
              Text(
                'A confiança que o mercado reconhece',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray500,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
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
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    benefit.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray500,
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
    return Container(
      height: 140,
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Início',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Pesquisar',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite_rounded,
                label: 'Favoritos',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: 'Perfil',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentBottomNav == index;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.of(context).pushNamed(AppRoutes.search);
        } else if (index == 2) {
          Navigator.of(context).pushNamed(AppRoutes.favorites);
        } else if (index == 3) {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        } else {
          setState(() => _currentBottomNav = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? AppColors.gold : AppColors.gray400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodyTiny.copyWith(
                color: isSelected ? AppColors.gold : AppColors.gray400,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final IconData icon;
  final String title;
  final int count;
  final String? filterType;

  const _CategoryData({
    required this.icon,
    required this.title,
    required this.count,
    this.filterType,
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
