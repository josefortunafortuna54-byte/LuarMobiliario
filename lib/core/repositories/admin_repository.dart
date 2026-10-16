import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AdminRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<({int properties, int lands, int users, int unreadMessages})>
      fetchStats() async {
    final results = await Future.wait([
      _client.from('properties').select('id').eq('is_available', true),
      _client.from('lands').select('id').eq('is_available', true),
      _client.from('users').select('id'),
      _client.from('messages').select('id').eq('is_read', false),
    ]);

    return (
      properties: (results[0] as List).length,
      lands: (results[1] as List).length,
      users: (results[2] as List).length,
      unreadMessages: (results[3] as List).length,
    );
  }

  Future<List<UserModel>> fetchUsers() async {
    final response = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    await _client.from('users').update({'role': role.name}).eq('id', userId);
  }

  /// Altera o estado de verificação de um anunciante e regista a ação no
  /// moderation_log. A migration 018 propaga `verified` para
  /// `properties.agent_verified`/`lands.agent_verified` via trigger.
  Future<void> setUserVerified({
    required String userId,
    required bool verified,
    required String adminId,
  }) async {
    await _client.from('users').update({'verified': verified}).eq('id', userId);
    await _client.from('moderation_log').insert({
      'actor_id': adminId,
      'action': verified ? 'verify_user' : 'unverify_user',
      'target_type': 'user',
      'target_id': userId,
      'metadata': {'verified': verified},
    });
  }

  /// Apaga um utilizador através do RPC `delete_user` (SECURITY DEFINER), que
  /// valida o papel de admin no servidor. `auth.admin.deleteUser` exigiria a
  /// service_role key, indisponível no cliente.
  Future<void> deleteUser(String userId) async {
    await _client.rpc('delete_user', params: {'p_user_id': userId});
  }
}