import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/category_model.dart';

void main() {
  CategoryModel createSubject({
    String id = 'c1',
    String name = 'Vivendas',
    String icon = 'house',
    CategoryType type = CategoryType.property,
    int count = 25,
  }) {
    return CategoryModel(
      id: id,
      name: name,
      icon: icon,
      type: type,
      count: count,
    );
  }

  group('CategoryType', () {
    test('has two values', () {
      expect(CategoryType.values.length, 2);
    });

    test('contains all expected types', () {
      expect(CategoryType.values, contains(CategoryType.property));
      expect(CategoryType.values, contains(CategoryType.land));
    });
  });

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'c2',
        'name': 'Terrenos',
        'icon': 'terrain',
        'type': 'land',
        'count': 12,
      };

      final c = CategoryModel.fromJson(json);

      expect(c.id, 'c2');
      expect(c.name, 'Terrenos');
      expect(c.icon, 'terrain');
      expect(c.type, CategoryType.land);
      expect(c.count, 12);
    });

    test('defaults to property for unknown type string', () {
      final c = CategoryModel.fromJson({'type': 'unknown'});
      expect(c.type, CategoryType.property);
    });

    test('defaults to property when type is null', () {
      final c = CategoryModel.fromJson(<String, dynamic>{'type': null});
      expect(c.type, CategoryType.property);
    });

    test('handles all type strings', () {
      expect(
        CategoryModel.fromJson({'type': 'property'}).type,
        CategoryType.property,
      );
      expect(
        CategoryModel.fromJson({'type': 'land'}).type,
        CategoryType.land,
      );
    });

    test('defaults string fields to empty when null', () {
      final c = CategoryModel.fromJson(<String, dynamic>{});
      expect(c.id, '');
      expect(c.name, '');
      expect(c.icon, '');
    });

    test('defaults count to 0 when null', () {
      final c = CategoryModel.fromJson(<String, dynamic>{});
      expect(c.count, 0);
    });

    test('parses integer count from JSON', () {
      final c = CategoryModel.fromJson({'count': 10});
      expect(c.count, 10);
    });

    test('parses double count from JSON', () {
      final c = CategoryModel.fromJson({'count': 15.0});
      expect(c.count, 15);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final c = createSubject(
        type: CategoryType.land,
        count: 42,
      );

      final json = c.toJson();

      expect(json['id'], 'c1');
      expect(json['name'], 'Vivendas');
      expect(json['icon'], 'house');
      expect(json['type'], 'land');
      expect(json['count'], 42);
    });

    test('has 5 keys', () {
      final json = createSubject().toJson();
      expect(json.length, 5);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('preserves all values through serialization', () {
      final original = createSubject(
        id: 'rt1',
        name: 'Round Trip',
        icon: 'terrain',
        type: CategoryType.land,
        count: 99,
      );

      final restored = CategoryModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.icon, original.icon);
      expect(restored.type, original.type);
      expect(restored.count, original.count);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.icon, original.icon);
      expect(copy.type, original.type);
      expect(copy.count, original.count);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(name: 'Novo Terrenos', count: 50);

      expect(copy.name, 'Novo Terrenos');
      expect(copy.count, 50);
      expect(copy.id, original.id);
      expect(copy.icon, original.icon);
      expect(copy.type, original.type);
    });

    test('can change type', () {
      final original = createSubject(type: CategoryType.property);
      final copy = original.copyWith(type: CategoryType.land);

      expect(copy.type, CategoryType.land);
      expect(original.type, CategoryType.property);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(name: 'Changed', count: 0);

      expect(original.name, 'Vivendas');
      expect(original.count, 25);
    });
  });
}
