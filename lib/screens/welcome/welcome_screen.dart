import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
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
      backgroundColor: AppColors.white,
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
          Expanded(
            flex: 1,
            child: _buildHeaderSection(context, isDesktop),
          ),
          SizedBox(width: isDesktop ? 64 : 40),
          Expanded(
            flex: 1,
            child: _buildContentSection(context, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double padding, double screenHeight) {
    return Column(
      children: [
        _buildHeaderSection(context, false),
        SizedBox(height: screenHeight * 0.04),
        _buildContentSection(context, false),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isDesktop) {
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
            'Luar Mobiliario',
            style: AppTextStyles.h2White.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.fontSize(context, 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.appTagline,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
              fontSize: Responsive.fontSize(context, 15),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: 'Entrar',
            isFullWidth: true,
            size: CustomButtonSize.large,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.adminLogin);
              },
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
              label: Text(
                'Entrar como Admin',
                style: AppTextStyles.buttonLarge.copyWith(color: AppColors.navy),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                side: const BorderSide(color: AppColors.navy, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Não tem conta? ',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.register);
                },
                child: Text(
                  'Cadastre-se',
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.partnerRegister);
            },
            child: Text(
              'Quer ser parceiro? Cadastre-se',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Versão ${AppConstants.appVersion}',
            style: AppTextStyles.bodyTiny.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
