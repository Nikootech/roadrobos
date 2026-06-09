import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../home/vehicle_provider.dart';

class InsuranceSelectionScreen extends ConsumerStatefulWidget {
  const InsuranceSelectionScreen({super.key});

  @override
  ConsumerState<InsuranceSelectionScreen> createState() => _InsuranceSelectionScreenState();
}

class _InsuranceSelectionScreenState extends ConsumerState<InsuranceSelectionScreen> {
  int _selectedPackageIndex = 0;
  final TextEditingController _policyNoController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  bool _isLinking = false;
  bool _isBuying = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': 'RoboShield Premium',
      'subtitle': 'Ultimate All-Inclusive Cover',
      'price': '₹499/mo',
      'color': AppColors.primaryBlue,
      'emoji': '🛡️',
      'benefits': [
        'Zero depreciation on all parts',
        '24/7 Roadside Assistance & Towing',
        'Engine & Gearbox Protection cover',
        'Key & Lock replacement allowance',
      ],
    },
    {
      'title': 'Road Assist Basic',
      'subtitle': 'Accident & Breakdown Towing',
      'price': '₹199/mo',
      'color': AppColors.accentOrange,
      'emoji': '⚙️',
      'benefits': [
        'Accident recovery tow up to 50km',
        'Flat tyre & battery jumpstart service',
        'Basic third-party liability coverage',
        '₹5,000 damage deductibles cover',
      ],
    },
    {
      'title': 'EV Specialized Cover',
      'subtitle': 'Dedicated Electric Vehicle Protection',
      'price': '₹349/mo',
      'color': Colors.cyan,
      'emoji': '⚡',
      'benefits': [
        'Battery pack leakage & surge damage cover',
        'Charging station liability protection',
        'Towing to nearest charging hub (unlimited)',
        'Zero-depreciation on EV electricals',
      ],
    },
  ];

  @override
  void dispose() {
    _policyNoController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successDark,
                size: 48,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Success!',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.pop(); // Return to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBuyInsurance(Vehicle vehicle) async {
    _triggerHaptic();
    setState(() => _isBuying = true);

    // Simulate API request
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isBuying = false);
      final package = _packages[_selectedPackageIndex]['title'];
      _showSuccessDialog('Your vehicle (${vehicle.name}) is now covered under the $package policy!');
    }
  }

  void _handleLinkPolicy(Vehicle vehicle) async {
    if (_policyNoController.text.trim().isEmpty || _providerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    _triggerHaptic();
    setState(() => _isLinking = true);

    // Simulate API request
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isLinking = false);
      final policyNo = _policyNoController.text.trim();
      _policyNoController.clear();
      _providerController.clear();
      _showSuccessDialog('Successfully linked existing policy #$policyNo to your vehicle (${vehicle.name})!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehicleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Theme.of(context).appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ),
        title: Text(
          'Vehicle Insurance',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic vehicle header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDarkCard : AppColors.bgSkyLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.transparent : AppColors.primaryBlue.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        vehicle.type == 'Car' ? Icons.directions_car_rounded : Icons.pedal_bike_rounded,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Reg No: ${vehicle.plate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.warningAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'UNSECURED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 28),
              
              Text(
                'Select Insurance Cover',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Policy packages list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final pkg = _packages[index];
                  final isSelected = _selectedPackageIndex == index;
                  final borderCol = isSelected 
                      ? pkg['color'] as Color 
                      : (isDark ? Colors.transparent : AppColors.border);
                  final bgCol = isSelected 
                      ? (pkg['color'] as Color).withValues(alpha: 0.05) 
                      : (isDark ? AppColors.bgDarkCard : Colors.white);

                  return GestureDetector(
                    onTap: () {
                      _triggerHaptic();
                      setState(() => _selectedPackageIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: bgCol,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderCol, width: isSelected ? 2.0 : 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(pkg['emoji'], style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pkg['title'],
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      pkg['subtitle'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                pkg['price'],
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: pkg['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const Divider(height: 24),
                            ...List.generate(
                              (pkg['benefits'] as List).length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_rounded, size: 14, color: pkg['color'] as Color),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        pkg['benefits'][i],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Buy cover button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBuying ? null : () => _handleBuyInsurance(vehicle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isBuying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                        )
                      : const Text(
                          'Buy Insurance Cover',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 36),
              
              const Divider(),
              const SizedBox(height: 24),

              Text(
                                'Already Insured? Link Policy',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add your current policy details to link it with RoadRobos and get service renewal alerts.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Existing Policy link fields
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.bgDarkCard : AppColors.bgLightGrey,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.transparent : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _providerController,
                                      label: 'Insurance Provider',
                                      hint: 'e.g., Acko, HDFC Ergo, ICICI Lombard',
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _policyNoController,
                                      label: 'Policy Number',
                                      hint: 'e.g., POL-123456789',
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: _isLinking ? null : () => _handleLinkPolicy(vehicle),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.primaryBlue),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: _isLinking
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 2.0),
                                              )
                                            : const Text(
                                                'Link Policy Number',
                                                style: TextStyle(
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
