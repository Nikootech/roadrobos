import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';

class ActiveRidesScreen extends StatefulWidget {
  const ActiveRidesScreen({super.key});

  @override
  State<ActiveRidesScreen> createState() => _ActiveRidesScreenState();
}

class _ActiveRidesScreenState extends State<ActiveRidesScreen> {
  bool _isMapMode = false;

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
          'Active Rides',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapMode ? Iconsax.menu : Iconsax.map, color: AppColors.primaryBlue),
            onPressed: () => setState(() => _isMapMode = !_isMapMode),
          ),
          IconButton(
            icon: const Icon(Iconsax.filter, color: AppColors.primaryBlue),
            onPressed: () => _showRideFilterSheet(context),
          ),
        ],
      ),
      body: _isMapMode ? _buildMapView() : _buildListView(),
    );
  }

  void _showRideFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Rides',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('On Trip', false),
                _buildFilterChip('Pending', false),
                _buildFilterChip('Completed', false),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Ride Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Bike', false),
                _buildFilterChip('Auto', false),
                _buildFilterChip('Mini', false),
                _buildFilterChip('Sedan', false),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : AppColors.bgLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Summary bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Active', '42'),
              _buildSummaryItem('In Transit', '28'),
              _buildSummaryItem('Pending', '14'),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildRideCard(index, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        const LiveMapWidget(
          height: double.infinity,
          showLiveIndicator: true,
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Icon(Iconsax.radar, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Tracking 42 Live Rides',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.5, end: 0).fadeIn(),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRideCard(int index, BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFF0F4FF), child: Icon(Icons.person, color: AppColors.primaryBlue)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ravi Verma', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('ID: RID-201938', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('ON TRIP', style: TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildLocationRow(Icons.radio_button_checked, AppColors.primaryBlue, 'Hitech City, Hyderabad'),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on_rounded, AppColors.dangerRed, 'Gachibowli DLF, Hyderabad'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maruti Suzuki Swift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('TS 08 EX 4567', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/live-tracking'),
                child: Text(
                  'View Live',
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms * index).slideX(begin: 0.1, end: 0);
  }

  Widget _buildLocationRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}

