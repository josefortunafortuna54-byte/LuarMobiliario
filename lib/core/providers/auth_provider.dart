import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      _user = user;
    } catch (e) {
      _user = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email: email, password: password);
      final user = await _authService.getCurrentUser();
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      final user = await _authService.getCurrentUser();
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpPartner({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String companyName,
    required String nif,
    required String businessType,
    required String address,
    required String whatsapp,
    required String license,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpPartner(
        email: email,
        password: password,
        name: name,
        phone: phone,
        companyName: companyName,
        nif: nif,
        businessType: businessType,
        address: address,
        whatsapp: whatsapp,
        license: license,
      );
      final user = await _authService.getCurrentUser();
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      if (_user != null) {
        _user = _user!.copyWith(name: name, phone: phone, avatarUrl: avatarUrl);
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

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
