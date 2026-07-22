enum PropertyType { house, apartment, office, warehouse, condo, shop }

PropertyType _propertyTypeFromString(String value) {
  return PropertyType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PropertyType.house,
  );
}

String _propertyTypeToString(PropertyType type) => type.name;

enum TransactionType { sale, rent }

TransactionType _transactionTypeFromString(String value) {
  return TransactionType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TransactionType.sale,
  );
}

String _transactionTypeToString(TransactionType type) => type.name;

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final PropertyType type;
  final TransactionType transactionType;
  final double price;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final int garage;
  final String address;
  final String city;
  final String municipality;
  final String neighborhood;
  final double latitude;
  final double longitude;
  final List<String> images;
  final List<String> features;
  final String agentId;
  final String agentName;
  final String agentPhone;
  final bool isFeatured;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.transactionType,
    required this.price,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.garage,
    required this.address,
    required this.city,
    required this.municipality,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.features,
    required this.agentId,
    required this.agentName,
    required this.agentPhone,
    required this.isFeatured,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _propertyTypeFromString(json['type'] as String? ?? 'house'),
      transactionType: _transactionTypeFromString(
        json['transaction_type'] as String? ?? 'sale',
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      garage: (json['garage'] as num?)?.toInt() ?? 0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      municipality: json['municipality'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      agentId: json['agent_id'] as String? ?? '',
      agentName: json['agent_name'] as String? ?? '',
      agentPhone: json['agent_phone'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': _propertyTypeToString(type),
      'transaction_type': _transactionTypeToString(transactionType),
      'price': price,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garage': garage,
      'address': address,
      'city': city,
      'municipality': municipality,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'features': features,
      'agent_id': agentId,
      'agent_name': agentName,
      'agent_phone': agentPhone,
      'is_featured': isFeatured,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    PropertyType? type,
    TransactionType? transactionType,
    double? price,
    double? area,
    int? bedrooms,
    int? bathrooms,
    int? garage,
    String? address,
    String? city,
    String? municipality,
    String? neighborhood,
    double? latitude,
    double? longitude,
    List<String>? images,
    List<String>? features,
    String? agentId,
    String? agentName,
    String? agentPhone,
    bool? isFeatured,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      transactionType: transactionType ?? this.transactionType,
      price: price ?? this.price,
      area: area ?? this.area,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      garage: garage ?? this.garage,
      address: address ?? this.address,
      city: city ?? this.city,
      municipality: municipality ?? this.municipality,
      neighborhood: neighborhood ?? this.neighborhood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      features: features ?? this.features,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
