import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/comparison_provider.dart';
import '../../core/providers/discover_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/playback_provider.dart';
import '../../core/providers/review_provider.dart';
import '../../core/providers/search_provider.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/deep_links.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/navigation.dart';
import '../../core/utils/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/video_player_widget.dart';

/// Feed vertical de descoberta de imóveis (Luar Discover).
///
/// Cada página mostra um imóvel com vídeo automático (apenas na página ativa),
/// ou a primeira fotografia quando não existe vídeo. A paginação é feita a
/// partir do backend.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    this.isActive = true,
    this.onSelectTab,
  });

  /// Indica se o tab Discover está selecionado no [MainShell]. O
  /// [IndexedStack] mantém o ecrã vivo mesmo fora de vista, por isso sem
  /// este sinal o vídeo continuaria a tocar ao mudar de separador.
  final bool isActive;

  /// Seleciona um separador do [MainShell] (usado pelas tabs segmentadas do
  /// topo). Quando nulo (ecrã empurrado por rota) a navegação é por rotas.
  final ValueChanged<int>? onSelectTab;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with RouteAware {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  /// Falso quando outro ecrã é empurrado por cima desta rota (RouteAware).
  bool _routeIsCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppNavigator.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    super.didPushNext();
    if (_routeIsCurrent) setState(() => _routeIsCurrent = false);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (!_routeIsCurrent) setState(() => _routeIsCurrent = true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<DiscoverProvider>();
      if (provider.items.isEmpty && !provider.isLoading) {
        provider.load();
      }
      _loadLikeCounts(0);
      _watchConnectivity();
    });
  }

  /// Volta a carregar o feed quando a ligação regressa e o último pedido
  /// falhou (retry automático pós-offline).
  void _watchConnectivity() {
    final connectivity = context.read<ConnectivityService>();
    bool wasOffline = !connectivity.isOnline;
    connectivity.addListener(() {
      if (!mounted) return;
      final provider = context.read<DiscoverProvider>();
      final isOnline = connectivity.isOnline;
      if (wasOffline && isOnline && provider.error != null) {
        provider.refresh();
      }
      wasOffline = !isOnline;
    });
  }

  /// Pré-carrega as contagens de favoritos das próximas páginas do feed.
  void _loadLikeCounts(int index) {
    if (!mounted) return;
    final items = context.read<DiscoverProvider>().items;
    final ids = items.skip(index).take(3).map((p) => p.id).toList();
    if (ids.isEmpty) return;
    context.read<FavoriteProvider>().loadLikeCounts(ids);
    context.read<ReviewProvider>().loadCounts(ids);
  }

  @override
  void dispose() {
    AppNavigator.routeObserver.unsubscribe(this);
    _pageController.dispose();
    super.dispose();
  }

  /// O vídeo só reproduce com o tab selecionado E a rota no topo.
  bool get _screenIsActive => widget.isActive && _routeIsCurrent;

  void _onPageChanged(int index) {
    setState(() => _activeIndex = index);
    final provider = context.read<DiscoverProvider>();
    if (index >= provider.items.length - 3) {
      provider.loadMore();
    }
    _loadLikeCounts(index);
  }

  /// Navega para outro separador do shell (ou para a rota equivalente quando
  /// o Discover foi empurrado como rota independente).
  void _goToTab(int index) {
    if (index == 0) return;
    final onSelect = widget.onSelectTab;
    if (onSelect != null) {
      onSelect(index);
      return;
    }
    final route = index == 1 ? AppRoutes.search : AppRoutes.favorites;
    Navigator.of(context).pushNamed(route);
  }

  /// Abre os filtros e, ao voltar, recarrega o feed com os critérios
  /// aplicados no SearchProvider (mesma linguagem de filtros do repositório).
  Future<void> _openFilters() async {
    await Navigator.of(context).pushNamed(AppRoutes.filters);
    if (!mounted) return;
    await context.read<DiscoverProvider>().load(filters: _activeFilters());
  }

  Map<String, dynamic>? _activeFilters() {
    final search = context.read<SearchProvider>();
    final filters = <String, dynamic>{
      'type': search.propertyType,
      'transactionType': search.transactionType,
      'province': search.province,
      'city': search.city,
      'municipality': search.municipality,
      'neighborhood': search.neighborhood,
      'minPrice': search.minPrice,
      'maxPrice': search.maxPrice,
      'minArea': search.minArea,
      'maxArea': search.maxArea,
      'bedrooms': search.bedrooms,
      'bathrooms': search.bathrooms,
      'garage': search.garage,
    }..removeWhere((_, value) => value == null);
    return filters.isEmpty ? null : filters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Consumer<DiscoverProvider>(
        builder: (context, provider, _) {
          final l10n = AppLocalizations.of(context);

          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            );
          }

          if (provider.error != null && provider.items.isEmpty) {
            return _buildMessageState(
              icon: Icons.cloud_off_rounded,
              title: l10n.erro,
              subtitle: l10n.descobrirErro,
              actionLabel: l10n.tentarNovamente,
              onAction: () => provider.load(),
            );
          }

          if (provider.items.isEmpty) {
            return _buildMessageState(
              icon: Icons.video_library_outlined,
              title: l10n.descobrirVazioTitulo,
              subtitle: l10n.descobrirVazioSubtitulo,
              actionLabel: l10n.tentarNovamente,
              onAction: () => provider.load(),
            );
          }

          final items = provider.items;
          return Stack(
            children: [
              // Overscroll no topo do feed (página 0) funciona como
              // pull-to-refresh do PageView.
              NotificationListener<OverscrollNotification>(
                onNotification: (notification) {
                  if (_activeIndex == 0 &&
                      notification.overscroll < -24 &&
                      !provider.isLoading) {
                    provider.refresh();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _DiscoverPage(
                      property: items[index],
                      isActive: _screenIsActive && index == _activeIndex,
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _buildTopBar(l10n),
                ),
              ),
              _buildMediaCounter(items[_activeIndex.clamp(0, items.length - 1)]),
              if (provider.isLoadingMore)
                const Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    // Seta de voltar apenas quando o Discover foi empurrado como rota
    // independente (dentro do shell o separador é o próprio meio de saída).
    final showBack = widget.onSelectTab == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (showBack)
            _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              label: l10n.voltar,
              onTap: () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 38),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TopTab(label: l10n.descobrir, selected: true, onTap: () => _goToTab(0)),
                const SizedBox(width: 20),
                _TopTab(label: l10n.pesquisar, selected: false, onTap: () => _goToTab(1)),
                const SizedBox(width: 20),
                _TopTab(label: l10n.favoritos, selected: false, onTap: () => _goToTab(2)),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.tune_rounded,
            label: l10n.filtros,
            onTap: () => _openFilters(),
          ),
          const SizedBox(width: 6),
          _buildComparisonButton(),
        ],
      ),
    );
  }

  /// Contador de galeria do imóvel ativo (ex.: `1/5`), como no design.
  Widget _buildMediaCounter(PropertyModel property) {
    final total = property.images.length + property.videos.length;
    if (total <= 1) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 56,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '1/$total',
          style: AppTextStyles.bodyTiny.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonButton() {
    return Consumer<ComparisonProvider>(
      builder: (context, comparison, _) {
        final l10n = AppLocalizations.of(context);
        return _CircleIconButton(
          icon: Icons.compare_arrows_rounded,
          label: l10n.comparar,
          badge: comparison.isEmpty ? null : '${comparison.count}',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.comparison),
        );
      },
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      color: context.palette.background,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 12,
              child: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                label: AppLocalizations.of(context).voltar,
                onTap: () => Navigator.of(context).maybePop(),
                light: true,
              ),
            ),
            EmptyState(
              icon: icon,
              title: title,
              subtitle: subtitle,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage({required this.property, required this.isActive});

  final PropertyModel property;
  final bool isActive;

  /// Contagem compacta de likes no estilo do design (`12.4k`, `1.2M`).
  static String _compactCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoriteProvider>();
    final userId = auth.user?.id ?? '';
    final isFavorite =
        userId.isNotEmpty &&
        favorites.isFavorite(userId, propertyId: property.id);
    final likeCount = favorites.likeCount(property.id);
    final commentCount = context.watch<ReviewProvider>().countFor(property.id);

    final isRent = property.transactionType == TransactionType.rent;
    final location = [
      property.neighborhood,
      property.municipality,
      property.city,
    ].where((part) => part.isNotEmpty).join(', ');

    return Semantics(
      label: property.title,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(context),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      AppColors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 10, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildCard(
                        context,
                        l10n,
                        isRent: isRent,
                        location: location,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildRail(
                      context,
                      l10n,
                      isFavorite: isFavorite,
                      commentCount: commentCount,
                      userId: userId,
                      likeCount: likeCount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final poster = property.images.isNotEmpty ? property.images.first : null;
    final autoplay = context.watch<PlaybackProvider>().autoplay;

    if (property.videos.isNotEmpty) {
      return VideoPlayerWidget(
        key: ValueKey('discover-video-${property.id}'),
        url: property.videos.first,
        posterUrl: poster,
        autoPlay: autoplay,
        looping: true,
        isActive: isActive,
      );
    }

    final palette = context.palette;
    if (property.images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: property.images.first,
        fit: BoxFit.cover,
        memCacheWidth: 1080,
        placeholder: (_, _) => Container(
          color: palette.surfaceAlt,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, _, _) => _buildPlaceholder(context),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      alignment: Alignment.center,
      child: Icon(
        Icons.apartment_rounded,
        size: 72,
        color: AppColors.white.withValues(alpha: 0.35),
      ),
    );
  }

  /// Cartão inferior com preço, título, especificações, descrição e ação
  /// "Ver imóvel" — réplica do design de referência.
  Widget _buildCard(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isRent,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            formatPrice(property.price),
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRent) ...[
                          const SizedBox(width: 4),
                          Text(
                            l10n.perMes,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            location.isEmpty
                ? property.title
                : '${property.title} • $location',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (property.bedrooms > 0)
                _SpecItem(
                  icon: Icons.king_bed_outlined,
                  value: '${property.bedrooms}',
                  semanticsLabel: l10n.quartosLabel,
                ),
              if (property.bathrooms > 0)
                _SpecItem(
                  icon: Icons.bathroom_outlined,
                  value: '${property.bathrooms}',
                  semanticsLabel: l10n.wc,
                ),
              if (property.area > 0)
                _SpecItem(
                  icon: Icons.square_foot_outlined,
                  value: formatArea(property.area),
                  semanticsLabel: l10n.areaLabel,
                ),
            ],
          ),
          if (property.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              property.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.75),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.propertyDetail,
                arguments: property.id,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.verImovel,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rail lateral de ações (favorito com contador, partilha, contacto e
  /// detalhes), alinhado com o design de referência.
  Widget _buildRail(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isFavorite,
    required String userId,
    required int likeCount,
    required int commentCount,
  }) {
    final favorites = context.read<FavoriteProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: _compactCount(likeCount),
          semanticsLabel: l10n.favoritos,
          color: isFavorite ? AppColors.error : AppColors.white,
          onTap: userId.isEmpty
              ? null
              : () => favorites.toggleFavorite(
                  userId,
                  propertyId: property.id,
                ),
        ),
        const SizedBox(height: 16),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: _compactCount(commentCount),
          semanticsLabel: l10n.avaliacoes,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.propertyDetail,
            arguments: property.id,
          ),
        ),
        const SizedBox(height: 16),
        _ActionButton(
          icon: Icons.share_outlined,
          label: l10n.partilhar,
          onTap: () => SharePlus.instance.share(
            ShareParams(
              text:
                  '${property.title} - ${formatPrice(property.price)}\n'
                  '${DeepLinks.property(property.id)}',
            ),
          ),
        ),
      ],
    );
  }
}


/// Especificação inline (ícone + valor) do cartão do Discover.
class _SpecItem extends StatelessWidget {
  const _SpecItem({
    required this.icon,
    required this.value,
    required this.semanticsLabel,
  });

  final IconData icon;
  final String value;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticsLabel $value',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 5),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.white,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  /// Rótulo acessível quando [label] é um contador (ex.: `12.4k`).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Icon(
                  icon,
                  size: 22,
                  color: enabled
                      ? color
                      : AppColors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodyTiny.copyWith(
              color: AppColors.white.withValues(alpha: enabled ? 0.9 : 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.light = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool light;

  /// Contador opcional apresentado como balão sobre o botão.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final button = Material(
      color: light ? palette.surface : AppColors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 22,
            color: light ? palette.textTitle : AppColors.white,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      child: badge == null
          ? button
          : Stack(
              clipBehavior: Clip.none,
              children: [
                button,
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.black.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.bodyTiny.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Tab segmentada do topo (Descobrir / Pesquisar / Favoritos).
class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.6),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.gold
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
