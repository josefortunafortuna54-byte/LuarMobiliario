import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/providers/land_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/feature_chip.dart';

class LandDetailScreen extends StatefulWidget {
  const LandDetailScreen({super.key});

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final landId = ModalRoute.of(context)?.settings.arguments as String?;
      if (landId != null) {
        context.read<LandProvider>().selectLand(landId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LandProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: LoadingWidget(
              isFullScreen: true,
              message: 'Carregando terreno...',
            ),
          );
        }

        if (provider.error != null || provider.selectedLand == null) {
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
                    provider.error ?? 'Terreno não encontrado',
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

        final land = provider.selectedLand!;
        return _buildDetailContent(land);
      },
    );
  }

  Widget _buildDetailContent(LandModel land) {
    final isRent = land.transactionType == LandTransactionType.rent;
    final location = '${land.neighborhood}, ${land.city}, ${land.municipality}';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(land, location),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(land.images),
                _buildTitlePriceSection(land, isRent, location),
                _buildFeaturesSection(land),
                _buildDescriptionSection(land),
                _buildLocationSection(land, location),
                _buildAgentSection(land),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(land),
    );
  }

  SliverAppBar _buildAppBar(LandModel land, String location) {
    final authProvider = context.watch<AuthProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final userId = authProvider.user?.id ?? '';

    if (userId.isNotEmpty) {
      _isFavorite = favoriteProvider.isFavorite(userId, landId: land.id);
    }

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      title: Text(
        'Detalhes do Terreno',
        style: AppTextStyles.h6.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(
                text: '${land.title} - AOA ${land.price.toStringAsFixed(0)}\n'
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
                    landId: land.id,
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
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.gray200,
                            child: const Icon(
                              Icons.landscape_rounded,
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
                      Icons.landscape_rounded,
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

  Widget _buildTitlePriceSection(LandModel land, bool isRent, String location) {
    final typeLabel = _landTypeLabel(land.type);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isRent ? AppColors.navyLight : AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRent ? 'ALUGUEL' : 'VENDA',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  typeLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(land.title, style: AppTextStyles.h4),
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
            'AOA ${land.price.toStringAsFixed(0)}',
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

  Widget _buildFeaturesSection(LandModel land) {
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
            icon: Icons.square_foot_outlined,
            value: '${land.area.toStringAsFixed(0)} m²',
            label: 'Área Total',
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          _buildFeatureItem(
            icon: Icons.landscape_rounded,
            value: _landTypeLabel(land.type),
            label: 'Tipo',
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
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: AppColors.navy,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(LandModel land) {
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
            land.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
              height: 1.6,
            ),
            maxLines: _descriptionExpanded ? null : 6,
            overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          if (land.description.length > 300)
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
          if (land.features.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Características',
              style: AppTextStyles.h6.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: land.features.map((feature) {
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

  Widget _buildLocationSection(LandModel land, String location) {
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
                  land.address.isNotEmpty ? land.address : location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${land.latitude.toStringAsFixed(4)}, ${land.longitude.toStringAsFixed(4)}',
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

  Widget _buildAgentSection(LandModel land) {
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
                AvatarWidget(name: land.agentName, size: AvatarSize.large),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        land.agentName,
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        land.agentPhone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${land.agentPhone}');
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(LandModel land) {
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
                onPressed: () async {
                  final message = Uri.encodeComponent(
                    'Olá! Tenho interesse no terreno "${land.title}" '
                    'no valor de AOA ${land.price.toStringAsFixed(0)}. '
                    'Gostaria de agendar uma visita.',
                  );
                  final uri = Uri.parse(
                    'https://wa.me/${AppConstants.whatsappNumber}?text=$message',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
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
                          'Olá! Tenho interesse no terreno "${land.title}".',
                        );
                        final uri = Uri.parse(
                          'https://wa.me/${land.agentPhone}?text=$message',
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
                        final uri = Uri.parse('tel:${land.agentPhone}');
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
}
