import 'package:flutter/foundation.dart';

import '../models/favorite_model.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import '../repositories/favorite_repository.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _repository = FavoriteRepository();

  List<FavoriteModel> _favorites = [];
  bool _isLoading = false;

  List<FavoriteModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _repository.fetchFavorites(userId);
    } catch (e) {
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(
    String userId, {
    String? propertyId,
    String? landId,
  }) async {
    try {
      final existingIndex = _favorites.indexWhere(
        (f) =>
            f.userId == userId &&
            ((propertyId != null && f.propertyId == propertyId) ||
                (landId != null && f.landId == landId)),
      );

      if (existingIndex != -1) {
        final existing = _favorites[existingIndex];

        await _repository.remove(existing.id);

        _favorites.removeAt(existingIndex);
        notifyListeners();
        return false;
      } else {
        final newFavorite = await _repository.add(
          userId: userId,
          propertyId: propertyId,
          landId: landId,
        );

        _favorites.insert(0, newFavorite);
        notifyListeners();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  bool isFavorite(String userId, {String? propertyId, String? landId}) {
    return _favorites.any(
      (f) =>
          f.userId == userId &&
          ((propertyId != null && f.propertyId == propertyId) ||
              (landId != null && f.landId == landId)),
    );
  }

  Future<List<PropertyModel>> getFavoriteProperties() async {
    final propertyIds = _favorites
        .where((f) => f.propertyId != null && f.propertyId!.isNotEmpty)
        .map((f) => f.propertyId!)
        .toList();

    try {
      return await _repository.fetchFavoriteProperties(propertyIds);
    } catch (e) {
      return [];
    }
  }

  Future<List<LandModel>> getFavoriteLands() async {
    final landIds = _favorites
        .where((f) => f.landId != null && f.landId!.isNotEmpty)
        .map((f) => f.landId!)
        .toList();

    try {
      return await _repository.fetchFavoriteLands(landIds);
    } catch (e) {
      return [];
    }
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}