import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/land_repository.dart';
import '../../core/repositories/property_repository.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/price_tag.dart';

/// "Os meus anúncios" — gestão de publicações do agente/administrador.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<PropertyModel> _properties = [];
  List<LandModel> _lands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _properties = [];
          _lands = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final properties = await PropertyRepository().fetchByAgent(userId);
      final lands = await LandRepository().fetchByAgent(userId);
      if (!mounted) return;
      setState(() {
        _properties = properties;
        _lands = lands;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _properties = [];
        _lands = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleProperty(PropertyModel property) async {
    final l10n = AppLocalizations.of(context);
    final next = !property.isAvailable;
    try {
      await PropertyRepository().setAvailable(property.id, next);
      if (!mounted) return;
      setState(() {
        _properties = [
          for (final p in _properties)
            if (p.id == property.id) p.copyWith(isAvailable: next) else p,
        ];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(l10n.erroAoGuardar),
        ),
      );
    }
  }

  Future<void> _toggleLand(LandModel land) async {
    final l10n = AppLocalizations.of(context);
    final next = !land.isAvailable;
    try {
      await LandRepository().setAvailable(land.id, next);
      if (!mounted) return;
      setState(() {
        _lands = [
          for (final l in _lands)
            if (l.id == land.id) l.copyWith(isAvailable: next) else l,
        ];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(l10n.erroAoGuardar),
        ),
      );
    }
  }

  void _openCreateSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.novoAnuncio, style: AppTextStyles.h6),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: AppColors.gold,
                  ),
                ),
                title: Text(l10n.imoveis, style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed(AppRoutes.propertyForm);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.landscape_outlined,
                    color: AppColors.gold,
                  ),
                ),
                title: Text(l10n.terrenos, style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed(AppRoutes.landForm);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
          l10n.meusAnuncios,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            onPressed: _openCreateSheet,
            tooltip: l10n.novoAnuncio,
            icon: const Icon(Icons.add_rounded, color: AppColors.gold),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.buttonMedium,
          unselectedLabelStyle: AppTextStyles.buttonMedium,
          tabs: [
            Tab(text: l10n.imoveis),
            Tab(text: l10n.terrenos),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(isFullScreen: true)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPropertiesTab(l10n),
                _buildLandsTab(l10n),
              ],
            ),
    );
  }

  Widget _buildPropertiesTab(AppLocalizations l10n) {
    if (_properties.isEmpty) {
      return _EmptyListings(onCreate: _openCreateSheet, l10n: l10n);
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _properties.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final property = _properties[index];
          return _ListingRow(
            title: property.title,
            location: property.address.isNotEmpty
                ? property.address
                : property.city,
            price: property.price,
            isRent: property.transactionType.name == 'rent',
            isAvailable: property.isAvailable,
            imageUrl: property.images.isNotEmpty ? property.images.first : null,
            accentIcon: Icons.home_outlined,
            onEdit: () => Navigator.of(context).pushNamed(
              AppRoutes.propertyForm,
              arguments: property,
            ),
            onToggle: () => _toggleProperty(property),
          );
        },
      ),
    );
  }

  Widget _buildLandsTab(AppLocalizations l10n) {
    if (_lands.isEmpty) {
      return _EmptyListings(onCreate: _openCreateSheet, l10n: l10n);
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _lands.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final land = _lands[index];
          return _ListingRow(
            title: land.title,
            location: land.address.isNotEmpty ? land.address : land.city,
            price: land.price,
            isRent: land.transactionType.name == 'rent',
            isAvailable: land.isAvailable,
            imageUrl: land.images.isNotEmpty ? land.images.first : null,
            accentIcon: Icons.landscape_outlined,
            onEdit: () => Navigator.of(context).pushNamed(
              AppRoutes.landForm,
              arguments: land,
            ),
            onToggle: () => _toggleLand(land),
          );
        },
      ),
    );
  }
}

class _EmptyListings extends StatelessWidget {
  const _EmptyListings({required this.onCreate, required this.l10n});

  final VoidCallback onCreate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.home_work_outlined,
      title: l10n.semAnuncios,
      subtitle: l10n.semAnunciosSubtitulo,
      actionLabel: l10n.novoAnuncio,
      onAction: onCreate,
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.title,
    required this.location,
    required this.price,
    required this.isRent,
    required this.isAvailable,
    required this.imageUrl,
    required this.accentIcon,
    required this.onEdit,
    required this.onToggle,
  });

  final String title;
  final String location;
  final double price;
  final bool isRent;
  final bool isAvailable;
  final String? imageUrl;
  final IconData accentIcon;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Icon(accentIcon, color: AppColors.gold),
                  )
                : Icon(accentIcon, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: PriceTag(
                        price: price,
                        isRent: isRent,
                        size: PriceTagSize.small,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      isActive: isAvailable,
                      activeLabel: l10n.anuncioAtivo,
                      inactiveLabel: l10n.anuncioInativo,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert_rounded,
              size: 22,
              color: palette.textMuted,
            ),
            color: palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'toggle') {
                onToggle();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.editar,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ctx.palette.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      isAvailable
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isAvailable ? l10n.desativar : l10n.ativar,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ctx.palette.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.isActive,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  final bool isActive;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : context.palette.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? activeLabel : inactiveLabel,
            style: AppTextStyles.bodyTiny.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
