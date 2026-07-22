import 'dart:io';
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
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/loading_widget.dart';

class LandFormScreen extends StatefulWidget {
  const LandFormScreen({super.key});

  @override
  State<LandFormScreen> createState() => _LandFormScreenState();
}

class _LandFormScreenState extends State<LandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
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

  void _removeNewImage(int index) => setState(() => _selectedImages.removeAt(index));
  void _removeExistingImage(int index) => setState(() => _existingImages.removeAt(index));

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final landProvider = context.read<LandProvider>();

      List<String> allImages = List.from(_existingImages);
      for (final file in _selectedImages) {
        try {
          final url = await StorageService().uploadImage(
            file: File(file.path),
            bucket: AppConstants.propertyImagesBucket,
          );
          allImages.add(url);
        } catch (_) {}
      }

      final user = auth.user;
      final land = LandModel(
        id: _existingLand?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: LandType.values.firstWhere((t) => t.name == _selectedType),
        transactionType: LandTransactionType.values.firstWhere((t) => t.name == _selectedTransaction),
        price: double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0,
        area: double.tryParse(_areaController.text.replaceAll('.', '')) ?? 0,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        municipality: _municipalityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        latitude: _existingLand?.latitude ?? -8.8390,
        longitude: _existingLand?.longitude ?? 13.2891,
        images: allImages,
        features: _existingLand?.features ?? [],
        agentId: user?.id ?? '',
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
              content: Text(_isEditing ? 'Terreno atualizado!' : 'Terreno criado!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(landProvider.error ?? 'Erro'), backgroundColor: AppColors.error),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
        title: Text(
          _isEditing ? 'Editar Terreno' : 'Novo Terreno',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: _isSubmitting
          ? const LoadingWidget(isFullScreen: true, message: 'Guardando...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    Text('Informações Básicas', style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Título',
                      hint: 'Ex: Terreno Urbano na Talatona',
                      prefixIcon: Icons.title,
                      controller: _titleController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Descrição',
                      hint: 'Descreva o terreno...',
                      prefixIcon: Icons.description_outlined,
                      controller: _descController,
                      maxLines: 4,
                      validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
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
                    Text('Dimensões', style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomInput(
                          label: 'Preço (AOA)',
                          hint: '0',
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          controller: _priceController,
                          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: CustomInput(
                          label: 'Área (m²)',
                          hint: '0',
                          prefixIcon: Icons.square_foot_outlined,
                          keyboardType: TextInputType.number,
                          controller: _areaController,
                          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Localização', style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Endereço',
                      hint: 'Rua, número...',
                      prefixIcon: Icons.home_outlined,
                      controller: _addressController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomInput(
                          label: 'Cidade',
                          hint: 'Luanda',
                          prefixIcon: Icons.location_city_outlined,
                          controller: _cityController,
                          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: CustomInput(
                          label: 'Município',
                          hint: 'Talatona',
                          prefixIcon: Icons.map_outlined,
                          controller: _municipalityController,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Bairro',
                      hint: 'Kilamba',
                      prefixIcon: Icons.place_outlined,
                      controller: _neighborhoodController,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: _isEditing ? 'Atualizar Terreno' : 'Criar Terreno',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fotos', style: AppTextStyles.h6),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        if (_existingImages.isEmpty && _selectedImages.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.gray400),
                const SizedBox(height: 8),
                Text('Nenhuma imagem selecionada', style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400)),
              ],
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImages.asMap().entries.map((e) => _buildImageThumbnail(
                  imageUrl: e.value,
                  onRemove: () => _removeExistingImage(e.key),
                )),
                ..._selectedImages.asMap().entries.map((e) => _buildImageThumbnail(
                  file: File(e.value.path),
                  onRemove: () => _removeNewImage(e.key),
                )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail({String? imageUrl, File? file, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          width: 100, height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.gray200),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null ? Image.network(imageUrl, fit: BoxFit.cover) : Image.file(file!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4, right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.error),
              child: const Icon(Icons.close, size: 14, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo',
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'urban', child: Text('Urbano')),
        DropdownMenuItem(value: 'agricultural', child: Text('Agrícola')),
        DropdownMenuItem(value: 'industrial', child: Text('Industrial')),
        DropdownMenuItem(value: 'commercial', child: Text('Comercial')),
        DropdownMenuItem(value: 'lot', child: Text('Lote')),
        DropdownMenuItem(value: 'farm', child: Text('Fazenda')),
      ],
      onChanged: (v) => setState(() => _selectedType = v ?? 'urban'),
    );
  }

  Widget _buildTransactionDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedTransaction,
      decoration: InputDecoration(
        labelText: 'Transação',
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
        prefixIcon: const Icon(Icons.swap_horiz, size: 20),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'sale', child: Text('Venda')),
        DropdownMenuItem(value: 'rent', child: Text('Arrendamento')),
      ],
      onChanged: (v) => setState(() => _selectedTransaction = v ?? 'sale'),
    );
  }
}
