/// URLs públicas dos anúncios, usadas na partilha e em deep links.
abstract final class DeepLinks {
  static const String baseUrl = 'https://luarcompany.ao';

  static String property(String id) =>
      id.isEmpty ? baseUrl : '$baseUrl/properties/$id';

  static String land(String id) => id.isEmpty ? baseUrl : '$baseUrl/lands/$id';
}
