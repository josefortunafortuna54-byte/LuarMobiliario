import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report_model.dart';
import '../services/supabase_service.dart';

class ReportRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<void> create({
    required String reporterId,
    required ReportTarget targetType,
    required String targetId,
    required String reason,
    String details = '',
  }) async {
    await _client.from('reports').insert({
      'reporter_id': reporterId,
      'target_type': targetType.value,
      'target_id': targetId,
      'reason': reason,
      'details': details,
    });
  }

  Future<List<ReportModel>> fetchAll({ReportStatus? status}) async {
    final query = _client
        .from('reports')
        .select('*, reporter:reporter_id(name)');

    final filtered = status != null ? query.eq('status', status.value) : query;

    final response = await filtered.order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStatus({
    required String id,
    required ReportStatus status,
    required String reviewedById,
  }) async {
    await _client
        .from('reports')
        .update({
          'status': status.value,
          'reviewed_by': reviewedById,
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Oculta um anúncio denunciado (imóvel ou terreno) a partir da ação de
  /// moderação. Só admins conseguem atualizar anúncios alheios (RLS 002).
  Future<void> hideListing({
    required ReportTarget targetType,
    required String targetId,
  }) async {
    final table = targetType == ReportTarget.land ? 'lands' : 'properties';
    await _client
        .from(table)
        .update({'is_available': false})
        .eq('id', targetId);
  }

  /// Devolve o agente dono de um anúncio (para notificar na moderação).
  /// Só admins chegam aqui — leitura de `properties`/`lands` é pública.
  Future<String?> fetchListingAgentId({
    required ReportTarget targetType,
    required String targetId,
  }) async {
    final table = targetType == ReportTarget.land ? 'lands' : 'properties';
    final response = await _client
        .from(table)
        .select('agent_id')
        .eq('id', targetId)
        .maybeSingle();
    return response?['agent_id'] as String?;
  }

  Future<void> logModeration({
    required String actorId,
    required String action,
    ReportTarget? targetType,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _client.from('moderation_log').insert({
      'actor_id': actorId,
      'action': action,
      'target_type': targetType?.value ?? '',
      'target_id': targetId,
      'metadata': metadata,
    });
  }
}
