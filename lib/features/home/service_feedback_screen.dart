import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Service Feedback Analytics screen matching Figma Screen [54]
/// Dark theme with aggregate rating card, category performance, technician leaderboard, reviews
class ServiceFeedbackScreen extends StatelessWidget {
  const ServiceFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkFeedback,
      appBar: AppBar(
        backgroundColor: AppColors.bgDarkFeedback,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgDarkSurface,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ),
        title: const Text(
          'Feedback Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnDark,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgDarkSurface,
            ),
            child: const Icon(
              Iconsax.export,
              color: AppColors.textOnDark,
              size: 18,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aggregate Rating Card (358x359, fill #1F2A38, radius 16)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgDarkSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Rating',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '4.7',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warningAmber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4
                            ? Icons.star_rounded
                            : Icons.star_half_rounded,
                        color: AppColors.warningAmber,
                        size: 28,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Based on 1,247 reviews',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textOnDarkMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Rating distribution
                  ..._buildRatingBars(),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            // Category Performance
            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryCard('Service Quality', 4.8, AppColors.successDark),
            _buildCategoryCard('Timeliness', 4.5, AppColors.primaryBlue),
            _buildCategoryCard(
                'Price Transparency', 4.6, AppColors.accentOrange),
            _buildCategoryCard('Communication', 4.9, AppColors.warningAmber),

            const SizedBox(height: 20),

            // Technician Leaderboard
            const Text(
              'Top Technicians',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildTechnicianItem('Rahul Sharma', '4.9', '156 services', 1),
            _buildTechnicianItem('Arjun Singh', '4.8', '142 services', 2),
            _buildTechnicianItem('Vikram Patel', '4.7', '128 services', 3),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRatingBars() {
    final ratings = [
      [5, 0.72],
      [4, 0.20],
      [3, 0.05],
      [2, 0.02],
      [1, 0.01],
    ];

    return ratings.map((r) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              child: Text(
                '${r[0]}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textOnDarkMuted,
                ),
              ),
            ),
            const Icon(Icons.star_rounded,
                size: 12, color: AppColors.warningAmber),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: r[1] as double,
                  backgroundColor: AppColors.bgDarkProfile,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.warningAmber),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Text(
                '${((r[1] as double) * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textOnDarkMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCategoryCard(String label, double rating, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDarkSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnDark,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                rating.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star_rounded, size: 16, color: color),
            ],
          ),
        ],
      ),
    )
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.03, end: 0);
  }

  Widget _buildTechnicianItem(
      String name, String rating, String services, int rank) {
    final rankColors = [
      AppColors.warningAmber,
      AppColors.textMuted,
      const Color(0xFFCD7F32)
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDarkSurface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankColors[rank - 1].withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: rankColors[rank - 1],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnDark,
                  ),
                ),
                Text(
                  services,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warningAmber,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.star_rounded,
                  size: 14, color: AppColors.warningAmber),
            ],
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }
}
