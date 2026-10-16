import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/saved_search_model.dart';

void main() {
  group('SavedSearchModel', () {
    test('fromJson ignora campos ausentes com valores por omissão', () {
      final search = SavedSearchModel.fromJson(const {});

      expect(search.id, '');
      expect(search.userId, '');
      expect(search.name, '');
      expect(search.filters, isEmpty);
      expect(search.createdAt.millisecondsSinceEpoch, 0);
    });

    test('fromJson lê os campos da BD e normaliza os filtros', () {
      final search = SavedSearchModel.fromJson(const {
        'id': 's1',
        'user_id': 'u1',
        'name': 'Apartamentos em Luanda',
        'filters': {'province': 'Luanda', 'maxPrice': 5000000},
        'created_at': '2026-10-15T10:00:00Z',
      });

      expect(search.id, 's1');
      expect(search.userId, 'u1');
      expect(search.name, 'Apartamentos em Luanda');
      expect(search.filters['province'], 'Luanda');
      expect(search.filters['maxPrice'], 5000000);
      expect(search.createdAt, DateTime.parse('2026-10-15T10:00:00Z'));
    });

    test('toJson não partilha a referência interna dos filtros', () {
      final search = SavedSearchModel(
        id: 's1',
        userId: 'u1',
        name: 'Casa',
        filters: const {'province': 'Benguela'},
        createdAt: DateTime(2026, 10, 15),
      );

      final json = search.toJson();

      expect(json['id'], 's1');
      expect(json['user_id'], 'u1');
      expect(json['name'], 'Casa');
      expect(json['filters'], {'province': 'Benguela'});
      expect(json['created_at'], DateTime(2026, 10, 15).toIso8601String());
    });

    test('copyWith substitui apenas os campos indicados', () {
      final original = SavedSearchModel(
        id: 's1',
        userId: 'u1',
        name: 'Casa',
        filters: const {'province': 'Benguela'},
        createdAt: DateTime(2026, 10, 15),
      );

      final renamed = original.copyWith(name: 'Casa nova');

      expect(renamed.name, 'Casa nova');
      expect(renamed.id, original.id);
      expect(renamed.filters, original.filters);
      expect(renamed.createdAt, original.createdAt);
    });
  });
}
