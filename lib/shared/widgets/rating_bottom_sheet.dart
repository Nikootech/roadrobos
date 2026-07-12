import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/rating_model.dart';
import '../../core/repositories/ratings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RatingBottomSheet extends ConsumerStatefulWidget {
  final String bookingId;
  final String revieweeId;
  final String partnerName;
  final String partnerAvatarUrl;
  final String role; // 'driver' or 'technician'

  const RatingBottomSheet({
    super.key,
    required this.bookingId,
    required this.revieweeId,
    required this.partnerName,
    required this.partnerAvatarUrl,
    required this.role,
  });

  static Future<void> show(
    BuildContext context, {
    required String bookingId,
    required String revieweeId,
    required String partnerName,
    required String partnerAvatarUrl,
    required String role,
  }) async {
    // If dismissed without rating, handle pending rating logic
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingBottomSheet(
        bookingId: bookingId,
        revieweeId: revieweeId,
        partnerName: partnerName,
        partnerAvatarUrl: partnerAvatarUrl,
        role: role,
      ),
    );

    if (result != true) {
      // User dismissed without rating, store for later
      final repo = ProviderContainer().read(ratingsRepositoryProvider);
      await repo.setPendingRating(bookingId);
    }
  }

  @override
  ConsumerState<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<RatingBottomSheet> {
  int _score = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    if (_score == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final rating = RatingModel(
        bookingId: widget.bookingId,
        reviewerId: userId,
        revieweeId: widget.revieweeId,
        role: widget.role,
        score: _score,
        reviewText: _reviewController.text.trim().isEmpty
            ? null
            : _reviewController.text.trim(),
      );

      final repo = ref.read(ratingsRepositoryProvider);
      await repo.submitRating(rating);

      // Clear pending rating if any
      await repo.clearPendingRating();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundImage: widget.partnerAvatarUrl.isNotEmpty
                  ? NetworkImage(widget.partnerAvatarUrl)
                  : null,
              child: widget.partnerAvatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'How was your experience with ${widget.partnerName}?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      index < _score ? Icons.star : Icons.star_border,
                      key: ValueKey<int>(index < _score ? 1 : 0),
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _score = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Leave a comment (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
