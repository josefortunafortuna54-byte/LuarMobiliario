import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/partner_model.dart';
import '../services/supabase_service.dart';

class PartnerRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<PartnerModel>> fetchAll() async {
    final response = await _client
        .from(AppConstants.partnersTable)
        .select()
        .order('company_name', ascending: true);

    return (response as List)
        .map((json) => PartnerModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PartnerModel?> fetchMine(String userId) async {
    final response = await _client
        .from(AppConstants.partnersTable)
        .select()
        .eq('user_id', userId)
        .limit(1);

    final list = response as List;
    if (list.isEmpty) return null;
    return PartnerModel.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> save(PartnerModel partner) async {
    final payload = {
      'user_id': partner.userId,
      'company_name': partner.companyName,
      'nif': partner.nif,
      'business_type': partner.businessType.name,
      'address': partner.address,
      'whatsapp': partner.whatsapp,
      'license': partner.license,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (partner.id.isEmpty) {
      await _client.from(AppConstants.partnersTable).insert(payload);
    } else {
      await _client
          .from(AppConstants.partnersTable)
          .update(payload)
          .eq('id', partner.id);
    }
  }

  Future<void> delete(String id) async {
    await _client.from(AppConstants.partnersTable).delete().eq('id', id);
  }
}