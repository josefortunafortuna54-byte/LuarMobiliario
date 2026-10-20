import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/saved_search_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/saved_search_provider.dart';
import '../../core/providers/search_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Lista de pesquisas guardadas do utilizador. Tocar num item repõe os
/// filtros no [SearchProvider], volta ao ecrã de pesquisa e executa a
/// pesquisa com esses filtros.
class SavedSearchesScreen extends StatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  State<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<SavedSearchesScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      context.read<SavedSearchProvider>().load(userId);
    }
  }

  /// Resumo legível dos filtros guardados (máx. 3 elementos).
  String _summary(SavedSearchModel item, AppLocalizations l10n) {
    final f = item.filters;
    final parts = <String>[
      if (f['query'] != null && (f['query'] as String).isNotEmpty)
        f['query'] as String,
      if (f['transactionType'] == 'sale') l10n.comprar,
      if (f['transactionType'] == 'rent') l10n.arrendar,
      if (f['transactionType'] == 'renew') l10n.renovar,
      if (f['propertyType'] != null) f['propertyType'] as String,
      if (f['landType'] != null) f['landType'] as String,
      if (f['province'] != null) f['province'] as String,
      if (f['municipality'] != null) f['municipality'] as String,
    ];
    final summary = parts.take(3).join(' · ');
    return summary.isEmpty ? l10n.filtros : summary;
  }

  void _apply(SavedSearchModel item) {
    final search = context.read<SearchProvider>();
    search.restoreFilters(item.filters);
    // Volta ao shell (a pesquisa fica ativa na tab) e executa a pesquisa.
    Navigator.of(context).popUntil((route) => route.isFirst);
    search.search();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final provider = context.watch<SavedSearchProvider>();
    final userId = context.watch<AuthProvider>().user?.id;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.pesquisasGuardadas,
          style: AppTextStyles.h5.copyWith(color: AppColors.white),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (userId == null) {
            return EmptyState(
              icon: Icons.bookmark_border,
              title: l10n.semPesquisasGuardadas,
              message: l10n.guardarPesquisa,
            );
          }
          if (provider.isLoading) {
            return const LoadingWidget(isFullScreen: true);
          }
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.erroAoCarregar,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: palette.textBody,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.load(userId),
                      child: Text(l10n.tentarNovamente),
                    ),
                  ],
                ),
              ),
            );
          }
          if (provider.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border,
              title: l10n.semPesquisasGuardadas,
              message: l10n.guardarPesquisa,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.items.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: palette.border),
            itemBuilder: (context, index) {
              final item = provider.items[index];
              final date = item.createdAt;
              final dateLabel =
                  '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year}';

              return ListTile(
                onTap: () => _apply(item),
                leading: const Icon(Icons.bookmark, color: AppColors.gold),
                title: Text(
                  item.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textBody,
                  ),
                ),
                subtitle: Text(
                  '${_summary(item, l10n)} · $dateLabel',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: palette.textMuted),
                  tooltip: l10n.eliminar,
                  onPressed: () => provider.remove(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
