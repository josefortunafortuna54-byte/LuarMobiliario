import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/permissions.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
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
  final _passController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    final client = SupabaseService.client;
    final email = _emailController.text.trim();
    final passcode = _passController.text.trim();

    try {
      final authService = AuthService();
      final response = await authService.signInWithEmail(
        email: email,
        password: passcode,
      );

      final user = response.user;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = l10n.passeIncorreta;
        });
        return;
      }

      final profile = await client
          .from(AppConstants.usersTable)
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      final role = userRoleFromString(profile?['role'] as String?);
      if (!Permissions.canAccessAdminPanel(role)) {
        await client.auth.signOut();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = l10n.semPermissoesAdmin;
        });
        return;
      }

      final auth = context.read<AuthProvider>();
      await auth.init();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMsg;
      final msg = e.message.toLowerCase();
      if (msg.contains('not confirmed')) {
        errorMsg = l10n.prepararAcessoErro;
      } else if (msg.contains('rate limit') || msg.contains('too many')) {
        errorMsg = l10n.muitasTentativas;
      } else {
        errorMsg = l10n.passeIncorreta;
      }

      setState(() {
        _isLoading = false;
        _error = errorMsg;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = l10n.erroEntrar;
      });
    }
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) return l10n.insiraEmail;
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return l10n.emailInvalido;
    }
    return null;
  }

  String? _validatePass(String? value) {
    return Validators.adminPassword(value, l10n: AppLocalizations.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.horizontalPadding(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.surface,
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
                  _buildCredentialsSection(),
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
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 20,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Text(l10n.acessoAdmin, style: AppTextStyles.h4),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.insiraEmailPasse,
          style: AppTextStyles.bodyMedium.copyWith(
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(
                label: l10n.emailAdmin,
                hint: l10n.emailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                controller: _emailController,
                validator: _validateEmail,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: l10n.passeAcesso,
                hint: l10n.passeHint,
                prefixIcon: Icons.lock_outline_rounded,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                obscureText: true,
                controller: _passController,
                validator: _validatePass,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _login(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: l10n.entrar,
          isFullWidth: true,
          size: CustomButtonSize.large,
          isLoading: _isLoading,
          icon: Icons.login_rounded,
          onPressed: _login,
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return TextButton.icon(
      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: Text(
        l10n.voltar,
        style: AppTextStyles.bodyMedium.copyWith(color: palette.textSecondary),
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
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error,
          ),
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
