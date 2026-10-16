import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/review_model.dart';
import 'package:luar_company/core/providers/review_provider.dart';
import 'package:luar_company/core/repositories/review_repository.dart';

class _FakeReviewRepository extends ReviewRepository {
  _FakeReviewRepository({
    List<ReviewModel>? reviews,
    this.throwOnUpsert = false,
    this.throwOnDelete = false,
  }) : _reviews = reviews ?? [];

  final List<ReviewModel> _reviews;
  final bool throwOnUpsert;
  final bool throwOnDelete;

  final List<Map<String, dynamic>> upserted = [];
  final List<String> deleted = [];

  @override
  Future<List<ReviewModel>> fetchByProperty(String propertyId) async {
    return _reviews.where((r) => r.propertyId == propertyId).toList();
  }

  @override
  Future<ReviewModel> upsert({
    required String propertyId,
    required String userId,
    required int rating,
    String comment = '',
  }) async {
    if (throwOnUpsert) throw Exception('falha de rede');
    upserted.add({
      'property_id': propertyId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
    return ReviewModel(
      id: 'rev${upserted.length}',
      propertyId: propertyId,
      userId: userId,
      userName: 'Eu',
      rating: rating,
      comment: comment,
      createdAt: DateTime(2026, 10, 15),
      updatedAt: DateTime(2026, 10, 15),
    );
  }

  @override
  Future<void> delete(String id) async {
    if (throwOnDelete) throw Exception('falha de rede');
    deleted.add(id);
  }
}

ReviewModel _review(
  String id, {
  String userId = 'u1',
  int rating = 5,
  String propertyId = 'p1',
}) {
  return ReviewModel(
    id: id,
    propertyId: propertyId,
    userId: userId,
    userName: 'Alguém',
    rating: rating,
    comment: '',
    createdAt: DateTime(2026, 10, 15),
    updatedAt: DateTime(2026, 10, 15),
  );
}

void main() {
  group('ReviewProvider', () {
    test('load popula a lista e calcula a média', () async {
      final repo = _FakeReviewRepository(
        reviews: [_review('r1', rating: 5), _review('r2', rating: 4)],
      );
      final provider = ReviewProvider(repository: repo);

      await provider.load('p1');

      expect(provider.reviews.length, 2);
      expect(provider.count, 2);
      expect(provider.averageRating, 4.5);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('load sem avaliações marca isEmpty e média 0', () async {
      final provider = ReviewProvider(repository: _FakeReviewRepository());

      await provider.load('p1');

      expect(provider.isEmpty, isTrue);
      expect(provider.averageRating, 0);
      expect(provider.count, 0);
    });

    test('load com falha grava erro e lista vazia', () async {
      final provider = ReviewProvider(repository: _ThrowingRepository());

      await provider.load('p1');

      expect(provider.error, contains('falha'));
      expect(provider.reviews, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('submit insere no topo e devolve true', () async {
      final repo = _FakeReviewRepository();
      final provider = ReviewProvider(repository: repo);

      final ok = await provider.submit(
        propertyId: 'p1',
        userId: 'u1',
        rating: 5,
        comment: 'Excelente',
      );

      expect(ok, isTrue);
      expect(repo.upserted.single['rating'], 5);
      expect(repo.upserted.single['comment'], 'Excelente');
      expect(provider.reviews.length, 1);
      expect(provider.averageRating, 5);
    });

    test('submit atualiza a avaliação existente do utilizador', () async {
      final repo = _FakeReviewRepository(reviews: [_review('r1', rating: 3)]);
      final provider = ReviewProvider(repository: repo);
      await provider.load('p1');

      final ok = await provider.submit(
        propertyId: 'p1',
        userId: 'u1',
        rating: 5,
        comment: 'Reavaliado',
      );

      expect(ok, isTrue);
      expect(provider.reviews.length, 1);
      expect(provider.reviews.single.rating, 5);
      expect(provider.reviews.single.comment, 'Reavaliado');
      expect(provider.averageRating, 5);
    });

    test('submit rejeita rating fora do intervalo 1-5', () async {
      final repo = _FakeReviewRepository();
      final provider = ReviewProvider(repository: repo);

      final tooLow = await provider.submit(
        propertyId: 'p1',
        userId: 'u1',
        rating: 0,
      );
      final tooHigh = await provider.submit(
        propertyId: 'p1',
        userId: 'u1',
        rating: 6,
      );

      expect(tooLow, isFalse);
      expect(tooHigh, isFalse);
      expect(repo.upserted, isEmpty);
      expect(provider.error, 'rating_invalid');
    });

    test('submit devolve false e grava erro quando o repositório falha', () async {
      final provider = ReviewProvider(
        repository: _FakeReviewRepository(throwOnUpsert: true),
      );

      final ok = await provider.submit(
        propertyId: 'p1',
        userId: 'u1',
        rating: 4,
      );

      expect(ok, isFalse);
      expect(provider.error, contains('falha'));
    });

    test('hasUserReviewed e reviewByUser detetam a avaliação do utilizador', () async {
      final repo = _FakeReviewRepository(reviews: [_review('r1', userId: 'u1')]);
      final provider = ReviewProvider(repository: repo);
      await provider.load('p1');

      expect(provider.hasUserReviewed('u1'), isTrue);
      expect(provider.hasUserReviewed('u2'), isFalse);
      expect(provider.reviewByUser('u1')?.id, 'r1');
      expect(provider.reviewByUser('u2'), isNull);
    });

    test('remove retira a avaliação e devolve true', () async {
      final repo = _FakeReviewRepository(reviews: [_review('r1', userId: 'u1')]);
      final provider = ReviewProvider(repository: repo);
      await provider.load('p1');

      final ok = await provider.remove('u1');

      expect(ok, isTrue);
      expect(repo.deleted, ['r1']);
      expect(provider.reviews, isEmpty);
      expect(provider.averageRating, 0);
    });

    test('remove repõe a avaliação quando o repositório falha', () async {
      final repo = _FakeReviewRepository(
        reviews: [_review('r1', userId: 'u1')],
        throwOnDelete: true,
      );
      final provider = ReviewProvider(repository: repo);
      await provider.load('p1');

      final ok = await provider.remove('u1');

      expect(ok, isFalse);
      expect(provider.error, contains('falha'));
      expect(provider.reviews.length, 1);
    });

    test('remove devolve false quando o utilizador não tem avaliação', () async {
      final provider = ReviewProvider(repository: _FakeReviewRepository());

      final ok = await provider.remove('u9');

      expect(ok, isFalse);
    });
  });
}

class _ThrowingRepository extends ReviewRepository {
  @override
  Future<List<ReviewModel>> fetchByProperty(String propertyId) async {
    throw Exception('falha de rede');
  }
}
