import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../discover/discover_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

/// Estrutura principal da app autenticada.
///
/// Mantém os separadores vivos num [IndexedStack] (o estado e a posição de
/// scroll são preservados ao alternar), construindo cada ecrã apenas na
/// primeira visita para evitar pedidos desnecessários no arranque.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _tabCount = 4;
  late int _index;
  late final Set<int> _visited;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _tabCount - 1);
    _visited = {_index};
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _visited.add(index);
    });
  }

  Widget _screenFor(int index) {
    switch (index) {
      case 0:
        return DiscoverScreen(isActive: _index == 0, onSelectTab: _select);
      case 1:
        return const SearchScreen();
      case 2:
        return const FavoritesScreen();
      case 3:
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: Row(
        children: [
          if (isDesktop) _buildNavigationRail(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: List.generate(
                _tabCount,
                (i) => _visited.contains(i)
                    ? _screenFor(i)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  /// Navegação lateral para desktop — a bottom nav é escondida em ecrãs
  /// largos sem substituto, deixando o utilizador sem navegação.
  Widget _buildNavigationRail() {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.appBar,
        border: Border(right: BorderSide(color: palette.borderStrong)),
      ),
      child: SafeArea(
        child: NavigationRail(
          backgroundColor: Colors.transparent,
          selectedIndex: _index,
          onDestinationSelected: _select,
          labelType: NavigationRailLabelType.all,
          selectedIconTheme: const IconThemeData(color: AppColors.gold),
          unselectedIconTheme: IconThemeData(color: palette.textMuted),
          selectedLabelTextStyle: AppTextStyles.bodyTiny.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelTextStyle: AppTextStyles.bodyTiny.copyWith(
            color: palette.textMuted,
            fontWeight: FontWeight.w500,
          ),
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: Text(l10n.descobrir),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search_rounded),
              label: Text(l10n.pesquisar),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.favorite_outline),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: Text(l10n.favoritos),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person_rounded),
              label: Text(l10n.perfil),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.palette.appBar,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: l10n.descobrir,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: l10n.pesquisar,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite_rounded,
                label: l10n.favoritos,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: l10n.perfil,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final palette = context.palette;
    final isSelected = _index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _select(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected ? AppColors.gold : palette.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodyTiny.copyWith(
                  color: isSelected ? AppColors.gold : palette.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
