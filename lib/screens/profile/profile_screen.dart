import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
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

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 8),
                _buildMenuSection(context),
                const SizedBox(height: 32),
                _buildVersionInfo(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
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

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      _MenuItem(icon: Icons.home_outlined, title: 'Meus Imóveis', route: null),
      _MenuItem(
        icon: Icons.favorite_border_rounded,
        title: 'Favoritos',
        route: null,
      ),
      _MenuItem(
        icon: Icons.calendar_today_outlined,
        title: 'Agendamentos',
        route: null,
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Mensagens',
        route: null,
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: 'Configurações',
        route: null,
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        title: 'Sair',
        route: null,
        isDestructive: true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
