/// Extração das URLs de media devolvidas pelo Supabase em tabelas ligadas
/// (`property_images`, `property_videos`, `land_images`, `land_videos`).
///
/// Cada registo é um mapa com a coluna da URL; entradas malformadas ou
/// nulas são ignoradas em vez de lançar erro para não quebrar a listagem.
library;

List<String> extractMediaUrls(dynamic data, String urlKey) {
  if (data is! List) return <String>[];
  final urls = <String>[];
  for (final item in data) {
    if (item is! Map) continue;
    final url = item[urlKey];
    if (url is String && url.isNotEmpty) urls.add(url);
  }
  return urls;
}

/// Remove e devolve uma lista de URLs do mapa de escrita, deixando o
/// payload pronto para insert/update (as media vivem em tabelas próprias).
List<String> popMediaUrls(Map<String, dynamic> data, String key) {
  final value = data.remove(key);
  if (value is List) return value.whereType<String>().toList();
  return <String>[];
}
