import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import 'user_provider.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/models/user_role.dart';
import '../../navigation/nav_helpers.dart';

class SavedLocationsScreen extends ConsumerWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final locations = user?.savedLocations ?? [];

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
            if (locations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_rounded, size: 80, color: AppColors.textMuted.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      const Text('No saved locations yet', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            
            ...locations.map((loc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLocationTile(context, ref, loc),
            )).toList(),
            
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: () => _showAddAddressSheet(context, ref),
              icon: const Icon(Icons.add_location_alt_rounded, size: 20),
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

  void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    
    // We use a ValueNotifier for the local loading state of the GPS fetch
    final isLoadingAddress = ValueNotifier<bool>(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy)),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Address Name',
                hintText: 'e.g. Home, Office',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: isLoadingAddress,
              builder: (context, loading, child) {
                return TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Full Address',
                    hintText: 'Street, Building, City...',
                    suffixIcon: loading 
                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                        : IconButton(
                            icon: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue),
                            onPressed: () => _getCurrentAddress(context, addressController, isLoadingAddress),
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty || addressController.text.isEmpty) return;
                  
                  final newLoc = SavedLocation(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    address: addressController.text,
                  );

                  final user = ref.read(userProvider).user;
                  if (user != null) {
                    final updatedLocations = [...user.savedLocations, newLoc];
                    await ref.read(userRepositoryProvider).updateField(user.id, 'saved_locations', updatedLocations.map((x) => x.toMap()).toList());
                    await ref.read(userProvider.notifier).fetchUserProfile(user.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      NavHelpers.showSuccess(context, 'Address added successfully!');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentAddress(BuildContext context, TextEditingController controller, ValueNotifier<bool> loading) async {
    try {
      loading.value = true;
      
      // 1. Check & Request Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) NavHelpers.showError(context, 'Location permissions are permanently denied.');
        return;
      }

      // 2. Get Current Position
      final position = await Geolocator.getCurrentPosition();
      
      // 3. Reverse Geocode using Nominatim (OpenStreetMap)
      // Note: We use an explicit User-Agent as per Nominatim policy
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}'),
        headers: {'User-Agent': 'RoAdRoBos_App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;
        if (address != null) {
          controller.text = address;
          if (context.mounted) {
            NavHelpers.showSuccess(context, 'Real-time address fetched successfully!');
          }
        }
      } else {
        throw Exception('Failed to fetch address');
      }
    } catch (e) {
      if (context.mounted) NavHelpers.showError(context, 'Could not fetch real-time address. Please enter manually.');
    } finally {
      loading.value = false;
    }
  }

  Widget _buildLocationTile(BuildContext context, WidgetRef ref, SavedLocation loc) {
    IconData icon = Icons.location_on_rounded;
    if (loc.title.toLowerCase().contains('home')) icon = Icons.home_rounded;
    if (loc.title.toLowerCase().contains('work') || loc.title.toLowerCase().contains('office')) icon = Icons.business_rounded;

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
                Text(loc.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(loc.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  final user = ref.read(userProvider).user;
                  if (user != null) {
                    final updated = user.savedLocations.where((x) => x.id != loc.id).toList();
                    await ref.read(userRepositoryProvider).updateField(user.id, 'saved_locations', updated.map((x) => x.toMap()).toList());
                    await ref.read(userProvider.notifier).fetchUserProfile(user.id);
                  }
                },
                child: const Text('Delete', style: TextStyle(color: AppColors.dangerRed)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
