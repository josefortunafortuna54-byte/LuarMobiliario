import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/partner_model.dart';

void main() {
  final now = DateTime(2025, 6, 15, 10, 30);
  final later = DateTime(2025, 7, 1);

  PartnerModel createSubject({
    String id = 'p1',
    String userId = 'u1',
    String companyName = 'Luar Imobiliária',
    String nif = '123456789',
    PartnerBusinessType businessType = PartnerBusinessType.imobiliaria,
    String address = 'Luanda, Talatona',
    String whatsapp = '+244923456789',
    String license = 'LIC-001',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerModel(
      id: id,
      userId: userId,
      companyName: companyName,
      nif: nif,
      businessType: businessType,
      address: address,
      whatsapp: whatsapp,
      license: license,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? later,
    );
  }

  group('PartnerBusinessType', () {
    test('has five values', () {
      expect(PartnerBusinessType.values.length, 5);
      expect(PartnerBusinessType.values,
          contains(PartnerBusinessType.imobiliaria));
      expect(
          PartnerBusinessType.values, contains(PartnerBusinessType.construtora));
      expect(PartnerBusinessType.values, contains(PartnerBusinessType.corretor));
      expect(PartnerBusinessType.values,
          contains(PartnerBusinessType.administrador));
      expect(PartnerBusinessType.values, contains(PartnerBusinessType.outro));
    });
  });

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'p2',
        'user_id': 'u2',
        'company_name': 'Construtora Nova',
        'nif': '987654321',
        'business_type': 'construtora',
        'address': 'Viana, Luanda',
        'whatsapp': '+244912345678',
        'license': 'LIC-002',
        'created_at': '2025-01-10T08:00:00.000',
        'updated_at': '2025-03-20T12:00:00.000',
      };

      final partner = PartnerModel.fromJson(json);

      expect(partner.id, 'p2');
      expect(partner.userId, 'u2');
      expect(partner.companyName, 'Construtora Nova');
      expect(partner.nif, '987654321');
      expect(partner.businessType, PartnerBusinessType.construtora);
      expect(partner.address, 'Viana, Luanda');
      expect(partner.whatsapp, '+244912345678');
      expect(partner.license, 'LIC-002');
      expect(partner.createdAt, DateTime(2025, 1, 10, 8, 0));
      expect(partner.updatedAt, DateTime(2025, 3, 20, 12, 0));
    });

    test('defaults to outro for unknown business type', () {
      final partner = PartnerModel.fromJson({'business_type': 'empresa'});
      expect(partner.businessType, PartnerBusinessType.outro);
    });

    test('handles all valid business type strings', () {
      expect(
        PartnerModel.fromJson({'business_type': 'imobiliaria'}).businessType,
        PartnerBusinessType.imobiliaria,
      );
      expect(
        PartnerModel.fromJson({'business_type': 'construtora'}).businessType,
        PartnerBusinessType.construtora,
      );
      expect(
        PartnerModel.fromJson({'business_type': 'corretor'}).businessType,
        PartnerBusinessType.corretor,
      );
      expect(
        PartnerModel.fromJson({'business_type': 'administrador'}).businessType,
        PartnerBusinessType.administrador,
      );
      expect(
        PartnerModel.fromJson({'business_type': 'outro'}).businessType,
        PartnerBusinessType.outro,
      );
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final json = createSubject().toJson();

      expect(json['id'], 'p1');
      expect(json['user_id'], 'u1');
      expect(json['company_name'], 'Luar Imobiliária');
      expect(json['nif'], '123456789');
      expect(json['business_type'], 'imobiliaria');
      expect(json['address'], 'Luanda, Talatona');
      expect(json['whatsapp'], '+244923456789');
      expect(json['license'], 'LIC-001');
      expect(json['created_at'], '2025-06-15T10:30:00.000');
      expect(json['updated_at'], '2025-07-01T00:00:00.000');
    });

    test('toJson produces 10 keys', () {
      expect(createSubject().toJson().length, 10);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('fromJson(toJson()) preserves all values', () {
      final original = createSubject(
        id: 'rt1',
        userId: 'u9',
        companyName: 'Corretora RT',
        nif: '111222333',
        businessType: PartnerBusinessType.corretor,
        address: 'Kilamba',
        whatsapp: '+244998877665',
        license: 'LIC-RT',
        createdAt: DateTime(2024, 12, 25, 8, 30),
        updatedAt: DateTime(2025, 6, 1, 16, 0),
      );

      final restored = PartnerModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.companyName, original.companyName);
      expect(restored.nif, original.nif);
      expect(restored.businessType, original.businessType);
      expect(restored.address, original.address);
      expect(restored.whatsapp, original.whatsapp);
      expect(restored.license, original.license);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments provided', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.companyName, original.companyName);
      expect(copy.nif, original.nif);
      expect(copy.businessType, original.businessType);
      expect(copy.address, original.address);
      expect(copy.whatsapp, original.whatsapp);
      expect(copy.license, original.license);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(companyName: 'Nova Empresa');

      expect(copy.companyName, 'Nova Empresa');
      expect(copy.id, original.id);
      expect(copy.nif, original.nif);
      expect(copy.businessType, original.businessType);
    });

    test('can change business type', () {
      final original = createSubject();
      final copy = original.copyWith(businessType: PartnerBusinessType.outro);

      expect(copy.businessType, PartnerBusinessType.outro);
      expect(original.businessType, PartnerBusinessType.imobiliaria);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(companyName: 'Changed');

      expect(original.companyName, 'Luar Imobiliária');
    });
  });
}