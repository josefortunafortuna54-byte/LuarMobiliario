import 'package:flutter/material.dart';

import '../core/constants/app_text_styles.dart';
import '../core/theme/app_palette.dart';

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
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: foregroundColor ?? palette.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.bodyTiny.copyWith(
              color: foregroundColor ?? palette.textBody,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
