import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/admin_repository.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final admin = context.read<AdminProvider>();
    await Future.wait([admin.loadStats(), admin.loadAnalytics()]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.read<AuthProvider>().user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.painelAdmin,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            tooltip: l10n.atualizar,
            onPressed: _loadData,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.gold,
              size: 22,
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: palette.surface,
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.contentMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(l10n),
                      if (admin.isLoading) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.gold,
                            backgroundColor: palette.surfaceAlt,
                          ),
                        ),
                      ],
                      if (admin.error != null && !admin.isLoading) ...[
                        const SizedBox(height: 16),
                        _buildErrorBanner(l10n, palette),
                      ],
                      const SizedBox(height: 24),
                      _buildStatsSection(admin, l10n, palette),
                      const SizedBox(height: 24),
                      _buildAnalyticsSection(admin, l10n, palette),
                      const SizedBox(height: 24),
                      _buildQuickActions(context, l10n, palette, isAdmin),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -36,
            child: _decorationCircle(
              140,
              AppColors.gold.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: 42,
            right: 84,
            child: _decorationCircle(
              56,
              AppColors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: -32,
            left: -44,
            child: _decorationCircle(
              120,
              AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.gold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.bemVindoAdmin, style: AppTextStyles.h4White),
                      const SizedBox(height: 6),
                      Text(
                        l10n.gestaoCompleta,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.78),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: 44,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorationCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildErrorBanner(AppLocalizations l10n, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.erroAoCarregar,
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadData,
              child: Text(
                l10n.tentarNovamente,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h6.copyWith(color: palette.textTitle)),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    AdminProvider admin,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.visaoGeral, palette),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 100,
            ),
            children: [
              _buildStatCard(
                icon: Icons.apartment_rounded,
                title: l10n.totalImoveis,
                value: '${admin.totalProperties}',
                color: AppColors.navy,
                palette: palette,
              ),
              _buildStatCard(
                icon: Icons.landscape_rounded,
                title: l10n.totalTerrenos,
                value: '${admin.totalLands}',
                color: AppColors.gold,
                palette: palette,
              ),
              _buildStatCard(
                icon: Icons.people_outline_rounded,
                title: l10n.totalUtilizadores,
                value: '${admin.totalUsers}',
                color: AppColors.info,
                palette: palette,
              ),
              _buildStatCard(
                icon: Icons.mark_email_unread_outlined,
                title: l10n.totalMensagens,
                value: '${admin.totalUnreadMessages}',
                color: AppColors.error,
                palette: palette,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required AppPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
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
              color: color.withValues(alpha: 0.12),
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
                  style: AppTextStyles.h4.copyWith(color: palette.textTitle),
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

  Widget _buildAnalyticsSection(
    AdminProvider admin,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    final analytics = admin.analytics;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.analise, palette),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: analytics != null
                ? _buildAnalyticsContent(analytics, l10n, palette)
                : (admin.error != null && !admin.isLoading)
                ? _buildInlineRetry(l10n, palette)
                : _buildAnalyticsLoading(l10n, palette),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsLoading(AppLocalizations l10n, AppPalette palette) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.carregandoAnalise,
          style: AppTextStyles.bodySmall.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInlineRetry(AppLocalizations l10n, AppPalette palette) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 20,
          color: AppColors.error,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.erroAoCarregar,
            style: AppTextStyles.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: _loadData,
          child: Text(
            l10n.tentarNovamente,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsContent(
    AdminAnalytics analytics,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetric(
                icon: Icons.person_add_alt_1_outlined,
                label: l10n.novosUtilizadores30d,
                value: '${analytics.newUsers30d}',
                color: AppColors.info,
                palette: palette,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetric(
                icon: Icons.event_available_outlined,
                label: l10n.agendamentosPendentes,
                value:
                    '${analytics.pendingBookings}/${analytics.totalBookings}',
                color: AppColors.gold,
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.09),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildMetric(
            icon: Icons.sell_outlined,
            label: l10n.precoMedioVenda,
            value: formatPriceCurrency(analytics.averageSalePrice),
            color: AppColors.gold,
            palette: palette,
            valueStyle: AppTextStyles.h6.copyWith(color: AppColors.gold),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.porTipo,
          style: AppTextStyles.bodySmallBold.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...analytics.propertiesByType.entries.map(
              (e) => _buildTypeChip(_typeLabel(e.key), e.value, palette),
            ),
            ...analytics.landsByType.entries.map(
              (e) => _buildTypeChip(_typeLabel(e.key), e.value, palette),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          l10n.maisVistos,
          style: AppTextStyles.bodySmallBold.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 10),
        if (analytics.topViewed.isEmpty)
          Text(
            l10n.semVisualizacoes,
            style: AppTextStyles.bodyTiny.copyWith(
              color: palette.textSecondary,
            ),
          )
        else
          ...analytics.topViewed.take(5).toList().asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final isTopRank = rank <= 3;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTopRank ? AppColors.gold : palette.surfaceAlt,
                      border: isTopRank
                          ? null
                          : Border.all(color: palette.border),
                    ),
                    child: Text(
                      '$rank',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 0,
                        fontSize: 11,
                        color: isTopRank
                            ? AppColors.navy
                            : palette.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: palette.textTitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.views} ${l10n.visualizacoes}',
                    style: AppTextStyles.bodyTiny.copyWith(
                      color: palette.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required AppPalette palette,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:
                    valueStyle ??
                    AppTextStyles.h6.copyWith(color: palette.textTitle),
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
    );
  }

  Widget _buildTypeChip(String label, int count, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: AppTextStyles.bodyTiny.copyWith(color: palette.textBody),
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
        return type.isEmpty ? type : type[0].toUpperCase() + type.substring(1);
    }
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    AppPalette palette,
    bool isAdmin,
  ) {
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
      if (isAdmin)
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
      if (isAdmin)
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
          _sectionTitle(l10n.acoesRapidas, palette),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 120,
            ),
            itemCount: actions.length,
            itemBuilder: (_, index) {
              final action = actions[index];
              return Material(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, action.route),
                  borderRadius: BorderRadius.circular(16),
                  highlightColor: AppColors.gold.withValues(alpha: 0.06),
                  splashColor: AppColors.gold.withValues(alpha: 0.10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.border),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            action.icon,
                            size: 20,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          action.title,
                          style: AppTextStyles.bodySmallBold.copyWith(
                            color: palette.textTitle,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
