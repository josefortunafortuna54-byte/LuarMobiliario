import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/favorite_model.dart';
import 'package:luar_company/core/models/land_model.dart';
import 'package:luar_company/core/models/property_model.dart';
import 'package:luar_company/core/providers/favorite_provider.dart';
import 'package:luar_company/core/repositories/favorite_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFavoriteRepository extends FavoriteRepository {
  _FakeFavoriteRepository({this.serverFavorites = const [], this.failOnAdd = false});

  List<FavoriteModel> serverFavorites;

  /// Simula a falha do `upsert` (o bug original: 409 em favor já existente).
  bool failOnAdd;

  /// Chaves lógicas removidas, no formato `user_id:property_id`.
  final List<String> removed = [];
  final List<String> addedFor = [];

  @override
  Future<List<FavoriteModel>> fetchFavorites(String userId) async =>
      serverFavorites.where((f) => f.userId == userId).toList();

  @override
  Future<void> remove({
    required String userId,
    String? propertyId,
    String? landId,
  }) async {
    final target = propertyId ?? landId ?? '';
    removed.add('$userId:$target');
    serverFavorites = serverFavorites
        .where(
          (f) =>
              !(f.userId == userId &&
                  ((propertyId != null && f.propertyId == propertyId) ||
                      (landId != null && f.landId == landId))),
        )
        .toList();
  }

  @override
  Future<FavoriteModel> add({
    required String userId,
    String? propertyId,
    String? landId,
  }) async {
    if (failOnAdd) {
      throw Exception('duplicate key value violates unique constraint');
    }

    addedFor.add(userId);

    // Semântica de `upsert`: se a linha já existe, devolve a mesma linha em
    // vez de criar uma nova.
    final existing = serverFavorites.where(
      (f) =>
          f.userId == userId &&
          ((propertyId != null && f.propertyId == propertyId) ||
              (landId != null && f.landId == landId)),
    );
    if (existing.isNotEmpty) return existing.first;

    final favorite = FavoriteModel(
      id: 'srv_${propertyId ?? landId}',
      userId: userId,
      propertyId: propertyId,
      landId: landId,
      createdAt: DateTime(2026, 1, 1),
    );
    serverFavorites = [favorite, ...serverFavorites];
    return favorite;
  }

  /// Contagem real de linhas por imóvel (como a RPC `favorite_counts`).
  ///
  /// A versão anterior devolvia sempre 7, o que não reproduzia o servidor:
  /// o provider reconcilia a contagem com o valor absoluto devolvido pelo
  /// backend e o teste passava a falhar (esperava 0, obtinha 6).
  @override
  Future<Map<String, int>> countLikes(List<String> propertyIds) async => {
    for (final id in propertyIds)
      id: serverFavorites.where((f) => f.propertyId == id).length,
  };

  @override
  Future<List<PropertyModel>> fetchFavoriteProperties(List<String> ids) async =>
      [];

  @override
  Future<List<LandModel>> fetchFavoriteLands(List<String> ids) async => [];
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('FavoriteProvider (convidado)', () {
    test('sem favoritos começa vazio', () async {
      final provider = FavoriteProvider(repository: _FakeFavoriteRepository());

      await provider.loadFavorites(FavoriteProvider.guestUserId);

      expect(provider.favorites, isEmpty);
      expect(
        provider.isFavorite(FavoriteProvider.guestUserId, propertyId: 'p1'),
        isFalse,
      );
    });

    test('toggleFavorite guarda localmente imóvel e terreno', () async {
      final provider = FavoriteProvider(repository: _FakeFavoriteRepository());

      expect(
        await provider.toggleFavorite(
          FavoriteProvider.guestUserId,
          propertyId: 'p1',
        ),
        FavoriteToggleResult.added,
      );
      expect(
        await provider.toggleFavorite(
          FavoriteProvider.guestUserId,
          landId: 'l1',
        ),
        FavoriteToggleResult.added,
      );

      expect(
        provider.isFavorite(FavoriteProvider.guestUserId, propertyId: 'p1'),
        isTrue,
      );
      expect(
        provider.isFavorite(FavoriteProvider.guestUserId, landId: 'l1'),
        isTrue,
      );
      expect(provider.favorites.length, 2);
    });

    test('persiste entre instâncias do provider', () async {
      final first = FavoriteProvider(repository: _FakeFavoriteRepository());
      await first.toggleFavorite(
        FavoriteProvider.guestUserId,
        propertyId: 'p1',
      );

      final second = FavoriteProvider(repository: _FakeFavoriteRepository());
      await second.loadFavorites(FavoriteProvider.guestUserId);

      expect(second.favorites.length, 1);
      expect(
        second.isFavorite(FavoriteProvider.guestUserId, propertyId: 'p1'),
        isTrue,
      );
    });

    test('segundo toggle remove o favorito', () async {
      final provider = FavoriteProvider(repository: _FakeFavoriteRepository());
      await provider.toggleFavorite(
        FavoriteProvider.guestUserId,
        propertyId: 'p1',
      );

      final result = await provider.toggleFavorite(
        FavoriteProvider.guestUserId,
        propertyId: 'p1',
      );

      expect(result, FavoriteToggleResult.removed);
      expect(provider.favorites, isEmpty);

      final reloaded = FavoriteProvider(repository: _FakeFavoriteRepository());
      await reloaded.loadFavorites(FavoriteProvider.guestUserId);
      expect(reloaded.favorites, isEmpty);
    });

    test('ensureLoaded não recarrega para o mesmo utilizador', () async {
      final provider = FavoriteProvider(repository: _FakeFavoriteRepository());
      await provider.toggleFavorite(
        FavoriteProvider.guestUserId,
        propertyId: 'p1',
      );

      await provider.ensureLoaded(FavoriteProvider.guestUserId);

      expect(provider.favorites.length, 1);
    });
  });

  group('FavoriteProvider (autenticado)', () {
    test('loadFavorites usa o repositório do servidor', () async {
      final repository = _FakeFavoriteRepository(
        serverFavorites: [
          FavoriteModel(
            id: 'f1',
            userId: 'user1',
            propertyId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      final provider = FavoriteProvider(repository: repository);

      await provider.loadFavorites('user1');

      expect(provider.favorites.length, 1);
      expect(provider.isFavorite('user1', propertyId: 'p1'), isTrue);
    });

    test('toggleFavorite adiciona no servidor', () async {
      final repository = _FakeFavoriteRepository();
      final provider = FavoriteProvider(repository: repository);

      final result = await provider.toggleFavorite('user1', propertyId: 'p9');

      expect(result, FavoriteToggleResult.added);
      expect(repository.addedFor, ['user1']);
      expect(provider.isFavorite('user1', propertyId: 'p9'), isTrue);
    });

    test('toggleFavorite remove do servidor quando já existe', () async {
      final repository = _FakeFavoriteRepository(
        serverFavorites: [
          FavoriteModel(
            id: 'f1',
            userId: 'user1',
            propertyId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      final provider = FavoriteProvider(repository: repository);
      await provider.loadFavorites('user1');

      final result = await provider.toggleFavorite('user1', propertyId: 'p1');

      expect(result, FavoriteToggleResult.removed);
      // A remoção é pela chave lógica (user_id + property_id), não pelo id.
      expect(repository.removed, ['user1:p1']);
      expect(provider.favorites, isEmpty);
    });

    test('falha do servidor devolve failed e não mexe no estado local', () async {
      final repository = _FakeFavoriteRepository(failOnAdd: true);
      final provider = FavoriteProvider(repository: repository);

      final result = await provider.toggleFavorite('user1', propertyId: 'p9');

      expect(result, FavoriteToggleResult.failed);
      expect(provider.favorites, isEmpty);
      expect(provider.isFavorite('user1', propertyId: 'p9'), isFalse);
    });

    test('toggle sem imóvel nem terreno devolve failed', () async {
      final repository = _FakeFavoriteRepository();
      final provider = FavoriteProvider(repository: repository);

      final result = await provider.toggleFavorite('user1');

      expect(result, FavoriteToggleResult.failed);
      expect(repository.addedFor, isEmpty);
    });

    test('favorito já existente no servidor não duplica no estado local', () async {
      // Regressão do bug original: o `insert` falhava com 409 porque a linha
      // já existia no servidor mas não no estado local.
      final repository = _FakeFavoriteRepository(
        serverFavorites: [
          FavoriteModel(
            id: 'f1',
            userId: 'user1',
            propertyId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      final provider = FavoriteProvider(repository: repository);

      final result = await provider.toggleFavorite('user1', propertyId: 'p1');

      expect(result, FavoriteToggleResult.added);
      expect(provider.favorites.length, 1);
      expect(provider.favorites.single.id, 'f1');
    });

    test('contagem de gostos acompanha o toggle', () async {
      final repository = _FakeFavoriteRepository();
      final provider = FavoriteProvider(repository: repository);

      await provider.toggleFavorite('user1', propertyId: 'p9');
      expect(provider.likeCount('p9'), 1);

      await provider.toggleFavorite('user1', propertyId: 'p9');
      expect(provider.likeCount('p9'), 0);
    });

    test('contagem de gostos reconcilia com o servidor no caminho de upsert', () async {
      // A linha já existe no servidor mas não no estado local (bug do 409):
      // o `upsert` devolve a linha existente, o estado local não duplica e a
      // contagem final é a real do servidor — não o ajuste otimista.
      final repository = _FakeFavoriteRepository(
        serverFavorites: [
          FavoriteModel(
            id: 'f1',
            userId: 'user1',
            propertyId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      final provider = FavoriteProvider(repository: repository);

      final result = await provider.toggleFavorite('user1', propertyId: 'p1');

      expect(result, FavoriteToggleResult.added);
      expect(provider.favorites.length, 1);
      expect(provider.likeCount('p1'), 1);
    });
  });
}
