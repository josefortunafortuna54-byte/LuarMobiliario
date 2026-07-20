import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import '../services/supabase_service.dart';

class SearchProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseService.client;

  String _query = '';
  String? _propertyType;
  String? _landType;
  String? _transactionType;
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

  String get query => _query;
  String? get propertyType => _propertyType;
  String? get landType => _landType;
  String? get transactionType => _transactionType;
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
  String? get error => _error;

  int get activeFilterCount {
    int count = 0;
    if (_query.isNotEmpty) count++;
    if (_propertyType != null) count++;
    if (_landType != null) count++;
    if (_transactionType != null) count++;
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
    String? transactionType,
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
    if (transactionType != null) _transactionType = transactionType;
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

  void clearFilters() {
    _query = '';
    _propertyType = null;
    _landType = null;
    _transactionType = null;
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
    notifyListeners();
  }

  Future<void> search() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final properties = await _searchProperties();
      final lands = await _searchLands();

      _results = [...properties, ...lands];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PropertyModel>> _searchProperties() async {
    var queryBuilder = _client
        .from('properties')
        .select()
        .eq('is_available', true);

    if (_query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
        'title.ilike.%$_query%,description.ilike.%$_query%,address.ilike.%$_query%,city.ilike.%$_query%,municipality.ilike.%$_query%,neighborhood.ilike.%$_query%',
      );
    }

    if (_transactionType != null) {
      queryBuilder = queryBuilder.eq('transaction_type', _transactionType!);
    }

    if (_city != null) {
      queryBuilder = queryBuilder.ilike('city', '%$_city%');
    }

    if (_municipality != null) {
      queryBuilder = queryBuilder.ilike('municipality', '%$_municipality%');
    }

    if (_neighborhood != null) {
      queryBuilder = queryBuilder.ilike('neighborhood', '%$_neighborhood%');
    }

    if (_minPrice != null) {
      queryBuilder = queryBuilder.gte('price', _minPrice!);
    }

    if (_maxPrice != null) {
      queryBuilder = queryBuilder.lte('price', _maxPrice!);
    }

    if (_minArea != null) {
      queryBuilder = queryBuilder.gte('area', _minArea!);
    }

    if (_maxArea != null) {
      queryBuilder = queryBuilder.lte('area', _maxArea!);
    }

    if (_bedrooms != null) {
      queryBuilder = queryBuilder.eq('bedrooms', _bedrooms!);
    }

    if (_bathrooms != null) {
      queryBuilder = queryBuilder.eq('bathrooms', _bathrooms!);
    }

    if (_garage != null) {
      queryBuilder = queryBuilder.gte('garage', _garage!);
    }

    if (_propertyType != null) {
      queryBuilder = queryBuilder.eq('type', _propertyType!);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .limit(AppConstants.defaultPageSize);

    return (response as List<dynamic>)
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<LandModel>> _searchLands() async {
    var queryBuilder = _client.from('lands').select().eq('is_available', true);

    if (_query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
        'title.ilike.%$_query%,description.ilike.%$_query%,address.ilike.%$_query%,city.ilike.%$_query%,municipality.ilike.%$_query%,neighborhood.ilike.%$_query%',
      );
    }

    if (_transactionType != null) {
      queryBuilder = queryBuilder.eq('transaction_type', _transactionType!);
    }

    if (_city != null) {
      queryBuilder = queryBuilder.ilike('city', '%$_city%');
    }

    if (_municipality != null) {
      queryBuilder = queryBuilder.ilike('municipality', '%$_municipality%');
    }

    if (_neighborhood != null) {
      queryBuilder = queryBuilder.ilike('neighborhood', '%$_neighborhood%');
    }

    if (_minPrice != null) {
      queryBuilder = queryBuilder.gte('price', _minPrice!);
    }

    if (_maxPrice != null) {
      queryBuilder = queryBuilder.lte('price', _maxPrice!);
    }

    if (_minArea != null) {
      queryBuilder = queryBuilder.gte('area', _minArea!);
    }

    if (_maxArea != null) {
      queryBuilder = queryBuilder.lte('area', _maxArea!);
    }

    if (_landType != null) {
      queryBuilder = queryBuilder.eq('type', _landType!);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .limit(AppConstants.defaultPageSize);

    return (response as List<dynamic>)
        .map((json) => LandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<PropertyModel> get propertyResults =>
      _results.whereType<PropertyModel>().toList();

  List<LandModel> get landResults => _results.whereType<LandModel>().toList();

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
