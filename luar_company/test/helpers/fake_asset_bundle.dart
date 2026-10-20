import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundle de assets falso para testes de widgets que renderizam imagens
/// (ex.: `logo.png` no splash/welcome), evitando erros de asset em falta.
class FakeAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  );

  static final Uint8List _emptyAssetManifest = Uint8List.sublistView(
    const StandardMessageCodec().encodeMessage(<String, Object?>{})!,
  );

  static final Uint8List _emptyFontManifest = Uint8List.sublistView(
    utf8.encode('{}'),
  );

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return ByteData.sublistView(_emptyAssetManifest);
    }
    if (key == 'FontManifest.json') {
      return ByteData.sublistView(_emptyFontManifest);
    }
    if (key.endsWith('.png')) {
      return ByteData.sublistView(_transparentPng);
    }
    throw FlutterError('Asset em falta no FakeAssetBundle: $key');
  }
}
