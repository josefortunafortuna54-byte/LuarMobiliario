import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmail(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) {
    return _authService.signUpWithEmail(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );
  }

  Future<bool> ensureAuthUserExists(String email, String name) {
    return _authService.ensureAuthUserExists(email, name);
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> resetPassword(String email) => _authService.resetPassword(email);

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) {
    return _authService.updateProfile(
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  Future<UserModel?> getCurrentUser() => _authService.getCurrentUser();

  Stream<AuthState> get onAuthStateChange => _authService.onAuthStateChange;
}