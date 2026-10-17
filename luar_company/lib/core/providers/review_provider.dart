import 'package:flutter/foundation.dart';

import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({ReviewRepository? repository})
    : _repository = repository ?? ReviewRepository();

  final ReviewRepository _repository;

  List<ReviewModel> _reviews = [];
  final Map<String, int> _counts = {};
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _reviews.isEmpty;

  int get count => _reviews.length;

  /// Número de avaliações/comentários de um imóvel (feed).
  int countFor(String propertyId) => _counts[propertyId] ?? 0;

  /// Pré-carrega as contagens dos imóveis do feed (só as que faltam).
  Future<void> loadCounts(List<String> propertyIds) async {
    final missing =
        propertyIds.where((id) => id.isNotEmpty && !_counts.containsKey(id))
            .toList();
    if (missing.isEmpty) return;

    try {
      _counts.addAll(await _repository.countByProperties(missing));
      notifyListeners();
    } catch (_) {
      // Contagens são decorativas: falha silenciosa.
    }
  }

  /// Média das avaliações (0 quando não há avaliações).
  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  /// Indica se o utilizador já avaliou este imóvel.
  bool hasUserReviewed(String userId) =>
      _reviews.any((r) => r.userId == userId);

  /// Devolve a avaliação existente do utilizador (para pré-preencher o form).
  ReviewModel? reviewByUser(String userId) {
    for (final r in _reviews) {
      if (r.userId == userId) return r;
    }
    return null;
  }

  Future<void> load(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _repository.fetchByProperty(propertyId);
    } catch (e) {
      _error = e.toString();
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submete (cria ou atualiza) a avaliação do utilizador. Devolve `false`
  /// quando os dados são inválidos ou o repositório falha.
  Future<bool> submit({
    required String propertyId,
    required String userId,
    required int rating,
    String comment = '',
  }) async {
    if (rating < 1 || rating > 5) {
      _error = 'rating_invalid';
      notifyListeners();
      return false;
    }

    try {
      final saved = await _repository.upsert(
        propertyId: propertyId,
        userId: userId,
        rating: rating,
        comment: comment.trim(),
      );

      final index = _reviews.indexWhere((r) => r.userId == userId);
      if (index != -1) {
        _reviews[index] = saved;
      } else {
        _reviews = [saved, ..._reviews];
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove a avaliação do utilizador (otimista, repõe em caso de falha).
  Future<bool> remove(String userId) async {
    final index = _reviews.indexWhere((r) => r.userId == userId);
    if (index == -1) return false;

    final removed = _reviews[index];
    final previous = _reviews;
    _reviews = _reviews.where((r) => r.userId != userId).toList();
    notifyListeners();

    try {
      await _repository.delete(removed.id);
      return true;
    } catch (e) {
      _reviews = previous;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
