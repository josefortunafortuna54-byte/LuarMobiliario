import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/property_card.dart';
import 'package:test_api/fake.dart';

// 1x1 transparent PNG
final _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xe2, 0x21, 0xbc, 0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  Future<Socket> get done => Future.error(SocketException('mock'));

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_kTransparentImage])
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Future<T> fold<T>(T initialValue, T Function(T, List<int>) combine) =>
      Stream<List<int>>.fromIterable(<List<int>>[_kTransparentImage])
          .fold(initialValue, combine);

  @override
  Future<void> forEach(void Function(List<int>) action) =>
      Stream<List<int>>.fromIterable(<List<int>>[_kTransparentImage]).forEach(action);
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  String? value(String name) => 'image/png';
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  PropertyCard createCard({
    String imageUrl = 'https://example.com/img.jpg',
    String title = 'Vivenda Moderna',
    String location = 'Talatona, Luanda',
    double price = 15000000,
    PropertyListingType listingType = PropertyListingType.venda,
    PropertyCardVariant variant = PropertyCardVariant.vertical,
    int? bedrooms = 3,
    int? bathrooms = 2,
    double? area = 350,
    VoidCallback? onTap,
    VoidCallback? onDetailsTap,
  }) {
    return PropertyCard(
      imageUrl: imageUrl,
      title: title,
      location: location,
      price: price,
      listingType: listingType,
      variant: variant,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      area: area,
      onTap: onTap,
      onDetailsTap: onDetailsTap,
    );
  }

  group('PropertyCard', () {
    group('vertical variant', () {
      testWidgets('renders title and location text', (tester) async {
        await tester.pumpWidget(wrapInApp(createCard()));
        await tester.pumpAndSettle();

        expect(find.text('Vivenda Moderna'), findsOneWidget);
        expect(find.text('Talatona, Luanda'), findsOneWidget);
      });

      testWidgets('shows Venda badge for venda listing type', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(listingType: PropertyListingType.venda),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Venda'), findsWidgets);
      });

      testWidgets('shows Arrendamento badge for arrendamento listing type',
          (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(listingType: PropertyListingType.arrendamento),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Arrendamento'), findsWidgets);
      });

      testWidgets('displays formatted price with AOA prefix', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(price: 15000000),
        ));
        await tester.pumpAndSettle();

        expect(find.text('AOA 15.000.000'), findsOneWidget);
      });

      testWidgets('formats price with dot separators', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(price: 1500000),
        ));
        await tester.pumpAndSettle();

        expect(find.text('AOA 1.500.000'), findsOneWidget);
      });

      testWidgets('formats small price without separators', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(price: 500),
        ));
        await tester.pumpAndSettle();

        expect(find.text('AOA 500'), findsOneWidget);
      });

      testWidgets('shows bedroom count', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(bedrooms: 4),
        ));
        await tester.pumpAndSettle();

        expect(find.text('4'), findsWidgets);
      });

      testWidgets('shows bathroom count', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(bathrooms: 3),
        ));
        await tester.pumpAndSettle();

        expect(find.text('3'), findsWidgets);
      });

      testWidgets('shows area in m²', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(area: 250),
        ));
        await tester.pumpAndSettle();

        expect(find.text('250 m²'), findsOneWidget);
      });

      testWidgets('hides features when null', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(bedrooms: null, bathrooms: null, area: null),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.king_bed_outlined), findsNothing);
        expect(find.byIcon(Icons.bathroom_outlined), findsNothing);
        expect(find.byIcon(Icons.square_foot_outlined), findsNothing);
      });

      testWidgets('calls onTap when card is tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(wrapInApp(
          createCard(onTap: () => tapped = true),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PropertyCard));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('calls onDetailsTap when details button is tapped',
          (tester) async {
        var detailsTapped = false;

        await tester.pumpWidget(wrapInApp(
          createCard(onDetailsTap: () => detailsTapped = true),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Detalhes'));
        await tester.pumpAndSettle();

        expect(detailsTapped, isTrue);
      });

      testWidgets('shows Detalhes button', (tester) async {
        await tester.pumpWidget(wrapInApp(createCard()));
        await tester.pumpAndSettle();

        expect(find.text('Detalhes'), findsOneWidget);
      });
    });

    group('horizontal variant', () {
      testWidgets('renders with horizontal variant', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(variant: PropertyCardVariant.horizontal),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Vivenda Moderna'), findsOneWidget);
        expect(find.text('Talatona, Luanda'), findsOneWidget);
      });

      testWidgets('shows Venda badge', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(
            variant: PropertyCardVariant.horizontal,
            listingType: PropertyListingType.venda,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Venda'), findsWidgets);
      });

      testWidgets('shows formatted price', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(
            variant: PropertyCardVariant.horizontal,
            price: 2500000,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('AOA 2.500.000'), findsOneWidget);
      });

      testWidgets('calls onTap on horizontal card', (tester) async {
        var tapped = false;

        await tester.pumpWidget(wrapInApp(
          createCard(
            variant: PropertyCardVariant.horizontal,
            onTap: () => tapped = true,
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PropertyCard));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('calls onDetailsTap on horizontal card', (tester) async {
        var detailsTapped = false;

        await tester.pumpWidget(wrapInApp(
          createCard(
            variant: PropertyCardVariant.horizontal,
            onDetailsTap: () => detailsTapped = true,
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Detalhes'));
        await tester.pumpAndSettle();

        expect(detailsTapped, isTrue);
      });

      testWidgets('shows Detalhes button', (tester) async {
        await tester.pumpWidget(wrapInApp(
          createCard(variant: PropertyCardVariant.horizontal),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Detalhes'), findsOneWidget);
      });
    });
  });
}
