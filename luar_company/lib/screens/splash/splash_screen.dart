import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../home/main_shell.dart';
import '../welcome/welcome_screen.dart';
import '../../widgets/gold_shimmer_ring.dart';
import '../../widgets/premium_splash_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Acesso livre: o utilizador entra diretamente no App sem obrigação de login.
    // Se existir sessão, restauramos o utilizador para funcionalidades autenticadas.
    try {
      final auth = context.read<AuthProvider>();
      await auth.init();
    } catch (e) {
      debugPrint('[Luar] Session restore failed: $e');
    }

    if (!mounted) return;

    // Notificação de arranque frio: salta as boas-vindas e vai direto ao destino.
    final hasPending = NotificationService().hasPendingNavigation;
    Navigator.of(context).pushReplacement(
      startupFadeRoute(
        hasPending ? const MainShell() : const WelcomeScreen(),
        RouteSettings(name: hasPending ? AppRoutes.home : AppRoutes.welcome),
      ),
    );
    if (hasPending) {
      NotificationService().consumePendingNavigation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PremiumSplashBackground(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildLogo(),
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.appName,
                            maxLines: 1,
                            style: AppTextStyles.h2White.copyWith(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.appTagline.toUpperCase(),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.goldLight,
                              letterSpacing: 3,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: AppColors.white.withValues(
                          alpha: 0.15,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.goldLight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return GoldShimmerRing(
      size: 120,
      radius: 28,
      borderWidth: 2,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.25),
              blurRadius: 48,
              spreadRadius: 6,
            ),
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'logo.png',
          fit: BoxFit.cover,
          // Fallback se o asset falhar (não quebra o arranque).
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: AppColors.navyLight,
            child: Icon(Icons.apartment_rounded, color: AppColors.gold),
          ),
        ),
      ),
    );
  }
}
