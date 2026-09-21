import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _client = SupabaseService.client;

  static const _uuid = Uuid();

  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    required String bucket,
    String? customPath,
  }) async {
    try {
      final fileExtension = path.extension(fileName).replaceAll('.', '');
      final safeExtension = fileExtension.isEmpty ? 'jpg' : fileExtension;
      final storageFileName = '${_uuid.v4()}.$safeExtension';
      final uploadPath = customPath != null
          ? '$customPath/$storageFileName'
          : storageFileName;

      await _client.storage
          .from(bucket)
          .uploadBinary(
            uploadPath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(uploadPath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadMultipleImages({
    required List<({Uint8List bytes, String fileName})> files,
    required String bucket,
    String? customPath,
  }) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
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
