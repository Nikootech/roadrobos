import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/repositories/kyc_repository.dart';
import '../../../features/profile/user_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userId = userState.user?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Refresh profile on build to get latest kyc_status if we want
    // But stream below handles document details

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text('KYC Status',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Prevent going back to unauthorized routes
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
            },
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ref.read(kycRepositoryProvider).streamKycUpdates(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_ind_outlined,
                        size: 80, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No documents uploaded',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Please upload your KYC documents to activate your driver account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'START KYC',
                      onPressed: () => context.push('/driver/kyc-upload'),
                    ),
                  ],
                ).animate().fadeIn(),
              ),
            );
          }

          final allApproved = docs.length >= 4 &&
              docs.every((doc) => doc['status'] == 'approved');
          final profileApproved = userState.user?.kycStatus == 'approved';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allApproved || profileApproved) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.brandGreen),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.brandGreen, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Verification Complete',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.brandGreen)),
                              SizedBox(height: 4),
                              Text(
                                  'Your account has been fully verified. You can now access the dashboard.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'ENTER DASHBOARD',
                    onPressed: () {
                      // Profile provider needs to be refreshed so router passes the guard
                      ref
                          .read(userProvider.notifier)
                          .fetchUserProfile(userId)
                          .then((_) {
                        if (context.mounted) {
                          context.go('/driver-home');
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                ],
                const Text(
                  'Uploaded Documents',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ...docs.map((doc) => _buildStatusCard(context, doc)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> doc) {
    final status = doc['status'] as String? ?? 'pending';
    final type = doc['document_type'] as String? ?? 'Unknown';
    final rejectionReason = doc['rejection_reason'] as String?;

    Color statusColor = AppColors.warningAmber;
    IconData statusIcon = Icons.hourglass_top;

    if (status == 'approved') {
      statusColor = AppColors.brandGreen;
      statusIcon = Icons.check_circle;
    } else if (status == 'rejected') {
      statusColor = AppColors.errorRed;
      statusIcon = Icons.cancel;
    }

    final String readableType = type.replaceAll('_', ' ').toUpperCase();
    String stepTarget = 'aadhar';
    if (type.contains('driving_license')) stepTarget = 'driving_license';
    if (type.contains('vehicle_rc')) stepTarget = 'vehicle_rc';
    if (type.contains('selfie')) stepTarget = 'selfie';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(readableType,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (status == 'rejected') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rejection Reason:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.errorRed)),
                  const SizedBox(height: 4),
                  Text(
                      rejectionReason ??
                          'Document unclear or invalid. Please re-upload.',
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/driver/kyc-upload', extra: stepTarget);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                      ),
                      child: const Text('RE-UPLOAD DOCUMENT'),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
