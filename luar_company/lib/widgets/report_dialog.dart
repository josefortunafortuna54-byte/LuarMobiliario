import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/models/report_model.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/report_provider.dart';
import '../core/theme/app_palette.dart';
import '../l10n/app_localizations.dart';

/// Abre o diálogo de denúncia de um anúncio (imóvel/terreno) ou utilizador.
/// Requer sessão iniciada; caso contrário, mostra apenas um aviso.
Future<void> showReportDialog(
  BuildContext context, {
  required ReportTarget targetType,
  required String targetId,
}) {
  final isAuthenticated = context.read<AuthProvider>().user != null;

  if (!isAuthenticated) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.reportarRequerLogin),
        backgroundColor: AppColors.navy,
      ),
    );
    return Future.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReportSheet(targetType: targetType, targetId: targetId),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.targetType, required this.targetId});

  final ReportTarget targetType;
  final String targetId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _detailsController = TextEditingController();
  String? _reason;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  List<(String, String)> _reasons(AppLocalizations l10n) => [
    ('spam', l10n.motivoSpam),
    ('false_info', l10n.motivoInformacaoFalsa),
    ('inappropriate', l10n.motivoConteudoInapropriado),
    ('scam', l10n.motivoBurla),
    ('other', l10n.motivoOutro),
  ];

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final reason = _reason;
    if (reason == null || _isSubmitting) return;

    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ReportProvider>();
    final success = await provider.submitReport(
      reporterId: userId,
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: reason,
      details: _detailsController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.denunciaEnviada),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.erroEnviarDenuncia),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  size: 22,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                Text(l10n.reportarAnuncio, style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.motivo,
              style: AppTextStyles.labelMedium.copyWith(
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons(l10n).map((entry) {
                final (value, label) = entry;
                final selected = _reason == value;
                return GestureDetector(
                  onTap: () => setState(() => _reason = value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.error.withValues(alpha: 0.12)
                          : palette.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.error
                            : palette.borderStrong,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: selected ? AppColors.error : palette.textBody,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              maxLength: 500,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.detalhesOpcionais,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: palette.textMuted,
                ),
                filled: true,
                fillColor: palette.inputFill,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: palette.borderStrong),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reason == null || _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: palette.border,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        l10n.enviarDenuncia,
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: _reason == null
                              ? palette.textMuted
                              : AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
