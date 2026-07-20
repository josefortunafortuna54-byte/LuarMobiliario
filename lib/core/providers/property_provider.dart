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

  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get featuredProperties => _featuredProperties;
  PropertyModel? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadProperties({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final from = 0;
      final to = AppConstants.defaultPageSize - 1;

      final response = await _client
          .from('properties')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .range(from, to);

      _properties = (response as List)
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();

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

      final response = await _client
          .from('properties')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .range(from, to);

      final newProperties = (response as List)
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();

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
          .select()
          .eq('is_featured', true)
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(10);

      _featuredProperties = (response as List)
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
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
          .select()
          .eq('id', id)
          .single();

      _selectedProperty = PropertyModel.fromJson(response);
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
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('properties')
          .insert(data)
          .select()
          .single();

      final newProperty = PropertyModel.fromJson(response);
      _properties.insert(0, newProperty);
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
      data['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('properties').update(data).eq('id', property.id);

      final index = _properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        _properties[index] = property;
      }

      if (_selectedProperty?.id == property.id) {
        _selectedProperty = property;
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
          .select()
          .eq('is_available', true)
          .or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%,municipality.ilike.%$searchQuery%,neighborhood.ilike.%$searchQuery%',
          )
          .order('created_at', ascending: false)
          .limit(AppConstants.defaultPageSize);

      _properties = (response as List)
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();

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
