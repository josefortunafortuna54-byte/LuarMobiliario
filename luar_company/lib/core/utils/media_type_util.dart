import 'dart:typed_data';

import 'package:mime/mime.dart';

/// Resolução e validação de tipos MIME para uploads.
///
/// Lógica pura (sem rede) para ser facilmente testável. O [StorageService]
/// usa-a para garantir que o `Content-Type` enviado é correto mesmo quando o
/// ficheiro escolhido não tem extensão.
abstract final class MediaTypeUtil {
  /// Tipos de imagem aceites (coincidem com o bucket `property-images`).
  static const Set<String> imageTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
  };

  /// Tipos de vídeo aceites (coincidem com o bucket `property-videos`).
  static const Set<String> videoTypes = {
    'video/mp4',
    'video/quicktime',
    'video/webm',
    'video/x-matroska',
    'video/3gpp',
    'video/x-msvideo',
  };

  /// Determina o MIME usando a extensão e a assinatura (magic bytes) do
  /// ficheiro. Devolve [fallback] quando nada é reconhecido.
  static String resolve({
    required String fileName,
    required Uint8List bytes,
    required String fallback,
  }) {
    final headerBytes = bytes.length > 64 ? bytes.sublist(0, 64) : bytes;
    final detected = lookupMimeType(fileName, headerBytes: headerBytes);
    if (isUsable(detected)) return detected!;

    final byName = lookupMimeType(fileName);
    if (isUsable(byName)) return byName!;

    return fallback;
  }

  /// Um MIME é utilizável quando é conhecido e não é o genérico
  /// `application/octet-stream`.
  static bool isUsable(String? mime) =>
      mime != null && mime != 'application/octet-stream';
}
