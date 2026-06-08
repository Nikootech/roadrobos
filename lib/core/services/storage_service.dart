import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  SupabaseClient get _client => Supabase.instance.client;
  static const String _bucketName = 'roadrobos-media';

  /// Uploads an image to Supabase Storage and returns the public URL
  Future<String?> uploadImage(File file, String path) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final fullPath = '$path/$fileName';

      await _client.storage.from(_bucketName).upload(
            fullPath,
            file,
          );

      return _client.storage.from(_bucketName).getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('Supabase Storage Error: $e');
      return null;
    }
  }

  /// Uploads and compresses an avatar, returning the public URL
  Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path, 
        tempPath,
        quality: 80,
        minWidth: 800,
        minHeight: 800,
      );

      if (result == null) return null;

      final fullPath = '$userId/avatar.jpg';

      await _client.storage.from('avatars').upload(
            fullPath,
            File(result.path),
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from('avatars').getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('Supabase Avatar Upload Error: $e');
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
