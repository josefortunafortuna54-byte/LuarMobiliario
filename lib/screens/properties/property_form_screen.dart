import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/property_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/loading_widget.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  bool _isSubmitting = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _garageController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _municipalityController;
  late TextEditingController _neighborhoodController;

  String _selectedType = 'house';
  String _selectedTransaction = 'sale';
  PropertyModel? _existingProperty;
  bool get _isEditing => _existingProperty != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
    _areaController = TextEditingController();
    _bedroomsController = TextEditingController(text: '0');
    _bathroomsController = TextEditingController(text: '0');
    _garageController = TextEditingController(text: '0');
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _municipalityController = TextEditingController();
    _neighborhoodController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prop = ModalRoute.of(context)?.settings.arguments as PropertyModel?;
      if (prop != null) {
        setState(() => _existingProperty = prop);
        _titleController.text = prop.title;
        _descController.text = prop.description;
        _priceController.text = prop.price.toStringAsFixed(0);
        _areaController.text = prop.area.toStringAsFixed(0);
        _bedroomsController.text = prop.bedrooms.toString();
        _bathroomsController.text = prop.bathrooms.toString();
        _garageController.text = prop.garage.toString();
        _addressController.text = prop.address;
        _cityController.text = prop.city;
        _municipalityController.text = prop.municipality;
        _neighborhoodController.text = prop.neighborhood;
        setState(() {
          _selectedType = prop.type.name;
          _selectedTransaction = prop.transactionType.name;
          _existingImages = List.from(prop.images);
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
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _garageController.dispose();
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

  void _removeNewImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImages.removeAt(index));
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos uma imagem'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final propertyProvider = context.read<PropertyProvider>();

      List<String> allImages = List.from(_existingImages);

      for (final file in _selectedImages) {
        try {
          final url = await StorageService().uploadImage(
            file: File(file.path),
            bucket: AppConstants.propertyImagesBucket,
          );
          allImages.add(url);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao enviar imagem: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      final user = auth.user;
      final property = PropertyModel(
        id: _existingProperty?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: PropertyType.values.firstWhere((t) => t.name == _selectedType),
        transactionType: TransactionType.values.firstWhere((t) => t.name == _selectedTransaction),
        price: double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0,
        area: double.tryParse(_areaController.text.replaceAll('.', '')) ?? 0,
        bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
        bathrooms: int.tryParse(_bathroomsController.text) ?? 0,
        garage: int.tryParse(_garageController.text) ?? 0,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        municipality: _municipalityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        latitude: _existingProperty?.latitude ?? -8.8390,
        longitude: _existingProperty?.longitude ?? 13.2891,
        images: allImages,
        features: _existingProperty?.features ?? [],
        agentId: user?.id,
        agentName: user?.name ?? '',
        agentPhone: user?.phone ?? '',
        isFeatured: _existingProperty?.isFeatured ?? false,
        isAvailable: true,
        createdAt: _existingProperty?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await propertyProvider.updateProperty(property);
      } else {
        success = await propertyProvider.createProperty(property);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Imóvel atualizado!' : 'Imóvel criado!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(propertyProvider.error ?? 'Erro ao guardar'),
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditing ? 'Editar Imóvel' : 'Novo Imóvel',
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
                      hint: 'Ex: Apartamento T3 na Talatona',
                      prefixIcon: Icons.title,
                      controller: _titleController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Descrição',
                      hint: 'Descreva o imóvel...',
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
                    Text('Detalhes', style: AppTextStyles.h6),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomInput(
                          label: 'Quartos',
                          hint: '0',
                          prefixIcon: Icons.king_bed_outlined,
                          keyboardType: TextInputType.number,
                          controller: _bedroomsController,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: CustomInput(
                          label: 'WC',
                          hint: '0',
                          prefixIcon: Icons.bathroom_outlined,
                          keyboardType: TextInputType.number,
                          controller: _bathroomsController,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: CustomInput(
                          label: 'Garagem',
                          hint: '0',
                          prefixIcon: Icons.garage_outlined,
                          keyboardType: TextInputType.number,
                          controller: _garageController,
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
                      text: _isEditing ? 'Atualizar Imóvel' : 'Criar Imóvel',
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
              border: Border.all(color: AppColors.gray200, style: BorderStyle.solid),
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
                ..._existingImages.asMap().entries.map((entry) => _buildImageThumbnail(
                  imageUrl: entry.value,
                  onRemove: () => _removeExistingImage(entry.key),
                )),
                ..._selectedImages.asMap().entries.map((entry) => _buildImageThumbnail(
                  file: File(entry.value.path),
                  onRemove: () => _removeNewImage(entry.key),
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
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.gray200,
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Image.file(file!, fit: BoxFit.cover),
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
        DropdownMenuItem(value: 'house', child: Text('Casa')),
        DropdownMenuItem(value: 'apartment', child: Text('Apartamento')),
        DropdownMenuItem(value: 'office', child: Text('Escritório')),
        DropdownMenuItem(value: 'warehouse', child: Text('Armazém')),
        DropdownMenuItem(value: 'condo', child: Text('Condomínio')),
        DropdownMenuItem(value: 'shop', child: Text('Loja')),
      ],
      onChanged: (v) => setState(() => _selectedType = v ?? 'house'),
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
