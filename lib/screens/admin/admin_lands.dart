import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/land_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/land_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/loading_widget.dart';

class AdminLandsScreen extends StatefulWidget {
  const AdminLandsScreen({super.key});

  @override
  State<AdminLandsScreen> createState() => _AdminLandsScreenState();
}

class _AdminLandsScreenState extends State<AdminLandsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<LandModel> _filteredLands = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      final isAgentOrAdmin =
          user?.role == UserRole.agent || user?.role == UserRole.admin;
      if (!isAgentOrAdmin && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).acessoRestritoAgentes),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<LandProvider>().loadLands();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLands(List<LandModel> lands) {
    if (_searchQuery.isEmpty) {
      _filteredLands = lands;
    } else {
      _filteredLands = lands
          .where(
            (l) =>
                l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.municipality.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  String _formatPrice(double value) {
    final parts = value.toStringAsFixed(0).split('.');
    final buffer = StringBuffer();
    for (var i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[0][i]);
    }
    return '${buffer.toString()} Kz';
  }

  Future<void> _deleteLand(LandModel land) async {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.removerTerreno, style: AppTextStyles.h6),
        content: Text(
          l10n.desejaRemoverTerreno(land.title),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancelar,
              style: AppTextStyles.buttonMedium.copyWith(
                color: palette.textBody,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.remover,
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<LandProvider>().deleteLand(land.id);
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
          l10n.gerirTerrenos,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<LandProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.lands.isEmpty) {
                  return Center(
                    child: LoadingWidget(
                      message: AppLocalizations.of(context).carregandoTerrenos,
                    ),
                  );
                }

                _filterLands(provider.lands);

                if (provider.lands.isEmpty) {
                  return _buildEmptyState();
                }

                if (_filteredLands.isEmpty) {
                  return _buildNoResults();
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadLands(),
                  color: AppColors.gold,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _filteredLands.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final land = _filteredLands[index];
                      return _buildLandTile(land);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.landForm),
        backgroundColor: AppColors.gold,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: palette.surface,
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: l10n.pesquisarTerrenos,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: palette.textMuted,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: palette.textMuted,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: palette.textMuted,
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: palette.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: palette.borderStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLandTile(LandModel land) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final imageUrl = land.images.isNotEmpty ? land.images.first : '';
    final location = [
      land.neighborhood,
      land.municipality,
    ].where((s) => s.isNotEmpty).join(', ');

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: palette.surfaceAlt,
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 32,
                          color: palette.textMuted,
                        ),
                      ),
                    )
                  : Container(
                      color: palette.surfaceAlt,
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 32,
                        color: palette.textMuted,
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    land.title,
                    style: AppTextStyles.bodyMediumBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: palette.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(land.price),
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.landForm,
                  arguments: land,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.info,
                ),
                tooltip: l10n.editar,
              ),
              IconButton(
                onPressed: () => _deleteLand(land),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                tooltip: l10n.remover,
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.landscape_rounded,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.semTerrenos,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cadastrePrimeiroTerreno,
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: palette.textMuted),
            const SizedBox(height: 16),
            Text(
              l10n.semResultados,
              style: AppTextStyles.h6.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.nenhumTerrenoBusca(_searchQuery),
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
