import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorite_model.dart';
import '../models/land_model.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';

class FavoriteRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<FavoriteModel>> fetchFavorites(String userId) async {
    final response = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> remove(String favoriteId) async {
    await _client.from('favorites').delete().eq('id', favoriteId);
  }

  Future<FavoriteModel> add({
    required String userId,
    String? propertyId,
    String? landId,
  }) async {
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

    return FavoriteModel.fromJson(response);
  }

  Future<List<PropertyModel>> fetchFavoriteProperties(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client
        .from('properties')
        .select()
        .inFilter('id', ids);

    return (response as List<dynamic>)
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<LandModel>> fetchFavoriteLands(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client.from('lands').select().inFilter('id', ids);

    return (response as List<dynamic>)
        .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}