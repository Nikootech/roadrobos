import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rating_model.dart';

class RatingsRepositoryException implements Exception {
  final String message;
  final dynamic details;
  RatingsRepositoryException(this.message, [this.details]);

  @override
  String toString() => 'RatingsRepositoryException: $message (${details ?? ''})';
}

class RatingsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Submit a rating
  Future<void> submitRating(RatingModel rating) async {
    try {
      await _supabase.from('ratings').insert(rating.toJson());
    } catch (e) {
      throw RatingsRepositoryException('Failed to submit rating', e);
    }
  }

  /// Get partner average rating and review count
  Future<Map<String, dynamic>?> getPartnerRating(String partnerId) async {
    try {
      final response = await _supabase
          .from('partner_avg_rating')
          .select()
          .eq('reviewee_id', partnerId)
          .maybeSingle();
      return response;
    } catch (e) {
      throw RatingsRepositoryException('Failed to get partner rating', e);
    }
  }

  /// Get pending rating ID from SharedPreferences
  Future<String?> getPendingRating() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pendingRatingBookingId');
  }

  /// Set pending rating ID in SharedPreferences
  Future<void> setPendingRating(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pendingRatingBookingId', bookingId);
  }

  /// Clear pending rating ID from SharedPreferences
  Future<void> clearPendingRating() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingRatingBookingId');
  }
  
  /// Get all recent reviews for the admin dashboard
  Future<List<RatingModel>> getRecentReviews({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('ratings')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List).map((json) => RatingModel.fromJson(json)).toList();
    } catch (e) {
      throw RatingsRepositoryException('Failed to fetch recent reviews', e);
    }
  }
  
  /// Delete a review (Admin)
  Future<void> deleteReview(String id) async {
    try {
      await _supabase.from('ratings').delete().eq('id', id);
    } catch (e) {
      throw RatingsRepositoryException('Failed to delete review', e);
    }
  }
}

final ratingsRepositoryProvider = Provider<RatingsRepository>((ref) {
  return RatingsRepository();
});

final partnerRatingProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, partnerId) async {
  final repo = ref.read(ratingsRepositoryProvider);
  return repo.getPartnerRating(partnerId);
});
