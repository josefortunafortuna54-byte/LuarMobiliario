import 'land_model.dart';
import 'property_model.dart';

/// Categoria unificada para a tabela de comparação.
///
/// Junta os tipos de imóvel (`PropertyType`) e de terreno (`LandType`) num só
/// enum para que a UI possa comparar entradas dos dois domínios lado a lado.
enum ComparisonCategory {
  house,
  apartment,
  office,
  warehouse,
  condo,
  shop,
  urbanLand,
  agriculturalLand,
  industrialLand,
  commercialLand,
  lot,
  farm,
}

/// Entrada normalizada de comparação (imóvel ou terreno).
///
/// O `ComparisonProvider` guarda `ComparisonEntry` em vez de `PropertyModel`
/// para suportar a comparação de terrenos sem duplicar toda a UI. Os campos
/// exclusivos de imóvel (`bedrooms`, `bathrooms`, `garage`) são `null` nos
/// terrenos e apresentados como "—" na tabela.
class ComparisonEntry {
  const ComparisonEntry({
    required this.id,
    required this.title,
    required this.price,
    required this.area,
    required this.images,
    required this.features,
    required this.neighborhood,
    required this.municipality,
    required this.city,
    required this.category,
    required this.isLand,
    required this.transactionName,
    this.bedrooms,
    this.bathrooms,
    this.garage,
  });

  final String id;
  final String title;
  final double price;
  final double area;
  final List<String> images;
  final List<String> features;
  final String neighborhood;
  final String municipality;
  final String city;
  final ComparisonCategory category;
  final bool isLand;

  /// Nome do valor do enum de transação (`sale`/`rent`/`renew`), comum aos
  /// dois modelos.
  final String transactionName;

  final int? bedrooms;
  final int? bathrooms;
  final int? garage;

  factory ComparisonEntry.fromProperty(PropertyModel property) {
    return ComparisonEntry(
      id: property.id,
      title: property.title,
      price: property.price,
      area: property.area,
      images: property.images,
      features: property.features,
      neighborhood: property.neighborhood,
      municipality: property.municipality,
      city: property.city,
      category: switch (property.type) {
        PropertyType.house => ComparisonCategory.house,
        PropertyType.apartment => ComparisonCategory.apartment,
        PropertyType.office => ComparisonCategory.office,
        PropertyType.warehouse => ComparisonCategory.warehouse,
        PropertyType.condo => ComparisonCategory.condo,
        PropertyType.shop => ComparisonCategory.shop,
      },
      isLand: false,
      transactionName: property.transactionType.name,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      garage: property.garage,
    );
  }

  factory ComparisonEntry.fromLand(LandModel land) {
    return ComparisonEntry(
      id: land.id,
      title: land.title,
      price: land.price,
      area: land.area,
      images: land.images,
      features: land.features,
      neighborhood: land.neighborhood,
      municipality: land.municipality,
      city: land.city,
      category: switch (land.type) {
        LandType.urban => ComparisonCategory.urbanLand,
        LandType.agricultural => ComparisonCategory.agriculturalLand,
        LandType.industrial => ComparisonCategory.industrialLand,
        LandType.commercial => ComparisonCategory.commercialLand,
        LandType.lot => ComparisonCategory.lot,
        LandType.farm => ComparisonCategory.farm,
      },
      isLand: true,
      transactionName: land.transactionType.name,
    );
  }
}
