import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/approval.dart';
import '../../../core/providers/rbac_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import 'approval_provider.dart';

class ApprovalDetailScreen extends ConsumerStatefulWidget {
  final ApprovalRequest request;

  const ApprovalDetailScreen({super.key, required this.request});

  @override
  ConsumerState<ApprovalDetailScreen> createState() =>
      _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends ConsumerState<ApprovalDetailScreen> {
  bool _isLoading = false;

  String get _permissionKey {
    switch (widget.request.type) {
      case ApprovalType.partnerKyc:
        return 'approve_kyc';
      case ApprovalType.refund:
        return 'approve_refunds';
      case ApprovalType.vehicleAttachment:
        return 'approve_vehicles';
      case ApprovalType.payout:
        return 'approve_withdrawals';
      default:
        return 'admin_access';
    }
  }

  bool get _hasActionPermission {
    return ref.watch(hasPermissionProvider(_permissionKey)) ||
        ref.watch(hasPermissionProvider('admin_access'));
  }

  void _handleApprove() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isLoading = true);
    try {
      await ref.read(approvalProvider.notifier).approve(widget.request.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Request approved successfully'),
          backgroundColor: AppColors.successDark,
        ),
      );
      router.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to approve: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleReject() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rejection Reason',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please specify the reason for rejecting this request.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Documents blurry, Invalid details...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.bgLightGrey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);

              Navigator.of(dialogContext).pop();
              setState(() => _isLoading = true);
              try {
                await ref
                    .read(approvalProvider.notifier)
                    .reject(widget.request.id, reason);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Request rejected successfully'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                router.pop();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to reject: $e'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showZoomedImage(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(color: Colors.white);
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final submittedDate =
        '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}';

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${request.type.displayName} Details',
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                _buildInfoCard(request, submittedDate),
                const SizedBox(height: 16),

                // Specific Details View
                _buildSpecificDetails(request),
                const SizedBox(height: 100), // Spacing for action buttons
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar:
          request.status == ApprovalStatus.pending && _hasActionPermission
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'REJECT',
                          backgroundColor: AppColors.bgLightGrey,
                          textColor: AppColors.dangerRed,
                          onPressed: _isLoading ? null : _handleReject,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          label: 'APPROVE',
                          backgroundColor: AppColors.successGreen,
                          textColor: Colors.white,
                          onPressed: _isLoading ? null : _handleApprove,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
    );
  }

  Widget _buildInfoCard(ApprovalRequest request, String submittedDate) {
    final payload = request.payload;
    final requesterName = payload['applicant_name'] ??
        payload['requester_name'] ??
        payload['user_name'] ??
        payload['name'] ??
        'User (${request.makerId.length > 8 ? request.makerId.substring(0, 8) : request.makerId})';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request ID: ${request.id.length > 8 ? request.id.substring(0, 8) : request.id}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              _buildStatusBadge(request.status),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('Requester', requesterName),
          const SizedBox(height: 8),
          _buildInfoRow('Submitted At', submittedDate),
          if (request.status == ApprovalStatus.rejected &&
              request.rejectionReason != null) ...[
            const Divider(height: 24),
            _buildInfoRow('Rejection Reason', request.rejectionReason!,
                isWarning: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isWarning = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isWarning ? AppColors.dangerRed : AppColors.textPrimary,
              fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ApprovalStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case ApprovalStatus.approved:
        bg = AppColors.successGreen.withValues(alpha: 0.15);
        fg = AppColors.successDark;
        break;
      case ApprovalStatus.rejected:
        bg = AppColors.dangerRed.withValues(alpha: 0.15);
        fg = AppColors.dangerRed;
        break;
      case ApprovalStatus.pending:
        bg = AppColors.warningAmber.withValues(alpha: 0.15);
        fg = AppColors.accentAmber;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildSpecificDetails(ApprovalRequest request) {
    final payload = request.payload;

    switch (request.type) {
      case ApprovalType.partnerKyc:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KYC Document Reviews',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            if (payload.containsKey('document_url'))
              _buildDocumentCard(
                  'Main Identity Proof', payload['document_url']),
            if (payload.containsKey('license_front'))
              _buildDocumentCard(
                  'Driving License Front', payload['license_front']),
            if (payload.containsKey('license_back'))
              _buildDocumentCard(
                  'Driving License Back', payload['license_back']),
            if (payload.containsKey('rc_document'))
              _buildDocumentCard(
                  'Registration Certificate (RC)', payload['rc_document']),
          ],
        );

      case ApprovalType.refund:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking & Refund Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const Divider(height: 24),
              _buildInfoRow('Booking ID',
                  request.entityId ?? payload['booking_id'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('Original Price',
                  '₹${payload['booking_amount'] ?? payload['original_amount'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              _buildInfoRow('Refund Amount', '₹${payload['amount'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Refund Reason', payload['reason'] ?? 'None specified'),
            ],
          ),
        );

      case ApprovalType.vehicleAttachment:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const Divider(height: 24),
              _buildInfoRow('Vehicle ID', request.entityId ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('Vehicle Model',
                  payload['vehicle_model'] ?? payload['vehicle_name'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Plate Number',
                  payload['vehicle_number'] ??
                      payload['plate_number'] ??
                      'N/A'),
              if (payload.containsKey('document_url')) ...[
                const Divider(height: 24),
                _buildDocumentCard('Vehicle Document', payload['document_url']),
              ],
            ],
          ),
        );

      case ApprovalType.payout:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payout Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                  'Withdrawal Amount', '₹${payload['amount'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              _buildInfoRow('Account Holder', payload['account_name'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('Bank Name', payload['bank_name'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Account Number', payload['account_number'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow('IFSC Code', payload['ifsc_code'] ?? 'N/A'),
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Raw Payload Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const Divider(height: 24),
              Text(
                payload.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildDocumentCard(String title, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton.icon(
                onPressed: () => _showZoomedImage(imageUrl, title),
                icon: const Icon(Icons.zoom_in_rounded, size: 18),
                label: const Text('Zoom'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showZoomedImage(imageUrl, title),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.bgLightGrey,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        size: 48, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
