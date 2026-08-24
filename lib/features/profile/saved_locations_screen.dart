import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'user_provider.dart';
import '../../core/models/user_role.dart';
import '../../core/repositories/user_repository.dart';
import '../../navigation/nav_helpers.dart';
import '../../core/services/location_permission_helper.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

class SavedLocationsScreen extends ConsumerWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final locations = user?.savedLocations ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: ScaleOnTap(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Text(
          'Saved Locations',
          style: GoogleFonts.outfit(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Saved Addresses',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP INFO BANNER ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006241), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child:
                          Icon(Iconsax.location, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick 1-Tap Booking',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Saved addresses appear automatically during rides & delivery checkout.',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF006241),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SAVED ADDRESSES',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${locations.length} Saved',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (locations.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Iconsax.location_slash,
                          size: 28, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No saved locations yet',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Save your home, office, and favorite spots for fast booking.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...locations.map((loc) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLocationTile(context, ref, loc),
                  )),

            const SizedBox(height: 24),

            // Add Address CTA
            ScaleOnTap(
              onTap: () {
                HapticFeedback.lightImpact();
                _showAddAddressSheet(context, ref);
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006241), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006241).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.add_circle,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ADD NEW ADDRESS',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
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
    final isLoadingAddress = ValueNotifier<bool>(false);
    String selectedTag = 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006241), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Iconsax.location_add,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Address',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Save for quick pickup and dropoff',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Tag Chips
              Row(
                children: ['Home', 'Work', 'Other'].map((tag) {
                  final isSel = selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ScaleOnTap(
                      onTap: () {
                        setModalState(() {
                          selectedTag = tag;
                          if (tag != 'Other') {
                            titleController.text = tag;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF006241),
                                    Color(0xFF10B981)
                                  ],
                                )
                              : null,
                          color: isSel ? null : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? const Color(0xFF006241)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          tag == 'Home'
                              ? '🏠 Home'
                              : (tag == 'Work' ? '🏢 Work' : '📍 Other'),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight:
                                isSel ? FontWeight.w800 : FontWeight.w600,
                            color:
                                isSel ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Title input
              TextField(
                controller: titleController,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Address Label',
                  hintText: 'e.g. My Apartment, HQ Office',
                  prefixIcon: const Icon(Iconsax.tag,
                      color: Color(0xFF006241), size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF006241), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Full Address input
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingAddress,
                builder: (context, loading, child) {
                  return TextField(
                    controller: addressController,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Full Address',
                      hintText: 'Flat / Building, Street, Area, Bengaluru',
                      prefixIcon: const Icon(Iconsax.location,
                          color: Color(0xFF006241), size: 18),
                      suffixIcon: loading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF006241),
                                ),
                              ),
                            )
                          : ScaleOnTap(
                              onTap: () => _getCurrentAddress(
                                  context, addressController, isLoadingAddress),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFBBF7D0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.gps,
                                        size: 14, color: Color(0xFF006241)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'GPS',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF006241),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF006241), width: 1.5),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Save CTA
              ScaleOnTap(
                onTap: () async {
                  if (titleController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in both label and address',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFFE11D48),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final newLoc = SavedLocation(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    address: addressController.text.trim(),
                  );

                  final user = ref.read(userProvider).user;
                  if (user != null) {
                    final updatedLocations = [...user.savedLocations, newLoc];
                    await ref.read(userRepositoryProvider).updateField(
                        user.id,
                        'saved_locations',
                        updatedLocations.map((x) => x.toMap()).toList());
                    await ref
                        .read(userProvider.notifier)
                        .fetchUserProfile(user.id);
                    if (context.mounted) {
                      Navigator.pop(bottomCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Address saved successfully! ✓',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          backgroundColor: const Color(0xFF006241),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006241), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006241).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'SAVE ADDRESS',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentAddress(BuildContext context,
      TextEditingController controller, ValueNotifier<bool> loading) async {
    try {
      loading.value = true;
      final hasPermission =
          await LocationPermissionHelper.requestLocationWithDisclosure(
        context: context,
        isBackgroundRequired: false,
      );
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition();
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}'),
        headers: {'User-Agent': 'RoAdRoBos_App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;
        if (address != null) {
          controller.text = address;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Live GPS location detected ✓',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                backgroundColor: const Color(0xFF006241),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not fetch GPS address automatically',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      loading.value = false;
    }
  }

  Widget _buildLocationTile(
      BuildContext context, WidgetRef ref, SavedLocation loc) {
    IconData icon = Iconsax.location;
    List<Color> gradient = [const Color(0xFF0284C7), const Color(0xFF38BDF8)];

    if (loc.title.toLowerCase().contains('home')) {
      icon = Iconsax.home;
      gradient = [const Color(0xFF006241), const Color(0xFF10B981)];
    } else if (loc.title.toLowerCase().contains('work') ||
        loc.title.toLowerCase().contains('office')) {
      icon = Iconsax.building;
      gradient = [const Color(0xFF0D9488), const Color(0xFF14B8A6)];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 20, color: Color(0xFFEF4444)),
            onPressed: () {
              HapticFeedback.selectionClick();
              NavHelpers.showConfirmDialog(
                context,
                title: 'Delete Address',
                message:
                    'Are you sure you want to remove "${loc.title}" from your saved locations?',
                onConfirm: () async {
                  final user = ref.read(userProvider).user;
                  if (user != null) {
                    final updated = user.savedLocations
                        .where((x) => x.id != loc.id)
                        .toList();
                    await ref.read(userRepositoryProvider).updateField(
                        user.id,
                        'saved_locations',
                        updated.map((x) => x.toMap()).toList());
                    await ref
                        .read(userProvider.notifier)
                        .fetchUserProfile(user.id);
                  }
                },
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
