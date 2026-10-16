import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/routes.dart';

void main() {
  group('AppRoutes', () {
    test('has all expected route constants', () {
      expect(AppRoutes.splash, isNotEmpty);
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

  group('AppRoutes.parse', () {
    test('accepts known static routes', () {
      expect(AppRoutes.parse('/favorites')?.name, AppRoutes.favorites);
      expect(AppRoutes.parse('/bookings')?.name, AppRoutes.bookings);
      expect(AppRoutes.parse('/messages')?.name, AppRoutes.messages);
      expect(AppRoutes.parse('/profile')?.name, AppRoutes.profile);
      expect(AppRoutes.parse('/admin/users')?.name, AppRoutes.adminUsers);
      expect(AppRoutes.parse('/favorites')?.arguments, isNull);
    });

    test('accepts property detail and extracts the id', () {
      final parsed = AppRoutes.parse('/properties/abc-123');
      expect(parsed?.name, AppRoutes.propertyDetail);
      expect(parsed?.arguments, 'abc-123');
    });

    test('accepts land detail and extracts the id', () {
      final parsed = AppRoutes.parse('/lands/xyz-789');
      expect(parsed?.name, AppRoutes.landDetail);
      expect(parsed?.arguments, 'xyz-789');
    });

    test('strips query string when parsing', () {
      final parsed = AppRoutes.parse('/properties/abc-123?utm=push');
      expect(parsed?.name, AppRoutes.propertyDetail);
      expect(parsed?.arguments, 'abc-123');
    });

    test('rejects null and empty', () {
      expect(AppRoutes.parse(null), isNull);
      expect(AppRoutes.parse(''), isNull);
    });

    test('rejects unknown routes', () {
      expect(AppRoutes.parse('/evil'), isNull);
      expect(AppRoutes.parse('/settings'), isNull);
      expect(AppRoutes.parse('/admin'), isNull);
      expect(AppRoutes.parse('/properties/extra/segment'), isNull);
    });

    test('rejects splash, welcome and admin login', () {
      expect(AppRoutes.parse(AppRoutes.splash), isNull);
      expect(AppRoutes.parse(AppRoutes.welcome), isNull);
      expect(AppRoutes.parse(AppRoutes.adminLogin), isNull);
    });

    test('rejects forms and admin dashboard (write/entry screens)', () {
      expect(AppRoutes.parse(AppRoutes.propertyForm), isNull);
      expect(AppRoutes.parse(AppRoutes.landForm), isNull);
      expect(AppRoutes.parse(AppRoutes.partnerForm), isNull);
      expect(AppRoutes.parse(AppRoutes.adminDashboard), isNull);
    });

    test('rejects path traversal and malformed ids', () {
      expect(AppRoutes.parse('/properties/../admin'), isNull);
      expect(AppRoutes.parse('/properties/a/b'), isNull);
      expect(AppRoutes.parse('/properties/:id'), isNull);
      expect(AppRoutes.parse('/lands/:id'), isNull);
    });

    test('rejects routes without a leading slash', () {
      expect(AppRoutes.parse('properties/abc'), isNull);
      expect(AppRoutes.parse('favorites'), isNull);
    });
  });
}
