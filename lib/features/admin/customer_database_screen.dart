import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class CustomerDatabaseScreen extends StatelessWidget {
  const CustomerDatabaseScreen({super.key});

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
        title: Text(
          'Customer Database',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Iconsax.search_normal, size: 20, color: AppColors.textSecondary),
                  hintText: 'Search by customer name or ID...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCustomerCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(int index) {
      final names = ['Ananya Roy', 'Vikram Seth', 'Neha Gupta', 'Amit Singh', 'Priya Das', 'Rahul Mehra', 'Sonia Jain', 'Deepak Pal'];
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
             CircleAvatar(radius: 20, backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 20)),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(names[index], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                   Text('Premium Customer', style: GoogleFonts.inter(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w700)),
                 ],
               ),
             ),
             Column(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 Text('LTV: ₹12.4K', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                 Text('12 Rides', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
               ],
             ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

