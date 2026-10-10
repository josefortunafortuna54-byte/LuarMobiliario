import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/providers/land_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/xfile_thumbnail.dart';

class LandFormScreen extends StatefulWidget {
  const LandFormScreen({super.key});

  @override
  State<LandFormScreen> createState() => _LandFormScreenState();
}

class _LandFormScreenState extends State<LandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  List<String> _selectedFeatures = [];
  bool _isSubmitting = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _municipalityController;
  late TextEditingController _neighborhoodController;

  String _selectedType = 'urban';
  String _selectedTransaction = 'sale';
  LandModel? _existingLand;
  bool get _isEditing => _existingLand != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
    _areaController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _municipalityController = TextEditingController();
    _neighborhoodController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final land = ModalRoute.of(context)?.settings.arguments as LandModel?;
      if (land != null) {
        setState(() => _existingLand = land);
        _titleController.text = land.title;
        _descController.text = land.description;
        _priceController.text = land.price.toStringAsFixed(0);
        _areaController.text = land.area.toStringAsFixed(0);
        _addressController.text = land.address;
        _cityController.text = land.city;
        _municipalityController.text = land.municipality;
        _neighborhoodController.text = land.neighborhood;
        setState(() {
          _selectedType = land.type.name;
          _selectedTransaction = land.transactionType.name;
          _existingImages = List.from(land.images);
          _selectedFeatures = List.from(land.features);
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _municipalityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  void _removeNewImage(int index) =>
      setState(() => _selectedImages.removeAt(index));
  void _removeExistingImage(int index) =>
      setState(() => _existingImages.removeAt(index));

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addImg), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final landProvider = context.read<LandProvider>();

      List<String> allImages = List.from(_existingImages);
      for (final file in _selectedImages) {
        try {
          final bytes = await file.readAsBytes();
          final url = await StorageService().uploadImage(
            bytes: bytes,
            fileName: file.name,
            bucket: AppConstants.propertyImagesBucket,
          );
          allImages.add(url);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.erroEnviarImagem('$e')),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      final user = auth.user;
      final land = LandModel(
        id: _existingLand?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: LandType.values.firstWhere((t) => t.name == _selectedType),
        transactionType: LandTransactionType.values.firstWhere(
          (t) => t.name == _selectedTransaction,
        ),
        price: double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0,
        area: double.tryParse(_areaController.text.replaceAll('.', '')) ?? 0,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        municipality: _municipalityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        latitude: _existingLand?.latitude ?? -8.8390,
        longitude: _existingLand?.longitude ?? 13.2891,
        images: allImages,
        features: _selectedFeatures,
        agentId: user?.id,
        agentName: user?.name ?? '',
        agentPhone: user?.phone ?? '',
        isFeatured: _existingLand?.isFeatured ?? false,
        isAvailable: true,
        createdAt: _existingLand?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await landProvider.updateLand(land);
      } else {
        success = await landProvider.createLand(land);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing ? l10n.terrenoAtualizado : l10n.terrenoCriado,
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(landProvider.error ?? l10n.erro),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditing ? l10n.editarTerreno : l10n.novoTerreno,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: _isSubmitting
          ? LoadingWidget(isFullScreen: true, message: l10n.guardando)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    Text(l10n.informacoesBasicas, style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: l10n.titulo,
                      hint: l10n.exTituloTerreno,
                      prefixIcon: Icons.title,
                      controller: _titleController,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.obrigatorio : null,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: l10n.descricao,
                      hint: l10n.descrevaTerreno,
                      prefixIcon: Icons.description_outlined,
                      controller: _descController,
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.obrigatorio : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTypeDropdown()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTransactionDropdown()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.dimensoes, style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: l10n.preco,
                            hint: '0',
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            controller: _priceController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? l10n.obrigatorio
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: l10n.areaM2,
                            hint: '0',
                            prefixIcon: Icons.square_foot_outlined,
                            keyboardType: TextInputType.number,
                            controller: _areaController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? l10n.obrigatorio
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.caracteristicas, style: AppTextStyles.h6),
                    const SizedBox(height: 12),
                    _buildFeaturesChips(),
                    const SizedBox(height: 24),
                    Text(l10n.localizacao, style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: l10n.endereco,
                      hint: l10n.ruaNumero,
                      prefixIcon: Icons.home_outlined,
                      controller: _addressController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: l10n.cidade,
                            hint: 'Luanda',
                            prefixIcon: Icons.location_city_outlined,
                            controller: _cityController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? l10n.obrigatorio
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: l10n.municipio,
                            hint: 'Talatona',
                            prefixIcon: Icons.map_outlined,
                            controller: _municipalityController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: l10n.bairro,
                      hint: 'Kilamba',
                      prefixIcon: Icons.place_outlined,
                      controller: _neighborhoodController,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: _isEditing
                          ? l10n.atualizarTerreno
                          : l10n.criarTerreno,
                      isFullWidth: true,
                      size: CustomButtonSize.large,
                      isLoading: _isSubmitting,
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.fotos, style: AppTextStyles.h6),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: Text(l10n.adicionar),
            ),
          ],
        ),
        if (_existingImages.isEmpty && _selectedImages.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.borderStrong),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: palette.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.nenhumaImagemSelecionada,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImages.asMap().entries.map(
                  (e) => _buildImageThumbnail(
                    imageUrl: e.value,
                    onRemove: () => _removeExistingImage(e.key),
                  ),
                ),
                ..._selectedImages.asMap().entries.map(
                  (e) => _buildImageThumbnail(
                    file: e.value,
                    onRemove: () => _removeNewImage(e.key),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail({
    String? imageUrl,
    XFile? file,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.palette.surfaceAlt,
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : XFileThumbnail(file: file!),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: l10n.tipo,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: palette.textSecondary,
        ),
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        filled: true,
        fillColor: palette.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
      ),
      items: [
        DropdownMenuItem(value: 'urban', child: Text(l10n.urbano)),
        DropdownMenuItem(value: 'agricultural', child: Text(l10n.agricola)),
        DropdownMenuItem(value: 'industrial', child: Text(l10n.industrial)),
        DropdownMenuItem(value: 'commercial', child: Text(l10n.comercial)),
        DropdownMenuItem(value: 'lot', child: Text(l10n.lote)),
        DropdownMenuItem(value: 'farm', child: Text(l10n.fazenda)),
      ],
      onChanged: (v) => setState(() => _selectedType = v ?? 'urban'),
    );
  }

  Widget _buildTransactionDropdown() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      initialValue: _selectedTransaction,
      decoration: InputDecoration(
        labelText: l10n.transacao,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: palette.textSecondary,
        ),
        prefixIcon: const Icon(Icons.swap_horiz, size: 20),
        filled: true,
        fillColor: palette.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
      ),
      items: [
        DropdownMenuItem(value: 'sale', child: Text(l10n.venda)),
        DropdownMenuItem(value: 'rent', child: Text(l10n.arrendamento)),
      ],
      onChanged: (v) => setState(() => _selectedTransaction = v ?? 'sale'),
    );
  }

  String _featureLabel(AppLocalizations l10n, String feature) {
    return switch (feature) {
      'Cercado' => l10n.cercado,
      'Água' => l10n.agua,
      'Eletricidade' => l10n.eletricidade,
      'Estrada Acessível' => l10n.estradaAcessivel,
      'Close à Praia' => l10n.closePraia,
      'Vista Panorâmica' => l10n.vistaPanoramica,
      'Flat' => l10n.flat,
      'Inclinação Suave' => l10n.inclinacaoSuave,
      'Solo Fértil' => l10n.soloFertil,
      'Árvore Frutífera' => l10n.arvoreFrutifera,
      'Poço' => l10n.poco,
      'Tanque de Água' => l10n.tanqueAgua,
      _ => feature,
    };
  }

  Widget _buildFeaturesChips() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    const availableFeatures = [
      'Cercado',
      'Água',
      'Eletricidade',
      'Estrada Acessível',
      'Close à Praia',
      'Vista Panorâmica',
      'Flat',
      'Inclinação Suave',
      'Solo Fértil',
      'Árvore Frutífera',
      'Poço',
      'Tanque de Água',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableFeatures.map((feature) {
        final isSelected = _selectedFeatures.contains(feature);
        return FilterChip(
          label: Text(
            _featureLabel(l10n, feature),
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.white : palette.textBody,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.gold,
          backgroundColor: palette.background,
          checkmarkColor: AppColors.white,
          side: BorderSide(
            color: isSelected ? AppColors.gold : palette.borderStrong,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFeatures.add(feature);
              } else {
                _selectedFeatures.remove(feature);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
