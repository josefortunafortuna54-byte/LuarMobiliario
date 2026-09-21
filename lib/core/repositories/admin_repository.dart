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

  Future<void> deleteUser(String userId) async {
    await _client.auth.admin.deleteUser(userId);
  }
}