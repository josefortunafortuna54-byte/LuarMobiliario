import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/comparison_entry.dart';
import '../../core/providers/comparison_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';

/// Ecrã de comparação de imóveis (Luar Compare).
///
/// Apresenta até 3 imóveis lado a lado, permitindo comparar preço,
/// área, características e preço por metro quadrado. Destaca o imóvel
/// mais barato, com maior área e melhor relação qualidade/preço.
class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Consumer<ComparisonProvider>(
          builder: (_, provider, _) {
            return Text(
              '${AppLocalizations.of(context).comparar} (${provider.count})',
              style: AppTextStyles.h5.copyWith(color: AppColors.white),
            );
          },
        ),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<ComparisonProvider>(
            builder: (_, provider, _) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearDialog(context, provider),
                child: Text(
                  AppLocalizations.of(context).limparTudo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidth(context),
          ),
          child: Consumer<ComparisonProvider>(
            builder: (context, provider, _) {
              if (provider.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildComparisonView(context, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.compare_arrows_rounded,
      title: l10n.comparacaoVaziaTitulo,
      message: l10n.comparacaoVaziaSubtitulo,
      actionLabel: l10n.explorarImoveis,
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.discover),
    );
  }

  Widget _buildComparisonView(
    BuildContext context,
    ComparisonProvider provider,
  ) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final items = provider.items;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHighlights(context, provider),
          const SizedBox(height: 20),
          _buildComparisonTable(context, items, provider),
          const SizedBox(height: 20),
          _buildImagesSection(context, items),
          const SizedBox(height: 20),
          _buildLocationSection(context, items),
          const SizedBox(height: 20),
          _buildFeaturesSection(context, items, l10n),
          const SizedBox(height: 20),
          _buildActionsSection(context, items, l10n, palette),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHighlights(BuildContext context, ComparisonProvider provider) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    if (provider.count < 2) return const SizedBox.shrink();

    final cheapest = provider.cheapest;
    final largest = provider.largest;
    final bestValue = provider.bestValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.destaques,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (cheapest != null)
              Expanded(
                child: _HighlightCard(
                  icon: Icons.savings_outlined,
                  iconColor: AppColors.gold,
                  label: l10n.maisBarato,
                  value: truncateText(cheapest.title, 20),
                ),
              ),
            if (largest != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _HighlightCard(
                  icon: Icons.square_foot_outlined,
                  iconColor: AppColors.navyLight,
                  label: l10n.maiorArea,
                  value: truncateText(largest.title, 20),
                ),
              ),
            ],
            if (bestValue != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _HighlightCard(
                  icon: Icons.trending_down_rounded,
                  iconColor: Colors.green,
                  label: l10n.melhorValor,
                  value: truncateText(bestValue.title, 20),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    List<ComparisonEntry> items,
    ComparisonProvider provider,
  ) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(context, items),
          _buildTableRow(
            context,
            label: l10n.preco,
            values: items.map((e) => formatPrice(e.price)).toList(),
            highlight: _bestIndex(items, (e) => -e.price),
          ),
          _buildTableRow(
            context,
            label: l10n.areaM2,
            values: items.map((e) => formatArea(e.area)).toList(),
            highlight: _bestIndex(items, (e) => e.area),
          ),
          _buildTableRow(
            context,
            label: l10n.precoPorM2,
            values: items.map((e) {
              final ppm = ComparisonProvider.pricePerSquareMeter(e);
              return ppm != null ? formatPrice(ppm) : '—';
            }).toList(),
            highlight: _bestIndex(items, (e) {
              final ppm = ComparisonProvider.pricePerSquareMeter(e);
              return ppm != null ? -ppm : double.infinity;
            }),
          ),
          _buildTableRow(
            context,
            label: l10n.tipo,
            values: items.map((e) => _categoryLabel(e.category, l10n)).toList(),
          ),
          _buildTableRow(
            context,
            label: l10n.transacao,
            values: items
                .map((e) => _transactionLabel(e.transactionName, l10n))
                .toList(),
          ),
          _buildTableRow(
            context,
            label: l10n.quartosLabel,
            values: items.map((e) => e.bedrooms?.toString() ?? '—').toList(),
            highlight: _bestIndex(items, (e) => (e.bedrooms ?? 0).toDouble()),
          ),
          _buildTableRow(
            context,
            label: l10n.casasDeBanhoLabel,
            values: items.map((e) => e.bathrooms?.toString() ?? '—').toList(),
            highlight: _bestIndex(items, (e) => (e.bathrooms ?? 0).toDouble()),
          ),
          _buildTableRow(
            context,
            label: l10n.garagemLabel,
            values: items.map((e) => e.garage?.toString() ?? '—').toList(),
            highlight: _bestIndex(items, (e) => (e.garage ?? 0).toDouble()),
          ),
        ],
      ),
    );
  }

  int? _bestIndex(
    List<ComparisonEntry> items,
    double Function(ComparisonEntry) score,
  ) {
    if (items.length < 2) return null;
    int best = 0;
    double bestScore = score(items[0]);
    for (var i = 1; i < items.length; i++) {
      final s = score(items[i]);
      if (s > bestScore) {
        bestScore = s;
        best = i;
      }
    }
    return best;
  }

  Widget _buildTableHeader(BuildContext context, List<ComparisonEntry> items) {
    final palette = context.palette;
    return Container(
      color: AppColors.navy.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '',
              style: AppTextStyles.labelMedium.copyWith(
                color: palette.textMuted,
              ),
            ),
          ),
          ...items.map(
            (p) => Expanded(
              child: Center(
                child: Text(
                  truncateText(p.title, 16),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: palette.textTitle,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context, {
    required String label,
    required List<String> values,
    int? highlight,
  }) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: palette.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...values.asMap().entries.map(
            (entry) => Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: entry.key == highlight
                      ? BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        )
                      : null,
                  child: Text(
                    entry.value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: entry.key == highlight
                          ? AppColors.gold
                          : palette.textBody,
                      fontWeight: entry.key == highlight
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(
    BuildContext context,
    List<ComparisonEntry> items,
  ) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).imagens,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        Row(
          children: items
              .map(
                (p) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(_detailRoute(p), arguments: p.id),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: p.images.isNotEmpty
                            ? Image.network(
                                p.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    size: 36,
                                    color: palette.textMuted,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.apartment_rounded,
                                  size: 36,
                                  color: palette.textMuted,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    List<ComparisonEntry> items,
  ) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.localizacao,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      p.neighborhood,
                      p.municipality,
                      p.city,
                    ].where((s) => s.isNotEmpty).join(', '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textBody,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    List<ComparisonEntry> items,
    AppLocalizations l10n,
  ) {
    final palette = context.palette;

    // Reunir todas as características únicas
    final allFeatures = <String>{};
    for (final p in items) {
      allFeatures.addAll(p.features);
    }

    if (allFeatures.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.caracteristicas,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allFeatures.map((feature) {
            final hasInAll = items.every((p) => p.features.contains(feature));
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasInAll
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : palette.border,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasInAll
                      ? AppColors.gold.withValues(alpha: 0.4)
                      : palette.borderStrong,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasInAll
                        ? Icons.check_circle_rounded
                        : Icons.remove_circle_outline_rounded,
                    size: 14,
                    color: hasInAll ? AppColors.gold : palette.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    feature,
                    style: AppTextStyles.bodyTiny.copyWith(
                      color: hasInAll ? palette.textTitle : palette.textMuted,
                      fontWeight: hasInAll ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    List<ComparisonEntry> items,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.acoes,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    truncateText(p.title, 24),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textBody,
                    ),
                  ),
                ),
                _SmallActionButton(
                  icon: Icons.info_outline_rounded,
                  label: l10n.detalhes,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(_detailRoute(p), arguments: p.id),
                ),
                const SizedBox(width: 8),
                _SmallActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.remover,
                  color: Colors.red,
                  onTap: () {
                    context.read<ComparisonProvider>().remove(p.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context, ComparisonProvider provider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.limparComparacao),
        content: Text(l10n.limparComparacaoConfirmacao),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () {
              provider.clear();
              Navigator.of(ctx).pop();
            },
            child: Text(
              l10n.limparTudo,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _detailRoute(ComparisonEntry entry) =>
      entry.isLand ? AppRoutes.landDetail : AppRoutes.propertyDetail;

  String _transactionLabel(String name, AppLocalizations l10n) {
    return switch (name) {
      'rent' => l10n.arrendamento,
      'renew' => l10n.renovar,
      _ => l10n.venda,
    };
  }

  String _categoryLabel(ComparisonCategory category, AppLocalizations l10n) {
    return switch (category) {
      ComparisonCategory.house => l10n.casas,
      ComparisonCategory.apartment => l10n.apartamentos,
      ComparisonCategory.office => l10n.escritorio,
      ComparisonCategory.warehouse => l10n.armazens,
      ComparisonCategory.condo => l10n.condominio,
      ComparisonCategory.shop => l10n.loja,
      ComparisonCategory.urbanLand => l10n.urbano,
      ComparisonCategory.agriculturalLand => l10n.agricola,
      ComparisonCategory.industrialLand => l10n.industrial,
      ComparisonCategory.commercialLand => l10n.comercial,
      ComparisonCategory.lot => l10n.lote,
      ComparisonCategory.farm => l10n.fazenda,
    };
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodyTiny.copyWith(
              color: palette.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: palette.textTitle,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.navy;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: btnColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: btnColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: btnColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodyTiny.copyWith(
                color: btnColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
