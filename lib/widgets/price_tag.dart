import 'package:flutter/material.dart';

import '../core/constants/app_text_styles.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';

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
    final text = showCurrency ? '$formattedPrice Kz' : formattedPrice;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(text, style: _textStyle),
        if (isRent) ...[
          const SizedBox(width: 2),
          Text(
            AppLocalizations.of(context).perMes,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.palette.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
