import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/favorite_model.dart';
import 'package:luar_company/core/models/land_model.dart';
import 'package:luar_company/core/models/property_model.dart';
import 'package:luar_company/core/providers/favorite_provider.dart';
import 'package:luar_company/core/repositories/favorite_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFavoriteRepository extends FavoriteRepository {
  _FakeFavoriteRepository({this.serverFavorites = const []});

  List<FavoriteModel> serverFavorites;
  final List<String> removed = [];
  final List<String> addedFor = [];

  @override
  Future<List<FavoriteModel>> fetchFavorites(String userId) async =>
      serverFavorites.where((f) => f.userId == userId).toList();

  @override
  Future<void> remove(String favoriteId) async {
    removed.add(favoriteId);
    serverFavorites = serverFavorites.where((f) => f.id != favoriteId).toList();
  }

  @override
  Future<FavoriteModel> add({
    required String userId,
    String? propertyId,
    String? landId,
  }) async {
    addedFor.add(userId);
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
        isTrue,
      );
      expect(
        await provider.toggleFavorite(
          FavoriteProvider.guestUserId,
          landId: 'l1',
        ),
        isTrue,
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

      final added = await provider.toggleFavorite(
        FavoriteProvider.guestUserId,
        propertyId: 'p1',
      );

      expect(added, isFalse);
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

      final added = await provider.toggleFavorite('user1', propertyId: 'p9');

      expect(added, isTrue);
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

      final added = await provider.toggleFavorite('user1', propertyId: 'p1');

      expect(added, isFalse);
      expect(repository.removed, ['f1']);
      expect(provider.favorites, isEmpty);
    });
  });
}
