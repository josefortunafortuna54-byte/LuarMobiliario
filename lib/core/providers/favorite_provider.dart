import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorite_model.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import '../services/supabase_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseService.client;

  List<FavoriteModel> _favorites = [];
  bool _isLoading = false;

  List<FavoriteModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _favorites = (response as List<dynamic>)
          .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
          .toList();
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

        await _client.from('favorites').delete().eq('id', existing.id);

        _favorites.removeAt(existingIndex);
        notifyListeners();
        return false;
      } else {
        final data = <String, dynamic>{
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        };

        if (propertyId != null) data['property_id'] = propertyId;
        if (landId != null) data['land_id'] = landId;

        final response = await _client
            .from('favorites')
            .insert(data)
            .select()
            .single();

        final newFavorite = FavoriteModel.fromJson(response);
        _favorites.insert(0, newFavorite);
        notifyListeners();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  bool isFavorite(
    String userId, {
    String? propertyId,
    String? landId,
  }) {
    return _favorites.any(
      (f) =>
          f.userId == userId &&
          ((propertyId != null && f.propertyId == propertyId) ||
              (landId != null && f.landId == landId)),
    );
  }

  Future<List<PropertyModel>> getFavoriteProperties() async {
    final propertyIds = _favorites
        .where((f) => f.propertyId.isNotEmpty)
        .map((f) => f.propertyId)
        .toList();

    if (propertyIds.isEmpty) return [];

    try {
      final response = await _client
          .from('properties')
          .select()
          .inFilter('id', propertyIds);

      return (response as List<dynamic>)
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LandModel>> getFavoriteLands() async {
    final landIds = _favorites
        .where((f) => f.landId.isNotEmpty)
        .map((f) => f.landId)
        .toList();

    if (landIds.isEmpty) return [];

    try {
      final response = await _client
          .from('lands')
          .select()
          .inFilter('id', landIds);

      return (response as List<dynamic>)
          .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}
