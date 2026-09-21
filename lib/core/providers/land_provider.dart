import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/land_model.dart';
import '../repositories/land_repository.dart';

class LandProvider extends ChangeNotifier {
  final LandRepository _repository = LandRepository();

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

  Future<void> loadLands({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      _lands = await _repository.fetchLands(
        filters: filters,
        page: 0,
        pageSize: AppConstants.defaultPageSize,
      );

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
      final newLands = await _repository.fetchLands(
        filters: filters,
        page: _currentPage,
        pageSize: AppConstants.defaultPageSize,
      );

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
      _featuredLands = await _repository.fetchFeatured();
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
      _selectedLand = await _repository.fetchById(id);
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
      final newLand = await _repository.create(land);
      _lands.insert(0, newLand);
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
      await _repository.update(land);

      final updated = land.copyWith(images: List<String>.from(land.images));
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
      await _repository.delete(id);

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
      _lands = await _repository.search(searchQuery);
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