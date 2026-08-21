import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      await auth.resetPassword(_emailController.text.trim());
      if (mounted) setState(() { _sent = true; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao enviar email. Tente novamente.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text('Recuperar Senha', style: AppTextStyles.h6.copyWith(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidth(context),
          ),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppColors.gold),
        ),
        const SizedBox(height: 24),
        Text('Esqueceu a senha?', style: AppTextStyles.h4, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Insira o seu e-mail para receber um link de recuperação.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: CustomInput(
            label: 'E-mail',
            hint: 'exemplo@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Insira o e-mail';
              if (!RegExp(AppConstants.emailRegex).hasMatch(v)) return 'E-mail inválido';
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Enviar Link',
          isFullWidth: true,
          size: CustomButtonSize.large,
          isLoading: _isLoading,
          onPressed: _handleReset,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 80),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.success),
        ),
        const SizedBox(height: 24),
        Text('E-mail Enviado!', style: AppTextStyles.h4, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Verifique a sua caixa de entrada e siga as instruções para redefinir a sua senha.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        CustomButton(
          text: 'Voltar ao Login',
          isFullWidth: true,
          size: CustomButtonSize.large,
          variant: CustomButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
