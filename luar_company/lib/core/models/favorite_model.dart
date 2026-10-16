class FavoriteModel {
  final String id;
  final String userId;
  final String? propertyId;
  final String? landId;
  final DateTime createdAt;

  const FavoriteModel({
    required this.id,
    required this.userId,
    this.propertyId,
    this.landId,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      propertyId: json['property_id'] as String?,
      landId: json['land_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'land_id': landId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? landId,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      landId: landId ?? this.landId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
