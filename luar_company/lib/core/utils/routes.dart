import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/welcome/welcome_screen.dart';
import '../../screens/auth/admin_login_screen.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/discover/discover_screen.dart';
import '../../screens/comparison/comparison_screen.dart';
import '../../screens/search/filters_screen.dart';
import '../../screens/search/saved_searches_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/properties/properties_screen.dart';
import '../../screens/properties/property_detail_screen.dart';
import '../../screens/lands/lands_screen.dart';
import '../../screens/lands/land_detail_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/messages/messages_screen.dart';
import '../../screens/profile/my_listings_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/bookings/bookings_screen.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/admin/admin_properties.dart';
import '../../screens/admin/admin_users.dart';
import '../../screens/admin/admin_lands.dart';
import '../../screens/admin/admin_bookings.dart';
import '../../screens/admin/admin_reports.dart';
import '../../screens/messages/chat_screen.dart';
import '../../screens/properties/property_form_screen.dart';
import '../../screens/lands/land_form_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/partners/partners_screen.dart';
import '../../screens/partners/partner_form_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String adminLogin = '/admin-login';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String comparison = '/comparison';
  static const String search = '/search';
  static const String filters = '/filters';
  static const String savedSearches = '/saved-searches';
  static const String properties = '/properties';
  static const String propertyDetail = '/properties/:id';
  static const String lands = '/lands';
  static const String landDetail = '/lands/:id';
  static const String favorites = '/favorites';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProperties = '/admin/properties';
  static const String adminLands = '/admin/lands';
  static const String adminUsers = '/admin/users';
  static const String adminBookings = '/admin/bookings';
  static const String adminReports = '/admin/reports';
  static const String chat = '/chat';
  static const String propertyForm = '/property-form';
  static const String landForm = '/land-form';
  static const String editProfile = '/edit-profile';
  static const String myListings = '/my-listings';
  static const String partners = '/partners';
  static const String partnerForm = '/partner-form';

  /// Rotas estáticas que uma notificação pode abrir (allowlist fechada).
  /// Exclui splash/welcome/adminLogin e formulários: um payload não
  /// confiável não pode empurrar o utilizador para ecrãs de escrita nem
  /// para o arranque. As rotas de admin ficam porque os ecrãs de gestão
  /// já aplicam as suas próprias guardas de função.
  static const Set<String> _notificationRoutes = {
    home,
    discover,
    comparison,
    search,
    properties,
    lands,
    favorites,
    messages,
    profile,
    bookings,
    adminProperties,
    adminLands,
    adminUsers,
    adminBookings,
    adminReports,
    chat,
    editProfile,
    partners,
  };

  /// Valida um payload de rota vindo de uma notificação (FCM ou notificação
  /// local) contra as rotas conhecidas da app.
  ///
  /// Devolve o nome da rota e os arguments a passar (o id, no caso das rotas
  /// de detalhe), ou `null` se o payload não for seguro/conhecido.
  static ({String name, Object? arguments})? parse(String? route) {
    if (route == null || route.isEmpty) return null;

    final path = Uri.tryParse(route)?.path ?? '';
    if (path.isEmpty || !path.startsWith('/')) return null;

    if (_notificationRoutes.contains(path)) {
      return (name: path, arguments: null);
    }

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length == 2) {
      final id = segments[1];
      if (id.isEmpty || id.contains('/') || id.contains(':')) return null;
      if (segments[0] == 'properties') {
        return (name: propertyDetail, arguments: id);
      }
      if (segments[0] == 'lands') {
        return (name: landDetail, arguments: id);
      }
    }

    return null;
  }
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? '';

  if (name.startsWith('/properties/') && name != AppRoutes.properties) {
    return _buildRoute(
      const PropertyDetailScreen(),
      settings,
      arguments: settings.arguments ?? _idFromPath(name, 'properties'),
    );
  }

  if (name.startsWith('/lands/') && name != AppRoutes.lands) {
    return _buildRoute(
      const LandDetailScreen(),
      settings,
      arguments: settings.arguments ?? _idFromPath(name, 'lands'),
    );
  }

  switch (name) {
    case AppRoutes.splash:
      return _buildRoute(const SplashScreen(), settings);

    case AppRoutes.welcome:
      return _buildRoute(const WelcomeScreen(), settings);

    case AppRoutes.adminLogin:
      return _buildRoute(const AdminLoginScreen(), settings);

    case AppRoutes.home:
      return _buildRoute(const MainShell(), settings);

    case AppRoutes.discover:
      return _buildRoute(const DiscoverScreen(), settings);

    case AppRoutes.comparison:
      return _buildRoute(const ComparisonScreen(), settings);

    case AppRoutes.search:
      return _buildRoute(const SearchScreen(), settings);

    case AppRoutes.filters:
      return _buildRoute(const FiltersScreen(), settings);

    case AppRoutes.savedSearches:
      return _buildRoute(const SavedSearchesScreen(), settings);

    case AppRoutes.properties:
      return _buildRoute(const PropertiesScreen(), settings);

    case AppRoutes.lands:
      return _buildRoute(const LandsScreen(), settings);

    case AppRoutes.favorites:
      return _buildRoute(const FavoritesScreen(), settings);

    case AppRoutes.messages:
      return _buildRoute(const MessagesScreen(), settings);

    case AppRoutes.profile:
      return _buildRoute(const ProfileScreen(), settings);

    case AppRoutes.bookings:
      return _buildRoute(const BookingsScreen(), settings);

    case AppRoutes.adminDashboard:
      return _buildRoute(const AdminDashboard(), settings);

    case AppRoutes.adminProperties:
      return _buildRoute(const AdminPropertiesScreen(), settings);

    case AppRoutes.adminLands:
      return _buildRoute(const AdminLandsScreen(), settings);

    case AppRoutes.adminUsers:
      return _buildRoute(const AdminUsersScreen(), settings);

    case AppRoutes.adminBookings:
      return _buildRoute(const AdminBookingsScreen(), settings);

    case AppRoutes.adminReports:
      return _buildRoute(const AdminReportsScreen(), settings);

    case AppRoutes.chat:
      return _buildRoute(const ChatScreen(), settings, arguments: settings.arguments);

    case AppRoutes.propertyForm:
      return _buildRoute(const PropertyFormScreen(), settings, arguments: settings.arguments);

    case AppRoutes.landForm:
      return _buildRoute(const LandFormScreen(), settings, arguments: settings.arguments);

    case AppRoutes.editProfile:
      return _buildRoute(const EditProfileScreen(), settings);

    case AppRoutes.myListings:
      return _buildRoute(const MyListingsScreen(), settings);

    case AppRoutes.partners:
      return _buildRoute(const PartnersScreen(), settings);

    case AppRoutes.partnerForm:
      return _buildRoute(const PartnerFormScreen(), settings);

    default:
      return _buildRoute(const WelcomeScreen(), settings);
  }
}

/// Extrai o id do segmento final de um caminho `/properties/<id>` ou
/// `/lands/<id>`. Devolve `null` se o caminho não tiver um id válido.
String? _idFromPath(String path, String prefix) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.length != 2 || segments[0] != prefix) return null;
  final id = segments[1];
  return id.isEmpty || id.contains(':') ? null : id;
}

PageRouteBuilder _buildRoute(
  Widget page,
  RouteSettings settings, {
  Object? arguments,
}) {
  return PageRouteBuilder(
    settings: RouteSettings(
      name: settings.name,
      arguments: arguments ?? settings.arguments,
    ),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final fadeTween = Tween(begin: 0.0, end: 1.0);

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}
