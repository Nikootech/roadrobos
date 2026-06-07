import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/ratings_repository.dart';
import '../../core/models/rating_model.dart';

class ServiceFeedbackAnalyticsScreen extends ConsumerStatefulWidget {
  const ServiceFeedbackAnalyticsScreen({super.key});

  @override
  ConsumerState<ServiceFeedbackAnalyticsScreen> createState() => _ServiceFeedbackAnalyticsScreenState();
}

class _ServiceFeedbackAnalyticsScreenState extends ConsumerState<ServiceFeedbackAnalyticsScreen> {
  List<RatingModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final repo = ref.read(ratingsRepositoryProvider);
      final reviews = await repo.getRecentReviews();
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }

  Future<void> _deleteReview(String id) async {
    try {
      final repo = ref.read(ratingsRepositoryProvider);
      await repo.deleteReview(id);
      await _fetchReviews(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate overall rating if possible
    double avgScore = 0;
    if (_reviews.isNotEmpty) {
      avgScore = _reviews.fold(0.0, (sum, item) => sum + item.score) / _reviews.length;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Feedback & Reviews', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Rating
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.all(Radius.circular(24))),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(avgScore.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star_half, color: Colors.amber, size: 14),
                        ],
                      ),
                      const Text('Overall Rating', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(width: 32),
                  const Expanded(
                    child: Column(
                      children: [
                        _RatingBar(stars: 5, progress: 0.8),
                        _RatingBar(stars: 4, progress: 0.15),
                        _RatingBar(stars: 3, progress: 0.03),
                        _RatingBar(stars: 2, progress: 0.01),
                        _RatingBar(stars: 1, progress: 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Recent Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_reviews.isEmpty)
              const Center(child: Text('No reviews yet.', style: TextStyle(color: AppColors.textMuted))),
            ..._reviews.map((review) => _buildReviewTile(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile(RatingModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) => Icon(
                  index < review.score ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 14,
                )),
              ),
              Row(
                children: [
                  Text(
                    review.createdAt != null 
                      ? '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}' 
                      : '', 
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10)
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 16),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (review.id != null) {
                        _deleteReview(review.id!);
                      }
                    },
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (review.reviewText != null && review.reviewText!.isNotEmpty)
            Text(review.reviewText!, style: const TextStyle(fontSize: 13, height: 1.4))
          else
            const Text('No comment provided', style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('Role: ${review.role}', style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue)),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final double progress;
  const _RatingBar({required this.stars, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
