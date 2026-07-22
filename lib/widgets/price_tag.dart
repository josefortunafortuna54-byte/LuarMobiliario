import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/formatters.dart';

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

  TextStyle get _textStyle => switch (size) {
    PriceTagSize.small => AppTextStyles.priceSmall,
    PriceTagSize.medium => AppTextStyles.priceMedium,
    PriceTagSize.large => AppTextStyles.priceLarge,
  };

  @override
  Widget build(BuildContext context) {
    final formattedPrice = formatPriceRaw(price);
    final currency = showCurrency ? 'AOA ' : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$currency$formattedPrice', style: _textStyle),
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
