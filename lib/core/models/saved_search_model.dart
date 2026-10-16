class SavedSearchModel {
  final String id;
  final String userId;
  final String name;
  final Map<String, dynamic> filters;
  final DateTime createdAt;

  const SavedSearchModel({
    required this.id,
    required this.userId,
    required this.name,
    this.filters = const {},
    required this.createdAt,
  });

  factory SavedSearchModel.fromJson(Map<String, dynamic> json) {
    return SavedSearchModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'filters': filters,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SavedSearchModel copyWith({
    String? id,
    String? userId,
    String? name,
    Map<String, dynamic>? filters,
    DateTime? createdAt,
  }) {
    return SavedSearchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      filters: filters ?? this.filters,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
