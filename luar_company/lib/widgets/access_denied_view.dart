import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Ecrã de acesso recusado.
///
/// Usado pelos painéis administrativos quando o utilizador autenticado não
/// tem o role `admin`. Enquanto o ecrã restrito é substituído por este, o
/// conteúdo administrativo não é desenhado nem carregado.
class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
