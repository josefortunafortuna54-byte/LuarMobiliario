import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/review_model.dart';
import '../services/supabase_service.dart';

class ReviewRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<ReviewModel>> fetchByProperty(String propertyId) async {
    final response = await _client
        .from('reviews')
        .select('*, user:users(name)')
        .eq('property_id', propertyId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Cria ou atualiza (upsert) a avaliação de um utilizador a um imóvel.
  /// A restrição UNIQUE (property_id, user_id) garante uma avaliação por
  /// utilizador; em conflito, atualiza rating/comment/updated_at.
  Future<ReviewModel> upsert({
    required String propertyId,
    required String userId,
    required int rating,
    String comment = '',
  }) async {
    final response =
        await _client
            .from('reviews')
            .upsert(
              {
                'property_id': propertyId,
                'user_id': userId,
                'rating': rating,
                'comment': comment,
                'updated_at': DateTime.now().toIso8601String(),
              },
              onConflict: 'property_id,user_id',
            )
            .select('*, user:users(name)')
            .single();

    return ReviewModel.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client.from('reviews').delete().eq('id', id);
  }
}
