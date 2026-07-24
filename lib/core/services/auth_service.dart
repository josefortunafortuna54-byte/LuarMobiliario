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

  Future<AuthResponse> signUpPartner({
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
          'phone': phone,
          'role': UserRole.agent.name,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await _client.from(AppConstants.partnersTable).upsert({
          'user_id': response.user!.id,
          'company_name': companyName,
          'nif': nif,
          'business_type': businessType,
          'address': address,
          'whatsapp': whatsapp,
          'license': license,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to sign up partner: $e');
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
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
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
