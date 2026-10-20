import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/routes.dart';

void main() {
  group('AppRoutes.parse', () {
    test('retorna null para route null', () {
      expect(AppRoutes.parse(null), isNull);
    });

    test('retorna null para route vazia', () {
      expect(AppRoutes.parse(''), isNull);
    });

    test('retorna null para route sem / no início', () {
      expect(AppRoutes.parse('home'), isNull);
    });

    test('retorna null para route maliciosa com ..', () {
      expect(AppRoutes.parse('/home/../admin'), isNull);
    });

    test('retorna null para route com //', () {
      expect(AppRoutes.parse('//home'), isNull);
    });

    test('retorna null para rota com dois pontos no segmento id', () {
      expect(AppRoutes.parse('/properties/abc:def'), isNull);
    });

    test('retorna null para rota com / extra no segmento id', () {
      expect(AppRoutes.parse('/properties/abc/def'), isNull);
    });

    test('retorna null para /properties/ sem id', () {
      expect(AppRoutes.parse('/properties/'), isNull);
    });

    test('retorna (home) para rota estática válida', () {
      final result = AppRoutes.parse('/home');
      expect(result, isNotNull);
      expect(result!.name, AppRoutes.home);
      expect(result.arguments, isNull);
    });

    test('retorna (discover) para rota estática válida', () {
      final result = AppRoutes.parse('/discover');
      expect(result, isNotNull);
      expect(result!.name, AppRoutes.discover);
    });

    test('retorna (messages) para rota estática válida', () {
      expect(AppRoutes.parse('/messages')!.name, AppRoutes.messages);
    });

    test('retorna (favorites) para rota estática válida', () {
      expect(AppRoutes.parse('/favorites')!.name, AppRoutes.favorites);
    });

    test('retorna (profile) para rota estática válida', () {
      expect(AppRoutes.parse('/profile')!.name, AppRoutes.profile);
    });

    test('retorna (bookings) para rota estática válida', () {
      expect(AppRoutes.parse('/bookings')!.name, AppRoutes.bookings);
    });

    test('retorna (adminProperties) para rota estática válida', () {
      expect(AppRoutes.parse('/admin/properties')!.name, AppRoutes.adminProperties);
    });

    test('retorna (propertyDetail) com id válido', () {
      final result = AppRoutes.parse('/properties/abc123');
      expect(result, isNotNull);
      expect(result!.name, AppRoutes.propertyDetail);
      expect(result.arguments, 'abc123');
    });

    test('retorna (landDetail) com id válido', () {
      final result = AppRoutes.parse('/lands/xyz789');
      expect(result, isNotNull);
      expect(result!.name, AppRoutes.landDetail);
      expect(result.arguments, 'xyz789');
    });

    test('retorna null para rota desconhecida', () {
      expect(AppRoutes.parse('/unknown'), isNull);
    });

    test('retorna null para rotas de formulário (propertyForm)', () {
      expect(AppRoutes.parse('/property-form'), isNull);
    });

    test('retorna null para rotas de formulário (landForm)', () {
      expect(AppRoutes.parse('/land-form'), isNull);
    });

    test('bloqueia splash, welcome e adminLogin', () {
      expect(AppRoutes.parse('/'), isNull);
      expect(AppRoutes.parse('/welcome'), isNull);
      expect(AppRoutes.parse('/admin-login'), isNull);
    });
  });
}
