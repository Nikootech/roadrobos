import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class FleetAssetItem {
  final String id;
  final String name;
  final String category; // 'EV Bike', 'Car', 'Auto', 'Battery'
  final String plateNumber;
  final int batteryLevel; // percentage
  final int odometerKm;
  final int nextServiceDueKm;
  String status; // 'Active', 'Maintenance', 'Inspection Due'

  FleetAssetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.plateNumber,
    required this.batteryLevel,
    required this.odometerKm,
    required this.nextServiceDueKm,
    this.status = 'Active',
  });
}

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Maintenance', 'Inspection Due'];

  final List<FleetAssetItem> _assets = [
    FleetAssetItem(
      id: 'AST-101',
      name: 'Ather 450X EV Fleet #01',
      category: 'EV Bike',
      plateNumber: 'KA 05 EQ 8821',
      batteryLevel: 92,
      odometerKm: 14200,
      nextServiceDueKm: 15000,
    ),
    FleetAssetItem(
      id: 'AST-102',
      name: 'Tata Tiago EV Cab #04',
      category: 'Car',
      plateNumber: 'KA 01 MR 4109',
      batteryLevel: 28,
      odometerKm: 38400,
      nextServiceDueKm: 39000,
      status: 'Inspection Due',
    ),
    FleetAssetItem(
      id: 'AST-103',
      name: 'Bajaj RE E-Auto #12',
      category: 'Auto',
      plateNumber: 'KA 04 TC 9901',
      batteryLevel: 68,
      odometerKm: 22100,
      nextServiceDueKm: 25000,
    ),
    FleetAssetItem(
      id: 'AST-104',
      name: 'Ola S1 Pro Field Bike #09',
      category: 'EV Bike',
      plateNumber: 'KA 05 JK 2218',
      batteryLevel: 15,
      odometerKm: 19800,
      nextServiceDueKm: 20000,
      status: 'Maintenance',
    ),
    FleetAssetItem(
      id: 'AST-105',
      name: 'Mahindra Treo EV Auto #07',
      category: 'Auto',
      plateNumber: 'KA 02 AB 1234',
      batteryLevel: 85,
      odometerKm: 8500,
      nextServiceDueKm: 10000,
    ),
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.successGreen;
      case 'Maintenance':
        return AppColors.dangerRed;
      case 'Inspection Due':
        return AppColors.warningAmber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _assets.where((a) => a.status == 'Active').length;
    final maintCount = _assets.where((a) => a.status == 'Maintenance').length;
    final inspectionCount = _assets.where((a) => a.status == 'Inspection Due').length;
    final readinessPct = ((activeCount / _assets.length) * 100).toInt();

    final filteredAssets = _assets.where((a) {
      if (_selectedFilter == 'All') return true;
      return a.status == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin-home');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fleet Asset & Health Tracker',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Vehicle Readiness & Battery Telemetry',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Readiness Gauge Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepNavy, Color(0xFF1E3A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Fleet Readiness',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$readinessPct%',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brandGreenLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$activeCount of ${_assets.length} vehicles operational in field',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: AppColors.brandGreenLight, size: 36),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // Stat Summary Chips
            Row(
              children: [
                _buildStatBadge('Active', activeCount.toString(), AppColors.successGreen),
                const SizedBox(width: 8),
                _buildStatBadge('Maintenance', maintCount.toString(), AppColors.dangerRed),
                const SizedBox(width: 8),
                _buildStatBadge('Inspect Due', inspectionCount.toString(), AppColors.warningAmber),
              ],
            ),

            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSelected,
                      selectedColor: AppColors.deepNavy,
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilter = f);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Vehicle Cards List
            ...filteredAssets.map((asset) {
              final statusColor = _getStatusColor(asset.status);
              final isLowBattery = asset.batteryLevel <= 30;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            asset.category == 'EV Bike'
                                ? Icons.two_wheeler_rounded
                                : asset.category == 'Auto'
                                    ? Icons.electric_rickshaw_rounded
                                    : Icons.directions_car_rounded,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${asset.plateNumber} · ${asset.id}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            asset.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Battery & Odometer
                    Row(
                      children: [
                        Icon(
                          isLowBattery
                              ? Icons.battery_alert_rounded
                              : Icons.battery_charging_full_rounded,
                          size: 16,
                          color: isLowBattery ? AppColors.dangerRed : AppColors.successGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Battery: ${asset.batteryLevel}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLowBattery ? AppColors.dangerRed : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: asset.batteryLevel / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isLowBattery ? AppColors.dangerRed : AppColors.successGreen,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Odo: ${asset.odometerKm} km',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Next Service: ${asset.nextServiceDueKm} km',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: asset.odometerKm >= asset.nextServiceDueKm - 500
                                ? AppColors.warningAmber
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (asset.status != 'Maintenance')
                          TextButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => asset.status = 'Maintenance');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${asset.name} flagged as In-Maintenance.')),
                              );
                            },
                            icon: const Icon(Icons.build_circle_outlined, size: 16),
                            label: const Text('Mark In-Service'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.warningAmber),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              setState(() => asset.status = 'Active');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${asset.name} restored to Active Fleet!'),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text('Release to Active'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              count,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
