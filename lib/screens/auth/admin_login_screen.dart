import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
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
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _error;
  String? _maskedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '***@$domain';
    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  Future<void> _sendOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SupabaseService.client;
      final email = _emailController.text.trim();

      final response = await client
          .from(AppConstants.usersTable)
          .select('role')
          .eq('email', email)
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

      await client.auth.signInWithOtp(email: email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _otpSent = true;
        _maskedEmail = _maskEmail(email);
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Erro ao enviar código. Tente novamente.';
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SupabaseService.client;
      final email = _emailController.text.trim();
      final otp = _otpController.text.trim();

      final response = await client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (!mounted) return;

      if (response.session != null) {
        final auth = context.read<AuthProvider>();
        await auth.init();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Código inválido ou expirado';
        });
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Erro ao verificar código. Tente novamente.';
      });
    }
  }

  void _goBackToEmail() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _error = null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Insira o seu e-mail';
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'Insira o código';
    if (value.length < 6) return 'Código deve ter 6 dígitos';
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
                  if (_otpSent) _buildOtpSection() else _buildEmailSection(),
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
          _otpSent
              ? 'Código enviado para ${_maskedEmail ?? ""}'
              : 'Insira o email para receber o código de acesso',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      children: [
        Form(
          key: _emailFormKey,
          child: CustomInput(
            label: 'E-mail do administrador',
            hint: 'exemplo@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            controller: _emailController,
            validator: _validateEmail,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _sendOtp(),
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Enviar Código',
          isFullWidth: true,
          size: CustomButtonSize.large,
          isLoading: _isLoading,
          icon: Icons.send_rounded,
          onPressed: _sendOtp,
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.mark_email_read_outlined, size: 22, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verifique a sua caixa de entrada',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _otpFormKey,
          child: CustomInput(
            label: 'Código de verificação',
            hint: '000000',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            controller: _otpController,
            validator: _validateOtp,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _verifyOtp(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: Text(
              'Reenviar código',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Verificar e Entrar',
          isFullWidth: true,
          size: CustomButtonSize.large,
          isLoading: _isLoading,
          icon: Icons.verified_rounded,
          onPressed: _verifyOtp,
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _isLoading
          ? null
          : _otpSent
              ? _goBackToEmail
              : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: Text(
        _otpSent ? 'Usar outro email' : 'Voltar',
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
