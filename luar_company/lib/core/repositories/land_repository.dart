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
      final videos = _extractVideoUrls(json.remove('land_videos'));
      return LandModel.fromJson(json).copyWith(images: images, videos: videos);
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

  List<String> _extractVideoUrls(dynamic videosData) {
    if (videosData == null) return [];
    try {
      return (videosData as List)
          .map((video) => (video as Map<String, dynamic>)['video_url'] as String)
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
          case 'province':
            query = query.ilike('province', '%${entry.value}%');
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
          .select('*, land_images(image_url), land_videos(video_url)')
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
        .select('*, land_images(image_url), land_videos(video_url)')
        .eq('is_featured', true)
        .eq('is_available', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return _mapResponse(response as List);
  }

  /// Registo de visualização (analytics), melhor esforço.
  Future<void> registerView(String id) async {
    try {
      await _client.rpc(
        'register_listing_view',
        params: {'p_kind': 'land', 'p_id': id},
      );
    } catch (_) {
      // Telemetria não crítica.
    }
  }

  Future<LandModel> fetchById(String id) async {
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url), land_videos(video_url)')
        .eq('id', id)
        .single();

    final json = Map<String, dynamic>.from(response as Map);
    final images = _extractImageUrls(json.remove('land_images'));
    final videos = _extractVideoUrls(json.remove('land_videos'));
    return LandModel.fromJson(json).copyWith(images: images, videos: videos);
  }

  Future<LandModel> create(LandModel land) async {
    final data = land.toJson();
    data.remove('id');
    final imageUrls = List<String>.from(data.remove('images') ?? []);
    final videoUrls = List<String>.from(data.remove('videos') ?? []);
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

    if (videoUrls.isNotEmpty) {
      final videoRecords = videoUrls
          .map((url) => {'land_id': newLand.id, 'video_url': url})
          .toList();
      await _client.from('land_videos').insert(videoRecords);
    }

    return newLand.copyWith(images: imageUrls, videos: videoUrls);
  }

  Future<void> update(LandModel land) async {
    final data = land.toJson();
    final imageUrls = List<String>.from(data.remove('images') ?? []);
    final videoUrls = List<String>.from(data.remove('videos') ?? []);
    data['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('lands').update(data).eq('id', land.id);

    await _client.from('land_images').delete().eq('land_id', land.id);
    if (imageUrls.isNotEmpty) {
      final imageRecords = imageUrls
          .map((url) => {'land_id': land.id, 'image_url': url})
          .toList();
      await _client.from('land_images').insert(imageRecords);
    }

    await _client.from('land_videos').delete().eq('land_id', land.id);
    if (videoUrls.isNotEmpty) {
      final videoRecords = videoUrls
          .map((url) => {'land_id': land.id, 'video_url': url})
          .toList();
      await _client.from('land_videos').insert(videoRecords);
    }
  }

  Future<void> delete(String id) async {
    await _client.from('land_images').delete().eq('land_id', id);
    await _client.from('land_videos').delete().eq('land_id', id);

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
    String? province,
    String? city,
    String? municipality,
    String? neighborhood,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    var queryBuilder = _client
        .from('lands')
        .select('*, land_images(image_url), land_videos(video_url)')
        .eq('is_available', true);

    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
        'title.ilike.%$query%,description.ilike.%$query%,address.ilike.%$query%,province.ilike.%$query%,city.ilike.%$query%,municipality.ilike.%$query%,neighborhood.ilike.%$query%',
      );
    }

    if (transactionType != null) {
      queryBuilder = queryBuilder.eq('transaction_type', transactionType);
    }

    if (province != null) {
      queryBuilder = queryBuilder.ilike('province', '%$province%');
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

    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await queryBuilder
        .order(orderBy, ascending: ascending)
        .range(from, to);

    return _mapResponse(response as List);
  }

  /// Terrenos do agente (inclui os indisponíveis, para gestão própria).
  Future<List<LandModel>> fetchByAgent(String agentId) async {
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url), land_videos(video_url)')
        .eq('agent_id', agentId)
        .order('created_at', ascending: false);

    return _mapResponse(response as List);
  }

  /// Número de terrenos do agente (estatística do perfil).
  Future<int> countByAgent(String agentId) async {
    final response = await _client
        .from('lands')
        .select('id')
        .eq('agent_id', agentId);
    return (response as List).length;
  }

  /// Nº de terrenos ativos do agente (para a aprovação do perfil).
  Future<int> countAvailableByAgent(String agentId) async {
    final response = await _client
        .from('lands')
        .select('id')
        .eq('agent_id', agentId)
        .eq('is_available', true);
    return (response as List).length;
  }

  /// Ativa ou desativa a publicação de um terreno do próprio agente.
  Future<void> setAvailable(String id, bool available) async {
    await _client.from('lands').update({'is_available': available}).eq('id', id);
  }

  Future<List<LandModel>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client
        .from('lands')
        .select('*, land_images(image_url), land_videos(video_url)')
        .inFilter('id', ids);

    return _mapResponse(response as List);
  }
}