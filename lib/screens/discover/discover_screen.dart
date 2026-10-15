import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/discover_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/whatsapp_util.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/video_player_widget.dart';

/// Feed vertical de descoberta de imóveis (Luar Discover).
///
/// Cada página mostra um imóvel com vídeo automático (apenas na página ativa),
/// ou a primeira fotografia quando não existe vídeo. A paginação é feita a
/// partir do backend.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<DiscoverProvider>();
      if (provider.items.isEmpty && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _activeIndex = index);
    final provider = context.read<DiscoverProvider>();
    if (index >= provider.items.length - 3) {
      provider.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Consumer<DiscoverProvider>(
        builder: (context, provider, _) {
          final l10n = AppLocalizations.of(context);

          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            );
          }

          if (provider.error != null && provider.items.isEmpty) {
            return _buildMessageState(
              icon: Icons.cloud_off_rounded,
              title: l10n.erro,
              subtitle: l10n.descobrirErro,
              actionLabel: l10n.tentarNovamente,
              onAction: () => provider.load(),
            );
          }

          if (provider.items.isEmpty) {
            return _buildMessageState(
              icon: Icons.video_library_outlined,
              title: l10n.descobrirVazioTitulo,
              subtitle: l10n.descobrirVazioSubtitulo,
              actionLabel: l10n.tentarNovamente,
              onAction: () => provider.load(),
            );
          }

          final items = provider.items;
          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: _onPageChanged,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _DiscoverPage(
                    property: items[index],
                    isActive: index == _activeIndex,
                    showHint: index == 0 && items.length > 1,
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _buildTopBar(l10n),
                ),
              ),
              if (provider.isLoadingMore)
                const Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            label: l10n.voltar,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.descobrir,
            style: AppTextStyles.h6.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      color: context.palette.background,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 12,
              child: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                label: AppLocalizations.of(context).voltar,
                onTap: () => Navigator.of(context).maybePop(),
                light: true,
              ),
            ),
            EmptyState(
              icon: icon,
              title: title,
              subtitle: subtitle,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage({
    required this.property,
    required this.isActive,
    this.showHint = false,
  });

  final PropertyModel property;
  final bool isActive;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoriteProvider>();
    final userId = auth.user?.id ?? '';
    final isFavorite =
        userId.isNotEmpty &&
        favorites.isFavorite(userId, propertyId: property.id);

    final isRent = property.transactionType == TransactionType.rent;
    final location = [
      property.neighborhood,
      property.municipality,
      property.city,
    ].where((part) => part.isNotEmpty).join(', ');

    return Semantics(
      label: property.title,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(context),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      AppColors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildInfo(context, l10n, isRent, location),
                    ),
                    const SizedBox(width: 12),
                    _buildActions(
                      context,
                      l10n,
                      isFavorite: isFavorite,
                      userId: userId,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showHint)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildScrollHint(l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    if (property.videos.isNotEmpty) {
      return VideoPlayerWidget(
        key: ValueKey('discover-video-${property.id}'),
        url: property.videos.first,
        autoPlay: true,
        looping: true,
        isActive: isActive,
      );
    }

    final palette = context.palette;
    if (property.images.isNotEmpty) {
      return Image.network(
        property.images.first,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: palette.surfaceAlt,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, _, _) => _buildPlaceholder(context),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      alignment: Alignment.center,
      child: Icon(
        Icons.apartment_rounded,
        size: 72,
        color: AppColors.white.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
    AppLocalizations l10n,
    bool isRent,
    String location,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isRent ? AppColors.navyLight : AppColors.gold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isRent ? l10n.arrendamento : l10n.venda,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          property.title,
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatPrice(property.price),
              style: AppTextStyles.priceMedium,
            ),
            if (isRent) ...[
              const SizedBox(width: 4),
              Text(
                l10n.perMes,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
        if (property.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            property.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (property.bedrooms > 0)
              _InfoChip(
                icon: Icons.king_bed_outlined,
                label: '${property.bedrooms} ${l10n.quartosLabel}',
              ),
            if (property.bathrooms > 0)
              _InfoChip(
                icon: Icons.bathroom_outlined,
                label: '${property.bathrooms} ${l10n.wc}',
              ),
            if (property.area > 0)
              _InfoChip(
                icon: Icons.square_foot_outlined,
                label: formatArea(property.area),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isFavorite,
    required String userId,
  }) {
    final favorites = context.read<FavoriteProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: l10n.favoritos,
          color: isFavorite ? AppColors.gold : AppColors.white,
          onTap: userId.isEmpty
              ? null
              : () => favorites.toggleFavorite(
                  userId,
                  propertyId: property.id,
                ),
        ),
        const SizedBox(height: 18),
        _ActionButton(
          icon: Icons.share_outlined,
          label: l10n.partilhar,
          onTap: () => SharePlus.instance.share(
            ShareParams(
              text:
                  '${property.title} - ${formatPrice(property.price)}\n'
                  '${l10n.verEmLuar}',
            ),
          ),
        ),
        const SizedBox(height: 18),
        _ActionButton(
          icon: Icons.chat_rounded,
          label: l10n.contactar,
          onTap: () => WhatsAppUtil.open(
            phone: property.agentPhone.isNotEmpty
                ? property.agentPhone
                : null,
            message: l10n.mensagemInteresseImovel(property.title),
          ),
        ),
        const SizedBox(height: 18),
        _ActionButton(
          icon: Icons.info_outline_rounded,
          label: l10n.detalhes,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.propertyDetail,
            arguments: property.id,
          ),
        ),
      ],
    );
  }

  Widget _buildScrollHint(AppLocalizations l10n) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.white70,
              size: 22,
            ),
            Text(
              l10n.descobrirDeslizar,
              style: AppTextStyles.bodyTiny.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.bodyTiny.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Icon(
                  icon,
                  size: 22,
                  color: enabled
                      ? color
                      : AppColors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodyTiny.copyWith(
              color: AppColors.white.withValues(alpha: enabled ? 0.9 : 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.light = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: light
            ? palette.surface
            : AppColors.black.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 22,
              color: light ? palette.textTitle : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
