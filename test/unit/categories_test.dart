import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/constants/app_categories.dart';
import 'package:luar_company/core/models/land_model.dart';
import 'package:luar_company/core/models/property_model.dart';

void main() {
  group('Property categories', () {
    test('cobrem exatamente todos os PropertyType', () {
      final enumKeys = PropertyType.values.map((e) => e.name).toSet();
      final categoryKeys = propertyCategories.map((c) => c.key).toSet();
      expect(categoryKeys, enumKeys);
    });

    test('não têm categorias de terreno', () {
      expect(propertyCategories.every((c) => c.isLand == false), isTrue);
    });

    test('chaves são únicas', () {
      final keys = propertyCategories.map((c) => c.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('propertyFilterKeys inclui "Todos" e cada categoria', () {
      expect(propertyFilterKeys.first, '');
      expect(propertyFilterKeys.length, propertyCategories.length + 1);
      expect(
        propertyFilterKeys.sublist(1),
        propertyCategories.map((c) => c.key).toList(),
      );
    });

    test('inclui condomínio (regressão)', () {
      expect(propertyFilterKeys, contains('condo'));
    });
  });

  group('Land categories', () {
    test('cobrem exatamente todos os LandType', () {
      final enumKeys = LandType.values.map((e) => e.name).toSet();
      final categoryKeys = landCategories.map((c) => c.key).toSet();
      expect(categoryKeys, enumKeys);
    });

    test('estão todas marcadas como terreno', () {
      expect(landCategories.every((c) => c.isLand == true), isTrue);
    });

    test('chaves são únicas', () {
      final keys = landCategories.map((c) => c.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('landFilterKeys inclui "Todos" e cada categoria', () {
      expect(landFilterKeys.first, '');
      expect(landFilterKeys.length, landCategories.length + 1);
      expect(
        landFilterKeys.sublist(1),
        landCategories.map((c) => c.key).toList(),
      );
    });
  });
}
