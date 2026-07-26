import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../widgets/avatar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sair da Conta', style: AppTextStyles.h6),
        content: Text(
          'Tem certeza que deseja sair?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: Text(
              'Sair',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Meu Perfil',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;

          if (user == null) {
            return _buildGuestState(context, isDesktop);
          }

          final isAgentOrAdmin = user.role == UserRole.agent || user.role == UserRole.admin;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(user, isDesktop),
                    const SizedBox(height: 8),
                    _buildMenuSection(context, isAgentOrAdmin: isAgentOrAdmin, padding: padding),
                    const SizedBox(height: 32),
                    _buildVersionInfo(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isDesktop) {

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 48 : 40),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          AvatarWidget(
            imageUrl: user?.avatarUrl ?? '',
            name: user?.name ?? 'U',
            size: AvatarSize.large,
            borderColor: AppColors.gold,
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? 'Utilizador', style: AppTextStyles.h4White),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          ),
          if (user?.phone != null && user!.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.phone,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              (user?.role?.name ?? 'client').toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.gold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, {required bool isAgentOrAdmin, double padding = 16}) {
    final menuItems = [
      _MenuItem(
        icon: Icons.edit_outlined,
        title: 'Editar Perfil',
        route: AppRoutes.editProfile,
      ),
      if (isAgentOrAdmin)
        _MenuItem(
          icon: Icons.home_outlined,
          title: 'Meus Imóveis',
          route: AppRoutes.adminProperties,
        ),
      _MenuItem(
        icon: Icons.favorite_border_rounded,
        title: 'Favoritos',
        route: AppRoutes.favorites,
      ),
      _MenuItem(
        icon: Icons.calendar_today_outlined,
        title: 'Agendamentos',
        route: AppRoutes.bookings,
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Mensagens',
        route: AppRoutes.messages,
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        title: 'Sair',
        route: null,
        isDestructive: true,
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (item.isDestructive) {
                      _showSignOutDialog(context);
                    } else if (item.route != null) {
                      Navigator.of(context).pushNamed(item.route!);
                    }
                  },
                  highlightColor: AppColors.gold.withValues(alpha: 0.05),
                  splashColor: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.isDestructive
                                ? AppColors.error.withValues(alpha: 0.08)
                                : AppColors.gold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: item.isDestructive
                                ? AppColors.error
                                : AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: item.isDestructive
                                  ? AppColors.error
                                  : AppColors.gray800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: AppColors.gray300,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 74, color: AppColors.gray100),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Versão ${AppConstants.appVersion}',
      style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray400),
    );
  }

  Widget _buildGuestState(BuildContext context, bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo!',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie uma conta para gerenciar seus imóveis, favoritos e agendamentos.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.register);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Criar Conta',
                  style: AppTextStyles.buttonMedium.copyWith(color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.navy, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Já tenho conta',
                  style: AppTextStyles.buttonMedium.copyWith(color: AppColors.navy),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? route;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.route,
    this.isDestructive = false,
  });
}
