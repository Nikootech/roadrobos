import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';

class ServiceFeedbackAnalyticsScreen extends StatelessWidget {
  const ServiceFeedbackAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Feedback Analytics', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Rating
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.all(Radius.circular(24))),
              child: const Row(
                children: [
                  Column(
                    children: [
                      Text('4.8', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star_half, color: Colors.amber, size: 14),
                        ],
                      ),
                      Text('Overall Rating', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                  SizedBox(width: 32),
                  Expanded(
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
            const Text('Sentiment Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 75, color: AppColors.successGreen, title: 'Positive', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: 20, color: Colors.amber, title: 'Neutral', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: 5, color: AppColors.dangerRed, title: 'Negative', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Recent Feedback Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFeedbackTile('Great service, the technician was very professional and punctual.', 'Positive'),
            _buildFeedbackTile('The app tracking was slightly delayed, but ride was okay.', 'Neutral'),
            _buildFeedbackTile('Excellent car condition and polite driver behavior.', 'Positive'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTile(String text, String sentiment) {
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
              Text(sentiment, style: TextStyle(color: sentiment == 'Positive' ? AppColors.successGreen : Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
              const Text('2 hours ago', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
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
              backgroundColor: Colors.white.withOpacity(0.2),
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
