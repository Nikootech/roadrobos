import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/models/user_role.dart';
import '../../navigation/nav_helpers.dart';

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

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final list = await ref.read(adminOpsRepositoryProvider).getAllEmployees();
      setState(() {
        _employees = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NavHelpers.showError(context, 'Failed to load employees: $e');
      }
    }
  }

  Future<void> _toggleApproval(String uid, bool currentApproval) async {
    try {
      await ref
          .read(adminOpsRepositoryProvider)
          .updateEmployeeApproval(uid, !currentApproval);
      if (!mounted) return;
      NavHelpers.showSuccess(
        context,
        currentApproval
            ? 'Employee access suspended!'
            : 'Employee approved and activated!',
      );
      await _loadEmployees();
    } catch (e) {
      if (mounted) {
        NavHelpers.showError(context, 'Operation failed: $e');
      }
    }
  }

  Future<void> _changeRole(String uid, String currentRole) async {
    // Show dialog to select role
    final String? selectedRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Employee Role'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: UserRole.values
                .where((role) =>
                    role != UserRole.customer &&
                    role != UserRole.driver &&
                    role != UserRole.admin)
                .map((role) {
              final roleNameDb = _getRoleDbString(role);
              final displayName = role.name.toUpperCase().replaceAll('_', ' ');
              final isCurrent = roleNameDb == currentRole;

              return ListTile(
                title: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent
                        ? AppColors.primaryBlue
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryBlue)
                    : null,
                onTap: () => Navigator.pop(context, roleNameDb),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selectedRole != null && selectedRole != currentRole) {
      try {
        await ref
            .read(adminOpsRepositoryProvider)
            .updateEmployeeApproval(uid, true, role: selectedRole);
        if (mounted) {
          NavHelpers.showSuccess(context, 'Role changed successfully!');
          await _loadEmployees();
        }
      } catch (e) {
        if (mounted) {
          NavHelpers.showError(context, 'Role update failed: $e');
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final filtered = _employees.where((emp) {
      final name = emp['name']?.toString().toLowerCase() ?? '';
      final email = emp['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Admin & Staff Console',
          style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  icon: Icon(Iconsax.search_normal,
                      size: 20, color: AppColors.textSecondary),
                  hintText: 'Search employees by name or email...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Managing Employees',
                    style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filtered.length} Total',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              )
            else if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.user_remove,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'No employees found',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    const Text('Registered employees will appear here.',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
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
                  return _buildEmployeeCard(filtered[index])
                      .animate()
                      .fadeIn(delay: (index * 50).ms)
                      .slideX(begin: 0.05, end: 0);
                },
              ),

            const SizedBox(height: 32),
            Text('Audit Logs',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildAuditLogTile(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
    final String uid = emp['id'] ?? '';
    final String name = emp['name'] ?? 'Unknown Employee';
    final String email = emp['email'] ?? '';
    final String role = emp['role'] ?? 'technician';
    final bool isApproved = emp['is_approved'] ?? false;

    final displayName = role.toUpperCase().replaceAll('_', ' ');

    return GestureDetector(
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: Text(name[0],
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: GoogleFonts.outfit(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(email,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? AppColors.successGreen.withValues(alpha: 0.1)
                          : AppColors.warningAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isApproved ? 'ACTIVE' : 'PENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isApproved
                            ? AppColors.successGreen
                            : AppColors.warningAmber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Display requested role in a chip
                  GestureDetector(
                    onTap: () => _changeRole(uid, role),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueGrey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Iconsax.edit_2,
                                size: 12, color: Colors.blueGrey),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Approve / Reject Actions
                  Row(
                    children: [
                      if (!isApproved)
                        ElevatedButton.icon(
                          onPressed: () => _toggleApproval(uid, isApproved),
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => _toggleApproval(uid, isApproved),
                          icon: const Icon(Icons.block, size: 14),
                          label: const Text('Suspend'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.dangerRed,
                            side: const BorderSide(color: AppColors.dangerRed),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildAuditLogTile(int index) {
    final logs = [
      'Approved Technician account #31',
      'Changed role of User #42 to ops_head',
      'Suspended access for employee #19',
      'Rejected signup application from User #09'
    ];
    return ListTile(
      title: Text(logs[index],
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: const Text('Today, 10:45 AM', style: TextStyle(fontSize: 11)),
      trailing:
          const Icon(Icons.chevron_right, size: 16, color: AppColors.border),
    );
  }
}
