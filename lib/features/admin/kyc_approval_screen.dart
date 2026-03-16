import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';

/// KYC Document Approval matching Figma Screen [95]
class KycApprovalScreen extends StatelessWidget {
  const KycApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('KYC Approval', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applicant Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 30),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vikas Singh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              SizedBox(height: 4),
                              Text('Driver Application • ID: DRV-8492', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              SizedBox(height: 4),
                              Text('Applied: Oct 24, 2023', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),
                  const Text('Documents Submitted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDocCard('Driving License (Front)', 'Verified by AI', true, Icons.badge_outlined, context),
                const SizedBox(height: 12),
                _buildDocCard('Driving License (Back)', 'Verified by AI', true, Icons.badge_outlined, context),
                const SizedBox(height: 12),
                _buildDocCard('Aadhar Card / Gov ID', 'Pending manual review', false, Icons.contact_page_outlined, context),
                const SizedBox(height: 12),
                _buildDocCard('Vehicle RC Print', 'Verified by AI', true, Icons.description_outlined, context),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'REJECT',
                backgroundColor: AppColors.bgLightGrey,
                textColor: AppColors.dangerRed,
                onPressed: () => NavHelpers.showComingSoon(context, 'Rejection reason modal'), // Would pop up a reject reason modal
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                label: 'APPROVE',
                backgroundColor: AppColors.successGreen,
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KYC Approved successfully!')));
                   context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(String title, String status, bool isValid, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isValid ? Icons.check_circle_rounded : Icons.pending_rounded, size: 14, color: isValid ? AppColors.successGreen : AppColors.warningAmber),
                        const SizedBox(width: 4),
                        Text(status, style: TextStyle(fontSize: 12, color: isValid ? AppColors.successGreen : AppColors.warningAmber)),
                      ],
                    )
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.primaryBlue), onPressed: () => NavHelpers.showComingSoon(context, 'Document preview'))
            ],
          ),
          if (!isValid) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.textMuted)), // Simulated doc preview
            )
          ]
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

