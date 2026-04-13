import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';
import '../profile/user_provider.dart';

/// Refer & Earn Rewards matching Figma Screen [20]
class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    
    // Generate a code if one isn't assigned (Fallback)
    final referralCode = (user?.referralCode != null && user!.referralCode.isNotEmpty) 
        ? user.referralCode 
        : 'ROADROBO_${user?.name.split(' ').first.toUpperCase() ?? 'GUEST'}';

    final shareMessage = 'Hey! Use my referral code $referralCode to get ₹500 discount on your first service with RoAd RoBo\'s. Download now: https://roadrobos.com/download';

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Refer & Earn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image/Illustration area
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 80, color: AppColors.primaryBlue),
                  SizedBox(height: 16),
                  Text('Invite Friends & Earn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Get ₹500 in your wallet when your friend completes their first service or ride.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Referral Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            referralCode, 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.primaryBlue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: referralCode));
                            NavHelpers.showSuccess(context, 'Referral code copied to clipboard!');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
                            child: const Icon(Icons.copy_rounded, size: 20, color: AppColors.textPrimary),
                          ),
                        )
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Share Invite Link',
                    icon: Icons.share_rounded,
                    onPressed: () => Share.share(shareMessage),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 48),
                  const Text('How it works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),
                  _buildStep(1, 'Share your code', 'Invite friends using your unique referral code.'),
                  _buildStep(2, 'Friend signs up', 'They register and complete their first transaction.'),
                  _buildStep(3, 'You earn ₹500', 'Cashback is instantly credited to your wallet.', isLast: true),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Total Earned
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.deepNavy, AppColors.primaryBlue]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Earned', style: TextStyle(fontSize: 14, color: Colors.white70)),
                            SizedBox(height: 4),
                            Text('₹1,500', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                          child: const Text('3 Friends Joined', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        )
                      ],
                    ),
                  ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String subtitle, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('$number', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue))),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.primaryBlue.withOpacity(0.1),
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
              const SizedBox(height: 24),
            ],
          ),
        )
      ],
    );
  }
}

