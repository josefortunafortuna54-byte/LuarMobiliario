import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/report_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/report_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  ReportStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.role != UserRole.admin && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).acessoRestritoAdmin),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<ReportProvider>().loadReports();
    });
  }

  List<ReportModel> _filtered(List<ReportModel> reports) {
    final filter = _filter;
    if (filter == null) return reports;
    return reports.where((r) => r.status == filter).toList();
  }

  String _reasonLabel(AppLocalizations l10n, String reason) => switch (reason) {
    'spam' => l10n.motivoSpam,
    'false_info' => l10n.motivoInformacaoFalsa,
    'inappropriate' => l10n.motivoConteudoInapropriado,
    'scam' => l10n.motivoBurla,
    _ => l10n.motivoOutro,
  };

  String _targetLabel(AppLocalizations l10n, ReportTarget target) =>
      switch (target) {
        ReportTarget.property => l10n.imovel,
        ReportTarget.land => l10n.terreno,
        ReportTarget.user => l10n.utilizador,
      };

  (String, Color) _statusInfo(AppLocalizations l10n, ReportStatus status) =>
      switch (status) {
        ReportStatus.pending => (l10n.pendente, AppColors.warning),
        ReportStatus.reviewing => (l10n.emAnalise, AppColors.info),
        ReportStatus.resolved => (l10n.resolvida, AppColors.success),
        ReportStatus.dismissed => (l10n.dispensada, AppColors.gray500),
      };

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReportProvider>();
    final reports = _filtered(provider.reports);

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.denuncias,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Column(
        children: [
          _buildFilters(l10n),
          Expanded(
            child: provider.isLoading && provider.reports.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  )
                : reports.isEmpty
                ? EmptyState(
                    icon: Icons.flag_outlined,
                    title: l10n.semDenuncias,
                    message: l10n.gestaoCompleta,
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<ReportProvider>().loadReports(),
                    color: AppColors.gold,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _buildReportTile(report, l10n, palette);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final options = <(ReportStatus?, String)>[
      (null, l10n.todasAsOpcoes),
      (ReportStatus.pending, l10n.pendente),
      (ReportStatus.reviewing, l10n.emAnalise),
      (ReportStatus.resolved, l10n.resolvida),
      (ReportStatus.dismissed, l10n.dispensada),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label) = options[index];
          final selected = _filter == status;
          return GestureDetector(
            onTap: () => setState(() => _filter = status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.gray300,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.buttonSmall.copyWith(
                  color: selected ? AppColors.gold : AppColors.gray600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportTile(
    ReportModel report,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    final (statusLabel, statusColor) = _statusInfo(l10n, report.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showReportSheet(report),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _reasonLabel(l10n, report.reason),
                      style: AppTextStyles.bodyMediumBold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_targetLabel(l10n, report.targetType)} · ${report.targetId}',
                style: AppTextStyles.bodyTiny.copyWith(
                  color: palette.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (report.details.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  report.details,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textBody,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: palette.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${l10n.denunciadoPor}: '
                      '${report.reporterName.isNotEmpty ? report.reporterName : '—'}',
                      style: AppTextStyles.bodyTiny.copyWith(
                        color: palette.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(report.createdAt),
                    style: AppTextStyles.bodyTiny.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportSheet(ReportModel report) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ReportActionsSheet(report: report, onChanged: () => setState(() {})),
    );
  }
}

class _ReportActionsSheet extends StatefulWidget {
  const _ReportActionsSheet({required this.report, required this.onChanged});

  final ReportModel report;
  final VoidCallback onChanged;

  @override
  State<_ReportActionsSheet> createState() => _ReportActionsSheetState();
}

class _ReportActionsSheetState extends State<_ReportActionsSheet> {
  bool _isBusy = false;

  Future<void> _run(Future<bool> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final success = await action();
    if (!mounted) return;
    setState(() => _isBusy = false);

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.acaoConcluida : l10n.erroAcaoModeracao),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
    if (success) {
      widget.onChanged();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final report = widget.report;
    final actorId = context.read<AuthProvider>().user?.id ?? '';
    final provider = context.read<ReportProvider>();
    final admin = context.read<AdminProvider>();
    final isOpen =
        report.status == ReportStatus.pending ||
        report.status == ReportStatus.reviewing;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
          Text(l10n.denuncias, style: AppTextStyles.h6),
          const SizedBox(height: 4),
          Text(
            '${_targetName(report)} · ${_formatDate(report.createdAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (_isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
            )
          else ...[
            if (isOpen) ...[
              _ActionTile(
                icon: Icons.check_circle_outline_rounded,
                label: l10n.marcarResolvida,
                color: AppColors.success,
                onTap: () => _run(
                  () => provider.updateStatus(
                    reportId: report.id,
                    status: ReportStatus.resolved,
                    reviewedById: actorId,
                    action: 'report_resolved',
                    targetType: report.targetType,
                    targetId: report.targetId,
                  ),
                ),
              ),
              _ActionTile(
                icon: Icons.cancel_outlined,
                label: l10n.dispensar,
                color: AppColors.gray500,
                onTap: () => _run(
                  () => provider.updateStatus(
                    reportId: report.id,
                    status: ReportStatus.dismissed,
                    reviewedById: actorId,
                    action: 'report_dismissed',
                    targetType: report.targetType,
                    targetId: report.targetId,
                  ),
                ),
              ),
            ],
            if (report.targetType != ReportTarget.user)
              _ActionTile(
                icon: Icons.visibility_off_outlined,
                label: l10n.ocultarAnuncio,
                color: AppColors.warning,
                onTap: () => _run(
                  () => provider.hideListing(
                    targetType: report.targetType,
                    targetId: report.targetId,
                    actorId: actorId,
                    reportId: report.id,
                  ),
                ),
              )
            else
              _ActionTile(
                icon: Icons.verified_user_outlined,
                label: l10n.verificarAnunciante,
                color: AppColors.info,
                onTap: () => _run(() async {
                  final ok = await admin.setUserVerified(
                    userId: report.targetId,
                    verified: true,
                    actorId: actorId,
                  );
                  if (!ok) return false;
                  return provider.updateStatus(
                    reportId: report.id,
                    status: ReportStatus.resolved,
                    reviewedById: actorId,
                    action: 'report_user_verified',
                    targetType: report.targetType,
                    targetId: report.targetId,
                  );
                }),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.fechar,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: palette.textBody,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _targetName(ReportModel report) => report.targetId;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
