import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vehicle breakdown specialization categories
enum TechSpecialty {
  evBattery,
  tireAndHydraulic,
  engineMechanical,
  autoElectrical,
  locksmithAndKey,
  generalService,
}

/// A technician candidate evaluated for smart dispatch matching
class CandidateTechnician {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double rating;
  final List<TechSpecialty> specialties;
  final List<String> inventoryParts;
  final bool isAvailable;

  const CandidateTechnician({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.specialties,
    required this.inventoryParts,
    this.isAvailable = true,
  });
}

/// Service job dispatch requirement
class DispatchJobRequirement {
  final String jobId;
  final String vehicleType;
  final TechSpecialty requiredSpecialty;
  final String requiredPart;
  final double breakdownLat;
  final double breakdownLng;
  final bool isUrgentSos;

  const DispatchJobRequirement({
    required this.jobId,
    required this.vehicleType,
    required this.requiredSpecialty,
    required this.requiredPart,
    required this.breakdownLat,
    required this.breakdownLng,
    this.isUrgentSos = false,
  });
}

/// Scored match result for dispatch assignment
class DispatchMatchResult {
  final CandidateTechnician technician;
  final double overallMatchScore; // 0.0 - 100.0%
  final double estimatedEtaMinutes;
  final bool hasRequiredPart;
  final bool hasSkillMatch;
  final String matchReason;

  const DispatchMatchResult({
    required this.technician,
    required this.overallMatchScore,
    required this.estimatedEtaMinutes,
    required this.hasRequiredPart,
    required this.hasSkillMatch,
    required this.matchReason,
  });
}

/// AI-Powered Smart Dispatch Matching Service.
/// Evaluates distance, technician specialty, and on-board spare parts stock.
class SmartDispatchService {
  List<DispatchMatchResult> calculateBestMatches({
    required DispatchJobRequirement job,
    required List<CandidateTechnician> availableTechs,
  }) {
    final results = <DispatchMatchResult>[];

    for (final tech in availableTechs.where((t) => t.isAvailable)) {
      // 1. Distance & ETA calculation (approx euclidean in km)
      final distanceKm = _calculateDistanceKm(
        job.breakdownLat,
        job.breakdownLng,
        tech.latitude,
        tech.longitude,
      );
      final etaMinutes = (distanceKm * 2.5).clamp(4.0, 45.0);

      // Distance score (max 40 pts, decreases with distance)
      final distanceScore = (40.0 - (distanceKm * 2.5)).clamp(5.0, 40.0);

      // 2. Skill match score (max 30 pts)
      final hasSkill = tech.specialties.contains(job.requiredSpecialty);
      final skillScore = hasSkill ? 30.0 : 10.0;

      // 3. Spare parts availability score (max 20 pts)
      final hasPart = tech.inventoryParts.any(
        (part) => part.toLowerCase().contains(job.requiredPart.toLowerCase()),
      );
      final partScore = hasPart ? 20.0 : 0.0;

      // 4. Partner Rating score (max 10 pts)
      final ratingScore = ((tech.rating / 5.0) * 10.0).clamp(6.0, 10.0);

      final totalScore = distanceScore + skillScore + partScore + ratingScore;

      String reason;
      if (hasSkill && hasPart) {
        reason =
            'Exact Skill & Spare Parts in Vehicle (${distanceKm.toStringAsFixed(1)} km away)';
      } else if (hasSkill) {
        reason =
            'Verified Specialist (${distanceKm.toStringAsFixed(1)} km away)';
      } else {
        reason = 'Nearest Available Partner';
      }

      results.add(DispatchMatchResult(
        technician: tech,
        overallMatchScore: totalScore.clamp(20.0, 99.8),
        estimatedEtaMinutes: etaMinutes,
        hasRequiredPart: hasPart,
        hasSkillMatch: hasSkill,
        matchReason: reason,
      ));
    }

    results.sort((a, b) => b.overallMatchScore.compareTo(a.overallMatchScore));
    return results;
  }

  double _calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    // Pythagorean planar approximation for city-scale dispatch
    final dLat = (lat2 - lat1) * 111.0;
    final dLon = (lon2 - lon1) * 111.0;
    return (dLat * dLat + dLon * dLon).clamp(0.1, 50.0);
  }
}

final smartDispatchServiceProvider = Provider<SmartDispatchService>((ref) {
  return SmartDispatchService();
});
