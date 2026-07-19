class LocationModel {
  final String id;
  final String city;
  final List<String> municipalities;
  final List<String> neighborhoods;

  const LocationModel({
    required this.id,
    required this.city,
    required this.municipalities,
    required this.neighborhoods,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String? ?? '',
      city: json['city'] as String? ?? '',
      municipalities: (json['municipalities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      neighborhoods: (json['neighborhoods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'municipalities': municipalities,
      'neighborhoods': neighborhoods,
    };
  }

  LocationModel copyWith({
    String? id,
    String? city,
    List<String>? municipalities,
    List<String>? neighborhoods,
  }) {
    return LocationModel(
      id: id ?? this.id,
      city: city ?? this.city,
      municipalities: municipalities ?? this.municipalities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
    );
  }
}
