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
        .select('*, property_images(image_url)')
        .inFilter('id', ids);

    return (response as List<dynamic>).map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      final imagesData = json.remove('property_images');
      final images = imagesData is List
          ? imagesData
              .map((row) => (row as Map)['image_url'] as String? ?? '')
              .where((url) => url.isNotEmpty)
              .toList()
          : <String>[];
      return PropertyModel.fromJson(json).copyWith(images: images);
    }).toList();
  }

  Future<List<LandModel>> fetchFavoriteLands(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url)')
        .inFilter('id', ids);

    return (response as List<dynamic>).map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      final imagesData = json.remove('land_images');
      final images = imagesData is List
          ? imagesData
              .map((row) => (row as Map)['image_url'] as String? ?? '')
              .where((url) => url.isNotEmpty)
              .toList()
          : <String>[];
      return LandModel.fromJson(json).copyWith(images: images);
    }).toList();
  }

  /// Contagem de favoritos por imóvel (alimenta o contador de "gostos" do
  /// feed Discover). Devolve uma entrada por id pedido, mesmo que zero.
  ///
  /// Usa a RPC `favorite_counts` (migration 021): a policy "read own" da
  /// tabela `favorites` não deixa ler contagens de terceiros — para
  /// utilizadores anónimos a query direta devolvia sempre 0.
  Future<Map<String, int>> countLikes(List<String> propertyIds) async {
    final counts = <String, int>{for (final id in propertyIds) id: 0};
    if (counts.isEmpty) return counts;

    final response = await _client.rpc(
      'favorite_counts',
      params: {'p_property_ids': propertyIds},
    );

    for (final row in response as List<dynamic>) {
      final map = row as Map<String, dynamic>;
      final id = map['property_id'] as String?;
      final likes = (map['likes'] as num?)?.toInt() ?? 0;
      if (id != null && counts.containsKey(id)) {
        counts[id] = likes;
      }
    }
    return counts;
  }
}