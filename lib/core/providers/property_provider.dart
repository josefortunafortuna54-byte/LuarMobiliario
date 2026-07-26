import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';

class PropertyProvider extends ChangeNotifier {
  SupabaseClient get _client => SupabaseService.client;

  List<PropertyModel> _properties = [];
  List<PropertyModel> _featuredProperties = [];
  PropertyModel? _selectedProperty;
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 0;
  Map<String, dynamic>? _currentFilters;

  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get featuredProperties => _featuredProperties;
  PropertyModel? get selectedProperty => _selectedProperty;
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
          case 'transactionType':
            query = query.eq('transaction_type', entry.value);
          case 'city':
            query = query.ilike('city', '%${entry.value}%');
          case 'municipality':
            query = query.ilike('municipality', '%${entry.value}%');
          case 'neighborhood':
            query = query.ilike('neighborhood', '%${entry.value}%');
          case 'minPrice':
            query = query.gte('price', entry.value);
          case 'maxPrice':
            query = query.lte('price', entry.value);
          case 'minArea':
            query = query.gte('area', entry.value);
          case 'maxArea':
            query = query.lte('area', entry.value);
          case 'bedrooms':
            query = query.eq('bedrooms', entry.value);
          case 'bathrooms':
            query = query.eq('bathrooms', entry.value);
          case 'garage':
            query = query.gte('garage', entry.value);
        }
      }
    }
    return query;
  }

  Future<void> loadProperties({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    _currentFilters = filters;
    notifyListeners();

    try {
      final from = 0;
      final to = AppConstants.defaultPageSize - 1;

      final query = _applyFilters(
        _client
            .from('properties')
            .select('*, property_images(image_url)')
            .eq('is_available', true),
        filters,
      );

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      _properties = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('property_images'));
        return PropertyModel.fromJson(j).copyWith(images: images);
      }).toList();

      _hasMore = _properties.length >= AppConstants.defaultPageSize;
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

      final query = _applyFilters(
        _client
            .from('properties')
            .select('*, property_images(image_url)')
            .eq('is_available', true),
        filters ?? _currentFilters,
      );

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      final newProperties = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('property_images'));
        return PropertyModel.fromJson(j).copyWith(images: images);
      }).toList();

      _properties.addAll(newProperties);
      _hasMore = newProperties.length >= AppConstants.defaultPageSize;
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
          .from('properties')
          .select('*, property_images(image_url)')
          .eq('is_featured', true)
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(10);

      _featuredProperties = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('property_images'));
        return PropertyModel.fromJson(j).copyWith(images: images);
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('properties')
          .select('*, property_images(image_url)')
          .eq('id', id)
          .single();

      final j = response;
      final images = _extractImageUrls(j.remove('property_images'));
      _selectedProperty = PropertyModel.fromJson(j).copyWith(images: images);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProperty(PropertyModel property) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = property.toJson();
      data.remove('id');
      final imageUrls = List<String>.from(data.remove('images') ?? []);
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('properties')
          .insert(data)
          .select()
          .single();

      final newProperty = PropertyModel.fromJson(response);

      if (imageUrls.isNotEmpty) {
        final imageRecords = imageUrls
            .map((url) => {'property_id': newProperty.id, 'image_url': url})
            .toList();
        await _client.from('property_images').insert(imageRecords);
      }

      _properties.insert(
        0,
        newProperty.copyWith(images: imageUrls),
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

  Future<bool> updateProperty(PropertyModel property) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = property.toJson();
      final imageUrls = List<String>.from(data.remove('images') ?? []);
      data['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('properties').update(data).eq('id', property.id);

      await _client.from('property_images').delete().eq('property_id', property.id);
      if (imageUrls.isNotEmpty) {
        final imageRecords = imageUrls
            .map((url) => {'property_id': property.id, 'image_url': url})
            .toList();
        await _client.from('property_images').insert(imageRecords);
      }

      final updated = property.copyWith(images: imageUrls);
      final index = _properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        _properties[index] = updated;
      }

      if (_selectedProperty?.id == property.id) {
        _selectedProperty = updated;
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

  Future<bool> deleteProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.from('property_images').delete().eq('property_id', id);

      await _client
          .from('properties')
          .update({'is_available': false})
          .eq('id', id);

      _properties.removeWhere((p) => p.id == id);

      if (_selectedProperty?.id == id) {
        _selectedProperty = null;
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

  Future<void> searchProperties(String searchQuery) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _client
          .from('properties')
          .select('*, property_images(image_url)')
          .eq('is_available', true)
          .or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%,municipality.ilike.%$searchQuery%,neighborhood.ilike.%$searchQuery%',
          )
          .order('created_at', ascending: false)
          .limit(AppConstants.defaultPageSize);

      _properties = (response as List).map((json) {
        final j = json as Map<String, dynamic>;
        final images = _extractImageUrls(j.remove('property_images'));
        return PropertyModel.fromJson(j).copyWith(images: images);
      }).toList();

      _hasMore = _properties.length >= AppConstants.defaultPageSize;
      _currentPage = 1;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedProperty() {
    _selectedProperty = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
