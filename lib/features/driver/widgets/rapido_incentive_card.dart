import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Rapido Captain Incentive Quest & Milestone Hub Card
/// Displays daily quests, peak hour bonuses, and step progress.
class RapidoIncentiveCard extends StatelessWidget {
  final int completedTrips;
  final int targetTrips;
  final int bonusAmount;

  const RapidoIncentiveCard({
    super.key,
    this.completedTrips = 0,
    this.targetTrips = 5,
    this.bonusAmount = 150,
  });

  @override
  Widget build(BuildContext context) {
    final validTarget = targetTrips > 0 ? targetTrips : 1;
    final progress = (completedTrips / validTarget).clamp(0.0, 1.0);
    final remaining = (validTarget - completedTrips).clamp(0, validTarget);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24), // Dark cockpit surface
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Quest Title + Bonus Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.award5,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY CAPTAIN QUEST',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Peak Shift Milestone',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+₹$bonusAmount BONUS',
                  style: const TextStyle(
                    color: Color(0xFF121212),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar with Steps
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),

          const SizedBox(height: 10),

          // Stats Subtitle & Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedTrips of $targetTrips trips done (${(progress * 100).toInt()}%)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                remaining > 0 ? '$remaining trips left today' : '🎉 Quest Unlocked!',
                style: TextStyle(
                  color: remaining > 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Peak Guarantee tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(Iconsax.flash_1, size: 14, color: Color(0xFFF59E0B)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Peak Hours (6 PM - 10 PM): 1.5x extra on all trips',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
