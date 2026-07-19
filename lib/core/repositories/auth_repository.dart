import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final _client = SupabaseService.client;

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response =
          await _client
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> updateProfile(
    String userId, {
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final response =
        await _client
            .from('users')
            .update(updates)
            .eq('id', userId)
            .select()
            .single();

    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    await _client.from('users').delete().eq('id', userId);
  }
}
