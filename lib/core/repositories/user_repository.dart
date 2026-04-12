import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch user profile from Firestore
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Create or update user profile
  Future<void> saveUser(AppUser user) async {
    try {
      await _db.collection('users').doc(user.id).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Check if user exists (useful for registration flow)
  Future<bool> userExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Update specific fields (e.g., profile pic, role)
  Future<void> updateField(String uid, String field, dynamic value) async {
    try {
      await _db.collection('users').doc(uid).update({field: value});
    } catch (e) {
      throw Exception('Failed to update user field ($field): $e');
    }
  }
}
