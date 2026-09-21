import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/partner_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/partner_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/loading_widget.dart';

class PartnerFormScreen extends StatefulWidget {
  const PartnerFormScreen({super.key});

  @override
  State<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends State<PartnerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _companyController;
  late TextEditingController _nifController;
  late TextEditingController _addressController;
  late TextEditingController _whatsappController;
  late TextEditingController _licenseController;
  String _selectedBusinessType = 'outro';

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController();
    _nifController = TextEditingController();
    _addressController = TextEditingController();
    _whatsappController = TextEditingController();
    _licenseController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId == null) return;

      final provider = context.read<PartnerProvider>();
      if (provider.mine == null) {
        provider.loadMine(userId).then((_) {
          if (!mounted) return;
          _populate(provider.mine);
        });
      } else {
        _populate(provider.mine);
      }
    });
  }

  void _populate(PartnerModel? partner) {
    if (partner == null) return;
    _companyController.text = partner.companyName;
    _nifController.text = partner.nif;
    _addressController.text = partner.address;
    _whatsappController.text = partner.whatsapp;
    _licenseController.text = partner.license;
    setState(() => _selectedBusinessType = partner.businessType.name);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _nifController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      _showMessage('Sessão expirada. Entre novamente.', AppColors.error);
      return;
    }

    final provider = context.read<PartnerProvider>();
    final existing = provider.mine;

    final partner = PartnerModel(
      id: existing?.id ?? '',
      userId: user.id,
      companyName: _companyController.text.trim(),
      nif: _nifController.text.trim(),
      businessType: PartnerBusinessType.values.firstWhere(
        (t) => t.name == _selectedBusinessType,
        orElse: () => PartnerBusinessType.outro,
      ),
      address: _addressController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      license: _licenseController.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);
    final success = await provider.save(partner);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showMessage(
        'Perfil de parceiro salvo com sucesso!',
        AppColors.success,
      );
      Navigator.of(context).pop();
    } else {
      _showMessage(provider.error ?? 'Erro ao guardar', AppColors.error);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil de Parceiro',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: _isSaving
          ? const LoadingWidget(isFullScreen: true, message: 'Guardando...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados da Empresa', style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Nome da Empresa',
                      hint: 'Ex: Luar Imobiliária Lda',
                      prefixIcon: Icons.business_outlined,
                      controller: _companyController,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: 'NIF',
                            hint: '123456789',
                            prefixIcon: Icons.badge_outlined,
                            controller: _nifController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBusinessTypeDropdown()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Contactos', style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Endereço',
                      hint: 'Rua, número, município...',
                      prefixIcon: Icons.place_outlined,
                      controller: _addressController,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'WhatsApp',
                      hint: '+244 9XX XXX XXX',
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                      keyboardType: TextInputType.phone,
                      controller: _whatsappController,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Licença',
                      hint: 'Número da licença de corretor (opcional)',
                      prefixIcon: Icons.fact_check_outlined,
                      controller: _licenseController,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Guardar Perfil',
                      isFullWidth: true,
                      size: CustomButtonSize.large,
                      isLoading: _isSaving,
                      onPressed: _handleSave,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBusinessType,
      decoration: InputDecoration(
        labelText: 'Tipo de Negócio',
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.gray500,
        ),
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'imobiliaria', child: Text('Imobiliária')),
        DropdownMenuItem(value: 'construtora', child: Text('Construtora')),
        DropdownMenuItem(value: 'corretor', child: Text('Corretor')),
        DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
        DropdownMenuItem(value: 'outro', child: Text('Outro')),
      ],
      onChanged: (v) => setState(() => _selectedBusinessType = v ?? 'outro'),
    );
  }
}