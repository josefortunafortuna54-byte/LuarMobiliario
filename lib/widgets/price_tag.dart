import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

enum PriceTagSize { small, medium, large }

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.isRent = false,
    this.size = PriceTagSize.medium,
    this.showCurrency = true,
  });

  final double price;
  final bool isRent;
  final PriceTagSize size;
  final bool showCurrency;

  String _formatPrice(double value) {
    final parts = value.toStringAsFixed(0).split('.');
    final buffer = StringBuffer();
    for (var i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[0][i]);
    }
    return buffer.toString();
  }

  TextStyle get _textStyle => switch (size) {
    PriceTagSize.small => AppTextStyles.priceSmall,
    PriceTagSize.medium => AppTextStyles.priceMedium,
    PriceTagSize.large => AppTextStyles.priceLarge,
  };

  @override
  Widget build(BuildContext context) {
    final formattedPrice = _formatPrice(price);
    final currency = showCurrency ? 'AOA ' : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$currency$formattedPrice',
          style: _textStyle,
        ),
        if (isRent) ...[
          const SizedBox(width: 2),
          Text(
            '/mês',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
