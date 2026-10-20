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

  /// JPEG 1×1 navy (o decoder de imagens valida o formato pelos bytes).
  static final Uint8List _tinyJpeg = base64Decode(
    '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABALDA4MChAODQ4SERATGCgaGBYWGDEjJR0oOjM9PDkzODdASFxOQERXRTc4UG1RV19iZ2hnPk1xeXBkeFxlZ2P/2wBDARESEhgVGC8aGi9jQjhCY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2P/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDlqKKK6DkP/9k=',
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
    // JPEG de 1×1 válido (o decoder rejeita PNG bytes numa chave .jpeg).
    if (key.endsWith('.jpeg') || key.endsWith('.jpg')) {
      return ByteData.sublistView(_tinyJpeg);
    }
    throw FlutterError('Asset em falta no FakeAssetBundle: $key');
  }
}
