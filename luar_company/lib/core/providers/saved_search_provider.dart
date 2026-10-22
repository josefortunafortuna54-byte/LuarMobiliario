import 'package:flutter/foundation.dart';

import '../models/saved_search_model.dart';
import '../repositories/saved_search_repository.dart';
import '../utils/error_mapper.dart';

class SavedSearchProvider extends ChangeNotifier {
  SavedSearchProvider({SavedSearchRepository? repository})
    : _repository = repository ?? SavedSearchRepository();

  final SavedSearchRepository _repository;

  List<SavedSearchModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<SavedSearchModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _items.isEmpty;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.fetchByUser(userId);
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SavedSearchModel?> save({
    required String userId,
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 60) return null;

    try {
      final item = await _repository.create(
        userId: userId,
        name: trimmed,
        filters: filters,
      );
      _items = [item, ..._items];
      _error = null;
      notifyListeners();
      return item;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> remove(String id) async {
    final previous = _items;
    _items = _items.where((s) => s.id != id).toList();
    notifyListeners();

    try {
      await _repository.delete(id);
      return true;
    } catch (e) {
      _items = previous;
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
      return false;
    }
  }
}
