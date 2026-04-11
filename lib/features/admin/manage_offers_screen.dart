import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/services/gsheets_api.dart';
import '../../core/theme/app_colors.dart';

class ManageOffersScreen extends StatelessWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Offers & Coupons', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Offer Button
            ElevatedButton.icon(
              onPressed: () {
                GSheetsApi.logAdminAction('ADMIN-01', 'CREATE_OFFER_ATTEMPT', 'GLOBAL', 'Attempting to create new campaign');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer creation — coming soon!'), behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Iconsax.ticket_2, size: 20),
              label: const Text('Create New Offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Active Campaigns', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildOfferCard('WELCOME50', '50% off on first ride', 'Expired in 4 days', true),
            const SizedBox(height: 12),
            _buildOfferCard('FESTIVE20', '20% discount on rentals', 'Active', true),
            const SizedBox(height: 12),
            _buildOfferCard('ROAdROBoS10', 'Flat ₹100 off on services', 'Active', true),
            
            const SizedBox(height: 32),
            const Text('Drafts & Expired', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildOfferCard('SUMMER40', '40% seasonal discount', 'Expired', false),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String code, String desc, String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? AppColors.primaryBlue.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: (isActive ? AppColors.primaryBlue : AppColors.textMuted).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Iconsax.ticket_discount, color: isActive ? AppColors.primaryBlue : AppColors.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Text(status, style: TextStyle(color: isActive ? AppColors.successGreen : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

