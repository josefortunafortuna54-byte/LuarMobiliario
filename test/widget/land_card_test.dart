import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/widgets/land_card.dart';

final _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9c, 0x62, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xe2, 0x21,
  0xbc, 0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60,
  0x82,
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

  Future<Socket> get done => Future.error(SocketException('mock'));

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[
      _kTransparentImage,
    ]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<T> fold<T>(T initialValue, T Function(T, List<int>) combine) =>
      Stream<List<int>>.fromIterable(<List<int>>[
        _kTransparentImage,
      ]).fold(initialValue, combine);

  @override
  Future<void> forEach(void Function(List<int>) action) =>
      Stream<List<int>>.fromIterable(<List<int>>[
        _kTransparentImage,
      ]).forEach(action);
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

  LandCard createCard({
    String imageUrl = 'https://example.com/land.jpg',
    String title = 'Terreno Talatona',
    String location = 'Talatona, Luanda',
    double area = 500,
    double price = 25000000,
    String badgeLabel = 'Urbano',
    List<String> features = const ['Zona residencial'],
    VoidCallback? onTap,
    VoidCallback? onDetailsTap,
  }) {
    return LandCard(
      imageUrl: imageUrl,
      title: title,
      location: location,
      area: area,
      price: price,
      badgeLabel: badgeLabel,
      features: features,
      onTap: onTap,
      onDetailsTap: onDetailsTap,
    );
  }

  group('LandCard', () {
    testWidgets('renders title, location and badge', (tester) async {
      await tester.pumpWidget(wrapInApp(createCard()));
      await tester.pumpAndSettle();

      expect(find.text('Terreno Talatona'), findsOneWidget);
      expect(find.text('Talatona, Luanda'), findsOneWidget);
      expect(find.text('Urbano'), findsOneWidget);
    });

    testWidgets('renders formatted price', (tester) async {
      await tester.pumpWidget(wrapInApp(createCard(price: 25000000)));
      await tester.pumpAndSettle();

      expect(find.text('AOA 25.000.000'), findsOneWidget);
    });

    testWidgets('renders area with m² suffix', (tester) async {
      await tester.pumpWidget(wrapInApp(createCard(area: 500)));
      await tester.pumpAndSettle();

      expect(find.text('500 m²'), findsOneWidget);
    });

    testWidgets('renders feature chips', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          createCard(features: const ['Zona residencial', 'Cerca completa']),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zona residencial'), findsOneWidget);
      expect(find.text('Cerca completa'), findsOneWidget);
    });

    testWidgets('does not render features when empty', (tester) async {
      await tester.pumpWidget(wrapInApp(createCard(features: const [])));
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(wrapInApp(createCard(onTap: () => tapped = true)));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LandCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onDetailsTap when Detalhes is tapped', (tester) async {
      var detailsTapped = false;

      await tester.pumpWidget(
        wrapInApp(createCard(onDetailsTap: () => detailsTapped = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Detalhes'));
      await tester.pumpAndSettle();

      expect(detailsTapped, isTrue);
    });
  });
}