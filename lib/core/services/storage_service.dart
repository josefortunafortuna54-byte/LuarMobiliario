import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils/media_type_util.dart';
import 'supabase_service.dart';

/// Erro de upload com mensagem pronta a apresentar ao utilizador.
class StorageUploadException implements Exception {
  final String message;
  final Object? cause;

  StorageUploadException(this.message, {this.cause});

  @override
  String toString() => message;
}

/// Serviço de armazenamento (Supabase Storage).
///
/// Centraliza o upload de ficheiros com deteção de MIME (extensão + assinatura
/// do ficheiro), validação contra os tipos aceites, verificação de tamanho e
/// repetição automática em falhas transitórias de rede.
class StorageService {
  final SupabaseClient _client = SupabaseService.client;

  static const _uuid = Uuid();

  static const int _maxAttempts = 3;

  /// Tipos MIME de imagem aceites (coincidem com o bucket `property-images`).
  static const Set<String> allowedImageTypes = MediaTypeUtil.imageTypes;

  /// Tipos MIME de vídeo aceites (coincidem com o bucket `property-videos`).
  static const Set<String> allowedVideoTypes = MediaTypeUtil.videoTypes;

  /// Envia uma imagem para [bucket] e devolve o URL público.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    required String bucket,
    String? customPath,
    int? maxBytes,
  }) {
    return uploadFile(
      bytes: bytes,
      fileName: fileName,
      bucket: bucket,
      customPath: customPath,
      maxBytes: maxBytes,
      allowedTypes: allowedImageTypes,
      fallbackType: 'image/jpeg',
      label: 'imagem',
    );
  }

  /// Envia um vídeo para [bucket] e devolve o URL público.
  Future<String> uploadVideo({
    required Uint8List bytes,
    required String fileName,
    required String bucket,
    String? customPath,
    int? maxBytes,
  }) {
    return uploadFile(
      bytes: bytes,
      fileName: fileName,
      bucket: bucket,
      customPath: customPath,
      maxBytes: maxBytes,
      allowedTypes: allowedVideoTypes,
      fallbackType: 'video/mp4',
      label: 'vídeo',
    );
  }

  /// Upload genérico, resiliente e validado.
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String bucket,
    required Set<String> allowedTypes,
    required String fallbackType,
    required String label,
    String? customPath,
    int? maxBytes,
  }) async {
    if (bytes.isEmpty) {
      throw StorageUploadException('O ficheiro de $label está vazio.');
    }

    if (maxBytes != null && bytes.length > maxBytes) {
      throw StorageUploadException(
        'O $label excede o tamanho máximo de ${_formatMb(maxBytes)} MB.',
      );
    }

    final mimeType = MediaTypeUtil.resolve(
      fileName: fileName,
      bytes: bytes,
      fallback: fallbackType,
    );

    if (!allowedTypes.contains(mimeType)) {
      throw StorageUploadException(
        'Formato de $label não suportado ($mimeType).',
      );
    }

    final extension =
        extensionFromMime(mimeType) ?? _extensionFromName(fileName) ?? 'bin';
    final storageFileName = '${_uuid.v4()}.$extension';
    final uploadPath = customPath != null
        ? '$customPath/$storageFileName'
        : storageFileName;

    Object? lastError;
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        await _client.storage.from(bucket).uploadBinary(
          uploadPath,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: mimeType),
        );
        return _client.storage.from(bucket).getPublicUrl(uploadPath);
      } catch (e) {
        lastError = e;
        if (attempt < _maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    throw StorageUploadException(
      'Não foi possível enviar o $label. Verifique a ligação e tente novamente.',
      cause: lastError,
    );
  }

  String? _extensionFromName(String fileName) {
    final ext = path.extension(fileName).replaceAll('.', '').toLowerCase();
    return ext.isEmpty ? null : ext;
  }

  String _formatMb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(0);

  Future<List<String>> uploadMultipleImages({
    required List<({Uint8List bytes, String fileName})> files,
    required String bucket,
    String? customPath,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadImage(
        bytes: file.bytes,
        fileName: file.fileName,
        bucket: bucket,
        customPath: customPath,
      );
      urls.add(url);
    }
    return urls;
  }

  Future<void> deleteImage({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  String getPublicUrl({required String bucket, required String path}) {
    try {
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Failed to get public URL: $e');
    }
  }
}
