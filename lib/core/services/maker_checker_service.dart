import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';

/// High-value dual authorization request
class DualApprovalRequest {
  final String id;
  final String title;
  final double amount;
  final String makerUserId;
  final UserRole makerRole;
  final String? checkerUserId;
  final UserRole? checkerRole;
  final String reason;
  final DateTime createdAt;
  final bool isApproved;

  const DualApprovalRequest({
    required this.id,
    required this.title,
    required this.amount,
    required this.makerUserId,
    required this.makerRole,
    this.checkerUserId,
    this.checkerRole,
    required this.reason,
    required this.createdAt,
    this.isApproved = false,
  });
}

/// Maker-Checker Dual Authorization Governance Service for High-Value Financial & RBAC Actions.
class MakerCheckerService {
  final double highValueThreshold = 5000.0; // ₹5,000 threshold

  bool requiresDualApproval(double amount) => amount >= highValueThreshold;

  bool canAuthorize({
    required UserRole userRole,
    required DualApprovalRequest request,
    required String currentUserId,
  }) {
    // Maker cannot approve their own request (4-Eyes principle)
    if (request.makerUserId == currentUserId) return false;

    // Checker must be superAdmin or founderAdmin
    return userRole == UserRole.superAdmin || userRole == UserRole.founderAdmin;
  }
}

final makerCheckerServiceProvider = Provider<MakerCheckerService>((ref) {
  return MakerCheckerService();
});
