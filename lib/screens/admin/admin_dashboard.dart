import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/routes.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Painel Admin',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.gold,
            ),
          ),
        ],
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
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Text('Bem-vindo, Admin', style: AppTextStyles.h4White),
          const SizedBox(height: 6),
          Text(
            'Gestão completa da sua imobiliária',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visão Geral', style: AppTextStyles.h6),
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
                title: 'Total Imóveis',
                value: '24',
                color: AppColors.navy,
              ),
              _buildStatCard(
                icon: Icons.landscape_rounded,
                title: 'Total Terrenos',
                value: '12',
                color: AppColors.gold,
              ),
              _buildStatCard(
                icon: Icons.people_outline_rounded,
                title: 'Total Utilizadores',
                value: '156',
                color: AppColors.info,
              ),
              _buildStatCard(
                icon: Icons.mark_email_unread_outlined,
                title: 'Mensagens Não Lidas',
                value: '8',
                color: AppColors.error,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ações Rápidas', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_home_work_outlined,
                  title: 'Cadastrar\nImóvel',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_location_alt_outlined,
                  title: 'Cadastrar\nTerreno',
                  onTap: () {},
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
                  title: 'Ver\nUtilizadores',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.adminUsers);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.mail_outline_rounded,
                  title: 'Ver\nMensagens',
                  onTap: () {},
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

  Widget _buildRecentActivity() {
    final activities = [
      _ActivityItem(
        icon: Icons.add_home_work_outlined,
        title: 'Novo imóvel cadastrado',
        subtitle: 'Apartamento T3 - Luanda Sul',
        time: '2min atrás',
        color: AppColors.success,
      ),
      _ActivityItem(
        icon: Icons.person_add_outlined,
        title: 'Novo utilizador registado',
        subtitle: 'ana.ferreira@email.com',
        time: '15min atrás',
        color: AppColors.info,
      ),
      _ActivityItem(
        icon: Icons.calendar_today_outlined,
        title: 'Agendamento confirmado',
        subtitle: 'Casa T4 - Talatona',
        time: '1h atrás',
        color: AppColors.gold,
      ),
      _ActivityItem(
        icon: Icons.mail_outline_rounded,
        title: 'Nova mensagem recebida',
        subtitle: 'Carlos Mendes - Dúvida sobre imóvel',
        time: '2h atrás',
        color: AppColors.navy,
      ),
      _ActivityItem(
        icon: Icons.favorite_border_rounded,
        title: 'Imóvel favoritado',
        subtitle: 'Cobertura T5 - Miramar',
        time: '3h atrás',
        color: AppColors.error,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Atividade Recente', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(activities.length, (index) {
                final activity = activities[index];
                final isLast = index == activities.length - 1;
                return _buildActivityTile(activity, isLast);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(_ActivityItem activity, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, size: 18, color: activity.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}
