import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/property_model.dart';
import '../repositories/property_repository.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyRepository _repository = PropertyRepository();

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

  Future<void> loadProperties({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    _currentFilters = filters;
    notifyListeners();

    try {
      final response = await _repository.fetchProperties(
        filters: filters,
        page: 0,
        pageSize: AppConstants.defaultPageSize,
      );

      _properties = response;
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
      final response = await _repository.fetchProperties(
        filters: filters ?? _currentFilters,
        page: _currentPage,
        pageSize: AppConstants.defaultPageSize,
      );

      _properties.addAll(response);
      _hasMore = response.length >= AppConstants.defaultPageSize;
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
      _featuredProperties = await _repository.fetchFeatured();
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
      _selectedProperty = await _repository.fetchById(id);
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
      final newProperty = await _repository.create(property);
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
      await _repository.update(property);

      final updated = property.copyWith(
        images: List<String>.from(property.images),
      );
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
      await _repository.delete(id);

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
      _properties = await _repository.search(searchQuery);
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