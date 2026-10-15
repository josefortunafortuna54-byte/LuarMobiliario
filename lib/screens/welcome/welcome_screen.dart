import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.horizontalPadding(context);
    final screenHeight = Responsive.height(context);

    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: isDesktop || isTablet
                  ? _buildWideLayout(context, padding, screenHeight, isDesktop)
                  : _buildMobileLayout(context, padding, screenHeight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    double padding,
    double screenHeight,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildHeaderSection(context, isDesktop)),
          SizedBox(width: isDesktop ? 64 : 40),
          Expanded(flex: 1, child: _buildContentSection(context, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    double padding,
    double screenHeight,
  ) {
    return Column(
      children: [
        _buildHeaderSection(context, false),
        SizedBox(height: screenHeight * 0.04),
        _buildContentSection(context, false),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isDesktop) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final logoSize = isDesktop ? 140.0 : 120.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 80 : 64,
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('logo.png', fit: BoxFit.cover),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.appName,
            style: AppTextStyles.h2White.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.fontSize(context, 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.appTagline,
            style: AppTextStyles.bodyMedium.copyWith(
              color: palette.textMuted,
              fontSize: Responsive.fontSize(context, 15),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, bool isDesktop) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Headline do design de referência (sem alterar a cor do app).
          Text(
            l10n.welcomeHeadline,
            style: AppTextStyles.h3White.copyWith(
              fontSize: Responsive.fontSize(context, 22),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.welcomeDesc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: l10n.explorarImoveis,
            isFullWidth: true,
            size: CustomButtonSize.large,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          ),
          const SizedBox(height: 32),
          _buildWhyChooseSection(context, isDesktop),
          const SizedBox(height: 24),
          Text(
            l10n.versao(AppConstants.appVersion),
            style: AppTextStyles.bodyTiny.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }

  /// Secção "Por que escolher o Luar Mobiliário?" — lista de features com
  /// ícone dourado, replicando o layout do material de referência.
  Widget _buildWhyChooseSection(BuildContext context, bool isDesktop) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final features = <({IconData icon, String title, String desc})>[
      (
        icon: Icons.play_circle_outline_rounded,
        title: l10n.featVideosTitle,
        desc: l10n.featVideosDesc,
      ),
      (
        icon: Icons.swipe_vertical_rounded,
        title: l10n.featVerticalTitle,
        desc: l10n.featVerticalDesc,
      ),
      (
        icon: Icons.search_rounded,
        title: l10n.featSearchTitle,
        desc: l10n.featSearchDesc,
      ),
      (
        icon: Icons.map_outlined,
        title: l10n.featMapTitle,
        desc: l10n.featMapDesc,
      ),
      (
        icon: Icons.phone_outlined,
        title: l10n.featContactTitle,
        desc: l10n.featContactDesc,
      ),
      (
        icon: Icons.favorite_outline_rounded,
        title: l10n.featFavoritesTitle,
        desc: l10n.featFavoritesDesc,
      ),
      (
        icon: Icons.notifications_none_rounded,
        title: l10n.featNotificationsTitle,
        desc: l10n.featNotificationsDesc,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.whyChooseTitle,
          style: AppTextStyles.h6.copyWith(
            color: palette.textTitle,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...features.map(
          (f) => _FeatureItem(icon: f.icon, title: f.title, desc: f.desc),
        ),
      ],
    );
  }
}

/// Linha de feature com ícone em círculo dourado (design de referência),
/// reutilizando as cores atuais do app (navy + gold).
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.title, required this.desc});

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 1.5),
              color: AppColors.gold.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 22, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
