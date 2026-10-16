import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    test('fromJson lê todos os campos', () {
      final model = ReviewModel.fromJson({
        'id': 'r1',
        'property_id': 'p1',
        'user_id': 'u1',
        'user_name': 'Maria',
        'rating': 4,
        'comment': 'Muito bom',
        'created_at': '2026-10-15T10:00:00Z',
        'updated_at': '2026-10-15T10:00:00Z',
      });

      expect(model.id, 'r1');
      expect(model.propertyId, 'p1');
      expect(model.userId, 'u1');
      expect(model.userName, 'Maria');
      expect(model.rating, 4);
      expect(model.comment, 'Muito bom');
      expect(model.createdAt, DateTime.parse('2026-10-15T10:00:00Z'));
    });

    test('fromJson lê o nome aninhado do join Supabase (user.name)', () {
      final model = ReviewModel.fromJson({
        'id': 'r1',
        'property_id': 'p1',
        'user_id': 'u1',
        'user': {'name': 'João'},
        'rating': 5,
        'created_at': '2026-10-15T10:00:00Z',
        'updated_at': '2026-10-15T10:00:00Z',
      });

      expect(model.userName, 'João');
    });

    test('fromJson com campos em falta usa valores por omissão', () {
      final model = ReviewModel.fromJson({});

      expect(model.id, '');
      expect(model.propertyId, '');
      expect(model.userId, '');
      expect(model.userName, '');
      expect(model.rating, 0);
      expect(model.comment, '');
      expect(
        model.createdAt,
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });

    test('toJson e fromJson são consistentes', () {
      final original = ReviewModel(
        id: 'r1',
        propertyId: 'p1',
        userId: 'u1',
        userName: 'Ana',
        rating: 3,
        comment: 'Ok',
        createdAt: DateTime(2026, 10, 15),
        updatedAt: DateTime(2026, 10, 15),
      );

      final roundtrip = ReviewModel.fromJson(original.toJson());

      expect(roundtrip.id, original.id);
      expect(roundtrip.propertyId, original.propertyId);
      expect(roundtrip.userId, original.userId);
      expect(roundtrip.userName, original.userName);
      expect(roundtrip.rating, original.rating);
      expect(roundtrip.comment, original.comment);
    });

    test('copyWith substitui apenas os campos indicados', () {
      final original = ReviewModel(
        id: 'r1',
        propertyId: 'p1',
        userId: 'u1',
        rating: 3,
        createdAt: DateTime(2026, 10, 15),
        updatedAt: DateTime(2026, 10, 15),
      );

      final updated = original.copyWith(rating: 5, comment: 'Excelente');

      expect(updated.rating, 5);
      expect(updated.comment, 'Excelente');
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
    });
  });
}
