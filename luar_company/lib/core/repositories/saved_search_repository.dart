import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/saved_search_model.dart';
import '../services/supabase_service.dart';

class SavedSearchRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<SavedSearchModel>> fetchByUser(String userId) async {
    final response = await _client
        .from('saved_searches')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => SavedSearchModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SavedSearchModel> create({
    required String userId,
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    final response =
        await _client
            .from('saved_searches')
            .insert({
              'user_id': userId,
              'name': name,
              'filters': filters,
            })
            .select()
            .single();

    return SavedSearchModel.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client.from('saved_searches').delete().eq('id', id);
  }
}
