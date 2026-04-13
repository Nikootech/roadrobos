import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _bucketName = 'roadrobos-media';

  /// Uploads an image to Supabase Storage and returns the public URL
  Future<String?> uploadImage(File file, String path) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final fullPath = '$path/$fileName';

      await _client.storage.from(_bucketName).upload(
            fullPath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _client.storage.from(_bucketName).getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('Supabase Storage Error: $e');
      return null;
    }
  }

  /// Deletes a file from Supabase Storage
  Future<void> deleteFile(String fullPath) async {
    try {
      await _client.storage.from(_bucketName).remove([fullPath]);
    } catch (e) {
      debugPrint('Supabase Delete Error: $e');
    }
  }

  /// Generates a public URL for a given path
  String getPublicUrl(String path) {
    return _client.storage.from(_bucketName).getPublicUrl(path);
  }
}
