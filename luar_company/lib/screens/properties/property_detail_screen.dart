import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/models/report_model.dart';
import '../../core/providers/property_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/comparison_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/deep_links.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/whatsapp_util.dart';
import '../../core/services/view_history_service.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/bookings/booking_bottom_sheet.dart';
import '../../screens/videos/video_viewer_screen.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/report_dialog.dart';
import '../../widgets/reviews_section.dart';
import '../../widgets/verified_badge.dart';

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
        ViewHistory.recordProperty(propertyId);
      }
      final userId =
          context.read<AuthProvider>().user?.id ?? FavoriteProvider.guestUserId;
      context.read<FavoriteProvider>().ensureLoaded(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Consumer<PropertyProvider>(
      builder: (_, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: palette.surface,
            body: LoadingWidget(
              isFullScreen: true,
              message: l10n.carregandoImovel,
            ),
          );
        }

        if (provider.error != null || provider.selectedProperty == null) {
          return Scaffold(
            backgroundColor: palette.surface,
            appBar: AppBar(
              foregroundColor: AppColors.white,
              title: Text(
                l10n.erro,
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
                    provider.error ?? l10n.imovelNaoEncontrado,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: palette.textBody,
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
                      l10n.voltar,
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
    final palette = context.palette;
    final isRent = property.transactionType != TransactionType.sale;
    final location = _displayLocation(property);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          top: false,
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(property),
                    _buildTitlePriceSection(property, isRent, location),
                    _buildFeaturesRow(property),
                    _buildDetailTabs(),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _buildOverviewTab(property),
                _buildPhotosTab(property.images),
                _buildVideosTab(property.videos),
                _buildLocationTab(property, location),
              ],
            ),
          ),
        ),
        bottomSheet: _buildContactActions(property),
      ),
    );
  }

  /// Localização sem repetições (`Talatona, Luanda`, nunca `Luanda, Luanda`).
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

  /// Imagem principal full-bleed com ações sobrepostas, como no design.
  Widget _buildHero(PropertyModel property) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final images = property.images;
    final authProvider = context.watch<AuthProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final userId = authProvider.user?.id ?? FavoriteProvider.guestUserId;
    _isFavorite = favoriteProvider.isFavorite(userId, propertyId: property.id);

    final location = _displayLocation(property);
    final topPad = MediaQuery.of(context).padding.top;
    final canPop = Navigator.of(context).canPop();
    // Altura proporcional: não estica em tablets/desktop nem afunila em
    // dispositivos baixos (landscape).
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      260.0,
      420.0,
    );

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          images.isNotEmpty
              ? PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      memCacheWidth: 1080,
                      errorWidget: (_, _, _) => Container(
                        color: palette.surfaceAlt,
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 64,
                          color: palette.textMuted,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: palette.surfaceAlt,
                  child: Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 80,
                      color: palette.textMuted,
                    ),
                  ),
                ),
          const IgnorePointer(
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Colors.transparent,
                    Color(0xB3000000),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          if (canPop)
            Positioned(
              top: topPad + 6,
              left: 10,
              child: _CircleActionButton(
                icon: Icons.arrow_back_rounded,
                label: l10n.voltar,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          Positioned(
            top: topPad + 6,
            right: 10,
            child: Row(
              children: [
                _CircleActionButton(
                  icon: Icons.share_outlined,
                  label: l10n.partilhar,
                  onTap: () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${property.title} - ${formatPrice(property.price)}\n'
                          '${l10n.localizacao}: $location\n'
                          '${DeepLinks.property(property.id)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CircleActionButton(
                  icon: _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: l10n.favoritos,
                  color: _isFavorite ? AppColors.error : AppColors.white,
                  onTap: () => favoriteProvider.toggleFavorite(
                    userId,
                    propertyId: property.id,
                  ),
                ),
              ],
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
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
                      color: isActive ? AppColors.gold : Colors.white70,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          if (images.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitlePriceSection(
    PropertyModel property,
    bool isRent,
    String location,
  ) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  formatPrice(property.price),
                  style: AppTextStyles.priceLarge.copyWith(
                    color: palette.textTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRent) ...[
                const SizedBox(width: 6),
                Text(
                  l10n.perMes,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location.isEmpty
                      ? property.title
                      : '${property.title} \u2022 $location',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesRow(PropertyModel property) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
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
          Expanded(
            child: Center(
              child: _buildFeatureItem(
                icon: Icons.king_bed_outlined,
                value: '${property.bedrooms}',
                label: l10n.quartosLabel,
              ),
            ),
          ),
          Container(width: 1, height: 40, color: palette.borderStrong),
          Expanded(
            child: Center(
              child: _buildFeatureItem(
                icon: Icons.bathroom_outlined,
                value: '${property.bathrooms}',
                label: l10n.wc,
              ),
            ),
          ),
          Container(width: 1, height: 40, color: palette.borderStrong),
          Expanded(
            child: Center(
              child: _buildFeatureItem(
                icon: Icons.square_foot_outlined,
                value: '${property.area.toStringAsFixed(0)} m\u00b2',
                label: l10n.areaLabel,
              ),
            ),
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
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: AppColors.gold),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: palette.textTitle,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyTiny.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(PropertyModel property) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.descricao,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        Text(
          property.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: palette.textBody,
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
                _descriptionExpanded ? l10n.verMenos : l10n.verMais,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Lista de características com vistos em duas colunas (design).
  Widget _buildCharacteristicsSection(PropertyModel property) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.caracteristicas,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: Responsive.gridColumns(
            context,
            mobile: 2,
            tablet: 3,
            desktop: 3,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 12,
          // Altura fixa por célula: comporta 2 linhas de texto sem transbordar,
          // independentemente da largura (aspectRatio quebrava com fontes grandes).
          mainAxisExtent: 44,
          children: property.features.map((feature) {
            return Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textBody,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection(PropertyModel property, String location) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.localizacao,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.borderStrong),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 28,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                property.address.isNotEmpty ? property.address : location,
                style: AppTextStyles.bodySmall.copyWith(
                  color: palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                (property.latitude != 0.0 || property.longitude != 0.0)
                    ? '${property.latitude.toStringAsFixed(4)}, ${property.longitude.toStringAsFixed(4)}'
                    : l10n.coordenadasIndisponiveis,
                style: AppTextStyles.bodyTiny.copyWith(
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (property.latitude != 0.0 || property.longitude != 0.0)
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.map,
                arguments: {
                  'propertyId': property.id,
                  'latitude': property.latitude,
                  'longitude': property.longitude,
                  'title': property.title,
                },
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(
                l10n.verNoMapa,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: palette.textTitle,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textTitle,
                side: BorderSide(color: palette.textTitle, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAgentSection(PropertyModel property) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final isGuest = context.watch<AuthProvider>().user == null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.consultor,
            style: AppTextStyles.h6.copyWith(color: palette.textTitle),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
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
                          color: palette.textTitle,
                        ),
                      ),
                      if (property.agentVerified) ...[
                        const SizedBox(height: 4),
                        const VerifiedBadge(),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        property.agentPhone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: palette.textSecondary,
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
                      if (isGuest) {
                        _showGuestChatNotice(l10n);
                        return;
                      }
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

  /// Aviso mostrado a convidados que tentam conversar com o consultor.
  void _showGuestChatNotice(AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.mensagensDisponiveisConta} ${l10n.converseCorretores}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Secção principal (design: "Visão Geral").
  Widget _buildOverviewTab(PropertyModel property) {
    final l10n = AppLocalizations.of(context);
    final comparison = context.watch<ComparisonProvider>();
    final isCompared = comparison.isSelected(property.id);
    final palette = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      children: [
        _buildDescriptionSection(property),
        if (property.features.isNotEmpty)
          _buildCharacteristicsSection(property),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BookingBottomSheet(
                  propertyId: property.id,
                  propertyTitle: property.title,
                  isLand: false,
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_rounded, size: 20),
            label: Text(
              l10n.agendarVisita,
              style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildCompareButton(property, isCompared, comparison, l10n),
        const SizedBox(height: 24),
        _buildAgentSection(property),
        const SizedBox(height: 24),
        ReviewsSection(propertyId: property.id, agentId: property.agentId),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: () => showReportDialog(
              context,
              targetType: ReportTarget.property,
              targetId: property.id,
            ),
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: Text(
              l10n.reportar,
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Separadores "Visão Geral | Fotos | Vídeos | Localização" (design).
  Widget _buildDetailTabs() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.borderStrong)),
      ),
      child: TabBar(
        labelColor: AppColors.gold,
        unselectedLabelColor: palette.textSecondary,
        labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 13),
        unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.gold,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.fill,
        tabs: [
          Tab(text: l10n.visaoGeral),
          Tab(text: l10n.fotos),
          Tab(text: l10n.videos),
          Tab(text: l10n.localizacao),
        ],
      ),
    );
  }

  /// Grelha de fotografias (separador "Fotos").
  Widget _buildPhotosTab(List<String> images) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    if (images.isEmpty) {
      return _EmptyTab(icon: Icons.photo_outlined, message: l10n.semFotos);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: images.length,
      itemBuilder: (_, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
            memCacheWidth: 720,
            errorWidget: (_, _, _) => Container(
              color: palette.surfaceAlt,
              child: Icon(
                Icons.photo_outlined,
                size: 32,
                color: palette.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Lista de vídeos (separador "Vídeos").
  Widget _buildVideosTab(List<String> videos) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    if (videos.isEmpty) {
      return _EmptyTab(icon: Icons.videocam_outlined, message: l10n.semVideos);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: videos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VideoViewerScreen(videos: videos, initialIndex: index),
            ),
          ),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.gold,
                      size: 34,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 10,
                  child: Text(
                    '${l10n.videos} ${index + 1}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Localização (separador "Localização").
  Widget _buildLocationTab(PropertyModel property, String location) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: _buildLocationSection(property, location),
    );
  }

  /// Barra inferior fixa: apenas WhatsApp e Ligar (design de referência).
  Widget _buildContactActions(PropertyModel property) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.borderStrong)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await WhatsAppUtil.open(
                      message: l10n.mensagemInteresseImovel(property.title),
                      phone: property.agentPhone,
                    );
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
                    elevation: 0,
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
                    l10n.ligar,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: palette.textTitle,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textTitle,
                    side: BorderSide(color: palette.textTitle, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareButton(
    PropertyModel property,
    bool isCompared,
    ComparisonProvider comparison,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {
          if (!isCompared && comparison.isFull) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.limiteComparacao),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            return;
          }

          comparison.toggle(property);

          if (!isCompared && comparison.canCompare) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.imovelAdicionadoComparacao(comparison.count),
                ),
                backgroundColor: AppColors.gold,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: l10n.comparar,
                  textColor: AppColors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.comparison);
                  },
                ),
              ),
            );
          }
        },
        icon: Icon(
          isCompared
              ? Icons.check_circle_rounded
              : Icons.compare_arrows_rounded,
          size: 18,
        ),
        label: Text(
          isCompared ? l10n.comparando : l10n.adicionarComparacao,
          style: AppTextStyles.buttonMedium.copyWith(
            color: isCompared ? AppColors.gold : AppColors.navy,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isCompared ? AppColors.gold : AppColors.navy,
          side: BorderSide(
            color: isCompared ? AppColors.gold : AppColors.navy,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// Botão circular translúcido sobre a imagem (design de referência).
class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? color : AppColors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vazio dos separadores de conteúdo.
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: palette.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
