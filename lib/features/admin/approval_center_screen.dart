import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/approval.dart';
import '../../core/repositories/approval_repository.dart';
import '../../shared/widgets/custom_button.dart';

class ApprovalCenterScreen extends ConsumerWidget {
  const ApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingApprovals = ref.watch(pendingApprovalsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Approval Center', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: pendingApprovals.when(
        data: (approvals) => approvals.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: approvals.length,
                itemBuilder: (context, index) => _ApprovalCard(approval: approvals[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.successGreen.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('All caught up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('No pending approval requests.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ).animate().fadeIn().scale(),
    );
  }
}

final pendingApprovalsProvider = StreamProvider<List<ApprovalRequest>>((ref) {
  return ref.watch(approvalRepositoryProvider).watchPendingApprovals();
});

class _ApprovalCard extends ConsumerWidget {
  final ApprovalRequest approval;
  const _ApprovalCard({required this.approval});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (approval.type == ApprovalType.partnerKyc) {
          context.push('/admin-kyc', extra: approval);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeIcon(approval.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        approval.type.name.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 1.2),
                      ),
                      Text(
                        'Request ID: ${approval.id.substring(0, 8)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(approval.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Payload Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
              child: Text(
                approval.payload.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'REJECT',
                    backgroundColor: AppColors.bgLightGrey,
                    textColor: AppColors.dangerRed,
                    onPressed: () => _handleAction(context, ref, ApprovalStatus.rejected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'APPROVE',
                    backgroundColor: AppColors.successGreen,
                    onPressed: () => _handleAction(context, ref, ApprovalStatus.approved),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildTypeIcon(ApprovalType type) {
    IconData icon;
    Color color;
    switch (type) {
      case ApprovalType.refund: icon = Icons.currency_exchange_rounded; color = Colors.orange; break;
      case ApprovalType.pricing: icon = Icons.sell_rounded; color = Colors.blue; break;
      case ApprovalType.partnerKyc: icon = Icons.verified_user_rounded; color = Colors.purple; break;
      case ApprovalType.payout: icon = Icons.account_balance_wallet_rounded; color = Colors.green; break;
      default: icon = Icons.help_outline_rounded; color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute}';
  }

  void _handleAction(BuildContext context, WidgetRef ref, ApprovalStatus status) async {
    try {
      await ref.read(approvalRepositoryProvider).updateApprovalStatus(
        id: approval.id,
        status: status,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${status == ApprovalStatus.approved ? 'Approved' : 'Rejected'} successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
