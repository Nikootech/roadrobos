import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// Reusable shimmer loading widget for demo loading states.
/// Shows a pulsing skeleton placeholder before real content loads.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgLightGrey,
      highlightColor: AppColors.bgWhite,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A pre-built card shimmer matching the Home screen cards
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgLightGrey,
      highlightColor: AppColors.bgWhite,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Full screen shimmer placeholder — shows 4 card skeletons
class ShimmerListPlaceholder extends StatelessWidget {
  final int itemCount;
  const ShimmerListPlaceholder({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ShimmerLoading(height: 180, borderRadius: 20),
          const SizedBox(height: 20),
          ...List.generate(itemCount, (_) => const ShimmerCard()),
        ],
      ),
    );
  }
}
