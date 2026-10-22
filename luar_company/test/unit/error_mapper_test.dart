import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/errors/app_failure.dart';
import 'package:luar_company/core/utils/error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

PostgrestException _pg({String message = 'erro', String? code, String? hint}) {
  return PostgrestException(message: message, code: code, hint: hint);
}

void main() {
  group('ErrorMapper — violações de RLS', () {
    test(
      'código 42501 (insufficient_privilege) mapeia para PermissionFailure',
      () {
        final failure = ErrorMapper.map(_pg(code: '42501'));
        expect(failure, isA<PermissionFailure>());
      },
    );

    test('código PGRST301 mapeia para PermissionFailure', () {
      final failure = ErrorMapper.map(_pg(code: 'PGRST301'));
      expect(failure, isA<PermissionFailure>());
    });

    test('mensagem "violates row-level security policy" é permissão', () {
      final failure = ErrorMapper.map(
        _pg(
          message: 'new row violates row-level security policy for table "x"',
        ),
      );
      expect(failure, isA<PermissionFailure>());
    });

    test('mensagem "permission denied" é permissão', () {
      final failure = ErrorMapper.map(_pg(message: 'permission denied'));
      expect(failure, isA<PermissionFailure>());
    });

    test('mensagem "not authorized" é permissão', () {
      final failure = ErrorMapper.map(_pg(message: 'Not authorized'));
      expect(failure, isA<PermissionFailure>());
    });

    test('a mensagem apresentada é amigável e não expõe SQL', () {
      final message = ErrorMapper.toMessage(
        _pg(
          message:
              'new row violates row-level security policy for table "properties"',
          code: '42501',
        ),
      );
      expect(message, isNot(contains('row-level security')));
      expect(message, isNot(contains('properties')));
      expect(message, contains('permissão'));
    });

    test('isPermissionError reconhece o código e a mensagem', () {
      expect(ErrorMapper.isPermissionError(_pg(code: '42501')), isTrue);
      expect(
        ErrorMapper.isPermissionError(_pg(message: 'permission denied')),
        isTrue,
      );
      expect(
        ErrorMapper.isPermissionError(_pg(message: 'erro normal')),
        isFalse,
      );
    });
  });

  group('ErrorMapper — mapeamento base', () {
    test('AuthException mapeia para AuthFailure', () {
      final failure = ErrorMapper.map(const AuthException('token inválido'));
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'token inválido');
    });

    test('PostgrestException comum mapeia para ServerFailure', () {
      final failure = ErrorMapper.map(_pg(message: 'relação não existe'));
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'relação não existe');
    });

    test('StorageException mapeia para StorageFailure', () {
      final failure = ErrorMapper.map(
        const StorageException('falhou o upload'),
      );
      expect(failure, isA<StorageFailure>());
    });

    test('FormatException mapeia para ValidationFailure', () {
      final failure = ErrorMapper.map(const FormatException('mau formato'));
      expect(failure, isA<ValidationFailure>());
    });

    test('StateError mapeia para ValidationFailure', () {
      final failure = ErrorMapper.map(StateError('estado inválido'));
      expect(failure, isA<ValidationFailure>());
    });

    test('TimeoutException mapeia para NetworkFailure', () {
      final failure = ErrorMapper.map(TimeoutException('demorou'));
      expect(failure, isA<NetworkFailure>());
    });

    test('SocketException mapeia para NetworkFailure', () {
      final failure = ErrorMapper.map(const SocketException('sem rede'));
      expect(failure, isA<NetworkFailure>());
    });

    test('erro genérico curto é mapeado para UnknownFailure', () {
      final failure = ErrorMapper.map(Exception('algo correu mal'));
      expect(failure, isA<UnknownFailure>());
    });

    test('mensagem muito longa é truncada por segurança', () {
      final failure = ErrorMapper.map(Exception('x' * 500));
      expect(failure, isA<UnknownFailure>());
      expect(failure.message.length, lessThan(120));
    });

    test('toMessage devolve a mensagem da failure', () {
      expect(ErrorMapper.toMessage(const AuthException('falhou')), 'falhou');
    });
  });
}
