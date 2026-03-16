import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';

class SosSetupScreen extends StatelessWidget {
  const SosSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Emergency SOS', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             // SOS illustration placeholder
             Container(
               padding: const EdgeInsets.all(32),
               decoration: BoxDecoration(color: AppColors.dangerRed.withValues(alpha: 0.05), shape: BoxShape.circle),
               child: const Icon(Iconsax.shield_slash, size: 80, color: AppColors.dangerRed),
             ).animate().shake(),
             
             const SizedBox(height: 32),
             const Text('Stay Safe on Every Trip', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
             const SizedBox(height: 12),
             const Text('Add trusted contacts who can be notified instantly in case of an emergency.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
             
             const SizedBox(height: 40),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(20)),
               child: Column(
                 children: [
                   _buildContactTile('Mom', '+91 98765 43210', context),
                   const Divider(height: 32),
                   _buildContactTile('Brother', '+91 87654 32109', context),
                 ],
               ),
             ),
             
             const SizedBox(height: 32),
             ElevatedButton.icon(
                onPressed: () => NavHelpers.showComingSoon(context, 'Add contact'),
               icon: const Icon(Iconsax.user_add, size: 20),
               label: const Text('ADD TRUSTED CONTACT'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primaryBlue,
                 foregroundColor: Colors.white,
                 minimumSize: const Size(double.infinity, 54),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(String name, String phone, BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: AppColors.textSecondary, size: 20)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(phone, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.dangerRed, size: 20),
          onPressed: () => NavHelpers.showConfirmDialog(
            context,
            title: 'Remove Contact',
            message: 'Are you sure you want to remove $name from your SOS list?',
            onConfirm: () => NavHelpers.showSuccess(context, '$name removed.'),
          ),
        ),
      ],
    );
  }
}

