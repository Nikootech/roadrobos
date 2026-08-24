import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/approval.dart';
import '../../../core/repositories/approval_repository.dart';

import '../../../core/models/user_role.dart';

class ApprovalNotifier extends AsyncNotifier<List<ApprovalRequest>> {
  @override
  Future<List<ApprovalRequest>> build() async {
    final supabase = Supabase.instance.client;

    // Subscribe to realtime updates on the 'approvals' table
    final subscription = supabase
        .from('approvals')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((data) {
          state = AsyncValue.data(
            data.map((map) => ApprovalRequest.fromMap(map)).toList(),
          );
        }, onError: (err, stack) {
          state = AsyncValue.error(err, stack);
        });

    ref.onDispose(() {
      unawaited(subscription.cancel());
    });

    // Fetch initial approvals list
    try {
      final response = await supabase
          .from('approvals')
          .select()
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((map) => ApprovalRequest.fromMap(map))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (_) {}

    // Fallback seed approvals across categories
    final now = DateTime.now();
    return [
      ApprovalRequest(
        id: 'APP-901',
        type: ApprovalType.partnerKyc,
        entityType: 'driver',
        entityId: 'DRV-8802',
        payload: {
          'driver_name': 'Ramesh Patil',
          'document_type': 'Commercial Insurance',
          'notes': 'New partner driver onboarding for Ramesh Patil',
        },
        makerId: 'SYSTEM',
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      ApprovalRequest(
        id: 'APP-902',
        type: ApprovalType.payout,
        entityType: 'driver_wallet',
        entityId: 'DRV-8801',
        payload: {
          'driver_name': 'Amit Singh',
          'amount': 4500.0,
          'bank': 'HDFC Bank (A/C: ****4910)',
        },
        makerId: 'DRV-8801',
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      ApprovalRequest(
        id: 'APP-903',
        type: ApprovalType.refund,
        entityType: 'ride_booking',
        entityId: 'RID-4892A',
        payload: {
          'customer_name': 'Rahul Verma',
          'amount': 50.0,
          'reason': 'Driver no-show cancellation fee reversal',
        },
        makerId: 'SUPPORT-AGENT-04',
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      ApprovalRequest(
        id: 'APP-904',
        type: ApprovalType.vehicleAttachment,
        entityType: 'fleet_asset',
        entityId: 'AST-101',
        payload: {
          'vehicle_model': 'Ather 450X EV',
          'plate_number': 'MH-02-EQ-8821',
          'hub': 'Bandra Fleet Hub',
        },
        makerId: 'FLEET-LOGISTICS',
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  Future<void> approve(String id) async {
    final repository = ref.read(approvalRepositoryProvider);
    await repository.updateApprovalStatus(
      id: id,
      status: ApprovalStatus.approved,
    );
  }

  Future<void> reject(String id, String reason) async {
    final repository = ref.read(approvalRepositoryProvider);
    await repository.updateApprovalStatus(
      id: id,
      status: ApprovalStatus.rejected,
      reason: reason,
    );
  }

  Future<void> updateCorrection({
    required String approvalId,
    required String targetUserId,
    required String name,
    required String phone,
    String? email,
    required UserRole role,
    required bool isApproved,
    required Map<String, dynamic> currentPayload,
    String? correctionNotes,
  }) async {
    final repository = ref.read(approvalRepositoryProvider);
    await repository.updateApprovalUserCorrection(
      approvalId: approvalId,
      targetUserId: targetUserId,
      name: name,
      phone: phone,
      email: email,
      role: role,
      isApproved: isApproved,
      currentPayload: currentPayload,
      correctionNotes: correctionNotes,
    );
  }
}

final approvalProvider =
    AsyncNotifierProvider<ApprovalNotifier, List<ApprovalRequest>>(() {
  return ApprovalNotifier();
});
