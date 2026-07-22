import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/property_model.dart';

void main() {
  final fixedDate = DateTime(2025, 3, 10);
  final updatedDate = DateTime(2025, 6, 20);

  PropertyModel createSubject({
    String id = 'p1',
    String title = 'Vivenda Talatona',
    String description = '3 quartos, piscina',
    PropertyType type = PropertyType.house,
    TransactionType transactionType = TransactionType.sale,
    double price = 15000000,
    double area = 350,
    int bedrooms = 3,
    int bathrooms = 2,
    int garage = 2,
    String address = 'Rua 5',
    String city = 'Luanda',
    String municipality = 'Talatona',
    String neighborhood = 'Kilamba',
    double latitude = -8.9,
    double longitude = 13.2,
    List<String> images = const ['img1.jpg'],
    List<String> features = const ['Piscina'],
    String agentId = 'a1',
    String agentName = 'Carlos',
    String agentPhone = '+244900000000',
    bool isFeatured = true,
    bool isAvailable = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id,
      title: title,
      description: description,
      type: type,
      transactionType: transactionType,
      price: price,
      area: area,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      garage: garage,
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

  group('PropertyType', () {
    test('has six values', () {
      expect(PropertyType.values.length, 6);
    });

    test('contains all expected types', () {
      expect(PropertyType.values, contains(PropertyType.house));
      expect(PropertyType.values, contains(PropertyType.apartment));
      expect(PropertyType.values, contains(PropertyType.office));
      expect(PropertyType.values, contains(PropertyType.warehouse));
      expect(PropertyType.values, contains(PropertyType.condo));
      expect(PropertyType.values, contains(PropertyType.shop));
    });
  });

  group('TransactionType', () {
    test('has two values: sale and rent', () {
      expect(TransactionType.values.length, 2);
      expect(TransactionType.values, contains(TransactionType.sale));
      expect(TransactionType.values, contains(TransactionType.rent));
    });
  });

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'p2',
        'title': 'Apartamento Miramar',
        'description': 'Vista para o mar',
        'type': 'apartment',
        'transaction_type': 'rent',
        'price': 250000,
        'area': 120,
        'bedrooms': 2,
        'bathrooms': 1,
        'garage': 1,
        'address': 'Av. 4 de Fevereiro',
        'city': 'Luanda',
        'municipality': 'Ingombota',
        'neighborhood': 'Miramar',
        'latitude': -8.81,
        'longitude': 13.23,
        'images': ['a.jpg', 'b.jpg'],
        'features': ['Varanda', 'Ar condicionado'],
        'agent_id': 'a5',
        'agent_name': 'Ana',
        'agent_phone': '+244911111111',
        'is_featured': false,
        'is_available': false,
        'created_at': '2025-01-15T09:00:00.000',
        'updated_at': '2025-04-10T14:30:00.000',
      };

      final p = PropertyModel.fromJson(json);

      expect(p.id, 'p2');
      expect(p.title, 'Apartamento Miramar');
      expect(p.description, 'Vista para o mar');
      expect(p.type, PropertyType.apartment);
      expect(p.transactionType, TransactionType.rent);
      expect(p.price, 250000);
      expect(p.area, 120);
      expect(p.bedrooms, 2);
      expect(p.bathrooms, 1);
      expect(p.garage, 1);
      expect(p.address, 'Av. 4 de Fevereiro');
      expect(p.city, 'Luanda');
      expect(p.municipality, 'Ingombota');
      expect(p.neighborhood, 'Miramar');
      expect(p.latitude, closeTo(-8.81, 0.001));
      expect(p.longitude, closeTo(13.23, 0.001));
      expect(p.images, ['a.jpg', 'b.jpg']);
      expect(p.features, ['Varanda', 'Ar condicionado']);
      expect(p.agentId, 'a5');
      expect(p.agentName, 'Ana');
      expect(p.agentPhone, '+244911111111');
      expect(p.isFeatured, false);
      expect(p.isAvailable, false);
      expect(p.createdAt, DateTime(2025, 1, 15, 9, 0));
      expect(p.updatedAt, DateTime(2025, 4, 10, 14, 30));
    });

    test('defaults to house type for unknown string', () {
      final p = PropertyModel.fromJson({'type': 'mansion'});
      expect(p.type, PropertyType.house);
    });

    test('defaults to sale for unknown transaction_type', () {
      final p = PropertyModel.fromJson({'transaction_type': 'swap'});
      expect(p.transactionType, TransactionType.sale);
    });

    test('defaults to sale when transaction_type is null', () {
      final p = PropertyModel.fromJson(<String, dynamic>{
        'transaction_type': null,
      });
      expect(p.transactionType, TransactionType.sale);
    });

    test('handles all property type strings', () {
      expect(
        PropertyModel.fromJson({'type': 'house'}).type,
        PropertyType.house,
      );
      expect(
        PropertyModel.fromJson({'type': 'apartment'}).type,
        PropertyType.apartment,
      );
      expect(
        PropertyModel.fromJson({'type': 'office'}).type,
        PropertyType.office,
      );
      expect(
        PropertyModel.fromJson({'type': 'warehouse'}).type,
        PropertyType.warehouse,
      );
      expect(
        PropertyModel.fromJson({'type': 'condo'}).type,
        PropertyType.condo,
      );
      expect(PropertyModel.fromJson({'type': 'shop'}).type, PropertyType.shop);
    });

    test('defaults numeric fields to 0 when null', () {
      final p = PropertyModel.fromJson(<String, dynamic>{});
      expect(p.price, 0.0);
      expect(p.area, 0.0);
      expect(p.bedrooms, 0);
      expect(p.bathrooms, 0);
      expect(p.garage, 0);
      expect(p.latitude, 0.0);
      expect(p.longitude, 0.0);
    });

    test('defaults list fields to empty when null', () {
      final p = PropertyModel.fromJson(<String, dynamic>{});
      expect(p.images, isEmpty);
      expect(p.features, isEmpty);
    });

    test('defaults isFeatured to false when null', () {
      final p = PropertyModel.fromJson(<String, dynamic>{});
      expect(p.isFeatured, false);
    });

    test('defaults isAvailable to true when null', () {
      final p = PropertyModel.fromJson(<String, dynamic>{});
      expect(p.isAvailable, true);
    });

    test('defaults string fields to empty when null', () {
      final p = PropertyModel.fromJson(<String, dynamic>{});
      expect(p.id, '');
      expect(p.title, '');
      expect(p.description, '');
      expect(p.address, '');
      expect(p.city, '');
      expect(p.municipality, '');
      expect(p.neighborhood, '');
      expect(p.agentId, '');
      expect(p.agentName, '');
      expect(p.agentPhone, '');
    });

    test('uses DateTime.now() for missing dates', () {
      final before = DateTime.now().subtract(const Duration(milliseconds: 10));
      final p = PropertyModel.fromJson(<String, dynamic>{});
      final after = DateTime.now().add(const Duration(milliseconds: 10));

      expect(p.createdAt.isAfter(before), isTrue);
      expect(p.createdAt.isBefore(after), isTrue);
      expect(p.updatedAt.isAfter(before), isTrue);
      expect(p.updatedAt.isBefore(after), isTrue);
    });

    test('parses integer price from JSON', () {
      final p = PropertyModel.fromJson({'price': 5000000});
      expect(p.price, 5000000.0);
    });

    test('parses double price from JSON', () {
      final p = PropertyModel.fromJson({'price': 5000000.5});
      expect(p.price, 5000000.5);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final p = createSubject(
        type: PropertyType.apartment,
        transactionType: TransactionType.rent,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 6, 15),
      );

      final json = p.toJson();

      expect(json['id'], 'p1');
      expect(json['title'], 'Vivenda Talatona');
      expect(json['description'], '3 quartos, piscina');
      expect(json['type'], 'apartment');
      expect(json['transaction_type'], 'rent');
      expect(json['price'], 15000000);
      expect(json['area'], 350);
      expect(json['bedrooms'], 3);
      expect(json['bathrooms'], 2);
      expect(json['garage'], 2);
      expect(json['address'], 'Rua 5');
      expect(json['city'], 'Luanda');
      expect(json['municipality'], 'Talatona');
      expect(json['neighborhood'], 'Kilamba');
      expect(json['latitude'], closeTo(-8.9, 0.001));
      expect(json['longitude'], closeTo(13.2, 0.001));
      expect(json['features'], ['Piscina']);
      expect(json['agent_id'], 'a1');
      expect(json['agent_name'], 'Carlos');
      expect(json['agent_phone'], '+244900000000');
      expect(json['is_featured'], true);
      expect(json['is_available'], true);
      expect(json['created_at'], '2025-01-01T00:00:00.000');
      expect(json['updated_at'], '2025-06-15T00:00:00.000');
    });

    test('includes images key', () {
      final json = createSubject().toJson();
      expect(json.containsKey('images'), isTrue);
    });

    test('uses snake_case keys', () {
      final json = createSubject().toJson();
      expect(json.containsKey('transaction_type'), isTrue);
      expect(json.containsKey('is_featured'), isTrue);
      expect(json.containsKey('is_available'), isTrue);
      expect(json.containsKey('agent_id'), isTrue);
      expect(json.containsKey('agent_name'), isTrue);
      expect(json.containsKey('agent_phone'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
      expect(json.containsKey('updated_at'), isTrue);
    });

    test('has 25 keys', () {
      final json = createSubject().toJson();
      expect(json.length, 25);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('preserves all values through serialization', () {
      final original = createSubject(
        id: 'rt1',
        title: 'Round Trip',
        type: PropertyType.warehouse,
        transactionType: TransactionType.rent,
        price: 750000,
        area: 200,
        bedrooms: 0,
        bathrooms: 1,
        garage: 4,
        latitude: -9.0,
        longitude: 13.5,
        images: ['x.jpg', 'y.jpg'],
        features: ['Estacionamento'],
        isFeatured: false,
        isAvailable: false,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2025, 1, 15),
      );

      final restored = PropertyModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.type, original.type);
      expect(restored.transactionType, original.transactionType);
      expect(restored.price, original.price);
      expect(restored.area, original.area);
      expect(restored.bedrooms, original.bedrooms);
      expect(restored.bathrooms, original.bathrooms);
      expect(restored.garage, original.garage);
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
      final copy = original.copyWith(title: 'Nova Vivenda', price: 20000000);

      expect(copy.title, 'Nova Vivenda');
      expect(copy.price, 20000000);
      expect(copy.id, original.id);
      expect(copy.type, original.type);
      expect(copy.area, original.area);
    });

    test('can change type and transactionType', () {
      final original = createSubject(
        type: PropertyType.house,
        transactionType: TransactionType.sale,
      );

      final copy = original.copyWith(
        type: PropertyType.apartment,
        transactionType: TransactionType.rent,
      );

      expect(copy.type, PropertyType.apartment);
      expect(copy.transactionType, TransactionType.rent);
      expect(original.type, PropertyType.house);
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
      expect(original.images, ['img1.jpg']);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(title: 'Changed', price: 0);

      expect(original.title, 'Vivenda Talatona');
      expect(original.price, 15000000);
    });
  });
}
