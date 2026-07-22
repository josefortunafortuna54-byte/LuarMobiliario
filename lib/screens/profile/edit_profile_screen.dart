import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/avatar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text('Editar Perfil', style: AppTextStyles.h6.copyWith(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AvatarWidget(
                    imageUrl: auth.user?.avatarUrl ?? '',
                    name: auth.user?.name ?? 'U',
                    size: AvatarSize.large,
                    borderColor: AppColors.gold,
                  ),
                  const SizedBox(height: 32),
                  CustomInput(
                    label: 'Nome Completo',
                    hint: 'O seu nome',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Insira o seu nome' : null,
                    enabled: !auth.isLoading,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: 'Telefone',
                    hint: '+244 9XX XXX XXX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    enabled: !auth.isLoading,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    label: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    controller: TextEditingController(text: auth.user?.email ?? ''),
                    enabled: false,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Guardar Alterações',
                    isFullWidth: true,
                    size: CustomButtonSize.large,
                    isLoading: auth.isLoading,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
