import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/media_type_util.dart';

Uint8List _bytes(List<int> data) => Uint8List.fromList(data);

/// Cabeçalho válido de um ficheiro MP4 (`....ftypavc1`).
final _mp4Header = _bytes([
  0x00, 0x00, 0x00, 0x00, 0x66, 0x74, 0x79, 0x70,
  0x61, 0x76, 0x63, 0x31,
]);

void main() {
  group('MediaTypeUtil.resolve', () {
    test('deteta pelo nome/extensão (mp4)', () {
      final mime = MediaTypeUtil.resolve(
        fileName: 'VID_2024.mp4',
        bytes: _bytes([1, 2, 3]),
        fallback: 'video/mp4',
      );
      expect(mime, 'video/mp4');
    });

    test('deteta pela assinatura quando o nome não tem extensão', () {
      final mime = MediaTypeUtil.resolve(
        fileName: 'sem_extensao',
        bytes: _mp4Header,
        fallback: 'video/mp4',
      );
      expect(mime, 'video/mp4');
    });

    test('reconhece imagens (jpg/png) por extensão', () {
      expect(
        MediaTypeUtil.resolve(
          fileName: 'foto.jpg',
          bytes: _bytes([1]),
          fallback: 'image/jpeg',
        ),
        'image/jpeg',
      );
      expect(
        MediaTypeUtil.resolve(
          fileName: 'foto.png',
          bytes: _bytes([1]),
          fallback: 'image/jpeg',
        ),
        'image/png',
      );
    });

    test('usa o fallback quando nada é reconhecido', () {
      final mime = MediaTypeUtil.resolve(
        fileName: 'ficheiro',
        bytes: _bytes([0xAA, 0xBB, 0xCC]),
        fallback: 'video/mp4',
      );
      expect(mime, 'video/mp4');
    });

    test('é insensível a maiúsculas na extensão', () {
      final mime = MediaTypeUtil.resolve(
        fileName: 'CLIP.MP4',
        bytes: _bytes([1]),
        fallback: 'video/mp4',
      );
      expect(mime, 'video/mp4');
    });
  });

  group('MediaTypeUtil.isUsable', () {
    test('rejeita null e octet-stream', () {
      expect(MediaTypeUtil.isUsable(null), isFalse);
      expect(MediaTypeUtil.isUsable('application/octet-stream'), isFalse);
    });

    test('aceita tipos conhecidos', () {
      expect(MediaTypeUtil.isUsable('video/mp4'), isTrue);
      expect(MediaTypeUtil.isUsable('image/jpeg'), isTrue);
    });
  });

  group('Conjuntos de tipos permitidos', () {
    test('incluem os formatos de vídeo do bucket', () {
      expect(MediaTypeUtil.videoTypes, contains('video/mp4'));
      expect(MediaTypeUtil.videoTypes, contains('video/quicktime'));
      expect(MediaTypeUtil.videoTypes, contains('video/webm'));
    });

    test('incluem os formatos de imagem do bucket', () {
      expect(MediaTypeUtil.imageTypes, contains('image/jpeg'));
      expect(MediaTypeUtil.imageTypes, contains('image/png'));
      expect(MediaTypeUtil.imageTypes, contains('image/webp'));
    });
  });
}
