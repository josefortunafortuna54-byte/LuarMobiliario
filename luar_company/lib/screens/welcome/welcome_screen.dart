import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gold_shimmer_ring.dart';
import '../../widgets/premium_splash_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _reveal(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.horizontalPadding(context);
    final contentWidth = Responsive.contentMaxWidth(context);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PremiumSplashBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: isDesktop || isTablet
                  ? _buildWideLayout(context, padding)
                  : _buildMobileLayout(context, padding),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: _buildBrandSection(context, 136)),
          const SizedBox(width: 64),
          Expanded(flex: 1, child: _buildContentSection(context, isWide: true)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 28),
      child: Column(
        children: [
          _buildBrandSection(context, 96),
          const SizedBox(height: 28),
          _buildContentSection(context, isWide: false),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, double logoSize) {
    final l10n = AppLocalizations.of(context);

    return _Reveal(
      animation: _reveal(0.0, 0.45),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GoldShimmerRing(
            size: logoSize,
            radius: logoSize * 0.24,
            borderWidth: 2,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(logoSize * 0.24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 48,
                    spreadRadius: 4,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'logo.png',
                fit: BoxFit.cover,
                // Fallback se o asset falhar (não quebra o ecrã).
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: AppColors.navyLight,
                  child: Icon(Icons.apartment_rounded, color: AppColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.appName,
            style: AppTextStyles.h2White.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.fontSize(context, 30),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 56,
            height: 2,
            decoration: const BoxDecoration(gradient: AppColors.goldGradient),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.appTagline.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.goldLight,
              letterSpacing: 2.5,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, {required bool isWide}) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Reveal(
          animation: _reveal(0.2, 0.6),
          child: Text(
            l10n.welcomeHeadline,
            style: AppTextStyles.h3White.copyWith(
              fontSize: Responsive.fontSize(context, isWide ? 24 : 22),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 14),
        _Reveal(
          animation: _reveal(0.3, 0.7),
          child: Text(
            l10n.welcomeDesc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),
        _Reveal(
          animation: _reveal(0.4, 0.85),
          child: _buildWhyChooseSection(context),
        ),
        const SizedBox(height: 28),
        _Reveal(
          animation: _reveal(0.55, 1.0),
          child: Column(
            children: [
              CustomButton(
                text: l10n.explorarImoveis,
                isFullWidth: true,
                size: CustomButtonSize.large,
                onPressed: _goToHome,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.versao(AppConstants.appVersion),
                style: AppTextStyles.bodyTiny.copyWith(
                  color: AppColors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Secção "Por que escolher o Luar Mobiliário?" — grelha de cartões
  /// "glass" com ícone dourado (navy + gold, conforme o design system).
  Widget _buildWhyChooseSection(BuildContext context) {
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
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: Responsive.fontSize(context, 18),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final cardWidth = (constraints.maxWidth - gap) / 2;
            // Com contagem ímpar, o último cartão ocupa a largura toda.
            final lastSpansFull = features.length.isOdd;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < features.length; i++)
                  SizedBox(
                    width: i == features.length - 1 && lastSpansFull
                        ? constraints.maxWidth
                        : cardWidth,
                    child: _FeatureCard(
                      icon: features[i].icon,
                      title: features[i].title,
                      desc: features[i].desc,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _goToHome() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}

/// Secção animada de entrada (fade + slide-up) usada nas peças do welcome.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

/// Cartão "glass" de feature com ícone dourado em círculo.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.14),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.55),
                width: 1.2,
              ),
            ),
            child: Icon(icon, size: 19, color: AppColors.gold),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: AppTextStyles.bodyTiny.copyWith(
              color: AppColors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
