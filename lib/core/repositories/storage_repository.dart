import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

class StorageRepository {
  final _supabase = Supabase.instance.client;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    final extension = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final fullPath = '$path/$fileName';

    await _supabase.storage.from(bucket).upload(
      fullPath,
      file,
    );

    return _supabase.storage.from(bucket).getPublicUrl(fullPath);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _supabase.storage.from(bucket).remove([path]);
  }
}
