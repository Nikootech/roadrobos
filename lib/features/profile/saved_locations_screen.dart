import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

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
        title: const Text('Saved Locations', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildLocationTile(Iconsax.home, 'Home', 'Flat 402, GSR Estates, Madhapur, Hyd'),
            const SizedBox(height: 12),
            _buildLocationTile(Iconsax.building, 'Work', 'Cyber Towers, Hitech City, Hyd'),
            const SizedBox(height: 12),
            _buildLocationTile(Iconsax.location, 'HDFC Bank', 'Gachibowli Branch, Hyderabad'),
            
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: () => _showAddAddressSheet(context),
              icon: const Icon(Iconsax.add, size: 20),
              label: const Text('ADD NEW ADDRESS'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy)),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: 'Address Name',
                hintText: 'e.g. Grandma\'s House',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Address',
                hintText: 'Street, Building, City...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address added successfully!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(IconData icon, String title, String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
