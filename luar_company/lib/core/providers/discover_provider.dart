import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/property_model.dart';
import '../repositories/property_repository.dart';
import '../utils/pagination.dart';

/// Estado do feed vertical (Luar Discover).
///
/// Mantém a lista de imóveis do feed, a paginação real a partir do backend
/// (Supabase) e os estados de carregamento/erro, sem interferir com o
/// [PropertyProvider] usado nas listagens tradicionais.
class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({PropertyRepository? repository})
    : _repository = repository ?? PropertyRepository();

  final PropertyRepository _repository;

  final List<PropertyModel> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 0;
  Map<String, dynamic>? _filters;

  List<PropertyModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && _items.isEmpty;

  /// Carrega a primeira página do feed, substituindo o conteúdo atual.
  Future<void> load({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    _hasMore = true;
    _page = 0;
    _filters = filters;
    notifyListeners();

    try {
      final result = await _repository.fetchProperties(
        filters: filters,
        page: 0,
        pageSize: AppConstants.defaultPageSize,
      );
      final slice = slicePage(result, AppConstants.defaultPageSize);
      _items
        ..clear()
        ..addAll(slice.items);
      _page = 1;
      _hasMore = slice.hasMore && _items.length < AppConstants.discoverMaxItems;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega a página seguinte sem duplicar pedidos em curso.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.fetchProperties(
        filters: _filters,
        page: _page,
        pageSize: AppConstants.defaultPageSize,
      );
      final slice = slicePage(result, AppConstants.defaultPageSize);
      _items.addAll(slice.items);
      _page++;
      _hasMore = slice.hasMore && _items.length < AppConstants.discoverMaxItems;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(filters: _filters);
}
