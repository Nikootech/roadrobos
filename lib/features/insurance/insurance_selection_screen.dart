import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../home/vehicle_provider.dart';
import '../profile/user_provider.dart';
import 'insurance_models.dart';
import 'insurance_provider.dart';

class InsuranceSelectionScreen extends ConsumerStatefulWidget {
  const InsuranceSelectionScreen({super.key});

  @override
  ConsumerState<InsuranceSelectionScreen> createState() =>
      _InsuranceSelectionScreenState();
}

class _InsuranceSelectionScreenState
    extends ConsumerState<InsuranceSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Plan Selection
  int _selectedPlanIndex = 1; // Default to Comprehensive
  final Set<String> _selectedAddOnIds = {
    'zero_dep',
    'roadside_assist',
  };

  // Nominee / Owner Form Controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _nomineeNameController = TextEditingController();
  String _nomineeRelation = 'Spouse';

  // Link Policy Controllers
  final TextEditingController _linkPolicyNoController = TextEditingController();
  final TextEditingController _linkProviderController = TextEditingController();
  final TextEditingController _linkVehiclePlateController =
      TextEditingController();

  bool _isProcessing = false;

  // Pre-defined Insurance Plans
  final List<InsurancePlan> _plans = const [
    InsurancePlan(
      id: 'third_party',
      title: 'Third-Party Mandatory',
      subtitle: 'Legal compliance for road safety',
      basePrice: 799.0,
      color: Color(0xFF10B981),
      emoji: '📜',
      tag: 'Mandatory',
      idvPercentage: 0.0,
      benefits: [
        'Mandatory by law (Motor Vehicles Act)',
        'Covers 3rd party property damage up to ₹7.5 Lakh',
        'Covers 3rd party injury / accidental liability',
        'Instant digital policy generation',
      ],
    ),
    InsurancePlan(
      id: 'comprehensive',
      title: 'Comprehensive Shield',
      subtitle: 'Complete Own Damage + Third Party',
      basePrice: 1499.0,
      color: Color(0xFF3B82F6),
      emoji: '🛡️',
      tag: 'Most Popular',
      idvPercentage: 0.85,
      benefits: [
        'Includes full Third-Party liability cover',
        'Own damage protection (Accident, Fire, Theft)',
        '85% IDV vehicle value protection',
        'Cashless repairs at 1,200+ partner workshops',
        'Natural calamities & flood damage covered',
      ],
    ),
    InsurancePlan(
      id: 'roboshield_zero_dep',
      title: 'RoboShield 0-Dep Premium',
      subtitle: 'All-Inclusive Zero Depreciation Protection',
      basePrice: 2299.0,
      color: Color(0xFFF97316),
      emoji: '⚡',
      tag: 'Best Protection',
      idvPercentage: 0.95,
      benefits: [
        '100% Zero-Depreciation on plastic, rubber & metal parts',
        '24/7 Unlimited Roadside Assistance & free towing',
        'Engine, gearbox & EV battery surge protection',
        'Consumables cover (Engine oil, nuts, bolts, coolant)',
        'Key & lock replacement allowance up to ₹5,000',
      ],
    ),
  ];

  // Optional Add-ons
  final List<InsuranceAddOn> _addOns = const [
    InsuranceAddOn(
      id: 'zero_dep',
      title: 'Zero Depreciation Cover',
      subtitle: 'Full claim payout without depreciation cuts',
      price: 399.0,
      icon: Icons.shield_rounded,
    ),
    InsuranceAddOn(
      id: 'roadside_assist',
      title: '24/7 Roadside Assistance',
      subtitle: 'Flat tyre, towing & emergency fuel delivery',
      price: 199.0,
      icon: Icons.emergency_rounded,
    ),
    InsuranceAddOn(
      id: 'engine_protect',
      title: 'Engine & Gearbox Protection',
      subtitle: 'Covers water ingression & lubricating oil leakage',
      price: 299.0,
      icon: Icons.speed_rounded,
    ),
    InsuranceAddOn(
      id: 'pa_cover',
      title: 'Personal Accident Cover (₹15 Lakh)',
      subtitle: 'Comprehensive driver & owner life security',
      price: 299.0,
      icon: Icons.health_and_safety_rounded,
    ),
    InsuranceAddOn(
      id: 'key_replacement',
      title: 'Key Replacement Allowance',
      subtitle: 'Covers cost of duplicate key & lock replacement',
      price: 99.0,
      icon: Icons.key_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider).user;
      if (user != null) {
        _ownerNameController.text = user.name;
        _ownerPhoneController.text = user.phone;
      }
      final vehicle = ref.read(vehicleProvider);
      _linkVehiclePlateController.text = vehicle.plate;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _nomineeNameController.dispose();
    _linkPolicyNoController.dispose();
    _linkProviderController.dispose();
    _linkVehiclePlateController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  double get _currentBasePrice => _plans[_selectedPlanIndex].basePrice;

  double get _currentAddOnsTotal {
    double total = 0.0;
    for (final addOn in _addOns) {
      if (_selectedAddOnIds.contains(addOn.id)) {
        total += addOn.price;
      }
    }
    return total;
  }

  double get _subtotal => _currentBasePrice + _currentAddOnsTotal;
  double get _gstAmount => _subtotal * 0.18;
  double get _grandTotal => _subtotal + _gstAmount;

  Future<void> _handleBuyInsurance() async {
    final vehicle = ref.read(vehicleProvider);
    final selectedPlan = _plans[_selectedPlanIndex];

    if (_ownerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the owner name')),
      );
      return;
    }

    _triggerHaptic();
    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1400));

      final selectedAddOnTitles = _addOns
          .where((a) => _selectedAddOnIds.contains(a.id))
          .map((a) => a.title)
          .toList();

      final policy = await ref.read(insuranceProvider.notifier).buyPolicy(
            vehicleName: vehicle.name,
            vehiclePlate: vehicle.plate,
            vehicleType: vehicle.type,
            plan: selectedPlan,
            totalPremium: _grandTotal,
            idvAmount: selectedPlan.idvPercentage > 0 ? 85000.0 : 0.0,
            ownerName: _ownerNameController.text.trim(),
            ownerPhone: _ownerPhoneController.text.trim(),
            nomineeName: _nomineeNameController.text.trim().isEmpty
                ? 'Primary Nominee'
                : _nomineeNameController.text.trim(),
            nomineeRelation: _nomineeRelation,
            selectedAddOns: selectedAddOnTitles,
          );

      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showPolicySuccessDialog(policy);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to purchase policy: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  Future<void> _handleLinkPolicy() async {
    if (_linkPolicyNoController.text.trim().isEmpty ||
        _linkProviderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all policy details')),
      );
      return;
    }

    final vehicle = ref.read(vehicleProvider);
    _triggerHaptic();
    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final policy =
          await ref.read(insuranceProvider.notifier).linkExistingPolicy(
                vehicleName: vehicle.name,
                vehiclePlate: _linkVehiclePlateController.text.trim().isNotEmpty
                    ? _linkVehiclePlateController.text.trim()
                    : vehicle.plate,
                providerName: _linkProviderController.text.trim(),
                policyNumber: _linkPolicyNoController.text.trim(),
                expiryDate: DateTime.now().add(const Duration(days: 180)),
              );

      if (!mounted) return;
      setState(() => _isProcessing = false);
      _linkPolicyNoController.clear();
      _linkProviderController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Successfully linked policy ${policy.policyNumber} with ${vehicle.name}!'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      _tabController.animateTo(1); // Switch to "My Policies" tab
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error linking policy: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _showPolicySuccessDialog(InsurancePolicy policy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.successGreen,
                size: 52,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              'Insurance Active & Protected!',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your policy has been successfully issued for ${policy.vehicleName}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Policy Card snippet
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        policy.planTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Policy No: ${policy.policyNumber}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('VEHICLE',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          Text(policy.vehiclePlate,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('VALID TILL',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          Text(
                            '${policy.expiryDate.day}/${policy.expiryDate.month}/${policy.expiryDate.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _tabController.animateTo(1); // Go to policies list
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'View My Policies',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop(); // Go back home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showInstantClaimSheet(InsurancePolicy policy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.emergency_rounded,
                      color: AppColors.accentOrange, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instant Roadside Claim',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Policy: ${policy.policyNumber}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Breakdown Emergency:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildClaimEmergencyOption('Flat Tyre & Puncture Assistance',
                Icons.tire_repair_rounded, ctx),
            _buildClaimEmergencyOption(
                'Battery Jumpstart / EV Recharge', Icons.bolt_rounded, ctx),
            _buildClaimEmergencyOption('Accident & Breakdown Towing to Garage',
                Icons.car_crash_rounded, ctx),
            _buildClaimEmergencyOption('Emergency Fuel / Coolant Delivery',
                Icons.local_gas_station_rounded, ctx),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '🚨 RoadRobos Emergency Partner dispatched to your live GPS location! ETA: 12 mins.'),
                      backgroundColor: AppColors.accentOrange,
                    ),
                  );
                },
                icon: const Icon(Icons.call_rounded, color: Colors.white),
                label: const Text(
                  'DISPATCH NEAREST TECHNICIAN',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimEmergencyOption(
      String title, IconData icon, BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgLightGrey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehicleProvider);
    final insuranceState = ref.watch(insuranceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDarkCard : AppColors.bgLightSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Bike & Vehicle Insurance',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          labelStyle:
              GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '🛡️ Buy Cover'),
            Tab(text: '📋 My Policies'),
            Tab(text: '🔗 Link Offline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyCoverTab(vehicle, isDark),
          _buildMyPoliciesTab(insuranceState, isDark),
          _buildLinkPolicyTab(vehicle, isDark),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: BUY NEW COVER FLOW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBuyCoverTab(Vehicle vehicle, bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Vehicle Selection Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      vehicle.type == 'Car'
                          ? Icons.directions_car_rounded
                          : Icons.two_wheeler_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Plate: ${vehicle.plate} • Est. IDV: ₹85,000',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'INSURE NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 24),

            // 2. Plan Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1. Select Insurance Plan',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Yearly Plan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Plan Cards
            ...List.generate(_plans.length, (index) {
              final plan = _plans[index];
              final isSelected = _selectedPlanIndex == index;

              return GestureDetector(
                onTap: () {
                  _triggerHaptic();
                  setState(() => _selectedPlanIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? plan.color.withValues(alpha: 0.05)
                        : (isDark ? AppColors.bgDarkCard : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? plan.color
                          : (isDark
                              ? Colors.white12
                              : AppColors.border.withValues(alpha: 0.7)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: plan.color.withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(plan.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      plan.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.textOnDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (plan.tag.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: plan.color
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          plan.tag,
                                          style: TextStyle(
                                            color: plan.color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plan.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textOnDarkMuted
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${plan.basePrice.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: plan.color,
                                ),
                              ),
                              const Text(
                                '/year',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const Divider(height: 24),
                        ...plan.benefits.map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      size: 14, color: plan.color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textOnDarkMuted
                                            : AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 3. Recommended Add-ons
            Text(
              '2. Recommended Add-on Protection',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ..._addOns.map((addOn) {
              final isChecked = _selectedAddOnIds.contains(addOn.id);
              return GestureDetector(
                onTap: () {
                  _triggerHaptic();
                  setState(() {
                    if (isChecked) {
                      _selectedAddOnIds.remove(addOn.id);
                    } else {
                      _selectedAddOnIds.add(addOn.id);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.primaryBlue.withValues(alpha: 0.05)
                        : (isDark ? AppColors.bgDarkCard : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked
                          ? AppColors.primaryBlue
                          : (isDark ? Colors.white12 : AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(addOn.icon,
                            size: 18, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addOn.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              addOn.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+₹${addOn.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Checkbox(
                            value: isChecked,
                            activeColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (v) {
                              _triggerHaptic();
                              setState(() {
                                if (v == true) {
                                  _selectedAddOnIds.add(addOn.id);
                                } else {
                                  _selectedAddOnIds.remove(addOn.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 4. Owner & Nominee Details
            Text(
              '3. Policy Owner & Nominee Details',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDarkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.border),
              ),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _ownerNameController,
                    label: 'Policy Holder Full Name',
                    hint: 'As per RC document',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _ownerPhoneController,
                    label: 'Registered Mobile Number',
                    hint: '+91 XXXXX XXXXX',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _nomineeNameController,
                    label: 'Nominee Name (for PA Claim)',
                    hint: 'e.g. Spouse / Parent / Child',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Nominee Relation:',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _nomineeRelation,
                        underline: const SizedBox(),
                        items: ['Spouse', 'Father', 'Mother', 'Son', 'Daughter']
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _nomineeRelation = v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Price Breakdown Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Plan Premium:',
                          style: TextStyle(fontSize: 13)),
                      Text('₹${_currentBasePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add-ons (${_selectedAddOnIds.length} chosen):',
                          style: const TextStyle(fontSize: 13)),
                      Text('₹${_currentAddOnsTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GST (18% Govt Taxes):',
                          style: TextStyle(fontSize: 13)),
                      Text('₹${_gstAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable:',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${_grandTotal.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buy & Generate Policy Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleBuyInsurance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'PAY ₹${_grandTotal.toStringAsFixed(0)} & ISSUE POLICY',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: MY ACTIVE POLICIES & CLAIMS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMyPoliciesTab(InsuranceState state, bool isDark) {
    if (state.policies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    size: 48, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Insurance Found',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Protect your bike or car against accidental damages, theft, and third-party liabilities.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Get Protected Today',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.policies.length,
      itemBuilder: (context, index) {
        final policy = state.policies[index];
        final daysRemaining =
            policy.expiryDate.difference(DateTime.now()).inDays;
        final isActive = daysRemaining > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded,
                                color: AppColors.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              policy.planTitle,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.successGreen.withValues(alpha: 0.2)
                                : AppColors.dangerRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isActive ? 'ACTIVE' : 'EXPIRED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? AppColors.successGreen
                                  : AppColors.dangerRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Policy #${policy.policyNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('VEHICLE',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              '${policy.vehicleName} (${policy.vehiclePlate})',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('VALIDITY',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              isActive ? '$daysRemaining days left' : 'Expired',
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.accentOrange
                                    : AppColors.dangerRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showInstantClaimSheet(policy),
                        icon: const Icon(Icons.emergency_share_rounded,
                            color: AppColors.accentOrange, size: 18),
                        label: const Text(
                          '1-Tap Claim',
                          style: TextStyle(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 20, color: Colors.white12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Downloading Policy Schedule #${policy.policyNumber}...'),
                              backgroundColor: AppColors.primaryBlue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.white70, size: 18),
                        label: const Text(
                          'Download PDF',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms);
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: LINK EXISTING POLICY
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildLinkPolicyTab(Vehicle vehicle, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Link your existing third-party insurance from other providers (Acko, HDFC Ergo, ICICI, etc.) to get automated renewal alerts and quick roadside assistance.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Enter Offline Policy Information',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: isDark ? Colors.white12 : AppColors.border),
            ),
            child: Column(
              children: [
                CustomTextField(
                  controller: _linkVehiclePlateController,
                  label: 'Vehicle Registration Number',
                  hint: 'e.g. KA 05 MN 4821',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _linkProviderController,
                  label: 'Insurance Provider Name',
                  hint: 'e.g. Acko, ICICI Lombard, Digit, HDFC Ergo',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _linkPolicyNoController,
                  label: 'Policy Number',
                  hint: 'e.g. POL-9928172901',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleLinkPolicy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.0),
                          )
                        : const Text(
                            'Link Policy Number',
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
