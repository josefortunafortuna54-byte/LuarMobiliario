import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/constants/app_constants.dart';
import 'package:luar_company/core/models/land_model.dart';
import 'package:luar_company/core/models/property_model.dart';
import 'package:luar_company/core/repositories/land_repository.dart';
import 'package:luar_company/core/repositories/property_repository.dart';
import 'package:luar_company/screens/map/map_screen.dart';

import '../helpers/test_app.dart';

const int _mapPageSize = 50;

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

LandModel _land(String id) {
  return LandModel(
    id: id,
    title: 'Terreno $id',
    description: 'Descrição',
    type: LandType.urban,
    transactionType: LandTransactionType.sale,
    price: 8000000,
    area: 500,
    address: 'Estrada',
    city: 'Luanda',
    municipality: 'Talatona',
    neighborhood: 'Nova Vida',
    latitude: -8.92,
    longitude: 13.18,
    images: const [],
    features: const [],
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

class _FakePropertyRepository extends PropertyRepository {
  _FakePropertyRepository({this.pages = const []});

  final List<List<PropertyModel>> pages;
  final List<int> requestedPages = [];

  @override
  Future<List<PropertyModel>> fetchProperties({
    Map<String, dynamic>? filters,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    requestedPages.add(page);
    if (page < pages.length) return pages[page];
    return const [];
  }
}

class _FakeLandRepository extends LandRepository {
  _FakeLandRepository({this.pages = const []});

  final List<List<LandModel>> pages;
  final List<int> requestedPages = [];

  @override
  Future<List<LandModel>> fetchLands({
    Map<String, dynamic>? filters,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    requestedPages.add(page);
    if (page < pages.length) return pages[page];
    return const [];
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('MapScreen', () {
    testWidgets('carrega todas as páginas de imóveis e terrenos', (
      tester,
    ) async {
      final fullPage = List.generate(_mapPageSize + 1, (i) => _property('$i'));
      final fullLandPage = List.generate(_mapPageSize + 1, (i) => _land('$i'));
      final properties = _FakePropertyRepository(
        pages: [
          fullPage,
          [_property('ultimo')],
        ],
      );
      final lands = _FakeLandRepository(
        pages: [
          fullLandPage,
          [_land('ultimo')],
        ],
      );

      await tester.pumpWidget(
        testApp(
          home: MapScreen(
            propertyRepository: properties,
            landRepository: lands,
          ),
        ),
      );
      await _settle(tester);

      expect(properties.requestedPages, [0, 1]);
      expect(lands.requestedPages, [0, 1]);
    });

    testWidgets('mostra aviso quando não há anúncios no mapa', (tester) async {
      await tester.pumpWidget(
        testApp(
          home: MapScreen(
            propertyRepository: _FakePropertyRepository(),
            landRepository: _FakeLandRepository(),
          ),
        ),
      );
      await _settle(tester);

      expect(find.text('Sem imóveis para mostrar no mapa'), findsOneWidget);
    });
  });
}
