// Removed unused foundation import

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

enum ApprovalType {
  refund,
  pricing,
  partnerKyc,
  payout,
  other,
}

class ApprovalRequest {
  final String id;
  final ApprovalType type;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic> payload;
  final String makerId;
  final String? checkerId;
  final ApprovalStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApprovalRequest({
    required this.id,
    required this.type,
    required this.entityType,
    this.entityId,
    required this.payload,
    required this.makerId,
    this.checkerId,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApprovalRequest.fromMap(Map<String, dynamic> map) {
    return ApprovalRequest(
      id: map['id'],
      type: _parseType(map['type']),
      entityType: map['entity_type'],
      entityId: map['entity_id'],
      payload: map['payload'] ?? {},
      makerId: map['maker_id'],
      checkerId: map['checker_id'],
      status: _parseStatus(map['status']),
      rejectionReason: map['rejection_reason'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static ApprovalType _parseType(String type) {
    switch (type) {
      case 'refund': return ApprovalType.refund;
      case 'pricing': return ApprovalType.pricing;
      case 'partner_kyc': return ApprovalType.partnerKyc;
      case 'payout': return ApprovalType.payout;
      default: return ApprovalType.other;
    }
  }

  static ApprovalStatus _parseStatus(String status) {
    switch (status) {
      case 'approved': return ApprovalStatus.approved;
      case 'rejected': return ApprovalStatus.rejected;
      default: return ApprovalStatus.pending;
    }
  }
}
