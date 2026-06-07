class RatingModel {
  final String? id;
  final String bookingId;
  final String reviewerId;
  final String revieweeId;
  final String role; // 'driver' or 'technician'
  final int score;
  final String? reviewText;
  final DateTime? createdAt;

  RatingModel({
    this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.role,
    required this.score,
    this.reviewText,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String?,
      bookingId: json['booking_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      revieweeId: json['reviewee_id'] as String,
      role: json['role'] as String,
      score: json['score'] as int,
      reviewText: json['review_text'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'booking_id': bookingId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'role': role,
      'score': score,
    };
    if (id != null) data['id'] = id;
    if (reviewText != null) data['review_text'] = reviewText;
    return data;
  }
}
