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
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/xfile_thumbnail.dart';
import '../videos/video_viewer_screen.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  final List<XFile> _selectedVideos = [];
  List<String> _existingVideos = [];
  List<String> _selectedFeatures = [];
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
          _existingVideos = List.from(prop.videos);
          _selectedFeatures = List.from(prop.features);
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

  Future<void> _pickVideo() async {
    final l10n = AppLocalizations.of(context);
    if (_existingVideos.length + _selectedVideos.length >=
        AppConstants.maxVideoUploads) {
      _showError(l10n.limiteVideos(AppConstants.maxVideoUploads));
      return;
    }
    try {
      final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      final size = await video.length();
      if (size > AppConstants.maxVideoSizeBytes) {
        final maxMb = AppConstants.maxVideoSizeBytes ~/ (1024 * 1024);
        _showError(l10n.videoMuitoGrande(maxMb));
        return;
      }

      if (!mounted) return;
      setState(() => _selectedVideos.add(video));
    } catch (_) {
      _showError(l10n.erroSelecionarVideo);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _removeNewImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImages.removeAt(index));
  }

  void _removeNewVideo(int index) {
    setState(() => _selectedVideos.removeAt(index));
  }

  void _removeExistingVideo(int index) {
    setState(() => _existingVideos.removeAt(index));
  }

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
      final propertyProvider = context.read<PropertyProvider>();

      List<String> allImages = List.from(_existingImages);

      for (final file in _selectedImages) {
        try {
          final bytes = await file.readAsBytes();
          final url = await StorageService().uploadImage(
            bytes: bytes,
            fileName: file.name,
            bucket: AppConstants.propertyImagesBucket,
            maxBytes: AppConstants.maxImageSizeBytes,
          );
          allImages.add(url);
        } on StorageUploadException catch (e) {
          _showError(e.message);
          return;
        } catch (e) {
          _showError(l10n.erroEnviarImagem('$e'));
          return;
        }
      }

      List<String> allVideos = List.from(_existingVideos);

      for (final file in _selectedVideos) {
        try {
          final bytes = await file.readAsBytes();
          final url = await StorageService().uploadVideo(
            bytes: bytes,
            fileName: file.name,
            bucket: AppConstants.propertyVideosBucket,
            maxBytes: AppConstants.maxVideoSizeBytes,
          );
          allVideos.add(url);
        } on StorageUploadException catch (e) {
          _showError(e.message);
          return;
        } catch (e) {
          _showError(l10n.erroEnviarVideo('$e'));
          return;
        }
      }

      final user = auth.user;
      final property = PropertyModel(
        id: _existingProperty?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: PropertyType.values.firstWhere((t) => t.name == _selectedType),
        transactionType: TransactionType.values.firstWhere(
          (t) => t.name == _selectedTransaction,
        ),
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
        videos: allVideos,
        features: _selectedFeatures,
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
              content: Text(
                _isEditing ? l10n.imovelAtualizado : l10n.imovelCriado,
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(propertyProvider.error ?? l10n.erroAoGuardar),
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
          _isEditing ? l10n.editarImovel : l10n.novoImovel,
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
                    _buildVideoSection(),
                    const SizedBox(height: 24),
                    Text(l10n.informacoesBasicas, style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: l10n.titulo,
                      hint: l10n.exTituloImovel,
                      prefixIcon: Icons.title,
                      controller: _titleController,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.obrigatorio : null,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: l10n.descricao,
                      hint: l10n.descrevaImovel,
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
                    Text(l10n.detalhes, style: AppTextStyles.h6),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: l10n.precoAOA,
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: l10n.quartosLabel,
                            hint: '0',
                            prefixIcon: Icons.king_bed_outlined,
                            keyboardType: TextInputType.number,
                            controller: _bedroomsController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: l10n.wc,
                            hint: '0',
                            prefixIcon: Icons.bathroom_outlined,
                            keyboardType: TextInputType.number,
                            controller: _bathroomsController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: l10n.garagemLabel,
                            hint: '0',
                            prefixIcon: Icons.garage_outlined,
                            keyboardType: TextInputType.number,
                            controller: _garageController,
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
                          ? l10n.atualizarImovel
                          : l10n.criarImovel,
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
              border: Border.all(
                color: palette.borderStrong,
                style: BorderStyle.solid,
              ),
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
                  (entry) => _buildImageThumbnail(
                    imageUrl: entry.value,
                    onRemove: () => _removeExistingImage(entry.key),
                  ),
                ),
                ..._selectedImages.asMap().entries.map(
                  (entry) => _buildImageThumbnail(
                    file: entry.value,
                    onRemove: () => _removeNewImage(entry.key),
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

  Widget _buildVideoSection() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final hasVideos = _existingVideos.isNotEmpty || _selectedVideos.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.videos, style: AppTextStyles.h6),
            TextButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_library_outlined, size: 20),
              label: Text(l10n.adicionarVideo),
            ),
          ],
        ),
        if (!hasVideos)
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.borderStrong),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 32,
                  color: palette.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.nenhumVideoSelecionado,
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
                ..._existingVideos.asMap().entries.map(
                  (entry) => _buildVideoThumbnail(
                    onRemove: () => _removeExistingVideo(entry.key),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoViewerScreen(
                          videos: _existingVideos,
                          initialIndex: entry.key,
                        ),
                      ),
                    ),
                  ),
                ),
                ..._selectedVideos.asMap().entries.map(
                  (entry) => _buildVideoThumbnail(
                    onRemove: () => _removeNewVideo(entry.key),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVideoThumbnail({
    required VoidCallback onRemove,
    VoidCallback? onTap,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.navy,
            ),
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 36,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
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
        DropdownMenuItem(value: 'house', child: Text(l10n.casa)),
        DropdownMenuItem(value: 'apartment', child: Text(l10n.apartamento)),
        DropdownMenuItem(value: 'office', child: Text(l10n.escritorio)),
        DropdownMenuItem(value: 'warehouse', child: Text(l10n.armazem)),
        DropdownMenuItem(value: 'condo', child: Text(l10n.condominio)),
        DropdownMenuItem(value: 'shop', child: Text(l10n.loja)),
      ],
      onChanged: (v) => setState(() => _selectedType = v ?? 'house'),
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
      'Piscina' => l10n.piscina,
      'Churrasqueira' => l10n.churrasqueira,
      'Ar Condicionado' => l10n.arCondicionado,
      'Portão Eletrónico' => l10n.portaoEletronico,
      'Segurança 24h' => l10n.seguranca24h,
      'Elevador' => l10n.elevador,
      'Varanda' => l10n.varanda,
      'Lareira' => l10n.lareira,
      'Jardim' => l10n.jardim,
      'Área de Serviço' => l10n.areaServico,
      'Despensa' => l10n.despensa,
      'Escritório' => l10n.escritorio,
      'Closet' => l10n.closet,
      'Suíte' => l10n.suite,
      'Varanda Gourmet' => l10n.varandaGourmet,
      'Condomínio Fechado' => l10n.condominioFechado,
      _ => feature,
    };
  }

  Widget _buildFeaturesChips() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    const availableFeatures = [
      'Piscina',
      'Churrasqueira',
      'Ar Condicionado',
      'Portão Eletrónico',
      'Segurança 24h',
      'Elevador',
      'Varanda',
      'Lareira',
      'Jardim',
      'Área de Serviço',
      'Despensa',
      'Escritório',
      'Closet',
      'Suíte',
      'Varanda Gourmet',
      'Condomínio Fechado',
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
