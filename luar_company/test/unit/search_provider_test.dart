import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/providers/search_provider.dart';

void main() {
  group('SearchProvider snapshot/restore', () {
    test('snapshotFilters só inclui chaves com valor', () {
      final provider = SearchProvider();

      final empty = provider.snapshotFilters();

      expect(empty.keys.toList(), ['sortOption']);
      expect(empty['sortOption'], 'recent');
    });

    test('snapshotFilters reflete filtros definidos via setFilter', () {
      final provider = SearchProvider();
      provider.setFilter(
        query: 'casa',
        propertyType: 'apartamento',
        province: 'Luanda',
        bedrooms: 3,
        minPrice: 1000000,
      );

      final snapshot = provider.snapshotFilters();

      expect(snapshot['query'], 'casa');
      expect(snapshot['propertyType'], 'apartamento');
      expect(snapshot['province'], 'Luanda');
      expect(snapshot['bedrooms'], 3);
      expect(snapshot['minPrice'], 1000000);
      expect(snapshot.containsKey('landType'), isFalse);
      expect(snapshot.containsKey('city'), isFalse);
    });

    test(
      'restoreFilters repõe todos os filtros e limpa estado de resultados',
      () async {
        final provider = SearchProvider();
        provider.setFilter(
          query: 'terreno',
          transactionType: 'rent',
          municipality: 'Talatona',
          bedrooms: 2,
        );
        provider.setSort('priceDesc');
        final snapshot = provider.snapshotFilters();

        // Estado "sujo" que o restore tem de limpar.
        provider.setFilter(query: 'outro');
        provider.clearFilters();
        provider.setSort('recent');

        provider.restoreFilters(snapshot);

        expect(provider.query, 'terreno');
        expect(provider.transactionType, 'rent');
        expect(provider.municipality, 'Talatona');
        expect(provider.bedrooms, 2);
        expect(provider.sortOption, 'priceDesc');
        expect(provider.results, isEmpty);
        expect(provider.error, isNull);
        expect(provider.activeFilterCount, 4);
      },
    );

    test('restoreFilters com mapa vazio limpa os filtros', () {
      final provider = SearchProvider();
      provider.setFilter(query: 'casa', province: 'Benguela');

      provider.restoreFilters(const {});

      expect(provider.query, '');
      expect(provider.province, isNull);
      expect(provider.activeFilterCount, 0);
      expect(provider.sortOption, 'recent');
    });

    test('restoreFilters converte preços inteiros (JSON) em double', () {
      final provider = SearchProvider();

      provider.restoreFilters(const {'minPrice': 500000, 'maxPrice': 9000000});

      expect(provider.minPrice, 500000.0);
      expect(provider.maxPrice, 9000000.0);
      expect(provider.minPrice, isA<double>());
    });

    test('restoreFilters emite notifyListeners', () {
      final provider = SearchProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.restoreFilters(const {'province': 'Huambo'});

      expect(notifications, 1);
    });
  });

  group('SearchProvider.setSort', () {
    test('altera a opção e notifica', () {
      final provider = SearchProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.setSort('areaDesc');

      expect(provider.sortOption, 'areaDesc');
      expect(notifications, 1);
    });

    test('com a mesma opção não notifica', () {
      final provider = SearchProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.setSort(provider.sortOption);

      expect(notifications, 0);
    });
  });
}
