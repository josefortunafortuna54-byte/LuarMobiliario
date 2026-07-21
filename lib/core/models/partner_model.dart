enum PartnerBusinessType {
  imobiliaria,
  construtora,
  corretor,
  administrador,
  outro;

  String get label => switch (this) {
    PartnerBusinessType.imobiliaria => 'Imobiliária',
    PartnerBusinessType.construtora => 'Construtora',
    PartnerBusinessType.corretor => 'Corretor',
    PartnerBusinessType.administrador => 'Administrador',
    PartnerBusinessType.outro => 'Outro',
  };
}

PartnerBusinessType _businessTypeFromString(String value) {
  return PartnerBusinessType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PartnerBusinessType.outro,
  );
}

String _businessTypeToString(PartnerBusinessType type) => type.name;

class PartnerModel {
  final String id;
  final String userId;
  final String companyName;
  final String nif;
  final PartnerBusinessType businessType;
  final String address;
  final String whatsapp;
  final String license;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PartnerModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.nif,
    required this.businessType,
    required this.address,
    required this.whatsapp,
    required this.license,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      nif: json['nif'] as String? ?? '',
      businessType: _businessTypeFromString(
        json['business_type'] as String? ?? 'outro',
      ),
      address: json['address'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      license: json['license'] as String? ?? '',
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
      'user_id': userId,
      'company_name': companyName,
      'nif': nif,
      'business_type': _businessTypeToString(businessType),
      'address': address,
      'whatsapp': whatsapp,
      'license': license,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PartnerModel copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? nif,
    PartnerBusinessType? businessType,
    String? address,
    String? whatsapp,
    String? license,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      nif: nif ?? this.nif,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      whatsapp: whatsapp ?? this.whatsapp,
      license: license ?? this.license,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
