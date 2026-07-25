import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SupabaseService.client;
      final response = await client
          .from(AppConstants.usersTable)
          .select('role')
          .eq('email', _emailController.text.trim())
          .maybeSingle();

      if (!mounted) return;

      if (response == null) {
        setState(() {
          _isLoading = false;
          _error = 'Email não encontrado';
        });
        return;
      }

      final role = response['role'] as String? ?? 'client';
      if (role != 'admin' && role != 'agent') {
        setState(() {
          _isLoading = false;
          _error = 'Sem permissões de administrador';
        });
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.login,
        arguments: _emailController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Erro ao verificar email. Tente novamente.';
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Insira o seu e-mail';
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDesktop || isTablet) ...[
                    _buildLogo(isDesktop: isDesktop),
                    const SizedBox(height: 40),
                  ],
                  if (!isDesktop && !isTablet) ...[
                    _buildLogo(isDesktop: false),
                    const SizedBox(height: 48),
                  ],
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildAdminButton(),
                  const SizedBox(height: 16),
                  _buildBackButton(),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    _buildError(),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({required bool isDesktop}) {
    final size = isDesktop ? 90.0 : 72.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('logo.png', fit: BoxFit.cover),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                size: 20,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Acesso Admin',
              style: AppTextStyles.h4,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Insira o email cadastrado para verificar permissões',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: CustomInput(
        label: 'E-mail do administrador',
        hint: 'exemplo@email.com',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        controller: _emailController,
        validator: _validateEmail,
        enabled: !_isLoading,
        onFieldSubmitted: (_) => _handleAdminLogin(),
      ),
    );
  }

  Widget _buildAdminButton() {
    return CustomButton(
      text: 'Verificar e Entrar',
      isFullWidth: true,
      size: CustomButtonSize.large,
      isLoading: _isLoading,
      icon: Icons.arrow_forward_rounded,
      onPressed: _handleAdminLogin,
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _isLoading
          ? null
          : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: Text(
        'Voltar',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
