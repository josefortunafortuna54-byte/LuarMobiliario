import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import 'property_card.dart' show PropertyCardVariant;
import 'verified_badge.dart';

class LandCard extends StatelessWidget {
  const LandCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.area,
    required this.price,
    required this.badgeLabel,
    this.features = const [],
    this.onTap,
    this.onDetailsTap,
    this.agentVerified = false,
    this.variant = PropertyCardVariant.vertical,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.onCompareTap,
    this.isCompared = false,
    this.statusLabel,
    this.statusColor,
  });

  final String imageUrl;
  final String title;
  final String location;
  final double area;
  final double price;
  final String badgeLabel;
  final List<String> features;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;
  final bool agentVerified;
  final PropertyCardVariant variant;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final VoidCallback? onCompareTap;
  final bool isCompared;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    if (variant == PropertyCardVariant.horizontal) {
      return _buildHorizontal(context);
    }
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildImage(context), _buildContent(context)],
          ),
        ),
      ),
    );
  }

  /// Variante horizontal: miniatura à esquerda, conteúdo à direita.
  Widget _buildHorizontal(BuildContext context) {
    final palette = context.palette;
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 132, child: _buildImage(context, expand: true)),
                Expanded(child: _buildHorizontalContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalContent(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatPriceCurrency(price),
            style: AppTextStyles.priceSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.h6.copyWith(fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.gold,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (agentVerified) ...[
                const SizedBox(width: 4),
                const VerifiedBadge(compact: true),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.square_foot_outlined,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${area.toStringAsFixed(0)} m²',
                        style: AppTextStyles.bodyTiny.copyWith(
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onCompareTap != null) ...[
                _buildCompareButton(context),
                const SizedBox(width: 6),
              ],
              if (onFavoriteTap != null)
                _buildHeart(context)
              else
                _buildDetailsButton(context),
            ],
          ),
        ],
      ),
    );
  }

  /// Botão "Detalhes" — à direita do conteúdo (variante horizontal).
  Widget _buildDetailsButton(BuildContext context) {
    return GestureDetector(
      onTap: onDetailsTap ?? onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          AppLocalizations.of(context).detalhes,
          style: AppTextStyles.buttonSmall.copyWith(
            fontSize: 10,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCompareButton(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onCompareTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isCompared
              ? AppColors.gold.withValues(alpha: 0.15)
              : palette.border,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompared ? AppColors.gold : palette.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompared
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 16,
              color: isCompared ? AppColors.gold : palette.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              isCompared ? l10n.comparando : l10n.comparar,
              style: AppTextStyles.buttonSmall.copyWith(
                fontSize: 11,
                color: isCompared ? AppColors.gold : palette.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeart(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      child: GestureDetector(
        onTap: onFavoriteTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.borderStrong),
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? AppColors.error : palette.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context, {
    double? height,
    bool expand = false,
  }) {
    final palette = context.palette;
    return Stack(
      fit: expand ? StackFit.expand : StackFit.loose,
      children: [
        SizedBox(
          height: height ?? 220,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            memCacheWidth: 800,
            errorWidget: (_, _, _) => Container(
              color: palette.surfaceAlt,
              child: Icon(
                Icons.landscape_rounded,
                size: 56,
                color: palette.textMuted,
              ),
            ),
          ),
        ),
        Container(
          height: height ?? 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.navy.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor ?? AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel ?? badgeLabel,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.square_foot, size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  '${area.toStringAsFixed(0)} m²',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h6,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
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
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (agentVerified) ...[
                const SizedBox(width: 6),
                const VerifiedBadge(compact: true),
              ],
            ],
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: features
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: palette.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        f,
                        style: AppTextStyles.bodyTiny.copyWith(
                          color: palette.textBody,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPriceCurrency(price),
                  style: AppTextStyles.priceMedium,
                ),
              ),
              if (onCompareTap != null) ...[
                _buildCompareButton(context),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onDetailsTap ?? onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.detalhes,
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
