import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_palette.dart';
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
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
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
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.bodyTiny.copyWith(
              color: palette.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.acoesRapidas, style: AppTextStyles.h6),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_home_work_outlined,
                  title: l10n.cadastroImovel,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.propertyForm),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_location_alt_outlined,
                  title: l10n.cadastroTerreno,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.landForm),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.people_alt_outlined,
                  title: l10n.verUtilizadores,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.adminUsers),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.apartment_rounded,
                  title: l10n.gerir,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.adminProperties),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.landscape_rounded,
                  title: l10n.gerirTerrenosCard,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.adminLands),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.handshake_outlined,
                  title: l10n.verParceiros,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.partners),
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
            Text(
              title,
              style: AppTextStyles.bodySmallBold.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
