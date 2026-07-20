import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/routes.dart';

void main() {
  group('AppRoutes', () {
    test('has all expected route constants', () {
      expect(AppRoutes.splash, isNotEmpty);
      expect(AppRoutes.login, isNotEmpty);
      expect(AppRoutes.register, isNotEmpty);
      expect(AppRoutes.home, isNotEmpty);
      expect(AppRoutes.search, isNotEmpty);
      expect(AppRoutes.properties, isNotEmpty);
      expect(AppRoutes.propertyDetail, isNotEmpty);
      expect(AppRoutes.lands, isNotEmpty);
      expect(AppRoutes.landDetail, isNotEmpty);
      expect(AppRoutes.favorites, isNotEmpty);
      expect(AppRoutes.messages, isNotEmpty);
      expect(AppRoutes.profile, isNotEmpty);
      expect(AppRoutes.bookings, isNotEmpty);
      expect(AppRoutes.adminDashboard, isNotEmpty);
      expect(AppRoutes.adminProperties, isNotEmpty);
      expect(AppRoutes.adminUsers, isNotEmpty);
    });

    test('route constants start with /', () {
      expect(AppRoutes.splash, startsWith('/'));
      expect(AppRoutes.login, startsWith('/'));
      expect(AppRoutes.register, startsWith('/'));
      expect(AppRoutes.home, startsWith('/'));
      expect(AppRoutes.search, startsWith('/'));
      expect(AppRoutes.properties, startsWith('/'));
      expect(AppRoutes.propertyDetail, startsWith('/'));
      expect(AppRoutes.lands, startsWith('/'));
      expect(AppRoutes.landDetail, startsWith('/'));
      expect(AppRoutes.favorites, startsWith('/'));
      expect(AppRoutes.messages, startsWith('/'));
      expect(AppRoutes.profile, startsWith('/'));
      expect(AppRoutes.bookings, startsWith('/'));
      expect(AppRoutes.adminDashboard, startsWith('/'));
      expect(AppRoutes.adminProperties, startsWith('/'));
      expect(AppRoutes.adminUsers, startsWith('/'));
    });

    test('detail routes use :id parameter pattern', () {
      expect(AppRoutes.propertyDetail, contains(':id'));
      expect(AppRoutes.landDetail, contains(':id'));
    });

    test('non-detail routes do not contain :id pattern', () {
      expect(AppRoutes.splash.contains(':id'), isFalse);
      expect(AppRoutes.login.contains(':id'), isFalse);
      expect(AppRoutes.register.contains(':id'), isFalse);
      expect(AppRoutes.home.contains(':id'), isFalse);
      expect(AppRoutes.search.contains(':id'), isFalse);
      expect(AppRoutes.properties.contains(':id'), isFalse);
      expect(AppRoutes.lands.contains(':id'), isFalse);
      expect(AppRoutes.favorites.contains(':id'), isFalse);
      expect(AppRoutes.messages.contains(':id'), isFalse);
      expect(AppRoutes.profile.contains(':id'), isFalse);
      expect(AppRoutes.bookings.contains(':id'), isFalse);
      expect(AppRoutes.adminDashboard.contains(':id'), isFalse);
      expect(AppRoutes.adminProperties.contains(':id'), isFalse);
      expect(AppRoutes.adminUsers.contains(':id'), isFalse);
    });
  });
}
