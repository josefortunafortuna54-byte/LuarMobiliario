import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;

  Session? get currentSession => _auth.currentSession;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        await _client.from(AppConstants.usersTable).upsert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'role': UserRole.client.name,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Garante que o email existe em auth.users (Supabase Auth).
  /// Se não existir, cria o utilizador em auth com senha temporária.
  /// Retorna true se o utilizador já existia ou foi criado com sucesso.
  Future<bool> ensureAuthUserExists(String email, String name) async {
    try {
      // Tenta criar o utilizador em auth.users
      // Se já existir, o Supabase retorna erro "User already registered" — o que é bom
      final tempPassword = 'AdminTemp${DateTime.now().millisecondsSinceEpoch}!';
      await _auth.signUp(
        email: email,
        password: tempPassword,
        data: {'name': name},
      );
      return true;
    } on AuthException catch (e) {
      // Se o utilizador já existe em auth.users, está tudo bem
      final msg = e.message.toLowerCase();
      if (msg.contains('already') ||
          msg.contains('already registered') ||
          msg.contains('already been registered') ||
          msg.contains('duplicate')) {
        return true;
      }
      // Para outros erros, relança para o chamador tratar
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userAttributes = <String, dynamic>{};
      if (name != null) userAttributes['name'] = name;

      if (userAttributes.isNotEmpty) {
        await _auth.updateUser(
          UserAttributes(data: userAttributes),
        );
      }
    } catch (_) {}

    if (currentUser != null) {
      final dbUpdates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        'name': ?name,
        'phone': ?phone,
        'avatar_url': ?avatarUrl,
      };

      await _client
          .from(AppConstants.usersTable)
          .update(dbUpdates)
          .eq('id', currentUser!.id);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from(AppConstants.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
}
