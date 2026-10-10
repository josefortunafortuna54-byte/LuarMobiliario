import 'package:flutter/material.dart';
import 'package:luar_company/l10n/app_localizations.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';

enum PropertyListingType { venda, arrendamento }

enum PropertyCardVariant { horizontal, vertical }

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.listingType,
    this.variant = PropertyCardVariant.vertical,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.onTap,
    this.onDetailsTap,
  });

  final String imageUrl;
  final String title;
  final String location;
  final double price;
  final PropertyListingType listingType;
  final PropertyCardVariant variant;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;

  String _badgeLabel(AppLocalizations l10n) =>
      listingType == PropertyListingType.venda ? l10n.venda : l10n.arrendamento;

  Color get _badgeColor => listingType == PropertyListingType.venda
      ? AppColors.gold
      : AppColors.navyLight;

  @override
  Widget build(BuildContext context) {
    return variant == PropertyCardVariant.vertical
        ? _buildVertical(context)
        : _buildHorizontal(context);
  }

  Widget _buildVertical(BuildContext context) {
    return GestureDetector(
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
          children: [
            _buildImage(height: 220, context: context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
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
        child: Row(
          children: [
            _buildImage(width: 160, context: context),
            Expanded(child: _buildHorizontalContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({double? height, double? width, required BuildContext context}) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          width: width,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: context.palette.surfaceAlt,
              child: Icon(
                Icons.apartment_rounded,
                size: 48,
                color: context.palette.textMuted,
              ),
            ),
          ),
        ),
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.navy.withValues(alpha: 0.6),
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
              color: _badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _badgeLabel(AppLocalizations.of(context)),
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
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
            ],
          ),
          const SizedBox(height: 12),
          _buildFeaturesRow(context: context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPriceCurrency(price),
                  style: AppTextStyles.priceMedium,
                ),
              ),
              GestureDetector(
                onTap: onDetailsTap,
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

  Widget _buildHorizontalContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.h6.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
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
            ],
          ),
          const SizedBox(height: 8),
          _buildFeaturesRow(compact: true, context: context),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPriceCurrency(price),
                  style: AppTextStyles.priceSmall,
                ),
              ),
              GestureDetector(
                onTap: onDetailsTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.detalhes,
                    style: AppTextStyles.buttonSmall.copyWith(
                      fontSize: 10,
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

  Widget _buildFeaturesRow({bool compact = false, required BuildContext context}) {
    final iconSize = compact ? 14.0 : 16.0;
    final textSize = compact ? AppTextStyles.bodyTiny : AppTextStyles.bodySmall;
    final spacing = compact ? 6.0 : 8.0;
    final palette = context.palette;

    final features = <Widget>[];

    if (bedrooms != null) {
      features.add(
        _FeatureItem(
          icon: Icons.king_bed_outlined,
          text: '$bedrooms',
          iconSize: iconSize,
          textStyle: textSize,
          iconColor: palette.textMuted,
          textColor: palette.textBody,
        ),
      );
    }

    if (bathrooms != null) {
      if (features.isNotEmpty) features.add(SizedBox(width: spacing));
      features.add(
        _FeatureItem(
          icon: Icons.bathroom_outlined,
          text: '$bathrooms',
          iconSize: iconSize,
          textStyle: textSize,
          iconColor: palette.textMuted,
          textColor: palette.textBody,
        ),
      );
    }

    if (area != null) {
      if (features.isNotEmpty) features.add(SizedBox(width: spacing));
      features.add(
        _FeatureItem(
          icon: Icons.square_foot_outlined,
          text: '${area!.toStringAsFixed(0)} m²',
          iconSize: iconSize,
          textStyle: textSize,
          iconColor: palette.textMuted,
          textColor: palette.textBody,
        ),
      );
    }

    return Row(children: features);
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.iconSize,
    required this.textStyle,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String text;
  final double iconSize;
  final TextStyle textStyle;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor ?? context.palette.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: textStyle.copyWith(
            color: textColor ?? context.palette.textBody,
          ),
        ),
      ],
    );
  }
}
