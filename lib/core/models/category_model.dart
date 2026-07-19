enum CategoryType { property, land }

CategoryType _categoryTypeFromString(String value) {
  return CategoryType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CategoryType.property,
  );
}

String _categoryTypeToString(CategoryType type) => type.name;

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final CategoryType type;
  final int count;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      type: _categoryTypeFromString(json['type'] as String? ?? 'property'),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': _categoryTypeToString(type),
      'count': count,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    CategoryType? type,
    int? count,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      count: count ?? this.count,
    );
  }
}
