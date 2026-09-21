import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/land_model.dart';
import '../services/supabase_service.dart';

class LandRepository {
  SupabaseClient get _client => SupabaseService.client;

  List<LandModel> _mapResponse(List<dynamic> response) {
    return response.map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      final images = _extractImageUrls(json.remove('land_images'));
      return LandModel.fromJson(json).copyWith(images: images);
    }).toList();
  }

  List<String> _extractImageUrls(dynamic imagesData) {
    if (imagesData == null) return [];
    try {
      return (imagesData as List)
          .map((img) => (img as Map<String, dynamic>)['image_url'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }

  PostgrestFilterBuilder<dynamic> _applyFilters(
    PostgrestFilterBuilder<dynamic> query,
    Map<String, dynamic>? filters,
  ) {
    if (filters == null) return query;
    for (final entry in filters.entries) {
      if (entry.value != null) {
        switch (entry.key) {
          case 'type':
            query = query.eq('type', entry.value);
            break;
          case 'transactionType':
            query = query.eq('transaction_type', entry.value);
            break;
          case 'city':
            query = query.ilike('city', '%${entry.value}%');
            break;
          case 'municipality':
            query = query.ilike('municipality', '%${entry.value}%');
            break;
          case 'neighborhood':
            query = query.ilike('neighborhood', '%${entry.value}%');
            break;
          case 'minPrice':
            query = query.gte('price', entry.value);
            break;
          case 'maxPrice':
            query = query.lte('price', entry.value);
            break;
          case 'minArea':
            query = query.gte('area', entry.value);
            break;
          case 'maxArea':
            query = query.lte('area', entry.value);
            break;
        }
      }
    }
    return query;
  }

  Future<List<LandModel>> fetchLands({
    Map<String, dynamic>? filters,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await _applyFilters(
      _client
          .from('lands')
          .select('*, land_images(image_url)')
          .eq('is_available', true),
      filters,
    )
        .order('created_at', ascending: false)
        .range(from, to);

    return _mapResponse(response as List);
  }

  Future<List<LandModel>> fetchFeatured({int limit = 10}) async {
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url)')
        .eq('is_featured', true)
        .eq('is_available', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return _mapResponse(response as List);
  }

  Future<LandModel> fetchById(String id) async {
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url)')
        .eq('id', id)
        .single();

    final json = Map<String, dynamic>.from(response as Map);
    final images = _extractImageUrls(json.remove('land_images'));
    return LandModel.fromJson(json).copyWith(images: images);
  }

  Future<LandModel> create(LandModel land) async {
    final data = land.toJson();
    data.remove('id');
    final imageUrls = List<String>.from(data.remove('images') ?? []);
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client.from('lands').insert(data).select().single();

    final newLand = LandModel.fromJson(response);

    if (imageUrls.isNotEmpty) {
      final imageRecords = imageUrls
          .map((url) => {'land_id': newLand.id, 'image_url': url})
          .toList();
      await _client.from('land_images').insert(imageRecords);
    }

    return newLand.copyWith(images: imageUrls);
  }

  Future<void> update(LandModel land) async {
    final data = land.toJson();
    final imageUrls = List<String>.from(data.remove('images') ?? []);
    data['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('lands').update(data).eq('id', land.id);

    await _client.from('land_images').delete().eq('land_id', land.id);
    if (imageUrls.isNotEmpty) {
      final imageRecords = imageUrls
          .map((url) => {'land_id': land.id, 'image_url': url})
          .toList();
      await _client.from('land_images').insert(imageRecords);
    }
  }

  Future<void> delete(String id) async {
    await _client.from('land_images').delete().eq('land_id', id);

    await _client.from('lands').update({'is_available': false}).eq('id', id);
  }

  Future<List<LandModel>> search(String searchQuery) async {
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url)')
        .eq('is_available', true)
        .or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%,municipality.ilike.%$searchQuery%,neighborhood.ilike.%$searchQuery%',
        )
        .order('created_at', ascending: false)
        .limit(AppConstants.defaultPageSize);

    return _mapResponse(response as List);
  }

  Future<List<LandModel>> searchAdvanced({
    String? query,
    String? type,
    String? transactionType,
    String? city,
    String? municipality,
    String? neighborhood,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
  }) async {
    var queryBuilder = _client.from('lands').select().eq('is_available', true);

    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
        'title.ilike.%$query%,description.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%,municipality.ilike.%$query%,neighborhood.ilike.%$query%',
      );
    }

    if (transactionType != null) {
      queryBuilder = queryBuilder.eq('transaction_type', transactionType);
    }

    if (city != null) {
      queryBuilder = queryBuilder.ilike('city', '%$city%');
    }

    if (municipality != null) {
      queryBuilder = queryBuilder.ilike('municipality', '%$municipality%');
    }

    if (neighborhood != null) {
      queryBuilder = queryBuilder.ilike('neighborhood', '%$neighborhood%');
    }

    if (minPrice != null) {
      queryBuilder = queryBuilder.gte('price', minPrice);
    }

    if (maxPrice != null) {
      queryBuilder = queryBuilder.lte('price', maxPrice);
    }

    if (minArea != null) {
      queryBuilder = queryBuilder.gte('area', minArea);
    }

    if (maxArea != null) {
      queryBuilder = queryBuilder.lte('area', maxArea);
    }

    if (type != null) {
      queryBuilder = queryBuilder.eq('type', type);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .limit(AppConstants.defaultPageSize);

    return (response as List)
        .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<LandModel>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client.from('lands').select().inFilter('id', ids);

    return (response as List)
        .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}