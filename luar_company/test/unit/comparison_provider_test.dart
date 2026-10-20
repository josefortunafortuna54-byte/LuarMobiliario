import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/comparison_entry.dart';
import 'package:luar_company/core/models/land_model.dart';
import 'package:luar_company/core/models/property_model.dart';
import 'package:luar_company/core/providers/comparison_provider.dart';

PropertyModel _property({
  String id = 'p1',
  PropertyType type = PropertyType.house,
  TransactionType transactionType = TransactionType.sale,
  double price = 1000000,
  double area = 100,
  int bedrooms = 2,
  int bathrooms = 1,
  int garage = 1,
}) {
  return PropertyModel(
    id: id,
    title: 'Imóvel $id',
    description: 'Descrição',
    type: type,
    transactionType: transactionType,
    price: price,
    area: area,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    garage: garage,
    address: 'Rua $id',
    city: 'Luanda',
    municipality: 'Belas',
    neighborhood: 'Talatona',
    latitude: -8.9,
    longitude: 13.2,
    images: const ['imovel.jpg'],
    features: const ['Piscina'],
    agentName: 'Agente',
    agentPhone: '+244900000000',
    isFeatured: false,
    isAvailable: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

LandModel _land({
  String id = 'l1',
  LandType type = LandType.urban,
  LandTransactionType transactionType = LandTransactionType.sale,
  double price = 8000000,
  double area = 500,
}) {
  return LandModel(
    id: id,
    title: 'Terreno $id',
    description: 'Descrição',
    type: type,
    transactionType: transactionType,
    price: price,
    area: area,
    address: 'Estrada',
    city: 'Luanda',
    municipality: 'Talatona',
    neighborhood: 'Nova Vida',
    latitude: -8.92,
    longitude: 13.18,
    images: const ['terreno.jpg'],
    features: const ['Cercado'],
    agentId: 'a2',
    agentName: 'Pedro',
    agentPhone: '+244922222222',
    agentVerified: false,
    isFeatured: false,
    isAvailable: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('ComparisonEntry.fromProperty', () {
    test('mapeia tipo de imóvel e transação', () {
      final entry = ComparisonEntry.fromProperty(
        _property(
          type: PropertyType.apartment,
          transactionType: TransactionType.rent,
        ),
      );

      expect(entry.category, ComparisonCategory.apartment);
      expect(entry.transactionName, 'rent');
      expect(entry.isLand, isFalse);
      expect(entry.bedrooms, 2);
      expect(entry.garage, 1);
    });

    test('mapeia cada tipo de imóvel para a categoria correta', () {
      const expected = {
        PropertyType.house: ComparisonCategory.house,
        PropertyType.apartment: ComparisonCategory.apartment,
        PropertyType.office: ComparisonCategory.office,
        PropertyType.warehouse: ComparisonCategory.warehouse,
        PropertyType.condo: ComparisonCategory.condo,
        PropertyType.shop: ComparisonCategory.shop,
      };

      expected.forEach((type, category) {
        final entry = ComparisonEntry.fromProperty(_property(type: type));
        expect(entry.category, category);
      });
    });
  });

  group('ComparisonEntry.fromLand', () {
    test('mapeia tipo de terreno e deixa campos de imóvel nulos', () {
      final entry = ComparisonEntry.fromLand(
        _land(type: LandType.farm, transactionType: LandTransactionType.rent),
      );

      expect(entry.category, ComparisonCategory.farm);
      expect(entry.transactionName, 'rent');
      expect(entry.isLand, isTrue);
      expect(entry.bedrooms, isNull);
      expect(entry.bathrooms, isNull);
      expect(entry.garage, isNull);
    });

    test('mapeia cada tipo de terreno para a categoria correta', () {
      const expected = {
        LandType.urban: ComparisonCategory.urbanLand,
        LandType.agricultural: ComparisonCategory.agriculturalLand,
        LandType.industrial: ComparisonCategory.industrialLand,
        LandType.commercial: ComparisonCategory.commercialLand,
        LandType.lot: ComparisonCategory.lot,
        LandType.farm: ComparisonCategory.farm,
      };

      expected.forEach((type, category) {
        final entry = ComparisonEntry.fromLand(_land(type: type));
        expect(entry.category, category);
      });
    });
  });

  group('ComparisonProvider', () {
    test('add acrescenta e notifica', () {
      final provider = ComparisonProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      expect(provider.add(_property(id: 'p1')), isTrue);
      expect(provider.count, 1);
      expect(provider.isEmpty, isFalse);
      expect(notified, 1);
    });

    test('add ignora duplicados e não notifica', () {
      final provider = ComparisonProvider();
      provider.add(_property(id: 'p1'));
      var notified = 0;
      provider.addListener(() => notified++);

      expect(provider.add(_property(id: 'p1')), isFalse);
      expect(provider.count, 1);
      expect(notified, 0);
    });

    test('respeita o limite de itens', () {
      final provider = ComparisonProvider();

      expect(provider.add(_property(id: 'p1')), isTrue);
      expect(provider.add(_property(id: 'p2')), isTrue);
      expect(provider.add(_property(id: 'p3')), isTrue);
      expect(provider.isFull, isTrue);
      expect(provider.add(_property(id: 'p4')), isFalse);
      expect(provider.count, ComparisonProvider.maxItems);
    });

    test('mistura imóveis e terrenos na mesma comparação', () {
      final provider = ComparisonProvider();

      provider.add(_property(id: 'p1'));
      provider.addLand(_land(id: 'l1'));

      expect(provider.count, 2);
      expect(provider.items.first.isLand, isFalse);
      expect(provider.items.last.isLand, isTrue);
      expect(provider.canCompare, isTrue);
    });

    test('toggle adiciona e remove', () {
      final provider = ComparisonProvider();
      final property = _property(id: 'p1');

      expect(provider.toggle(property), isTrue);
      expect(provider.isSelected('p1'), isTrue);
      expect(provider.toggle(property), isFalse);
      expect(provider.isSelected('p1'), isFalse);
    });

    test('toggleLand adiciona e remove', () {
      final provider = ComparisonProvider();
      final land = _land(id: 'l1');

      expect(provider.toggleLand(land), isTrue);
      expect(provider.isSelected('l1'), isTrue);
      expect(provider.toggleLand(land), isFalse);
      expect(provider.isSelected('l1'), isFalse);
    });

    test('remove devolve false para id inexistente', () {
      final provider = ComparisonProvider();
      expect(provider.remove('nope'), isFalse);
    });

    test('clear esvazia a lista', () {
      final provider = ComparisonProvider();
      provider.add(_property(id: 'p1'));
      provider.addLand(_land(id: 'l1'));

      provider.clear();

      expect(provider.isEmpty, isTrue);
      expect(provider.canCompare, isFalse);
    });

    test('pricePerSquareMeter devolve null para área inválida', () {
      expect(
        ComparisonProvider.pricePerSquareMeter(
          ComparisonEntry.fromProperty(_property(area: 0)),
        ),
        isNull,
      );
    });

    test('pricePerSquareMeter calcula preço por m²', () {
      final entry = ComparisonEntry.fromProperty(
        _property(price: 1000000, area: 100),
      );
      expect(ComparisonProvider.pricePerSquareMeter(entry), 10000);
    });

    test('cheapest e largest devolvem null com lista vazia', () {
      final provider = ComparisonProvider();
      expect(provider.cheapest, isNull);
      expect(provider.largest, isNull);
      expect(provider.bestValue, isNull);
    });

    test('cheapest, largest e bestValue escolhem as entradas corretas', () {
      final provider = ComparisonProvider();
      provider.add(_property(id: 'caro', price: 5000000, area: 100));
      provider.add(_property(id: 'barato', price: 1000000, area: 200));
      provider.addLand(_land(id: 'grande', price: 3000000, area: 1000));

      expect(provider.cheapest!.id, 'barato');
      expect(provider.largest!.id, 'grande');
      expect(provider.bestValue!.id, 'grande');
    });

    test('bestValue ignora entradas com área inválida', () {
      final provider = ComparisonProvider();
      provider.add(_property(id: 'invalido', price: 1, area: 0));
      provider.add(_property(id: 'valido', price: 100, area: 10));

      expect(provider.bestValue!.id, 'valido');
    });
  });
}
