import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ─── Base shimmer box ─────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ─── List tile shimmer ─────────────────────────────────────────────────────────

class ShimmerListTile extends StatelessWidget {
  final int lines;
  const ShimmerListTile({super.key, this.lines = 2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ShimmerBox(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: double.infinity, height: 14),
                if (lines > 1) ...[
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 180, height: 12),
                ],
                if (lines > 2) ...[
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 100, height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card shimmer ─────────────────────────────────────────────────────────────

class ShimmerCard extends StatelessWidget {
  final double height;
  final EdgeInsets padding;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ShimmerBox(
        width: double.infinity,
        height: height,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Quick actions row shimmer ────────────────────────────────────────────────

class ShimmerQuickActionsRow extends StatelessWidget {
  final int itemCount;
  const ShimmerQuickActionsRow({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          itemCount,
          (_) => Column(
            children: [
              ShimmerBox(
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(18),
              ),
              const SizedBox(height: 8),
              const ShimmerBox(width: 44, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grid shimmer ─────────────────────────────────────────────────────────────

class ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double itemHeight;

  const ShimmerGrid({
    super.key,
    this.crossAxisCount = 4,
    this.itemCount = 8,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 56 / 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: List.generate(
        itemCount,
        (_) => ShimmerBox(
          width: double.infinity,
          height: itemHeight,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── List of shimmer tiles ─────────────────────────────────────────────────────

class ShimmerList extends StatelessWidget {
  final int count;
  final int lines;

  const ShimmerList({super.key, this.count = 4, this.lines = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => ShimmerListTile(lines: lines),
      ),
    );
  }
}
