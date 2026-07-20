import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null value', () {
      expect(Validators.required(null), 'Campo obrigatório');
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), 'Campo obrigatório');
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.required('   '), 'Campo obrigatório');
    });

    test('returns null for valid value', () {
      expect(Validators.required('Luanda'), isNull);
    });
  });

  group('Validators.email', () {
    test('returns error for null value', () {
      expect(Validators.email(null), 'Email obrigatório');
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), 'Email obrigatório');
    });

    test('returns error for invalid email', () {
      expect(Validators.email('not-an-email'), 'Email inválido');
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@test.com'), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns error for null value', () {
      expect(Validators.phone(null), 'Telefone obrigatório');
    });

    test('returns error for empty string', () {
      expect(Validators.phone(''), 'Telefone obrigatório');
    });

    test('returns error for short number', () {
      expect(Validators.phone('12345'), 'Telefone inválido');
    });

    test('returns null for valid phone number', () {
      expect(Validators.phone('+244900000000'), isNull);
    });
  });

  group('Validators.minLength', () {
    test('returns error for null value', () {
      expect(Validators.minLength(null, 5), 'Campo obrigatório');
    });

    test('returns error for empty string', () {
      expect(Validators.minLength('', 5), 'Campo obrigatório');
    });

    test('returns error for too short value', () {
      expect(Validators.minLength('abc', 5), 'Mínimo de 5 caracteres');
    });

    test('returns null for valid value', () {
      expect(Validators.minLength('Luanda', 5), isNull);
    });

    test('uses custom message when provided', () {
      expect(
        Validators.minLength('ab', 5, customMessage: 'Muito curto'),
        'Muito curto',
      );
    });
  });

  group('Validators.maxLength', () {
    test('returns null for null value', () {
      expect(Validators.maxLength(null, 10), isNull);
    });

    test('returns null for empty string', () {
      expect(Validators.maxLength('', 10), isNull);
    });

    test('returns error for too long value', () {
      expect(
        Validators.maxLength('Texto muito longo aqui', 5),
        'Máximo de 5 caracteres',
      );
    });

    test('returns null for valid value', () {
      expect(Validators.maxLength('Curto', 10), isNull);
    });

    test('uses custom message when provided', () {
      expect(
        Validators.maxLength(
          'Texto longo demais',
          3,
          customMessage: 'Muito longo',
        ),
        'Muito longo',
      );
    });
  });

  group('Validators.numeric', () {
    test('returns error for null value', () {
      expect(Validators.numeric(null), 'Campo obrigatório');
    });

    test('returns error for empty string', () {
      expect(Validators.numeric(''), 'Campo obrigatório');
    });

    test('returns error for non-numeric value', () {
      expect(Validators.numeric('abc'), 'Número inválido');
    });

    test('returns null for valid number', () {
      expect(Validators.numeric('12345'), isNull);
    });

    test('returns null for decimal number with dot', () {
      expect(Validators.numeric('123.45'), isNull);
    });

    test('returns null for decimal number with comma', () {
      expect(Validators.numeric('123,45'), isNull);
    });
  });

  group('Validators.match', () {
    test('returns error for null value', () {
      expect(Validators.match(null, r'^\d+$'), 'Campo obrigatório');
    });

    test('returns error for empty string', () {
      expect(Validators.match('', r'^\d+$'), 'Campo obrigatório');
    });

    test('returns error when pattern does not match', () {
      expect(Validators.match('abc', r'^\d+$'), 'Formato inválido');
    });

    test('returns null when pattern matches', () {
      expect(Validators.match('12345', r'^\d+$'), isNull);
    });

    test('uses custom message when provided', () {
      expect(
        Validators.match('abc', r'^\d+$', customMessage: 'Só números'),
        'Só números',
      );
    });
  });
}
