import 'package:flutter_test/flutter_test.dart';

import 'package:luar_company/core/providers/auth_provider.dart';

void main() {
  group('AuthProvider - estado inicial', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('inicialmente sem utilizador autenticado', () {
      expect(authProvider.user, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
    });

    test('clearError limpa o erro', () {
      authProvider.clearError();
      expect(authProvider.error, isNull);
    });
  });
}
