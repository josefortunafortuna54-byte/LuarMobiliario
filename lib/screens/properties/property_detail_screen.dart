import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/property_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/routes.dart';
import '../../screens/bookings/booking_bottom_sheet.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/feature_chip.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyId = ModalRoute.of(context)?.settings.arguments as String?;
      if (propertyId != null) {
        context.read<PropertyProvider>().selectProperty(propertyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (_, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: LoadingWidget(
              isFullScreen: true,
              message: 'Carregando imóvel...',
            ),
          );
        }

        if (provider.error != null || provider.selectedProperty == null) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              title: Text(
                'Erro',
                style: AppTextStyles.h5.copyWith(color: AppColors.white),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error ?? 'Imóvel não encontrado',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Voltar',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final property = provider.selectedProperty!;
        return _buildDetailContent(property);
      },
    );
  }

  Widget _buildDetailContent(PropertyModel property) {
    final isRent = property.transactionType == TransactionType.rent;
    final location =
        '${property.neighborhood}, ${property.city}, ${property.municipality}';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(property, location),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(property.images),
                _buildTitlePriceSection(property, isRent, location),
                _buildFeaturesRow(property),
                _buildDescriptionSection(property),
                _buildLocationSection(property, location),
                _buildAgentSection(property),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(property),
    );
  }

  SliverAppBar _buildAppBar(PropertyModel property, String location) {
    final authProvider = context.watch<AuthProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final userId = authProvider.user?.id ?? '';

    if (userId.isNotEmpty) {
      _isFavorite = favoriteProvider.isFavorite(
        userId,
        propertyId: property.id,
      );
    }

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      title: Text(
        'Detalhes do Imóvel',
        style: AppTextStyles.h6.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(
                text: '${property.title} - AOA ${property.price.toStringAsFixed(0)}\n'
                    'Localização: $location\n'
                    'Ver em Luar Mobiliario',
              ),
            );
          },
          icon: const Icon(Icons.share_outlined, color: AppColors.white),
        ),
        IconButton(
          onPressed: userId.isNotEmpty
              ? () async {
                  await favoriteProvider.toggleFavorite(
                    userId,
                    propertyId: property.id,
                  );
                }
              : null,
          icon: Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavorite ? AppColors.gold : AppColors.white,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: images.isNotEmpty
              ? PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.gray200,
                            child: const Icon(
                              Icons.apartment_rounded,
                              size: 64,
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.navy.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Container(
                  color: AppColors.gray200,
                  child: const Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 80,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = _currentImageIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.gold : AppColors.gray300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: AppTextStyles.bodyTiny.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitlePriceSection(
    PropertyModel property,
    bool isRent,
    String location,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isRent ? AppColors.navyLight : AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isRent ? 'ALUGUEL' : 'VENDA',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(property.title, style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'AOA ${property.price.toStringAsFixed(0)}',
            style: AppTextStyles.priceLarge,
          ),
          if (isRent)
            Text(
              '/mês',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesRow(PropertyModel property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureItem(
            icon: Icons.king_bed_outlined,
            value: '${property.bedrooms}',
            label: 'Quartos',
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          _buildFeatureItem(
            icon: Icons.bathroom_outlined,
            value: '${property.bathrooms}',
            label: 'WC',
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          _buildFeatureItem(
            icon: Icons.square_foot_outlined,
            value: '${property.area.toStringAsFixed(0)} m²',
            label: 'Área',
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          _buildFeatureItem(
            icon: Icons.garage_outlined,
            value: '${property.garage}',
            label: 'Garagem',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: AppColors.gold),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.navy),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(PropertyModel property) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrição',
            style: AppTextStyles.h6.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          Text(
            property.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
              height: 1.6,
            ),
            maxLines: _descriptionExpanded ? null : 6,
            overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          if (property.description.length > 300)
            GestureDetector(
              onTap: () {
                setState(() {
                  _descriptionExpanded = !_descriptionExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _descriptionExpanded ? 'Ver menos' : 'Ver mais',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (property.features.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Características',
              style: AppTextStyles.h6.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: property.features.map((feature) {
                return FeatureChip(
                  label: feature,
                  backgroundColor: AppColors.navy.withValues(alpha: 0.06),
                  foregroundColor: AppColors.navy,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection(PropertyModel property, String location) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localização',
            style: AppTextStyles.h6.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    size: 28,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  property.address.isNotEmpty ? property.address : location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  (property.latitude != 0.0 || property.longitude != 0.0)
                      ? '${property.latitude.toStringAsFixed(4)}, ${property.longitude.toStringAsFixed(4)}'
                      : 'Coordenadas indisponíveis',
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentSection(PropertyModel property) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultor',
            style: AppTextStyles.h6.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AvatarWidget(name: property.agentName, size: AvatarSize.large),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.agentName,
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.agentPhone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${property.agentPhone}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      size: 20,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (property.agentId != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.chat,
                        arguments: {
                          'partnerId': property.agentId!,
                          'partnerName': property.agentName,
                        },
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(PropertyModel property) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BookingBottomSheet(
                      propertyId: property.id,
                      propertyTitle: property.title,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_rounded, size: 20),
                label: Text(
                  'Agendar Visita',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.gold.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final message = Uri.encodeComponent(
                          'Olá! Tenho interesse no imóvel "${property.title}".',
                        );
                        final uri = Uri.parse(
                          'https://wa.me/${property.agentPhone}?text=$message',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: Text(
                        'WhatsApp',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('tel:${property.agentPhone}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: Text(
                        'Ligar',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(
                          color: AppColors.navy,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
