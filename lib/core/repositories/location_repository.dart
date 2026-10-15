import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// Municípios e bairros por cidade (tabela `locations`, populada pelas
/// migrações e legível por qualquer papel).
class LocationRepository {
  SupabaseClient get _client => SupabaseService.client;

  /// Devolve a lista ordenada e sem duplicados de todos os municípios.
  Future<List<String>> fetchMunicipalities() async {
    final response = await _client.from('locations').select('municipalities');

    final municipalities = <String>{};
    for (final row in response as List<dynamic>) {
      final values = (row as Map<String, dynamic>)['municipalities'];
      if (values is! List) continue;
      for (final value in values) {
        if (value is String && value.trim().isNotEmpty) {
          municipalities.add(value.trim());
        }
      }
    }

    return municipalities.toList()..sort();
  }
}
