import '../models/land_model.dart';
import '../services/supabase_service.dart';

class LandRepository {
  final _client = SupabaseService.client;
  static const _table = 'lands';

  Future<List<LandModel>> getLands({
    String? type,
    String? transactionType,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from(_table)
          .select()
          .eq('is_available', true);

      if (type != null) query = query.eq('type', type);
      if (transactionType != null) {
        query = query.eq('transaction_type', transactionType);
      }
      if (city != null) query = query.eq('city', city);
      if (minPrice != null) query = query.gte('price', minPrice);
      if (maxPrice != null) query = query.lte('price', maxPrice);
      if (minArea != null) query = query.gte('area', minArea);
      if (maxArea != null) query = query.lte('area', maxArea);

      final effectiveLimit = limit ?? 20;
      final effectiveOffset = offset ?? 0;

      final response = await query
          .order('created_at', ascending: false)
          .range(effectiveOffset, effectiveOffset + effectiveLimit - 1);

      return (response as List<dynamic>)
          .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<LandModel> getLandById(String id) async {
    final response =
        await _client.from(_table).select().eq('id', id).single();

    return LandModel.fromJson(response);
  }

  Future<List<LandModel>> getFeaturedLands() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('is_featured', true)
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List<dynamic>)
          .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<LandModel> createLand(LandModel land) async {
    final data = land.toJson()..remove('id');

    final response =
        await _client.from(_table).insert(data).select().single();

    return LandModel.fromJson(response);
  }

  Future<LandModel> updateLand(LandModel land) async {
    final data = land.toJson()
      ..['updated_at'] = DateTime.now().toIso8601String();

    final response =
        await _client
            .from(_table)
            .update(data)
            .eq('id', land.id)
            .select()
            .single();

    return LandModel.fromJson(response);
  }

  Future<void> deleteLand(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<List<LandModel>> searchLands(String query) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('is_available', true)
          .or('title.ilike.%$query%,description.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%,neighborhood.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List<dynamic>)
          .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
