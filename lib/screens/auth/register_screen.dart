import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aceite os termos de uso para continuar'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Insira o seu nome';
    if (value.trim().length < 3) return 'Mínimo de 3 caracteres';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Insira o seu e-mail';
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Insira o seu telefone';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Insira a sua senha';
    if (value.length < 8) return 'Mínimo de 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Inclua pelo menos uma letra maiúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Inclua pelo menos um número';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirme a sua senha';
    if (value != _passwordController.text) return 'As senhas não coincidem';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(),
                      const SizedBox(height: 36),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildForm(auth),
                      const SizedBox(height: 8),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 24),
                      _buildRegisterButton(auth),
                      const SizedBox(height: 24),
                      _buildLoginLink(),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
        Text('Criar conta', style: AppTextStyles.h4),
        const SizedBox(height: 8),
        Text(
          'Preencha os dados abaixo para se cadastrar',
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
            label: 'Nome completo',
            hint: 'O seu nome completo',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            controller: _nameController,
            validator: _validateName,
            enabled: !auth.isLoading,
          ),
          const SizedBox(height: 16),
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
            label: 'Telefone',
            hint: '(00) 00000-0000',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            controller: _phoneController,
            validator: _validatePhone,
            enabled: !auth.isLoading,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: 'Senha',
            hint: 'Mínimo 8 caracteres',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            controller: _passwordController,
            validator: _validatePassword,
            enabled: !auth.isLoading,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: 'Confirmar senha',
            hint: 'Repita a sua senha',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            controller: _confirmPasswordController,
            validator: _validateConfirmPassword,
            enabled: !auth.isLoading,
            onFieldSubmitted: (_) => _handleRegister(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            activeColor: AppColors.gold,
            checkColor: AppColors.white,
            side: const BorderSide(color: AppColors.gray300, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  text: 'Li e aceito os ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                  children: [
                    TextSpan(
                      text: 'Termos de Uso',
                      style: AppTextStyles.bodySmallBold.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                    const TextSpan(text: ' e a '),
                    TextSpan(
                      text: 'Política de Privacidade',
                      style: AppTextStyles.bodySmallBold.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(AuthProvider auth) {
    return CustomButton(
      text: 'Criar Conta',
      isFullWidth: true,
      size: CustomButtonSize.large,
      isLoading: auth.isLoading,
      enabled: !auth.isLoading,
      onPressed: _handleRegister,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem conta? ',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Entrar',
            style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold),
          ),
        ),
      ],
    );
  }
}
