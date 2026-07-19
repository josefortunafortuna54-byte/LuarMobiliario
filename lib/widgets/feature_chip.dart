import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class FeatureChip extends StatelessWidget {
  const FeatureChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: foregroundColor ?? AppColors.gray500,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.bodyTiny.copyWith(
              color: foregroundColor ?? AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
