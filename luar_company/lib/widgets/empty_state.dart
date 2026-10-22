import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/theme/app_palette.dart';
import 'custom_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  static const double _verticalPadding = 24;

  @override
  Widget build(BuildContext context) {
    // Centraliza quando o conteúdo cabe e permite scroll quando as fontes
    // do sistema são grandes demais para o ecrã (evita overflow vertical).
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentHeight = constraints.hasBoundedHeight
            ? math.max(0.0, constraints.maxHeight - _verticalPadding * 2)
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(_verticalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxContentHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: AppColors.gold),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: context.palette.textTitle,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    message!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.palette.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  CustomButton(
                    text: actionLabel!,
                    onPressed: onAction,
                    isFullWidth: false,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
