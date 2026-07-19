import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/properties/properties_screen.dart';
import '../../screens/properties/property_detail_screen.dart';
import '../../screens/lands/lands_screen.dart';
import '../../screens/lands/land_detail_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/messages/messages_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/bookings/bookings_screen.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/admin/admin_properties.dart';
import '../../screens/admin/admin_users.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
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
  static const String adminUsers = '/admin/users';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? '';

  if (name.startsWith('/properties/') && name != AppRoutes.properties) {
    return _buildRoute(
      const PropertyDetailScreen(),
      settings,
      arguments: settings.arguments,
    );
  }

  if (name.startsWith('/lands/') && name != AppRoutes.lands) {
    return _buildRoute(
      const LandDetailScreen(),
      settings,
      arguments: settings.arguments,
    );
  }

  switch (name) {
    case AppRoutes.splash:
      return _buildRoute(const SplashScreen(), settings);

    case AppRoutes.login:
      return _buildRoute(const LoginScreen(), settings);

    case AppRoutes.register:
      return _buildRoute(const RegisterScreen(), settings);

    case AppRoutes.home:
      return _buildRoute(const HomeScreen(), settings);

    case AppRoutes.search:
      return _buildRoute(const SearchScreen(), settings);

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

    case AppRoutes.adminUsers:
      return _buildRoute(const AdminUsersScreen(), settings);

    default:
      return _buildRoute(const SplashScreen(), settings);
  }
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
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
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
