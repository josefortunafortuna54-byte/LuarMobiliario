import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/property_model.dart';
import '../repositories/property_repository.dart';
import '../utils/error_mapper.dart';
import '../utils/pagination.dart';

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
      final page = await _repository.fetchProperties(
        filters: filters,
        page: 0,
        pageSize: AppConstants.defaultPageSize,
      );
      final slice = slicePage(page, AppConstants.defaultPageSize);

      _properties = slice.items;
      _hasMore = slice.hasMore;
      _currentPage = 1;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
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
      final page = await _repository.fetchProperties(
        filters: filters ?? _currentFilters,
        page: _currentPage,
        pageSize: AppConstants.defaultPageSize,
      );
      final slice = slicePage(page, AppConstants.defaultPageSize);

      _properties.addAll(slice.items);
      _hasMore = slice.hasMore;
      _currentPage++;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
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
      _error = ErrorMapper.toMessage(e);
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
      _repository.registerView(id);
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
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
      _error = ErrorMapper.toMessage(e);
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
      _error = ErrorMapper.toMessage(e);
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
      _error = ErrorMapper.toMessage(e);
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
    // A pesquisa textual substitui a listagem filtrada: o loadMore seguinte
    // tem de partir da pesquisa, não dos filtros antigos.
    _currentFilters = null;
    notifyListeners();

    try {
      final page = await _repository.search(searchQuery);
      final slice = slicePage(page, AppConstants.defaultPageSize);
      _properties = slice.items;
      _hasMore = slice.hasMore;
      _currentPage = 1;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
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
