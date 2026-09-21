import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/formatters.dart';

void main() {
  group('formatPrice', () {
    test('formats zero', () {
      expect(formatPrice(0), 'AOA 0');
    });

    test('formats small value without thousands separator', () {
      expect(formatPrice(500), 'AOA 500');
    });

    test('formats value with one thousands separator', () {
      expect(formatPrice(1500000), 'AOA 1.500.000');
    });

    test('formats large value with multiple separators', () {
      expect(formatPrice(15000000), 'AOA 15.000.000');
    });
  });

  group('formatDate', () {
    test('formats single-digit day and month with leading zeros', () {
      expect(formatDate(DateTime(2025, 3, 5)), '05/03/2025');
    });

    test('formats double-digit day and month', () {
      expect(formatDate(DateTime(2025, 12, 25)), '25/12/2025');
    });

    test('formats year with four digits', () {
      expect(formatDate(DateTime(2026, 1, 1)), '01/01/2026');
    });
  });

  group('formatDateTime', () {
    test('formats date and time with leading zeros', () {
      expect(formatDateTime(DateTime(2025, 3, 5, 9, 30)), '05/03/2025 09:30');
    });

    test('formats midnight correctly', () {
      expect(formatDateTime(DateTime(2025, 12, 31, 0, 0)), '31/12/2025 00:00');
    });

    test('formats end of day correctly', () {
      expect(formatDateTime(DateTime(2025, 6, 15, 23, 59)), '15/06/2025 23:59');
    });
  });

  group('formatArea', () {
    test('formats area with m² suffix', () {
      expect(formatArea(350), '350 m²');
    });

    test('formats zero area', () {
      expect(formatArea(0), '0 m²');
    });

    test('formats large area', () {
      expect(formatArea(15000), '15000 m²');
    });
  });

  group('formatPhone', () {
    test('formats phone with country code prefix', () {
      expect(formatPhone('+244900000000'), '+244 900 000 000');
    });

    test('formats phone without country code', () {
      expect(formatPhone('900000000'), '+244 900 000 000');
    });

    test('returns original string for short numbers', () {
      expect(formatPhone('123'), '123');
    });
  });

  group('truncateText', () {
    test('returns original text when shorter than maxLength', () {
      expect(truncateText('Olá', 10), 'Olá');
    });

    test('truncates long text and appends ellipsis', () {
      expect(
        truncateText('Esta é uma mensagem muito longa para testar', 10),
        'Esta é uma...',
      );
    });

    test('truncates text with exactly maxLength characters', () {
      expect(truncateText('1234567890', 10), '1234567890');
    });

    test('truncates text longer than maxLength', () {
      expect(truncateText('12345678901', 10), '1234567890...');
    });

    test('handles empty string', () {
      expect(truncateText('', 5), '');
    });
  });

  group('formatPriceRaw', () {
    test('formats zero', () {
      expect(formatPriceRaw(0), '0');
    });

    test('formats small value without separator', () {
      expect(formatPriceRaw(999), '999');
    });

    test('formats value with one separator', () {
      expect(formatPriceRaw(1000), '1.000');
    });

    test('formats value with multiple separators', () {
      expect(formatPriceRaw(1234567890), '1.234.567.890');
    });

    test('formats exactly one thousand', () {
      expect(formatPriceRaw(1000), '1.000');
    });

    test('formats negative value', () {
      expect(formatPriceRaw(-1500), '-1.500');
    });
  });

  group('formatPriceCurrency', () {
    test('prepends AOA prefix', () {
      expect(formatPriceCurrency(1500000), 'AOA 1.500.000');
    });

    test('formats zero', () {
      expect(formatPriceCurrency(0), 'AOA 0');
    });

    test('formats large value', () {
      expect(formatPriceCurrency(500000000), 'AOA 500.000.000');
    });
  });
}
