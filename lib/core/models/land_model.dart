enum LandType { urban, agricultural, industrial, commercial, lot, farm }

LandType _landTypeFromString(String value) {
  return LandType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => LandType.urban,
  );
}

String _landTypeToString(LandType type) => type.name;

enum LandTransactionType { sale, rent }

LandTransactionType _transactionTypeFromString(String value) {
  return LandTransactionType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => LandTransactionType.sale,
  );
}

String _transactionTypeToString(LandTransactionType type) => type.name;

class LandModel {
  final String id;
  final String title;
  final String description;
  final LandType type;
  final LandTransactionType transactionType;
  final double price;
  final double area;
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

  const LandModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.transactionType,
    required this.price,
    required this.area,
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

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _landTypeFromString(json['type'] as String? ?? 'urban'),
      transactionType:
          _transactionTypeFromString(json['transaction_type'] as String? ?? 'sale'),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      municipality: json['municipality'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      features: (json['features'] as List<dynamic>?)
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
      'type': _landTypeToString(type),
      'transaction_type': _transactionTypeToString(transactionType),
      'price': price,
      'area': area,
      'address': address,
      'city': city,
      'municipality': municipality,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
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

  LandModel copyWith({
    String? id,
    String? title,
    String? description,
    LandType? type,
    LandTransactionType? transactionType,
    double? price,
    double? area,
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
    return LandModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      transactionType: transactionType ?? this.transactionType,
      price: price ?? this.price,
      area: area ?? this.area,
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
