import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

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
          'Admin Management',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Admin Button
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin invitation — coming soon!'), behavior: SnackBarBehavior.floating)),
              icon: const Icon(Iconsax.user_add, size: 20),
              label: const Text('Add New Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Managing Admins', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAdminTile(index, context);
              },
            ),
            
            const SizedBox(height: 32),
            Text('Audit Logs', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildAuditLogTile(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile(int index, BuildContext context) {
    final admins = [
      {'name': 'Rajesh Sharma', 'role': 'Senior Admin', 'status': 'Active'},
      {'name': 'Sunita Rao', 'role': 'Finance Manager', 'status': 'Active'},
      {'name': 'Karan Singh', 'role': 'Dispatch Admin', 'status': 'Inactive'},
    ];
    final admin = admins[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1), child: Text(admin['name']![0], style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(admin['name']!, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(admin['role']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Iconsax.setting_2, size: 20, color: AppColors.textSecondary), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin settings — coming soon!'), behavior: SnackBarBehavior.floating))),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildAuditLogTile(int index) {
    final logs = [
        'Updated KYC for Driver #829',
        'Changed Fare multiplier for Zone A',
        'Approved Bank Withdrawal for User #12',
        'Logistics Hub Hyderabad set to maintenance'
    ];
    return ListTile(
      title: Text(logs[index], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: const Text('Today, 10:45 AM', style: TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.border),
    );
  }
}

