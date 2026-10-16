import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/repositories/land_repository.dart';
import '../../core/repositories/message_repository.dart';
import '../../core/repositories/property_repository.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/settings_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _roleLabel(AppLocalizations l10n, UserRole role) {
    return switch (role) {
      UserRole.admin => l10n.administrador,
      UserRole.agent => l10n.agenteImobiliario,
      UserRole.client => l10n.cliente,
    };
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.sairDaConta, style: AppTextStyles.h6),
        content: Text(l10n.temCertezaSair, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancelar,
              style: AppTextStyles.buttonMedium.copyWith(
                color: palette.textBody,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: Text(
              l10n.sair,
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
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.meuPerfil,
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

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(context, user, l10n, isDesktop),
                    const SizedBox(height: 16),
                    _ProfileStats(userId: user.id),
                    const SizedBox(height: 16),
                    _buildActions(context, padding: padding),
                    const SizedBox(height: 16),
                    _buildMenuSection(
                      context,
                      role: user.role,
                      padding: padding,
                    ),
                    const SizedBox(height: 32),
                    _buildVersionInfo(context),
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

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    final role = user?.role as UserRole? ?? UserRole.client;
    final verified = user?.verified as bool? ?? false;

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
          Text(user?.name ?? l10n.utilizador, style: AppTextStyles.h4White),
          const SizedBox(height: 6),
          Text(
            _roleLabel(l10n, role),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          if (verified) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 16,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.verificado,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (user?.email != null && user!.email.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              user.email,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, {double padding = 16}) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: l10n.editarPerfil,
              variant: CustomButtonVariant.outline,
              icon: Icons.edit_outlined,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.editProfile),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: IconButton(
              tooltip: l10n.definicoes,
              onPressed: () => showSettingsSheet(context),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.gold,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required UserRole role,
    double padding = 16,
  }) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final canManageListings =
        role == UserRole.agent || role == UserRole.admin;

    final menuItems = [
      if (canManageListings)
        _MenuItem(
          icon: Icons.home_work_outlined,
          title: l10n.meusAnuncios,
          route: AppRoutes.myListings,
        ),
      _MenuItem(
        icon: Icons.favorite_border_rounded,
        title: l10n.favoritos,
        route: AppRoutes.favorites,
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: l10n.mensagens,
        route: AppRoutes.messages,
      ),
      _MenuItem(
        icon: Icons.calendar_today_outlined,
        title: l10n.agendamentos,
        route: AppRoutes.bookings,
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: l10n.definicoes,
        onTap: (ctx) => showSettingsSheet(ctx),
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        title: l10n.sair,
        route: null,
        isDestructive: true,
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: palette.border),
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
                    } else if (item.onTap != null) {
                      item.onTap!(context);
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
                                  : palette.textBody,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: palette.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 74, color: palette.border),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n.versaoApp(AppConstants.appVersion),
      style: AppTextStyles.bodyTiny.copyWith(color: context.palette.textMuted),
    );
  }

  Widget _buildGuestState(BuildContext context, bool isDesktop) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
              l10n.dadosRegistados,
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aoAgendarFicaRegistado,
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estatísticas do perfil — apenas com dados reais da base de dados:
/// anúncios publicados, favoritos guardados e conversas de mensagens.
class _ProfileStats extends StatefulWidget {
  const _ProfileStats({required this.userId});

  final String userId;

  @override
  State<_ProfileStats> createState() => _ProfileStatsState();
}

class _ProfileStatsState extends State<_ProfileStats> {
  int? _listings;
  int? _messages;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoriteProvider>().loadFavorites(widget.userId);
    });
  }

  Future<void> _load() async {
    int listings = 0;
    int messages = 0;

    try {
      final properties = await PropertyRepository().countByAgent(widget.userId);
      final lands = await LandRepository().countByAgent(widget.userId);
      listings = properties + lands;
    } catch (_) {
      listings = 0;
    }

    try {
      final conversations = await MessageRepository()
          .fetchConversations(widget.userId);
      messages = conversations.length;
    } catch (_) {
      messages = 0;
    }

    if (!mounted) return;
    setState(() {
      _listings = listings;
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final favorites = context.watch<FavoriteProvider>().favorites.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                value: _listings,
                label: l10n.anuncios,
              ),
            ),
            Container(width: 1, height: 44, color: palette.border),
            Expanded(
              child: _StatItem(
                value: favorites,
                label: l10n.favoritos,
              ),
            ),
            Container(width: 1, height: 44, color: palette.border),
            Expanded(
              child: _StatItem(
                value: _messages,
                label: l10n.mensagens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value == null ? '—' : '$value',
          style: AppTextStyles.h5.copyWith(color: palette.textBody),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? route;
  final bool isDestructive;
  final void Function(BuildContext)? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.route,
    this.isDestructive = false,
    this.onTap,
  });
}
