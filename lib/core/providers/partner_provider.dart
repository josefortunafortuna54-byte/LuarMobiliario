import 'package:flutter/foundation.dart';

import '../models/partner_model.dart';
import '../repositories/partner_repository.dart';

class PartnerProvider extends ChangeNotifier {
  final PartnerRepository _repository = PartnerRepository();

  List<PartnerModel> _partners = [];
  PartnerModel? _mine;
  bool _isLoading = false;
  String? _error;

  List<PartnerModel> get partners => _partners;
  PartnerModel? get mine => _mine;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _partners = await _repository.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMine(String userId) async {
    _error = null;

    try {
      _mine = await _repository.fetchMine(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> save(PartnerModel partner) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.save(partner);
      await loadMine(partner.userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.delete(id);
      _partners.removeWhere((p) => p.id == id);
      if (_mine?.id == id) _mine = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}