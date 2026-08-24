import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/models/user_role.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../navigation/nav_helpers.dart';
import '../../shared/widgets/kinetic_motion.dart';

class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  ConsumerState<AdminManagementScreen> createState() =>
      _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen> {
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all'; // 'all', 'staff', 'customer', 'driver', 'technician'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final list = await ref.read(adminOpsRepositoryProvider).getAllUsers();
      if (mounted) {
        setState(() {
          _employees = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Failed to load users: $e');
      }
    }
  }

  Future<void> _toggleApproval(String uid, bool currentApproval, String userName) async {
    await HapticFeedback.mediumImpact();
    final actionName = currentApproval ? 'Suspend' : 'Activate';

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentApproval
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentApproval ? Iconsax.user_minus : Iconsax.verify5,
                color: currentApproval
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF006241),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$actionName Account',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          currentApproval
              ? 'Are you sure you want to suspend $userName? The user will not be able to access the platform until reactivated.'
              : 'Activate $userName? The user will immediately regain full access according to their assigned role.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentApproval
                  ? const Color(0xFFE11D48)
                  : const Color(0xFF006241),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              actionName,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(adminOpsRepositoryProvider)
          .updateEmployeeApproval(uid, !currentApproval);
      if (!mounted) return;
      NavHelpers.showSuccess(
        context,
        currentApproval
            ? 'Account suspended successfully.'
            : 'Account activated and verified!',
      );
      await _loadEmployees();
    } catch (e) {
      if (mounted) {
        NavHelpers.showError(context, 'Operation failed: $e');
      }
    }
  }

  void _showRolePickerSheet(Map<String, dynamic> emp) {
    HapticFeedback.lightImpact();
    final String uid = emp['id'] ?? '';
    final String currentRoleDb = emp['role'] ?? 'customer';
    final rawName =
        (emp['full_name']?.toString() ?? emp['name']?.toString() ?? '').trim();
    final email = emp['email']?.toString() ?? '';
    final String displayName = (rawName.isEmpty || rawName.contains('@'))
        ? _formatEmailAsName(email)
        : rawName;

    String selectedRoleDb = currentRoleDb;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(sheetCtx).size.height * 0.85,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sheet Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.shield_security,
                        color: Color(0xFF006241), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Role & Access Level',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'For $displayName ($email)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 12),

              // Role Options List categorized
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRoleCategoryHeader(
                      'Executive & Governance',
                      'Full platform command & administrative rules',
                      Iconsax.crown,
                    ),
                    ..._buildRoleGroup([
                      UserRole.superAdmin,
                      UserRole.founderAdmin,
                      UserRole.admin,
                      UserRole.auditor,
                      UserRole.analyst,
                    ], selectedRoleDb, (newDb) {
                      setSheetState(() => selectedRoleDb = newDb);
                    }),
                    const SizedBox(height: 16),
                    _buildRoleCategoryHeader(
                      'Operations & Hub Management',
                      'Fleet dispatch, regional hub & finance controls',
                      Iconsax.status_up,
                    ),
                    ..._buildRoleGroup([
                      UserRole.opsHead,
                      UserRole.cityManager,
                      UserRole.areaManager,
                      UserRole.financeManager,
                      UserRole.supportManager,
                      UserRole.marketingAdmin,
                    ], selectedRoleDb, (newDb) {
                      setSheetState(() => selectedRoleDb = newDb);
                    }),
                    const SizedBox(height: 16),
                    _buildRoleCategoryHeader(
                      'Fleet & End Users',
                      'Field workforce, service partners & customer app',
                      Iconsax.car,
                    ),
                    ..._buildRoleGroup([
                      UserRole.driver,
                      UserRole.technician,
                      UserRole.customer,
                    ], selectedRoleDb, (newDb) {
                      setSheetState(() => selectedRoleDb = newDb);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save Action Button
              ScaleOnTap(
                onTap: () async {
                  if (selectedRoleDb == currentRoleDb) {
                    Navigator.pop(sheetCtx);
                    return;
                  }

                  Navigator.pop(sheetCtx);
                  setState(() => _isLoading = true);

                  try {
                    await ref
                        .read(adminOpsRepositoryProvider)
                        .updateEmployeeApproval(uid, true, role: selectedRoleDb);

                    if (mounted) {
                      NavHelpers.showSuccess(
                        context,
                        'Role updated to ${selectedRoleDb.toUpperCase()}! User will be notified to re-login.',
                      );
                      await _loadEmployees();
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      NavHelpers.showError(context, 'Role update failed: $e');
                    }
                  }
                },
                child: Container(
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
                        color: const Color(0xFF006241).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Save & Apply Role Update',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
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
      ),
    );
  }

  Widget _buildRoleCategoryHeader(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF006241)),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: const Color(0xFF006241),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoleGroup(
    List<UserRole> roles,
    String currentSelectedDb,
    ValueChanged<String> onSelected,
  ) {
    return roles.map((role) {
      final roleDb = _getRoleDbString(role);
      final isSelected = roleDb.toLowerCase() == currentSelectedDb.toLowerCase();
      final label = role.roleLabel;
      final description = _getRoleDescription(role);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(roleDb);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF006241) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF006241).withValues(alpha: 0.12)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF006241).withValues(alpha: 0.2)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Icon(
                    _getRoleIcon(role),
                    size: 16,
                    color: isSelected ? const Color(0xFF006241) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? const Color(0xFF006241) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF006241) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF006241) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  String _getRoleDbString(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.founderAdmin:
        return 'founder_admin';
      case UserRole.opsHead:
        return 'ops_head';
      case UserRole.cityManager:
        return 'city_manager';
      case UserRole.areaManager:
        return 'area_manager';
      case UserRole.financeManager:
        return 'finance_manager';
      case UserRole.supportManager:
        return 'support_manager';
      case UserRole.marketingAdmin:
        return 'marketing_admin';
      default:
        return role.name;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
      case UserRole.founderAdmin:
        return Iconsax.crown;
      case UserRole.admin:
        return Iconsax.shield_security;
      case UserRole.opsHead:
        return Iconsax.command;
      case UserRole.cityManager:
      case UserRole.areaManager:
        return Iconsax.buildings;
      case UserRole.financeManager:
        return Iconsax.wallet_3;
      case UserRole.supportManager:
        return Iconsax.headphone;
      case UserRole.marketingAdmin:
        return Iconsax.presention_chart;
      case UserRole.auditor:
      case UserRole.analyst:
        return Iconsax.document_text;
      case UserRole.driver:
        return Iconsax.driving;
      case UserRole.technician:
        return Iconsax.setting_2;
      case UserRole.customer:
        return Iconsax.user;
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Root access, security policies & global config';
      case UserRole.founderAdmin:
        return 'Executive control, ledger settlements & high-level rules';
      case UserRole.admin:
        return 'Staff management, approvals & platform settings';
      case UserRole.opsHead:
        return 'Central operations, fleet monitoring & dispatch supervision';
      case UserRole.cityManager:
        return 'City-level operations, pricing & partner onboarding';
      case UserRole.areaManager:
        return 'Regional station hub management & local field operations';
      case UserRole.financeManager:
        return 'Payout verification, refunds & wallet settlement audit';
      case UserRole.supportManager:
        return 'Customer ticketing, dispute resolution & rider safety desk';
      case UserRole.marketingAdmin:
        return 'Promotions, coupon codes & customer acquisition campaigns';
      case UserRole.auditor:
        return 'Audit log inspection, compliance & read-only trails';
      case UserRole.analyst:
        return 'Business intelligence, telemetry graphs & analytics';
      case UserRole.driver:
        return 'Driver mobile app, active trip dispatch & wallet earnings';
      case UserRole.technician:
        return 'Technician app, vehicle inspections & maintenance jobs';
      case UserRole.customer:
        return 'Standard customer mobile app & rental bookings';
    }
  }

  String _formatEmailAsName(String email) {
    final username = email.split('@').first;
    final parts = username
        .split(RegExp(r'[._-]'))
        .where((p) => p.isNotEmpty && !RegExp(r'^\d+$').hasMatch(p))
        .toList();
    if (parts.isEmpty) return username;
    return parts
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _employees.length;
    final activeCount = _employees.where((e) => e['is_approved'] == true).length;
    final suspendedCount = _employees.where((e) => e['is_approved'] != true).length;
    final staffCount = _employees.where((e) {
      final r = (e['role'] ?? 'customer').toString().toLowerCase();
      return r != 'customer' && r != 'driver' && r != 'technician';
    }).length;
    final driverCount = _employees.where((e) => (e['role'] ?? '').toString().toLowerCase() == 'driver').length;
    final techCount = _employees.where((e) => (e['role'] ?? '').toString().toLowerCase() == 'technician').length;
    final customerCount = _employees.where((e) => (e['role'] ?? '').toString().toLowerCase() == 'customer').length;

    final filtered = _employees.where((emp) {
      final name = (emp['full_name']?.toString() ?? emp['name']?.toString() ?? '').toLowerCase();
      final email = (emp['email']?.toString() ?? '').toLowerCase();
      final phone = (emp['phone']?.toString() ?? '').toLowerCase();
      final role = (emp['role']?.toString() ?? 'customer').toLowerCase();
      final query = _searchQuery.trim().toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          role.contains(query);

      if (!matchesQuery) return false;

      if (_selectedCategory == 'staff') {
        return role != 'customer' && role != 'driver' && role != 'technician';
      } else if (_selectedCategory == 'customer') {
        return role == 'customer';
      } else if (_selectedCategory == 'driver') {
        return role == 'driver';
      } else if (_selectedCategory == 'technician') {
        return role == 'technician';
      }
      return true;
    }).toList();

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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'User & Role Management',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Governance, Permissions & Access Control',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ScaleOnTap(
              onTap: () async {
                await HapticFeedback.lightImpact();
                await _loadEmployees();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: const Center(
                  child: Icon(Iconsax.refresh, size: 16, color: Color(0xFF006241)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEmployees,
        color: const Color(0xFF006241),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── KPI METRICS OVERVIEW STRIP ──────────────────────────────
              _buildMetricsStrip(
                total: totalCount,
                active: activeCount,
                staff: staffCount,
                suspended: suspendedCount,
              ),

              const SizedBox(height: 18),

              // ── FLOATING SEARCH BAR ──────────────────────────────────────
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    const Icon(Iconsax.search_normal_1,
                        size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, phone or role...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── SEGMENTED ROLE CATEGORY FILTER TABS ──────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All Users', 'all', totalCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Staff & Admins', 'staff', staffCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Drivers', 'driver', driverCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Technicians', 'technician', techCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Customers', 'customer', customerCount),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── LIST HEADER WITH LIVE COUNT ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Directory (${filtered.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Text(
                      '${filtered.length} matching',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006241),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── USERS LIST ───────────────────────────────────────────────
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(color: Color(0xFF006241)),
                  ),
                )
              else if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.user_search,
                            size: 36, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No matching users found',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try searching with a different name, email, or filter category.',
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final emp = filtered[index];
                    return _buildModernUserCard(emp)
                        .animate()
                        .fadeIn(delay: (index * 30).ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                ),

              const SizedBox(height: 28),

              // ── GOVERNANCE AUDIT TRAIL PREVIEW ──────────────────────────
              _buildGovernanceAuditCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsStrip({
    required int total,
    required int active,
    required int staff,
    required int suspended,
  }) {
    return Row(
      children: [
        _buildMetricItem(
          label: 'Total Users',
          value: total.toString(),
          icon: Iconsax.people,
          color: const Color(0xFF0F172A),
          bgColor: const Color(0xFFF1F5F9),
        ),
        const SizedBox(width: 8),
        _buildMetricItem(
          label: 'Active',
          value: active.toString(),
          icon: Iconsax.verify5,
          color: const Color(0xFF006241),
          bgColor: const Color(0xFFF0FDF4),
        ),
        const SizedBox(width: 8),
        _buildMetricItem(
          label: 'Staff & Ops',
          value: staff.toString(),
          icon: Iconsax.shield_tick,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFF0F9FF),
        ),
        const SizedBox(width: 8),
        _buildMetricItem(
          label: 'Suspended',
          value: suspended.toString(),
          icon: Iconsax.user_minus,
          color: const Color(0xFFE11D48),
          bgColor: const Color(0xFFFFF1F2),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, int count) {
    final isSelected = _selectedCategory == key;

    return ScaleOnTap(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedCategory = key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006241) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF006241) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF006241).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernUserCard(Map<String, dynamic> emp) {
    final String uid = emp['id'] ?? '';
    final String email = emp['email'] ?? '';
    final String phone = emp['phone'] ?? '';
    final String role = emp['role'] ?? 'customer';
    final bool isApproved = emp['is_approved'] ?? false;
    final String roleDisplay = role.toUpperCase().replaceAll('_', ' ');

    final rawName =
        (emp['full_name']?.toString() ?? emp['name']?.toString() ?? '').trim();
    final String name = (rawName.isEmpty || rawName.contains('@'))
        ? _formatEmailAsName(email)
        : rawName;
    final String avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    final isDriver = role.toLowerCase() == 'driver';
    final isTech = role.toLowerCase() == 'technician';
    final isStaff = !isDriver && !isTech && role.toLowerCase() != 'customer';

    Color roleColor = const Color(0xFF64748B);
    Color roleBgColor = const Color(0xFFF1F5F9);
    IconData roleIcon = Iconsax.user;

    if (isDriver) {
      roleColor = const Color(0xFF006241);
      roleBgColor = const Color(0xFFF0FDF4);
      roleIcon = Iconsax.driving;
    } else if (isTech) {
      roleColor = const Color(0xFF0284C7);
      roleBgColor = const Color(0xFFF0F9FF);
      roleIcon = Iconsax.setting_2;
    } else if (isStaff) {
      roleColor = const Color(0xFFD97706);
      roleBgColor = const Color(0xFFFFFBEB);
      roleIcon = Iconsax.shield_security;
    }

    return ScaleOnTap(
      onTap: () async {
        final shouldRefresh =
            await context.push<bool>('/admin-management-details', extra: emp);
        if (shouldRefresh == true && mounted) {
          await _loadEmployees();
        }
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar, Name/Contact & Status Pill
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isStaff
                              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                              : [const Color(0xFF006241), const Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          avatarLetter,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          phone,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isApproved
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFECDD3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isApproved
                              ? const Color(0xFF006241)
                              : const Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isApproved ? 'ACTIVE' : 'SUSPENDED',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isApproved
                              ? const Color(0xFF006241)
                              : const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),

            // Bottom Action Row: Role Selector Pill & Suspend/Activate Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Role Selector Pill
                ScaleOnTap(
                  onTap: () => _showRolePickerSheet(emp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: roleBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: roleColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon, size: 13, color: roleColor),
                        const SizedBox(width: 5),
                        Text(
                          roleDisplay,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: roleColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(Iconsax.edit_2, size: 11, color: roleColor),
                      ],
                    ),
                  ),
                ),

                // Suspend / Activate Action Button
                ScaleOnTap(
                  onTap: () => _toggleApproval(uid, isApproved, name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFFFFF1F2)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isApproved
                            ? const Color(0xFFFECDD3)
                            : const Color(0xFFDCFCE7),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isApproved ? Iconsax.slash : Iconsax.tick_circle,
                          size: 13,
                          color: isApproved
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF006241),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isApproved ? 'Suspend' : 'Activate',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isApproved
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF006241),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernanceAuditCard() {
    final logs = [
      {'action': 'Role modified for Ops Head (#104)', 'time': '10 mins ago', 'type': 'role'},
      {'action': 'Technician access authorized (#82)', 'time': '1 hour ago', 'type': 'approve'},
      {'action': 'Account suspended due to policy check', 'time': 'Yesterday', 'type': 'suspend'},
      {'action': 'Driver onboarding profile verified', 'time': '2 days ago', 'type': 'verify'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.shield_security, size: 18, color: Color(0xFF006241)),
              const SizedBox(width: 8),
              Text(
                'Recent Governance & Role Audits',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...logs.map((log) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.document_text_1, size: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      log['action']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                  Text(
                    log['time']!,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
