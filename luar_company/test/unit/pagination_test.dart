import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/pagination.dart';

void main() {
  group('slicePage', () {
    test('página incompleta não tem mais resultados', () {
      final slice = slicePage([1, 2, 3], 10);

      expect(slice.items, [1, 2, 3]);
      expect(slice.hasMore, isFalse);
    });

    test('página exatamente cheia (sem registo extra) não tem mais', () {
      final slice = slicePage(List.generate(10, (i) => i), 10);

      expect(slice.items.length, 10);
      expect(slice.hasMore, isFalse);
    });

    test('registo extra indica mais páginas e é descartado', () {
      final slice = slicePage(List.generate(11, (i) => i), 10);

      expect(slice.items.length, 10);
      expect(slice.items.last, 9);
      expect(slice.hasMore, isTrue);
    });

    test('página vazia', () {
      final slice = slicePage<int>([], 10);

      expect(slice.items, isEmpty);
      expect(slice.hasMore, isFalse);
    });
  });
}
