import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/approval_repository.dart';
import '../models/approval.dart';

final approvalServiceProvider = Provider<ApprovalService>((ref) {
  return ApprovalService(ref.watch(approvalRepositoryProvider));
});

class ApprovalService {
  final ApprovalRepository _repository;

  ApprovalService(this._repository);

  /// Triggers a request for a refund approval
  Future<void> requestRefundApproval({
    required String transactionId,
    required double amount,
    required String reason,
  }) async {
    await _repository.createApprovalRequest(
      type: ApprovalType.refund,
      entityType: 'transactions',
      entityId: transactionId,
      payload: {
        'amount': amount,
        'reason': reason,
        'action': 'REFUND',
      },
    );
  }

  /// Triggers a request for pricing change approval
  Future<void> requestPricingChange({
    required String serviceItemId,
    required double newPrice,
  }) async {
    await _repository.createApprovalRequest(
      type: ApprovalType.pricing,
      entityType: 'service_items',
      entityId: serviceItemId,
      payload: {
        'new_price': newPrice,
        'action': 'UPDATE_PRICE',
      },
    );
  }

  /// Triggers a request for payout approval
  Future<void> requestPayout({
    required String walletId,
    required double amount,
  }) async {
    await _repository.createApprovalRequest(
      type: ApprovalType.payout,
      entityType: 'payout_requests',
      payload: {
        'wallet_id': walletId,
        'amount': amount,
        'action': 'PAYOUT',
      },
    );
  }
}
