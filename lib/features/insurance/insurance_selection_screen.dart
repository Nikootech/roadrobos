import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF0F172A)),
          ),
        ),
        title: Text(
          'Vehicle Insurance',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            padding: const EdgeInsets.all(4),
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Buy Cover'),
                Tab(text: 'My Policies'),
                Tab(text: 'Link Policy'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyCoverTab(vehicle, false),
          _buildMyPoliciesTab(insuranceState, false),
          _buildLinkPolicyTab(vehicle, false),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: BUY NEW COVER FLOW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBuyCoverTab(Vehicle vehicle, bool isDark) {
    final vehicleDisplayName =
        vehicle.name.isNotEmpty && vehicle.name != 'Loading...'
            ? vehicle.name
            : 'My Vehicle';
    final vehicleDisplayPlate =
        vehicle.plate.isNotEmpty && vehicle.plate != 'Loading...'
            ? vehicle.plate
            : 'KA 05 MN 4821';

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
                  colors: [Color(0xFF006241), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006241).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      vehicle.type == 'Car'
                          ? Iconsax.car
                          : Icons.two_wheeler_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleDisplayName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Plate: $vehicleDisplayPlate • Est. IDV: ₹85,000',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'INSURE NOW',
                      style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Yearly Policy',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF006241),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF006241)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF006241).withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(plan.emoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        plan.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    if (plan.tag.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          plan.tag,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF006241),
                                            fontSize: 9.5,
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
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${plan.basePrice.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF006241),
                                ),
                              ),
                              Text(
                                '/year',
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        ...plan.benefits.map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 14, color: Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: const Color(0xFF334155),
                                        fontWeight: FontWeight.w500,
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
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
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
                    color: isChecked ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFF006241)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(addOn.icon,
                            size: 18,
                            color: isChecked
                                ? const Color(0xFF006241)
                                : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addOn.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              addOn.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+₹${addOn.price.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF006241),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isChecked
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isChecked
                            ? const Color(0xFF006241)
                            : const Color(0xFFCBD5E1),
                        size: 22,
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
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      Text('Nominee Relation:',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700)),
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
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Base Plan Premium:',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFF64748B))),
                      Text('₹${_currentBasePrice.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add-ons (${_selectedAddOnIds.length} chosen):',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFF64748B))),
                      Text('₹${_currentAddOnsTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GST (18% Govt Taxes):',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFF64748B))),
                      Text('₹${_gstAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const Divider(height: 22, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable:',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '₹${_grandTotal.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF006241),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buy & Generate Policy Button
            GestureDetector(
              onTap: _isProcessing ? null : _handleBuyInsurance,
              child: Container(
                height: 54,
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
                child: _isProcessing
                    ? const Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
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
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: const Icon(Iconsax.shield_tick,
                    size: 32, color: Color(0xFF006241)),
              ),
              const SizedBox(height: 18),
              Text(
                'No Active Insurance Found',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Protect your bike or car against accidental damages, theft, and third-party liabilities.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _tabController.animateTo(0);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006241), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Get Protected Today',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5),
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

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.policies.length,
      itemBuilder: (context, index) {
        final policy = state.policies[index];
        final daysRemaining =
            policy.expiryDate.difference(DateTime.now()).inDays;
        final isActive = daysRemaining > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.shield_tick,
                                color: Color(0xFF006241), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              policy.planTitle,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isActive
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFECDD3)),
                          ),
                          child: Text(
                            isActive ? 'ACTIVE' : 'EXPIRED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Policy #${policy.policyNumber}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VEHICLE',
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              '${policy.vehicleName} (${policy.vehiclePlate})',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('VALIDITY',
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              isActive ? '$daysRemaining days left' : 'Expired',
                              style: GoogleFonts.inter(
                                color: isActive
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFFE11D48),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showInstantClaimSheet(policy),
                        icon: const Icon(Iconsax.flash_1,
                            color: Color(0xFFD97706), size: 16),
                        label: Text(
                          '1-Tap Claim',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFD97706),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5),
                        ),
                      ),
                    ),
                    Container(
                        width: 1, height: 18, color: const Color(0xFFE2E8F0)),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Downloading Policy Schedule #${policy.policyNumber}...'),
                              backgroundColor: const Color(0xFF006241),
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.document_download,
                            color: Color(0xFF475569), size: 16),
                        label: Text(
                          'Download PDF',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5),
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
    final providers = [
      'Acko',
      'ICICI Lombard',
      'Digit',
      'HDFC Ergo',
      'Bajaj Allianz',
      'Tata AIG',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 3D Glassmorphic Sync Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006241).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006241), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006241).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Iconsax.shield_tick,
                        color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync External Coverage',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Link coverage from Acko, ICICI Lombard, Digit, or HDFC Ergo for 1-tap roadside claims & renewal alerts.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF475569),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Quick Provider Selection
          Text(
            'Select Provider',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: providers.map((provider) {
              final isSelected =
                  _linkProviderController.text.trim().toLowerCase() ==
                      provider.toLowerCase();
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _linkProviderController.text = provider;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF006241)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF006241)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF006241)
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    provider,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 3. Policy Form Card Container
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Policy Information',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.lock,
                        size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      '256-bit Encrypted',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
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
                GestureDetector(
                  onTap: _isProcessing ? null : _handleLinkPolicy,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006241), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF006241).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.0),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.link,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'LINK POLICY & ENABLE ALERTS',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
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
