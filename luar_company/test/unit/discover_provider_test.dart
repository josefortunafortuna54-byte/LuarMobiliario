import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/constants/app_constants.dart';
import 'package:luar_company/core/models/property_model.dart';
import 'package:luar_company/core/providers/discover_provider.dart';
import 'package:luar_company/core/repositories/property_repository.dart';

PropertyModel _property(String id) {
  return PropertyModel(
    id: id,
    title: 'Imóvel $id',
    description: 'Descrição',
    type: PropertyType.house,
    transactionType: TransactionType.sale,
    price: 1000000,
    area: 100,
    bedrooms: 2,
    bathrooms: 1,
    garage: 1,
    address: 'Rua $id',
    city: 'Luanda',
    municipality: 'Belas',
    neighborhood: 'Talatona',
    latitude: -8.9,
    longitude: 13.2,
    images: const [],
    features: const [],
    agentName: 'Agente',
    agentPhone: '+244900000000',
    isFeatured: false,
    isAvailable: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

class _FakePropertyRepository extends PropertyRepository {
  _FakePropertyRepository({
    this.pages = const [],
    this.throwOnFetch = false,
  });

  final List<List<PropertyModel>> pages;
  final bool throwOnFetch;
  final List<int> requestedPages = [];

  @override
  Future<List<PropertyModel>> fetchProperties({
    Map<String, dynamic>? filters,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    requestedPages.add(page);
    if (throwOnFetch) {
      throw Exception('falha de rede');
    }
    if (page < pages.length) return pages[page];
    return const [];
  }
}

void main() {
  group('DiscoverProvider', () {
    test('load popula itens e sinaliza hasMore com página completa', () async {
      final fullPage = List.generate(
        AppConstants.defaultPageSize,
        (i) => _property('$i'),
      );
      final provider = DiscoverProvider(
        repository: _FakePropertyRepository(pages: [fullPage]),
      );

      await provider.load();

      expect(provider.items.length, AppConstants.defaultPageSize);
      expect(provider.hasMore, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('load sinaliza hasMore falso com página incompleta', () async {
      final provider = DiscoverProvider(
        repository: _FakePropertyRepository(
          pages: [
            [_property('a'), _property('b')],
          ],
        ),
      );

      await provider.load();

      expect(provider.items.length, 2);
      expect(provider.hasMore, isFalse);
    });

    test('load define error quando o repositório falha', () async {
      final provider = DiscoverProvider(
        repository: _FakePropertyRepository(throwOnFetch: true),
      );

      await provider.load();

      expect(provider.error, isNotNull);
      expect(provider.items, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('loadMore acrescenta a página seguinte', () async {
      final firstPage = List.generate(
        AppConstants.defaultPageSize,
        (i) => _property('p$i'),
      );
      final repository = _FakePropertyRepository(
        pages: [
          firstPage,
          [_property('next')],
        ],
      );
      final provider = DiscoverProvider(repository: repository);

      await provider.load();
      await provider.loadMore();

      expect(provider.items.length, AppConstants.defaultPageSize + 1);
      expect(provider.items.last.id, 'next');
      expect(repository.requestedPages, [0, 1]);
      expect(provider.hasMore, isFalse);
    });

    test('loadMore não pede nova página quando hasMore é falso', () async {
      final repository = _FakePropertyRepository(
        pages: [
          [_property('único')],
        ],
      );
      final provider = DiscoverProvider(repository: repository);

      await provider.load();
      await provider.loadMore();

      expect(repository.requestedPages, [0]);
    });
  });
}
