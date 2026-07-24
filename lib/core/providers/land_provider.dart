import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/land_model.dart';
import '../services/supabase_service.dart';

class LandProvider extends ChangeNotifier {
  SupabaseClient get _client => SupabaseService.client;

  List<LandModel> _lands = [];
  List<LandModel> _featuredLands = [];
  LandModel? _selectedLand;
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 0;

  List<LandModel> get lands => _lands;
  List<LandModel> get featuredLands => _featuredLands;
  LandModel? get selectedLand => _selectedLand;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

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

  Future<void> loadLands({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final from = 0;
      final to = AppConstants.defaultPageSize - 1;

      var query = _client.from('lands').select('*, land_images(image_url)').eq('is_available', true);

      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            switch (entry.key) {
              case 'minPrice':
                query = query.gte('price', entry.value);
              case 'maxPrice':
                query = query.lte('price', entry.value);
              case 'minArea':
                query = query.gte('area', entry.value);
              case 'maxArea':
                query = query.lte('area', entry.value);
              case 'type':
                query = query.eq('type', entry.value);
              case 'transactionType':
                query = query.eq('transaction_type', entry.value);
              case 'city':
                query = query.ilike('city', '%${entry.value}%');
              case 'municipality':
                query = query.ilike('municipality', '%${entry.value}%');
              case 'neighborhood':
                query = query.ilike('neighborhood', '%${entry.value}%');
            }
          }
        }
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      _lands = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('land_images'));
        return LandModel.fromJson(j).copyWith(images: images);
      }).toList();

      _hasMore = _lands.length >= AppConstants.defaultPageSize;
      _currentPage = 1;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({Map<String, dynamic>? filters}) async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final from = _currentPage * AppConstants.defaultPageSize;
      final to = from + AppConstants.defaultPageSize - 1;

      var query = _client.from('lands').select('*, land_images(image_url)').eq('is_available', true);

      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            switch (entry.key) {
              case 'minPrice':
                query = query.gte('price', entry.value);
              case 'maxPrice':
                query = query.lte('price', entry.value);
              case 'minArea':
                query = query.gte('area', entry.value);
              case 'maxArea':
                query = query.lte('area', entry.value);
              case 'type':
                query = query.eq('type', entry.value);
              case 'transactionType':
                query = query.eq('transaction_type', entry.value);
              case 'city':
                query = query.ilike('city', '%${entry.value}%');
              case 'municipality':
                query = query.ilike('municipality', '%${entry.value}%');
              case 'neighborhood':
                query = query.ilike('neighborhood', '%${entry.value}%');
            }
          }
        }
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      final newLands = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('land_images'));
        return LandModel.fromJson(j).copyWith(images: images);
      }).toList();

      _lands.addAll(newLands);
      _hasMore = newLands.length >= AppConstants.defaultPageSize;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeatured() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('lands')
          .select('*, land_images(image_url)')
          .eq('is_featured', true)
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(10);

      _featuredLands = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('land_images'));
        return LandModel.fromJson(j).copyWith(images: images);
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectLand(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('lands')
          .select('*, land_images(image_url)')
          .eq('id', id)
          .single();

      final j = response;
      final images = _extractImageUrls(j.remove('land_images'));
      _selectedLand = LandModel.fromJson(j).copyWith(images: images);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLand(LandModel land) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = land.toJson();
      data.remove('id');
      final imageUrls = List<String>.from(data.remove('images') ?? []);
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('lands')
          .insert(data)
          .select()
          .single();

      final newLand = LandModel.fromJson(response);

      if (imageUrls.isNotEmpty) {
        final imageRecords = imageUrls
            .map((url) => {'land_id': newLand.id, 'image_url': url})
            .toList();
        await _client.from('land_images').insert(imageRecords);
      }

      _lands.insert(
        0,
        newLand.copyWith(images: imageUrls),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLand(LandModel land) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      final updated = land.copyWith(images: imageUrls);
      final index = _lands.indexWhere((l) => l.id == land.id);
      if (index != -1) {
        _lands[index] = updated;
      }

      if (_selectedLand?.id == land.id) {
        _selectedLand = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLand(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.from('land_images').delete().eq('land_id', id);

      await _client.from('lands').update({'is_available': false}).eq('id', id);

      _lands.removeWhere((l) => l.id == id);

      if (_selectedLand?.id == id) {
        _selectedLand = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> searchLands(String searchQuery) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _client
          .from('lands')
          .select('*, land_images(image_url)')
          .eq('is_available', true)
          .or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%,municipality.ilike.%$searchQuery%,neighborhood.ilike.%$searchQuery%',
          )
          .order('created_at', ascending: false)
          .limit(AppConstants.defaultPageSize);

      _lands = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('land_images'));
        return LandModel.fromJson(j).copyWith(images: images);
      }).toList();

      _hasMore = _lands.length >= AppConstants.defaultPageSize;
      _currentPage = 1;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedLand() {
    _selectedLand = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
