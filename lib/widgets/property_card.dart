import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

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

  String get _badgeLabel =>
      listingType == PropertyListingType.venda ? 'Venda' : 'Arrendamento';

  Color get _badgeColor =>
      listingType == PropertyListingType.venda
          ? AppColors.gold
          : AppColors.navyLight;

  String _formatPrice(double value) {
    final parts = value.toStringAsFixed(0).split('.');
    final buffer = StringBuffer();
    for (var i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[0][i]);
    }
    return 'AOA ${buffer.toString()}';
  }

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
          color: AppColors.white,
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
            _buildImage(height: 220),
            _buildContent(),
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
          color: AppColors.white,
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
            _buildImage(width: 160),
            Expanded(child: _buildHorizontalContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({double? height, double? width}) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          width: width,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.gray200,
              child: const Icon(
                Icons.apartment_rounded,
                size: 48,
                color: AppColors.gray400,
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
              _badgeLabel,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
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
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFeaturesRow(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatPrice(price),
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
                    'Detalhes',
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

  Widget _buildHorizontalContent() {
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
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFeaturesRow(compact: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatPrice(price),
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
                    'Detalhes',
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

  Widget _buildFeaturesRow({bool compact = false}) {
    final iconSize = compact ? 14.0 : 16.0;
    final textSize =
        compact ? AppTextStyles.bodyTiny : AppTextStyles.bodySmall;
    final spacing = compact ? 6.0 : 8.0;

    final features = <Widget>[];

    if (bedrooms != null) {
      features.add(
        _FeatureItem(
          icon: Icons.king_bed_outlined,
          text: '$bedrooms',
          iconSize: iconSize,
          textStyle: textSize,
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
  });

  final IconData icon;
  final String text;
  final double iconSize;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: AppColors.gray400),
        const SizedBox(width: 4),
        Text(
          text,
          style: textStyle.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }
}
