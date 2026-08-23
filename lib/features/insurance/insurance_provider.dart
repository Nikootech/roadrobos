import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'insurance_models.dart';

class InsuranceState {
  final List<InsurancePolicy> policies;
  final bool isLoading;
  final String? error;

  const InsuranceState({
    this.policies = const [],
    this.isLoading = false,
    this.error,
  });

  InsuranceState copyWith({
    List<InsurancePolicy>? policies,
    bool? isLoading,
    String? error,
  }) {
    return InsuranceState(
      policies: policies ?? this.policies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InsuranceNotifier extends StateNotifier<InsuranceState> {
  InsuranceNotifier() : super(const InsuranceState()) {
    loadPolicies();
  }

  static const String _storageKey = 'roadrobos_insurance_policies';

  Future<void> loadPolicies() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);

      List<InsurancePolicy> loaded = [];
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson);
        loaded = decoded
            .map((item) =>
                InsurancePolicy.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      // If empty, add a standard initial policy for demonstration
      if (loaded.isEmpty) {
        final now = DateTime.now();
        loaded = [
          InsurancePolicy(
            id: 'policy_init_1',
            policyNumber: 'RR-SHIELD-2026-8841',
            vehicleName: 'Yamaha FZ-S V3',
            vehiclePlate: 'KA 05 MN 4821',
            vehicleType: 'Bike',
            planTitle: 'RoboShield Zero-Dep Cover',
            planId: 'roboshield_zero_dep',
            provider: 'RoadRobos Shield Cover (Acko General)',
            issueDate: now.subtract(const Duration(days: 45)),
            expiryDate: now.add(const Duration(days: 320)),
            totalPremium: 2299.0,
            idvAmount: 85000.0,
            ownerName: 'Sudhan K',
            ownerPhone: '+91 98765 43210',
            nomineeName: 'Priya K',
            nomineeRelation: 'Spouse',
            selectedAddOns: [
              'Zero Depreciation',
              '24/7 Roadside Assistance & Towing',
              'Engine & Gearbox Protection',
            ],
          ),
        ];
        await _savePolicies(loaded);
      }

      state = state.copyWith(policies: loaded, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load policies: $e');
    }
  }

  Future<void> _savePolicies(List<InsurancePolicy> policies) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(policies.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<InsurancePolicy> buyPolicy({
    required String vehicleName,
    required String vehiclePlate,
    required String vehicleType,
    required InsurancePlan plan,
    required double totalPremium,
    required double idvAmount,
    required String ownerName,
    required String ownerPhone,
    required String nomineeName,
    required String nomineeRelation,
    required List<String> selectedAddOns,
  }) async {
    state = state.copyWith(isLoading: true);
    final now = DateTime.now();
    final randomSuffix =
        (1000 + (DateTime.now().millisecondsSinceEpoch % 9000));
    final policyNo = 'RR-${plan.id.toUpperCase()}-2026-$randomSuffix';

    final newPolicy = InsurancePolicy(
      id: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      policyNumber: policyNo,
      vehicleName: vehicleName,
      vehiclePlate: vehiclePlate.toUpperCase(),
      vehicleType: vehicleType,
      planTitle: plan.title,
      planId: plan.id,
      provider: 'RoadRobos Shield Assurance',
      issueDate: now,
      expiryDate: now.add(const Duration(days: 365)),
      totalPremium: totalPremium,
      idvAmount: idvAmount,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      nomineeName: nomineeName,
      nomineeRelation: nomineeRelation,
      selectedAddOns: selectedAddOns,
    );

    final updated = [newPolicy, ...state.policies];
    await _savePolicies(updated);
    state = state.copyWith(policies: updated, isLoading: false);
    return newPolicy;
  }

  Future<InsurancePolicy> linkExistingPolicy({
    required String vehicleName,
    required String vehiclePlate,
    required String providerName,
    required String policyNumber,
    required DateTime expiryDate,
  }) async {
    state = state.copyWith(isLoading: true);
    final now = DateTime.now();

    final linked = InsurancePolicy(
      id: 'linked_${DateTime.now().millisecondsSinceEpoch}',
      policyNumber: policyNumber.toUpperCase(),
      vehicleName: vehicleName,
      vehiclePlate: vehiclePlate.toUpperCase(),
      vehicleType: 'Vehicle',
      planTitle: 'Third-Party / Comprehensive Linked Cover',
      planId: 'linked_external',
      provider: providerName,
      issueDate: now,
      expiryDate: expiryDate,
      totalPremium: 0.0,
      idvAmount: 60000.0,
      ownerName: 'Registered Owner',
      ownerPhone: '',
      nomineeName: 'N/A',
      nomineeRelation: 'N/A',
      status:
          expiryDate.isAfter(now) ? PolicyStatus.active : PolicyStatus.expired,
    );

    final updated = [linked, ...state.policies];
    await _savePolicies(updated);
    state = state.copyWith(policies: updated, isLoading: false);
    return linked;
  }
}

final insuranceProvider =
    StateNotifierProvider<InsuranceNotifier, InsuranceState>((ref) {
  return InsuranceNotifier();
});
