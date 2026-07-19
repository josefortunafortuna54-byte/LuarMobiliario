import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _client = SupabaseService.client;

  static const _uuid = Uuid();

  Future<String> uploadImage({
    required File file,
    required String bucket,
    String? customPath,
  }) async {
    try {
      final fileExtension = path.extension(file.path).replaceAll('.', '');
      final fileName = '${_uuid.v4()}.$fileExtension';
      final uploadPath = customPath != null ? '$customPath/$fileName' : fileName;

      final response = await _client.storage.from(bucket).upload(
            uploadPath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isEmpty) {
        throw Exception('Upload returned empty response');
      }

      final publicUrl = _client.storage.from(bucket).getPublicUrl(uploadPath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadMultipleImages({
    required List<File> files,
    required String bucket,
    String? customPath,
  }) async {
    try {
      final urls = <String>[];

      for (final file in files) {
        final url = await uploadImage(
          file: file,
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

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    try {
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Failed to get public URL: $e');
    }
  }
}
