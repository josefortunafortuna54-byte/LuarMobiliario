import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/favorite_model.dart';

void main() {
  final fixedDate = DateTime(2025, 3, 10);

  FavoriteModel createSubject({
    String id = 'f1',
    String userId = 'u1',
    String propertyId = 'p1',
    String landId = 'l1',
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id,
      userId: userId,
      propertyId: propertyId,
      landId: landId,
      createdAt: createdAt ?? fixedDate,
    );
  }

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'f2',
        'user_id': 'u3',
        'property_id': 'p5',
        'land_id': 'l7',
        'created_at': '2025-02-01T10:00:00.000',
      };

      final f = FavoriteModel.fromJson(json);

      expect(f.id, 'f2');
      expect(f.userId, 'u3');
      expect(f.propertyId, 'p5');
      expect(f.landId, 'l7');
      expect(f.createdAt, DateTime(2025, 2, 1, 10, 0));
    });

    test('defaults string fields to empty/null when null', () {
      final f = FavoriteModel.fromJson(<String, dynamic>{});
      expect(f.id, '');
      expect(f.userId, '');
      expect(f.propertyId, isNull);
      expect(f.landId, isNull);
    });

    test('uses DateTime.now() for missing date', () {
      final before = DateTime.now().subtract(const Duration(milliseconds: 10));
      final f = FavoriteModel.fromJson(<String, dynamic>{});
      final after = DateTime.now().add(const Duration(milliseconds: 10));

      expect(f.createdAt.isAfter(before), isTrue);
      expect(f.createdAt.isBefore(after), isTrue);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final f = createSubject(createdAt: DateTime(2025, 1, 1));

      final json = f.toJson();

      expect(json['id'], 'f1');
      expect(json['user_id'], 'u1');
      expect(json['property_id'], 'p1');
      expect(json['land_id'], 'l1');
      expect(json['created_at'], '2025-01-01T00:00:00.000');
    });

    test('uses snake_case keys', () {
      final json = createSubject().toJson();
      expect(json.containsKey('user_id'), isTrue);
      expect(json.containsKey('property_id'), isTrue);
      expect(json.containsKey('land_id'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
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
        userId: 'u42',
        propertyId: 'p99',
        landId: 'l88',
        createdAt: DateTime(2024, 12, 25, 8, 30),
      );

      final restored = FavoriteModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.propertyId, original.propertyId);
      expect(restored.landId, original.landId);
      expect(restored.createdAt, original.createdAt);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.propertyId, original.propertyId);
      expect(copy.landId, original.landId);
      expect(copy.createdAt, original.createdAt);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(propertyId: 'p99');

      expect(copy.propertyId, 'p99');
      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.landId, original.landId);
    });

    test('can change multiple fields at once', () {
      final original = createSubject();
      final copy = original.copyWith(
        userId: 'u2',
        propertyId: 'p3',
        landId: 'l4',
      );

      expect(copy.userId, 'u2');
      expect(copy.propertyId, 'p3');
      expect(copy.landId, 'l4');
      expect(copy.id, original.id);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(propertyId: 'Changed');

      expect(original.propertyId, 'p1');
    });
  });
}
