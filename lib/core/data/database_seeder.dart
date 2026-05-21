import 'package:flutter/foundation.dart';
import 'mock_data.dart';

/// Database seeder — previously used Firestore, now a no-op stub.
/// TODO: Reimplement seeding against Supabase if needed for dev/testing.
class DatabaseSeeder {
  static Future<void> seedDatabase() async {
    if (!kDebugMode) return;
    debugPrint('[DatabaseSeeder] Skipped — Firestore seeder removed. Use Supabase SQL seeds instead.');
  }
}

