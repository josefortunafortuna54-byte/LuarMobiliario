import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/media_urls.dart';

void main() {
  group('extractMediaUrls', () {
    test('extrai as URLs da lista de registos', () {
      final urls = extractMediaUrls([
        {'image_url': 'https://a/1.jpg'},
        {'image_url': 'https://a/2.jpg'},
      ], 'image_url');

      expect(urls, ['https://a/1.jpg', 'https://a/2.jpg']);
    });

    test('devolve lista vazia para null', () {
      expect(extractMediaUrls(null, 'video_url'), isEmpty);
    });

    test('ignora registos malformados', () {
      final urls = extractMediaUrls([
        {'image_url': 'https://a/1.jpg'},
        {'outro': 'x'},
        'não-é-mapa',
      ], 'image_url');

      expect(urls, ['https://a/1.jpg']);
    });

    test('ignora URLs vazias', () {
      final urls = extractMediaUrls([
        {'video_url': ''},
        {'video_url': 'https://a/v.mp4'},
      ], 'video_url');

      expect(urls, ['https://a/v.mp4']);
    });
  });

  group('popMediaUrls', () {
    test('remove a chave e devolve as URLs', () {
      final data = <String, dynamic>{
        'title': 'Casa',
        'images': ['a.jpg', 'b.jpg'],
      };

      expect(popMediaUrls(data, 'images'), ['a.jpg', 'b.jpg']);
      expect(data.containsKey('images'), isFalse);
      expect(data['title'], 'Casa');
    });

    test('devolve lista vazia quando a chave não existe', () {
      expect(
        popMediaUrls(<String, dynamic>{'title': 'Casa'}, 'videos'),
        isEmpty,
      );
    });
  });
}
