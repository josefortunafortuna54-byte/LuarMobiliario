import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      final isAgentOrAdmin =
          user?.role == UserRole.agent || user?.role == UserRole.admin;
      if (!isAgentOrAdmin && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).acessoRestritoAgentes),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<AdminProvider>().loadStats();
      context.read<AdminProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.painelAdmin,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildAnalyticsSection(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.bemVindoAdmin, style: AppTextStyles.h4White),
          const SizedBox(height: 6),
          Text(
            l10n.gestaoCompleta,
            style: AppTextStyles.bodySmall.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final l10n = AppLocalizations.of(context);
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.visaoGeral, style: AppTextStyles.h6),
              const SizedBox(height: 16),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 88,
                    ),
                children: [
                  _buildStatCard(
                    icon: Icons.apartment_rounded,
                    title: l10n.totalImoveis,
                    value: '${admin.totalProperties}',
                    color: AppColors.navy,
                  ),
                  _buildStatCard(
                    icon: Icons.landscape_rounded,
                    title: l10n.totalTerrenos,
                    value: '${admin.totalLands}',
                    color: AppColors.gold,
                  ),
                  _buildStatCard(
                    icon: Icons.people_outline_rounded,
                    title: l10n.totalUtilizadores,
                    value: '${admin.totalUsers}',
                    color: AppColors.info,
                  ),
                  _buildStatCard(
                    icon: Icons.mark_email_unread_outlined,
                    title: l10n.totalMensagens,
                    value: '${admin.totalUnreadMessages}',
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h4.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        final analytics = admin.analytics;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.analise, style: AppTextStyles.h6),
              const SizedBox(height: 16),
              if (analytics == null)
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.carregandoAnalise,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsTile(
                        icon: Icons.person_add_alt_1_outlined,
                        label: l10n.novosUtilizadores30d,
                        value: '${analytics.newUsers30d}',
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAnalyticsTile(
                        icon: Icons.event_available_outlined,
                        label: l10n.agendamentosPendentes,
                        value:
                            '${analytics.pendingBookings}/${analytics.totalBookings}',
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAnalyticsTile(
                  icon: Icons.sell_outlined,
                  label: l10n.precoMedioVenda,
                  value: formatPriceCurrency(analytics.averageSalePrice),
                  color: AppColors.navy,
                  fullWidth: true,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.porTipo,
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: palette.textTitle,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...analytics.propertiesByType.entries.map(
                      (e) => _buildTypeChip(_typeLabel(e.key), e.value),
                    ),
                    ...analytics.landsByType.entries.map(
                      (e) => _buildTypeChip(_typeLabel(e.key), e.value),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.maisVistos,
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: palette.textTitle,
                  ),
                ),
                const SizedBox(height: 8),
                if (analytics.topViewed.isEmpty)
                  Text(
                    l10n.semVisualizacoes,
                    style: AppTextStyles.bodyTiny.copyWith(
                      color: palette.textSecondary,
                    ),
                  )
                else
                  ...analytics.topViewed.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyles.bodyTiny.copyWith(
                                color: palette.textTitle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.views} ${l10n.visualizacoes}',
                            style: AppTextStyles.bodyTiny.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    final palette = context.palette;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h6.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: AppTextStyles.bodyTiny.copyWith(color: AppColors.navy),
      ),
    );
  }

  String _typeLabel(String type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case 'house':
        return l10n.casa;
      case 'apartment':
        return l10n.apartamento;
      case 'office':
        return l10n.escritorio;
      case 'warehouse':
        return l10n.armazem;
      case 'condo':
        return l10n.condominio;
      case 'shop':
        return l10n.loja;
      case 'urban':
        return l10n.urbano;
      case 'farm':
        return l10n.fazenda;
      default:
        return type.isEmpty
            ? type
            : type[0].toUpperCase() + type.substring(1);
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = <({IconData icon, String title, String route})>[
      (
        icon: Icons.add_home_work_outlined,
        title: l10n.cadastroImovel,
        route: AppRoutes.propertyForm,
      ),
      (
        icon: Icons.add_location_alt_outlined,
        title: l10n.cadastroTerreno,
        route: AppRoutes.landForm,
      ),
      (
        icon: Icons.calendar_month_outlined,
        title: l10n.agendamentos,
        route: AppRoutes.adminBookings,
      ),
      (
        icon: Icons.people_alt_outlined,
        title: l10n.verUtilizadores,
        route: AppRoutes.adminUsers,
      ),
      (
        icon: Icons.apartment_rounded,
        title: l10n.gerir,
        route: AppRoutes.adminProperties,
      ),
      (
        icon: Icons.landscape_rounded,
        title: l10n.gerirTerrenosCard,
        route: AppRoutes.adminLands,
      ),
      (
        icon: Icons.flag_outlined,
        title: l10n.denuncias,
        route: AppRoutes.adminReports,
      ),
      (
        icon: Icons.handshake_outlined,
        title: l10n.verParceiros,
        route: AppRoutes.partners,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.acoesRapidas, style: AppTextStyles.h6),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 128,
            ),
            itemCount: actions.length,
            itemBuilder: (_, index) {
              final action = actions[index];
              return _buildActionCard(
                icon: action.icon,
                title: action.title,
                onTap: () => Navigator.pushNamed(context, action.route),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppColors.gold),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
