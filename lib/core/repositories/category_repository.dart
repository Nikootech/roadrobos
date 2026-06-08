import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/service_category.dart';
import '../data/local_database.dart';
import 'package:drift/drift.dart' as drift;

final categoryRepositoryProvider = Provider((ref) => CategoryRepository(ref.watch(localDatabaseProvider)));

class CategoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;

  CategoryRepository(this._db);

  Future<List<ServiceCategory>> getCategories() async {
    try {
      // ISSUE-04: Skip local SQLite cache on web — fall through to Supabase directly.
      if (!kIsWeb) {
        final localCategories = await _db.select(_db.cachedCategories).get();
        if (localCategories.isNotEmpty) {
          // Sync in background and return local data immediately
          // ignore: unawaited_futures
          _syncCategoriesFromRemote().catchError((e) {
            debugPrint('Background category sync failed: $e');
            return <ServiceCategory>[];
          });
          return localCategories.map((c) => ServiceCategory(
            id: c.id,
            icon: c.icon,
            label: c.label,
            count: c.count,
          )).toList();
        }
      }

      // Fetch from Supabase (primary path on web; fallback on native)
      return await _syncCategoriesFromRemote();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<ServiceCategory>> _syncCategoriesFromRemote() async {
    final response = await _supabase.from('categories').select();
    final categories = response.map((map) => ServiceCategory.fromMap(map, map['id'].toString())).toList();

    // Cache to Drift only on native platforms (ISSUE-04)
    if (!kIsWeb) {
      await _db.transaction(() async {
        await _db.delete(_db.cachedCategories).go();
        for (final cat in categories) {
          await _db.into(_db.cachedCategories).insert(
            CachedCategory(
              id: cat.id,
              icon: cat.icon,
              label: cat.label,
              count: cat.count,
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
      });
    }

    return categories;
  }
}
