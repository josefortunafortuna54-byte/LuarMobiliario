import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/saved_search_model.dart';
import 'package:luar_company/core/providers/saved_search_provider.dart';
import 'package:luar_company/core/repositories/saved_search_repository.dart';

class _FakeSavedSearchRepository extends SavedSearchRepository {
  _FakeSavedSearchRepository({
    List<SavedSearchModel>? items,
    this.throwOnCreate = false,
    this.throwOnDelete = false,
  }) : _items = items ?? [];

  final List<SavedSearchModel> _items;
  final bool throwOnCreate;
  final bool throwOnDelete;

  final List<Map<String, dynamic>> created = [];
  final List<String> deleted = [];

  @override
  Future<List<SavedSearchModel>> fetchByUser(String userId) async {
    return List.from(_items.where((s) => s.userId == userId));
  }

  @override
  Future<SavedSearchModel> create({
    required String userId,
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    if (throwOnCreate) throw Exception('falha de rede');
    created.add({'user_id': userId, 'name': name, 'filters': filters});
    return SavedSearchModel(
      id: 's${created.length}',
      userId: userId,
      name: name,
      filters: filters,
      createdAt: DateTime(2026, 10, 15),
    );
  }

  @override
  Future<void> delete(String id) async {
    if (throwOnDelete) throw Exception('falha de rede');
    deleted.add(id);
  }
}

SavedSearchModel _saved(String id, {String name = 'Casa'}) {
  return SavedSearchModel(
    id: id,
    userId: 'u1',
    name: name,
    filters: const {'province': 'Luanda'},
    createdAt: DateTime(2026, 10, 15),
  );
}

void main() {
  group('SavedSearchProvider', () {
    test('load popula a lista do utilizador', () async {
      final repo = _FakeSavedSearchRepository(items: [_saved('s1')]);
      final provider = SavedSearchProvider(repository: repo);

      await provider.load('u1');

      expect(provider.items.length, 1);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.isEmpty, isFalse);
    });

    test('load com lista vazia marca isEmpty', () async {
      final provider = SavedSearchProvider(
        repository: _FakeSavedSearchRepository(),
      );

      await provider.load('u1');

      expect(provider.isEmpty, isTrue);
      expect(provider.error, isNull);
    });

    test('save envia os filtros e insere no topo da lista', () async {
      final repo = _FakeSavedSearchRepository(items: [_saved('s0')]);
      final provider = SavedSearchProvider(repository: repo);
      await provider.load('u1');

      final result = await provider.save(
        userId: 'u1',
        name: 'Casas em Luanda',
        filters: const {'province': 'Luanda', 'bedrooms': 3},
      );

      expect(result, isNotNull);
      expect(repo.created.single['name'], 'Casas em Luanda');
      expect(repo.created.single['filters'], {
        'province': 'Luanda',
        'bedrooms': 3,
      });
      expect(provider.items.first.name, 'Casas em Luanda');
      expect(provider.items.length, 2);
    });

    test('save faz trim ao nome e rejeita nomes vazios', () async {
      final repo = _FakeSavedSearchRepository();
      final provider = SavedSearchProvider(repository: repo);

      final empty = await provider.save(
        userId: 'u1',
        name: '   ',
        filters: const {},
      );
      final trimmed = await provider.save(
        userId: 'u1',
        name: '  Casas  ',
        filters: const {},
      );

      expect(empty, isNull);
      expect(trimmed, isNotNull);
      expect(repo.created.single['name'], 'Casas');
    });

    test('save rejeita nomes com mais de 60 caracteres', () async {
      final repo = _FakeSavedSearchRepository();
      final provider = SavedSearchProvider(repository: repo);

      final result = await provider.save(
        userId: 'u1',
        name: 'a' * 61,
        filters: const {},
      );

      expect(result, isNull);
      expect(repo.created, isEmpty);
    });

    test('save devolve null e grava erro quando o repositório falha', () async {
      final provider = SavedSearchProvider(
        repository: _FakeSavedSearchRepository(throwOnCreate: true),
      );

      final result = await provider.save(
        userId: 'u1',
        name: 'Casa',
        filters: const {},
      );

      expect(result, isNull);
      expect(provider.error, contains('falha'));
    });

    test('remove devolve true e retira o item da lista', () async {
      final repo = _FakeSavedSearchRepository(items: [_saved('s1')]);
      final provider = SavedSearchProvider(repository: repo);
      await provider.load('u1');

      final ok = await provider.remove('s1');

      expect(ok, isTrue);
      expect(repo.deleted, ['s1']);
      expect(provider.items, isEmpty);
    });

    test('remove repõe a lista quando o repositório falha', () async {
      final repo = _FakeSavedSearchRepository(
        items: [_saved('s1')],
        throwOnDelete: true,
      );
      final provider = SavedSearchProvider(repository: repo);
      await provider.load('u1');

      final ok = await provider.remove('s1');

      expect(ok, isFalse);
      expect(provider.error, contains('falha'));
      expect(provider.items.length, 1);
    });
  });
}
