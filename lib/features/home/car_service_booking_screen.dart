import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/technician/technician_provider.dart';
import 'vehicle_provider.dart';

class CarServiceBookingScreen extends ConsumerStatefulWidget {
  const CarServiceBookingScreen({super.key});

  @override
  ConsumerState<CarServiceBookingScreen> createState() => _CarServiceBookingScreenState();
}

class _CarServiceBookingScreenState extends ConsumerState<CarServiceBookingScreen> {
  int _selectedPackageIndex = -1;

  final List<Map<String, dynamic>> _packages = [
    {
      'name': 'Silver Package',
      'price': '₹2,499',
      'subtitle': 'Essential maintenance and fluid check',
      'items': ['Oil Change', 'Oil Filter', 'Points Check', 'All Fluids Top-up'],
      'color': const Color(0xFF3B82F6),
      'isPremium': false,
    },
    {
      'name': 'Gold Package',
      'price': '₹4,999',
      'subtitle': 'Comprehensive care with wheel balance',
      'items': ['Silver + Wheel Balance', 'Brake Cleaning', 'AC Filter Clean', 'Full Wash'],
      'color': const Color(0xFF8B5CF6),
      'isPremium': true,
    },
    {
      'name': 'Platinum Package',
      'price': '₹7,999',
      'subtitle': 'Ultimate protection and performance tune',
      'items': ['Gold + Throttle Body Clean', 'Interior Sanitization', 'Wheel Alignment', 'Engine Tuning'],
      'color': const Color(0xFFF59E0B),
      'isPremium': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Car Service Packages',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Car Package',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_packages.length, (index) {
                    final pkg = _packages[index];
                    final isSelected = _selectedPackageIndex == index;
                    return _buildPremiumPackageCard(index, pkg, isSelected);
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: CustomButton(
              label: 'Proceed to Schedule',
              onPressed: _selectedPackageIndex == -1 ? null : () {
                context.push('/schedule-appointment');
              },
              backgroundColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPackageCard(int index, Map<String, dynamic> pkg, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPackageIndex = index);
        final selectedVehicle = ref.read(vehicleProvider);
        ref.read(bookingProvider.notifier).setVehicle(selectedVehicle.name, selectedVehicle.plate);
        ref.read(bookingProvider.notifier).setPackage(
          pkg['name'] as String, 
          pkg['price'] as String,
          List<String>.from(pkg['items'] as List),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (pkg['isPremium'] == true)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (pkg['color'] as Color).withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(32),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'PREMIUM CHOICE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: (pkg['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: pkg['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg['name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pkg['subtitle'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...List.generate((pkg['items'] as List).length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F5F9),
                            ),
                            child: const Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFF10B981)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pkg['items'][i],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Starting Investment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        pkg['price'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideY(begin: 0.1, end: 0);
  }


  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle('1', true),
          _stepLine(false),
          _stepCircle('2', false),
          _stepLine(false),
          _stepCircle('3', false),
        ],
      ),
    );
  }

  Widget _stepCircle(String label, bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : AppColors.bgLightGrey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: active ? AppColors.primaryBlue : AppColors.bgLightGrey,
    );
  }
}
