import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/land_model.dart';

void main() {
  final fixedDate = DateTime(2025, 3, 10);
  final updatedDate = DateTime(2025, 6, 20);

  LandModel createSubject({
    String id = 'l1',
    String title = 'Terreno Talatona',
    String description = '500m², zona residencial',
    LandType type = LandType.urban,
    LandTransactionType transactionType = LandTransactionType.sale,
    double price = 8000000,
    double area = 500,
    String address = 'Estrada do Camão',
    String city = 'Luanda',
    String municipality = 'Talatona',
    String neighborhood = 'Nova Vida',
    double latitude = -8.92,
    double longitude = 13.18,
    List<String> images = const ['terreno1.jpg'],
    List<String> features = const ['Cercado'],
    String agentId = 'a2',
    String agentName = 'Pedro',
    String agentPhone = '+244922222222',
    bool isFeatured = true,
    bool isAvailable = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LandModel(
      id: id,
      title: title,
      description: description,
      type: type,
      transactionType: transactionType,
      price: price,
      area: area,
      address: address,
      city: city,
      municipality: municipality,
      neighborhood: neighborhood,
      latitude: latitude,
      longitude: longitude,
      images: images,
      features: features,
      agentId: agentId,
      agentName: agentName,
      agentPhone: agentPhone,
      isFeatured: isFeatured,
      isAvailable: isAvailable,
      createdAt: createdAt ?? fixedDate,
      updatedAt: updatedAt ?? updatedDate,
    );
  }

  group('LandType', () {
    test('has six values', () {
      expect(LandType.values.length, 6);
    });

    test('contains all expected types', () {
      expect(LandType.values, contains(LandType.urban));
      expect(LandType.values, contains(LandType.agricultural));
      expect(LandType.values, contains(LandType.industrial));
      expect(LandType.values, contains(LandType.commercial));
      expect(LandType.values, contains(LandType.lot));
      expect(LandType.values, contains(LandType.farm));
    });
  });

  group('LandTransactionType', () {
    test('has two values: sale and rent', () {
      expect(LandTransactionType.values.length, 2);
      expect(LandTransactionType.values, contains(LandTransactionType.sale));
      expect(LandTransactionType.values, contains(LandTransactionType.rent));
    });
  });

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'l2',
        'title': 'Fazenda do Kuanza',
        'description': '2 hectares',
        'type': 'agricultural',
        'transaction_type': 'sale',
        'price': 50000000,
        'area': 20000,
        'address': 'Estrada do Kuanza',
        'city': 'Dondo',
        'municipality': 'Dondo',
        'neighborhood': 'Rural',
        'latitude': -9.7,
        'longitude': 14.1,
        'images': ['f1.jpg', 'f2.jpg'],
        'features': ['Água', 'Estrada asfaltada'],
        'agent_id': 'a7',
        'agent_name': 'Fernanda',
        'agent_phone': '+244933333333',
        'is_featured': true,
        'is_available': false,
        'created_at': '2025-02-01T10:00:00.000',
        'updated_at': '2025-05-15T16:00:00.000',
      };

      final l = LandModel.fromJson(json);

      expect(l.id, 'l2');
      expect(l.title, 'Fazenda do Kuanza');
      expect(l.description, '2 hectares');
      expect(l.type, LandType.agricultural);
      expect(l.transactionType, LandTransactionType.sale);
      expect(l.price, 50000000);
      expect(l.area, 20000);
      expect(l.address, 'Estrada do Kuanza');
      expect(l.city, 'Dondo');
      expect(l.municipality, 'Dondo');
      expect(l.neighborhood, 'Rural');
      expect(l.latitude, closeTo(-9.7, 0.001));
      expect(l.longitude, closeTo(14.1, 0.001));
      expect(l.images, ['f1.jpg', 'f2.jpg']);
      expect(l.features, ['Água', 'Estrada asfaltada']);
      expect(l.agentId, 'a7');
      expect(l.agentName, 'Fernanda');
      expect(l.agentPhone, '+244933333333');
      expect(l.isFeatured, true);
      expect(l.isAvailable, false);
      expect(l.createdAt, DateTime(2025, 2, 1, 10, 0));
      expect(l.updatedAt, DateTime(2025, 5, 15, 16, 0));
    });

    test('defaults to urban for unknown type string', () {
      final l = LandModel.fromJson({'type': 'forest'});
      expect(l.type, LandType.urban);
    });

    test('defaults to sale for unknown transaction_type', () {
      final l = LandModel.fromJson({'transaction_type': 'donation'});
      expect(l.transactionType, LandTransactionType.sale);
    });

    test('defaults to sale when transaction_type is null', () {
      final l = LandModel.fromJson(<String, dynamic>{'transaction_type': null});
      expect(l.transactionType, LandTransactionType.sale);
    });

    test('handles all land type strings', () {
      expect(LandModel.fromJson({'type': 'urban'}).type, LandType.urban);
      expect(
        LandModel.fromJson({'type': 'agricultural'}).type,
        LandType.agricultural,
      );
      expect(
        LandModel.fromJson({'type': 'industrial'}).type,
        LandType.industrial,
      );
      expect(
        LandModel.fromJson({'type': 'commercial'}).type,
        LandType.commercial,
      );
      expect(LandModel.fromJson({'type': 'lot'}).type, LandType.lot);
      expect(LandModel.fromJson({'type': 'farm'}).type, LandType.farm);
    });

    test('defaults numeric fields to 0 when null', () {
      final l = LandModel.fromJson(<String, dynamic>{});
      expect(l.price, 0.0);
      expect(l.area, 0.0);
      expect(l.latitude, 0.0);
      expect(l.longitude, 0.0);
    });

    test('defaults list fields to empty when null', () {
      final l = LandModel.fromJson(<String, dynamic>{});
      expect(l.images, isEmpty);
      expect(l.features, isEmpty);
    });

    test('defaults isFeatured to false when null', () {
      final l = LandModel.fromJson(<String, dynamic>{});
      expect(l.isFeatured, false);
    });

    test('defaults isAvailable to true when null', () {
      final l = LandModel.fromJson(<String, dynamic>{});
      expect(l.isAvailable, true);
    });

    test('defaults string fields to empty/null when null', () {
      final l = LandModel.fromJson(<String, dynamic>{});
      expect(l.id, '');
      expect(l.title, '');
      expect(l.description, '');
      expect(l.address, '');
      expect(l.city, '');
      expect(l.municipality, '');
      expect(l.neighborhood, '');
      expect(l.agentId, isNull);
      expect(l.agentName, '');
      expect(l.agentPhone, '');
    });

    test('uses DateTime.now() for missing dates', () {
      final before = DateTime.now().subtract(const Duration(milliseconds: 10));
      final l = LandModel.fromJson(<String, dynamic>{});
      final after = DateTime.now().add(const Duration(milliseconds: 10));

      expect(l.createdAt.isAfter(before), isTrue);
      expect(l.createdAt.isBefore(after), isTrue);
      expect(l.updatedAt.isAfter(before), isTrue);
      expect(l.updatedAt.isBefore(after), isTrue);
    });

    test('parses integer area from JSON', () {
      final l = LandModel.fromJson({'area': 1000});
      expect(l.area, 1000.0);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final l = createSubject(
        type: LandType.industrial,
        transactionType: LandTransactionType.rent,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 6, 15),
      );

      final json = l.toJson();

      expect(json['id'], 'l1');
      expect(json['title'], 'Terreno Talatona');
      expect(json['description'], '500m², zona residencial');
      expect(json['type'], 'industrial');
      expect(json['transaction_type'], 'rent');
      expect(json['price'], 8000000);
      expect(json['area'], 500);
      expect(json['address'], 'Estrada do Camão');
      expect(json['city'], 'Luanda');
      expect(json['municipality'], 'Talatona');
      expect(json['neighborhood'], 'Nova Vida');
      expect(json['latitude'], closeTo(-8.92, 0.001));
      expect(json['longitude'], closeTo(13.18, 0.001));
      expect(json['features'], ['Cercado']);
      expect(json['agent_id'], 'a2');
      expect(json['agent_name'], 'Pedro');
      expect(json['agent_phone'], '+244922222222');
      expect(json['is_featured'], true);
      expect(json['is_available'], true);
      expect(json['created_at'], '2025-01-01T00:00:00.000');
      expect(json['updated_at'], '2025-06-15T00:00:00.000');
    });

    test('includes images key', () {
      final json = createSubject().toJson();
      expect(json.containsKey('images'), isTrue);
    });

    test('has 22 keys', () {
      final json = createSubject().toJson();
      expect(json.length, 22);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('preserves all values through serialization', () {
      final original = createSubject(
        id: 'rt1',
        title: 'Round Trip',
        type: LandType.commercial,
        transactionType: LandTransactionType.rent,
        price: 12000000,
        area: 800,
        latitude: -8.5,
        longitude: 13.0,
        isFeatured: false,
        isAvailable: false,
        createdAt: DateTime(2024, 9, 1),
        updatedAt: DateTime(2025, 3, 10),
      );

      final restored = LandModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.type, original.type);
      expect(restored.transactionType, original.transactionType);
      expect(restored.price, original.price);
      expect(restored.area, original.area);
      expect(restored.address, original.address);
      expect(restored.city, original.city);
      expect(restored.municipality, original.municipality);
      expect(restored.neighborhood, original.neighborhood);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.features, original.features);
      expect(restored.agentId, original.agentId);
      expect(restored.agentName, original.agentName);
      expect(restored.agentPhone, original.agentPhone);
      expect(restored.isFeatured, original.isFeatured);
      expect(restored.isAvailable, original.isAvailable);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.type, original.type);
      expect(copy.price, original.price);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(title: 'Novo Terreno', price: 5000000);

      expect(copy.title, 'Novo Terreno');
      expect(copy.price, 5000000);
      expect(copy.id, original.id);
      expect(copy.type, original.type);
      expect(copy.area, original.area);
    });

    test('can change type and transactionType', () {
      final original = createSubject(
        type: LandType.urban,
        transactionType: LandTransactionType.sale,
      );

      final copy = original.copyWith(
        type: LandType.farm,
        transactionType: LandTransactionType.rent,
      );

      expect(copy.type, LandType.farm);
      expect(copy.transactionType, LandTransactionType.rent);
      expect(original.type, LandType.urban);
    });

    test('can change availability flags', () {
      final original = createSubject(isFeatured: true, isAvailable: true);
      final copy = original.copyWith(isFeatured: false, isAvailable: false);

      expect(copy.isFeatured, false);
      expect(copy.isAvailable, false);
      expect(original.isFeatured, true);
      expect(original.isAvailable, true);
    });

    test('can change lists', () {
      final original = createSubject();
      final copy = original.copyWith(
        images: ['new.jpg'],
        features: ['Novo', 'Moderno'],
      );

      expect(copy.images, ['new.jpg']);
      expect(copy.features, ['Novo', 'Moderno']);
      expect(original.images, ['terreno1.jpg']);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(title: 'Changed', price: 0);

      expect(original.title, 'Terreno Talatona');
      expect(original.price, 8000000);
    });
  });
}
