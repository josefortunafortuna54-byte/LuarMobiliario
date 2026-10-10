import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/avatar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  children: [
                    _buildProfileHeader(context, user, isDesktop),
                    const SizedBox(height: 8),
                    _buildSettingsSection(context, padding: padding),
                    const SizedBox(height: 16),
                    _buildMenuSection(context, padding: padding),
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
    bool isDesktop,
  ) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: AppTextStyles.bodySmall.copyWith(color: palette.textMuted),
          ),
          if (user?.phone != null && user!.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.phone,
              style: AppTextStyles.bodySmall.copyWith(color: palette.textMuted),
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

  Widget _buildMenuSection(BuildContext context, {double padding = 16}) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final menuItems = [
      _MenuItem(
        icon: Icons.edit_outlined,
        title: l10n.editarPerfil,
        route: AppRoutes.editProfile,
      ),
      _MenuItem(
        icon: Icons.favorite_border_rounded,
        title: l10n.favoritos,
        route: AppRoutes.favorites,
      ),
      _MenuItem(
        icon: Icons.calendar_today_outlined,
        title: l10n.agendamentos,
        route: AppRoutes.bookings,
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: l10n.mensagens,
        route: AppRoutes.messages,
      ),
      _MenuItem(
        icon: Icons.handshake_outlined,
        title: l10n.parceiros,
        route: AppRoutes.partners,
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

  Widget _buildSettingsSection(BuildContext context, {double padding = 16}) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    final themeLabel = switch (themeProvider.preference) {
      ThemePreference.system => l10n.temaSistema,
      ThemePreference.light => l10n.temaClaro,
      ThemePreference.dark => l10n.temaEscuro,
    };
    final languageLabel = localeProvider.locale.languageCode == 'en'
        ? l10n.ingles
        : l10n.portugues;

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
        children: [
          _buildSettingRow(
            context,
            icon: Icons.dark_mode_outlined,
            title: l10n.aparencia,
            value: themeLabel,
            onTap: () => _showThemeSheet(context),
          ),
          Divider(height: 1, indent: 74, color: palette.border),
          _buildSettingRow(
            context,
            icon: Icons.language_outlined,
            title: l10n.idioma,
            value: languageLabel,
            onTap: () => _showLanguageSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        splashColor: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textBody,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: palette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showThemeSheet(BuildContext context) async {
    final provider = context.read<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final palette = ctx.palette;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(l10n.aparencia, style: AppTextStyles.h6),
                  ],
                ),
              ),
              _buildChoiceTile(
                context: ctx,
                palette: palette,
                label: l10n.temaSistema,
                selected: provider.preference == ThemePreference.system,
                onTap: () {
                  provider.setPreference(ThemePreference.system);
                  Navigator.pop(ctx);
                },
              ),
              _buildChoiceTile(
                context: ctx,
                palette: palette,
                label: l10n.temaClaro,
                selected: provider.preference == ThemePreference.light,
                onTap: () {
                  provider.setPreference(ThemePreference.light);
                  Navigator.pop(ctx);
                },
              ),
              _buildChoiceTile(
                context: ctx,
                palette: palette,
                label: l10n.temaEscuro,
                selected: provider.preference == ThemePreference.dark,
                onTap: () {
                  provider.setPreference(ThemePreference.dark);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final provider = context.read<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final palette = ctx.palette;
        final code = provider.locale.languageCode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [Text(l10n.idioma, style: AppTextStyles.h6)],
                ),
              ),
              _buildChoiceTile(
                context: ctx,
                palette: palette,
                label: l10n.portugues,
                selected: code == 'pt',
                onTap: () {
                  provider.setLocale(const Locale('pt'));
                  Navigator.pop(ctx);
                },
              ),
              _buildChoiceTile(
                context: ctx,
                palette: palette,
                label: l10n.ingles,
                selected: code == 'en',
                onTap: () {
                  provider.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChoiceTile({
    required BuildContext context,
    required AppPalette palette,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: palette.textBody),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.gold)
          : null,
      onTap: onTap,
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
