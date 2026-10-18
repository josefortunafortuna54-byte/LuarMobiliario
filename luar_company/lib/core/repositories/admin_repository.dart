import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AdminRepository {
  SupabaseClient get _client => SupabaseService.client;

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

  /// Métricas agregadas para o painel de análise do administrador.
  Future<AdminAnalytics> fetchAnalytics() async {
    final results = await Future.wait([
      _client
          .from('properties')
          .select('id,title,type,price,views')
          .eq('is_available', true),
      _client
          .from('lands')
          .select('id,title,type,price,views')
          .eq('is_available', true),
      _client.from('users').select('id,created_at'),
      _client.from('bookings').select('id,status'),
    ]);

    final properties = results[0] as List;
    final lands = results[1] as List;
    final users = results[2] as List;
    final bookings = results[3] as List;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    var newUsers30d = 0;
    for (final u in users) {
      final createdAt = DateTime.tryParse('${(u as Map)['created_at']}');
      if (createdAt != null && createdAt.isAfter(thirtyDaysAgo)) newUsers30d++;
    }

    final propertiesByType = <String, int>{};
    var salePricesSum = 0.0;
    var salePricesCount = 0;
    for (final p in properties) {
      final map = p as Map;
      final type = '${map['type']}';
      propertiesByType[type] = (propertiesByType[type] ?? 0) + 1;
      final price = (map['price'] as num?)?.toDouble() ?? 0;
      if (price > 0) {
        salePricesSum += price;
        salePricesCount++;
      }
    }

    final landsByType = <String, int>{};
    for (final l in lands) {
      final type = '${(l as Map)['type']}';
      landsByType[type] = (landsByType[type] ?? 0) + 1;
    }

    var pendingBookings = 0;
    for (final b in bookings) {
      if ('${(b as Map)['status']}' == 'pending') pendingBookings++;
    }

    final viewed = <TopViewedListing>[];
    for (final p in properties) {
      final map = p as Map;
      viewed.add(TopViewedListing(
        title: '${map['title']}',
        views: (map['views'] as num?)?.toInt() ?? 0,
      ));
    }
    for (final l in lands) {
      final map = l as Map;
      viewed.add(TopViewedListing(
        title: '${map['title']}',
        views: (map['views'] as num?)?.toInt() ?? 0,
      ));
    }
    viewed.sort((a, b) => b.views.compareTo(a.views));
    final topViewed = viewed.where((v) => v.views > 0).take(5).toList();

    return AdminAnalytics(
      newUsers30d: newUsers30d,
      pendingBookings: pendingBookings,
      totalBookings: bookings.length,
      averageSalePrice: salePricesCount > 0 ? salePricesSum / salePricesCount : 0,
      propertiesByType: propertiesByType,
      landsByType: landsByType,
      topViewed: topViewed,
    );
  }
}

class TopViewedListing {
  const TopViewedListing({required this.title, required this.views});

  final String title;
  final int views;
}

class AdminAnalytics {
  const AdminAnalytics({
    required this.newUsers30d,
    required this.pendingBookings,
    required this.totalBookings,
    required this.averageSalePrice,
    required this.propertiesByType,
    required this.landsByType,
    required this.topViewed,
  });

  final int newUsers30d;
  final int pendingBookings;
  final int totalBookings;
  final double averageSalePrice;
  final Map<String, int> propertiesByType;
  final Map<String, int> landsByType;
  final List<TopViewedListing> topViewed;
}