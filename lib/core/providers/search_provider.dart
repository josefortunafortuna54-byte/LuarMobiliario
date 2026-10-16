import 'package:flutter/foundation.dart';

import '../constants/app_categories.dart';
import '../constants/app_constants.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import '../repositories/land_repository.dart';
import '../repositories/property_repository.dart';

class SearchProvider extends ChangeNotifier {
  final PropertyRepository _propertyRepository = PropertyRepository();
  final LandRepository _landRepository = LandRepository();

  String _query = '';
  String? _propertyType;
  String? _landType;
  String? _purpose;
  String? _transactionType;
  String? _province;
  String? _city;
  String? _municipality;
  String? _neighborhood;
  double? _minPrice;
  double? _maxPrice;
  double? _minArea;
  double? _maxArea;
  int? _bedrooms;
  int? _bathrooms;
  int? _garage;

  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _error;
  String _sortOption = 'recent';

  int _page = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  static const int _pageSize = AppConstants.defaultPageSize;

  String get query => _query;
  String? get propertyType => _propertyType;
  String? get landType => _landType;
  String? get purpose => _purpose;
  String? get transactionType => _transactionType;
  String? get province => _province;
  String? get city => _city;
  String? get municipality => _municipality;
  String? get neighborhood => _neighborhood;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  double? get minArea => _minArea;
  double? get maxArea => _maxArea;
  int? get bedrooms => _bedrooms;
  int? get bathrooms => _bathrooms;
  int? get garage => _garage;
  List<dynamic> get results => _results;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Opção de ordenação aplicada aos resultados na UI
  /// (`recent`, `priceAsc`, `priceDesc`, `areaDesc`).
  String get sortOption => _sortOption;

  /// Altera a ordenação dos resultados (client-side, sobre o que já foi
  /// carregado). Não refaz a pesquisa no backend.
  void setSort(String option) {
    if (_sortOption == option) return;
    _sortOption = option;
    notifyListeners();
  }

  /// `true` quando há filtros aplicados mas nenhum resultado — usado para
  /// distinguir o estado vazio inicial do estado vazio "sem correspondências".
  bool get isEmptyWithFilters =>
      !_isLoading && _results.isEmpty && activeFilterCount > 0;

  int get activeFilterCount {
    int count = 0;
    if (_query.isNotEmpty) count++;
    if (_propertyType != null) count++;
    if (_landType != null) count++;
    if (_purpose != null) count++;
    if (_transactionType != null) count++;
    if (_province != null) count++;
    if (_city != null) count++;
    if (_municipality != null) count++;
    if (_neighborhood != null) count++;
    if (_minPrice != null) count++;
    if (_maxPrice != null) count++;
    if (_minArea != null) count++;
    if (_maxArea != null) count++;
    if (_bedrooms != null) count++;
    if (_bathrooms != null) count++;
    if (_garage != null) count++;
    return count;
  }

  void setFilter({
    String? query,
    String? propertyType,
    String? landType,
    String? purpose,
    String? transactionType,
    String? province,
    String? city,
    String? municipality,
    String? neighborhood,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    int? bathrooms,
    int? garage,
  }) {
    if (query != null) _query = query;
    if (propertyType != null) _propertyType = propertyType;
    if (landType != null) _landType = landType;
    if (purpose != null) _purpose = purpose;
    if (transactionType != null) _transactionType = transactionType;
    if (province != null) _province = province;
    if (city != null) _city = city;
    if (municipality != null) _municipality = municipality;
    if (neighborhood != null) _neighborhood = neighborhood;
    if (minPrice != null) _minPrice = minPrice;
    if (maxPrice != null) _maxPrice = maxPrice;
    if (minArea != null) _minArea = minArea;
    if (maxArea != null) _maxArea = maxArea;
    if (bedrooms != null) _bedrooms = bedrooms;
    if (bathrooms != null) _bathrooms = bathrooms;
    if (garage != null) _garage = garage;
    notifyListeners();
  }

  /// Aplica o conjunto completo de filtros da folha de filtros, atribuindo
  /// diretamente (incluindo nulos) para que filtros removidos na folha sejam
  /// efetivamente limpos — o [setFilter] ignora valores nulos.
  void applyFilters({
    String? propertyType,
    String? landType,
    String? purpose,
    String? transactionType,
    String? province,
    String? city,
    String? municipality,
    String? neighborhood,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    int? bathrooms,
    int? garage,
  }) {
    _propertyType = propertyType;
    _landType = landType;
    _purpose = purpose;
    _transactionType = transactionType;
    _province = province;
    _city = city;
    _municipality = municipality;
    _neighborhood = neighborhood;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _minArea = minArea;
    _maxArea = maxArea;
    _bedrooms = bedrooms;
    _bathrooms = bathrooms;
    _garage = garage;
    notifyListeners();
  }

  /// Remove um filtro individual (o [setFilter] ignora valores nulos, pelo que
  /// a limpeza tem de ser feita por chave).
  void removeFilter(String key) {
    switch (key) {
      case 'query':
        _query = '';
        break;
      case 'propertyType':
        _propertyType = null;
        break;
      case 'landType':
        _landType = null;
        break;
      case 'purpose':
        _purpose = null;
        break;
      case 'transactionType':
        _transactionType = null;
        break;
      case 'province':
        _province = null;
        break;
      case 'city':
        _city = null;
        break;
      case 'municipality':
        _municipality = null;
        break;
      case 'neighborhood':
        _neighborhood = null;
        break;
      case 'minPrice':
        _minPrice = null;
        break;
      case 'maxPrice':
        _maxPrice = null;
        break;
      case 'minArea':
        _minArea = null;
        break;
      case 'maxArea':
        _maxArea = null;
        break;
      case 'bedrooms':
        _bedrooms = null;
        break;
      case 'bathrooms':
        _bathrooms = null;
        break;
      case 'garage':
        _garage = null;
        break;
      default:
        return;
    }
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _propertyType = null;
    _landType = null;
    _purpose = null;
    _transactionType = null;
    _province = null;
    _city = null;
    _municipality = null;
    _neighborhood = null;
    _minPrice = null;
    _maxPrice = null;
    _minArea = null;
    _maxArea = null;
    _bedrooms = null;
    _bathrooms = null;
    _garage = null;
    _results = [];
    _page = 0;
    _hasMore = false;
    notifyListeners();
  }

  Future<void> search() async {
    _isLoading = true;
    _error = null;
    _page = 0;
    _hasMore = false;
    notifyListeners();

    try {
      _results = await _fetchPage(0);
      _hasMore = _results.length >= _pageSize;
    } catch (e) {
      _error = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final next = _page + 1;
      final page = await _fetchPage(next);
      if (page.isEmpty) {
        _hasMore = false;
      } else {
        _page = next;
        _results = [..._results, ...page];
        _hasMore = page.length >= _pageSize;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> _fetchPage(int page) async {
    // A finalidade (residencial/comercial) restringe os tipos de imóvel e
    // não se aplica aos terrenos, que têm classificação própria.
    final purposeTypes = purposePropertyTypes(_purpose);

    final properties = await _propertyRepository.searchAdvanced(
      query: _query,
      type: _propertyType,
      types: purposeTypes,
      transactionType: _transactionType,
      province: _province,
      city: _city,
      municipality: _municipality,
      neighborhood: _neighborhood,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minArea: _minArea,
      maxArea: _maxArea,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      garage: _garage,
      page: page,
      pageSize: _pageSize,
    );

    if (purposeTypes != null) return properties;

    final lands = await _landRepository.searchAdvanced(
      query: _query,
      type: _landType,
      transactionType: _transactionType,
      province: _province,
      city: _city,
      municipality: _municipality,
      neighborhood: _neighborhood,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minArea: _minArea,
      maxArea: _maxArea,
      page: page,
      pageSize: _pageSize,
    );

    return [...properties, ...lands];
  }

  List<PropertyModel> get propertyResults {
    final list = _results.whereType<PropertyModel>().toList();
    switch (_sortOption) {
      case 'priceAsc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'areaDesc':
        list.sort((a, b) => b.area.compareTo(a.area));
        break;
      case 'recent':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  List<LandModel> get landResults {
    final list = _results.whereType<LandModel>().toList();
    switch (_sortOption) {
      case 'priceAsc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'areaDesc':
        list.sort((a, b) => b.area.compareTo(a.area));
        break;
      case 'recent':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
