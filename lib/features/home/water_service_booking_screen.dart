import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/custom_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/technician/technician_provider.dart';
import 'vehicle_provider.dart';

class WaterServiceBookingScreen extends ConsumerStatefulWidget {
  const WaterServiceBookingScreen({super.key});

  @override
  ConsumerState<WaterServiceBookingScreen> createState() => _WaterServiceBookingScreenState();
}

class _WaterServiceBookingScreenState extends ConsumerState<WaterServiceBookingScreen> {
  bool _isCarSelected = true;
  int _selectedPackageIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeVehicle = ref.read(vehicleProvider);
      setState(() {
        _isCarSelected = activeVehicle.type == 'Car';
      });
    });
  }

  final List<Map<String, dynamic>> _carPackages = [
    {
      'name': 'Express Wash',
      'price': '₹299',
      'subtitle': 'Quick exterior cleaning',
      'items': ['Pressure Wash', 'Tire Dressing', 'Microfiber Dry'],
      'color': const Color(0xFF3B82F6),
      'isPremium': false,
    },
    {
      'name': 'Deep Cleaning',
      'price': '₹899',
      'subtitle': 'Interior and exterior detailing',
      'items': ['Express Wash Items', 'Interior Vacuuming', 'Dashboard Polish', 'Glass Cleaning'],
      'color': const Color(0xFF0EA5E9),
      'isPremium': true,
    },
    {
      'name': 'Ceramic Wash',
      'price': '₹1,499',
      'subtitle': 'Premium protection & shine',
      'items': ['Deep Cleaning Items', 'Ceramic Spray Wax', 'Engine Bay Cleaning', 'Upholstery Shampoo'],
      'color': const Color(0xFF0284C7),
      'isPremium': true,
    },
  ];

  final List<Map<String, dynamic>> _bikePackages = [
    {
      'name': 'Express Rinse',
      'price': '₹99',
      'subtitle': 'Quick dirt removal',
      'items': ['High Pressure Wash', 'Air Dry'],
      'color': const Color(0xFF3B82F6),
      'isPremium': false,
    },
    {
      'name': 'Foam Bath',
      'price': '₹199',
      'subtitle': 'Safe & thorough cleaning',
      'items': ['Snow Foam Wash', 'Chain Cleaning', 'Basic Polishing'],
      'color': const Color(0xFF0EA5E9),
      'isPremium': true,
    },
    {
      'name': 'Pro Detail',
      'price': '₹499',
      'subtitle': 'Showroom finish for your ride',
      'items': ['Foam Bath Items', 'Teflon Coating', 'Engine Degreasing', 'Chrome Polish'],
      'color': const Color(0xFF0284C7),
      'isPremium': true,
    },
  ];

  List<Map<String, dynamic>> get _currentPackages => _isCarSelected ? _carPackages : _bikePackages;

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
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          ),
        ),
        title: const Text(
          'Water Service Packages',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Wash Package',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleTypeSelector(),
                  const SizedBox(height: 24),
                  ...List.generate(_currentPackages.length, (index) {
                    final pkg = _currentPackages[index];
                    final isSelected = _selectedPackageIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPackageCard(index, pkg, isSelected),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
              ],
            ),
            child: CustomButton(
              label: _selectedPackageIndex == -1 ? 'Select a Package' : 'Continue to Booking',
              onPressed: _selectedPackageIndex == -1 ? null : () => context.push('/schedule-appointment'),
              backgroundColor: const Color(0xFF0EA5E9),
            ),
          ),
        ],
      ),
    );
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
        color: active ? const Color(0xFF0EA5E9) : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF64748B),
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
      color: active ? const Color(0xFF0EA5E9) : const Color(0xFFF1F5F9),
    );
  }

  Widget _buildVehicleTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTypeButton('Car Wash', Icons.directions_car_rounded, _isCarSelected, () {
            setState(() {
              _isCarSelected = true;
              _selectedPackageIndex = -1;
            });
            // Auto-select a Car from the fleet
            final cars = ref.read(allVehiclesProvider).where((v) => v.type == 'Car').toList();
            if (cars.isNotEmpty) {
              ref.read(vehicleProvider.notifier).setVehicle(cars.first);
            }
          }),
          _buildTypeButton('Bike Wash', Icons.pedal_bike_rounded, !_isCarSelected, () {
            setState(() {
              _isCarSelected = false;
              _selectedPackageIndex = -1;
            });
            // Auto-select a Bike/EV Bike from the fleet
            final bikes = ref.read(allVehiclesProvider).where((v) => v.type == 'Bike' || v.type == 'EV Bike').toList();
            if (bikes.isNotEmpty) {
              ref.read(vehicleProvider.notifier).setVehicle(bikes.first);
            }
          }),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildTypeButton(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? const Color(0xFF0EA5E9) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPackageCard(int index, Map<String, dynamic> pkg, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [const Color(0xFF0EA5E9).withOpacity(0.02), Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 2.seconds, color: Colors.blue.withOpacity(0.05)),
              ),
            if (pkg['isPremium'] == true)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (pkg['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isCarSelected ? Icons.local_car_wash_rounded : Icons.water_drop_rounded,
                          color: pkg['color'],
                          size: 24,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              pkg['subtitle'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pkg['price'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0EA5E9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate((pkg['items'] as List).length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pkg['items'][i],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1, end: 0);
  }
}
