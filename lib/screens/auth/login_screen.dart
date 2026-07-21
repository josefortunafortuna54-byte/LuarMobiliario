import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Insira o seu e-mail';
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Insira a sua senha';
    if (value.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildLogo(),
                  const SizedBox(height: 48),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(auth),
                  const SizedBox(height: 24),
                  _buildLoginButton(auth),
                  const SizedBox(height: 16),
                  _buildForgotPassword(),
                  const SizedBox(height: 32),
                  _buildPartnerLink(),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bem-vindo', style: AppTextStyles.h4),
        const SizedBox(height: 8),
        Text(
          'Entre na sua conta para continuar',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomInput(
            label: 'E-mail',
            hint: 'exemplo@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _emailController,
            validator: _validateEmail,
            enabled: !auth.isLoading,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: 'Senha',
            hint: 'Mínimo 6 caracteres',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            controller: _passwordController,
            validator: _validatePassword,
            enabled: !auth.isLoading,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthProvider auth) {
    return CustomButton(
      text: 'Entrar',
      isFullWidth: true,
      size: CustomButtonSize.large,
      isLoading: auth.isLoading,
      onPressed: _handleLogin,
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'Esqueceu a senha?',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.gray200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.gray200, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.gray200, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColors.gray100,
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Entrar com Google',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Quer ser parceiro? ',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.partnerRegister);
          },
          child: Text(
            'Cadastre-se',
            style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold),
          ),
        ),
      ],
    );
  }
}
