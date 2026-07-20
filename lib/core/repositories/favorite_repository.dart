import '../models/favorite_model.dart';
import '../services/supabase_service.dart';

class FavoriteRepository {
  final _client = SupabaseService.client;
  static const _table = 'favorites';

  Future<List<FavoriteModel>> getFavorites(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<FavoriteModel> addFavorite(
    String userId, {
    String? propertyId,
    String? landId,
  }) async {
    final data = {
      'user_id': userId,
      'property_id': propertyId ?? '',
      'land_id': landId ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _client.from(_table).insert(data).select().single();

    return FavoriteModel.fromJson(response);
  }

  Future<void> removeFavorite(
    String userId, {
    String? propertyId,
    String? landId,
  }) async {
    var query = _client.from(_table).delete().eq('user_id', userId);

    if (propertyId != null) {
      query = query.eq('property_id', propertyId);
    }
    if (landId != null) {
      query = query.eq('land_id', landId);
    }

    await query;
  }

  Future<bool> isFavorite(
    String userId, {
    String? propertyId,
    String? landId,
  }) async {
    try {
      var query = _client.from(_table).select('id').eq('user_id', userId);

      if (propertyId != null) {
        query = query.eq('property_id', propertyId);
      }
      if (landId != null) {
        query = query.eq('land_id', landId);
      }

      final response = await query.maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
