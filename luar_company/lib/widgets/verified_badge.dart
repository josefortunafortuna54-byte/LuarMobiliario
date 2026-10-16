import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../l10n/app_localizations.dart';

/// Badge "Verificado" — só deve ser exibido quando `agent_verified` é true
/// (propagação real da verificação do anunciante, migration 018).
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: compact ? 12 : 14,
            color: AppColors.info,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            AppLocalizations.of(context).verificado,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.info,
              fontSize: compact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }
}
