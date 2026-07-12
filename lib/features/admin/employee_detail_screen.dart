import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../navigation/nav_helpers.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  late bool _isApproved;
  bool _isLoading = false;
  String? _selectedAdminRole;
  late String _initialRole;

  final List<String> _adminRoles = [
    'admin',
    'ops_head',
    'city_manager',
    'area_manager',
    'finance_manager',
    'support_manager',
    'marketing_admin',
    'auditor',
    'analyst',
    'super_admin',
    'founder_admin',
  ];

  String _formatRole(String r) {
    if (r == 'admin') return 'Select specific role...';
    return r
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _isApproved = widget.employee['is_approved'] ?? false;
    _initialRole = widget.employee['role'] ?? 'technician';
    if (_adminRoles.contains(_initialRole)) {
      _selectedAdminRole = _initialRole;
    }
  }

  Future<void> _toggleApproval() async {
    if (!_isApproved &&
        _adminRoles.contains(_initialRole) &&
        _selectedAdminRole == 'admin') {
      NavHelpers.showError(
          context, 'Please select a specific role before approving.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = widget.employee['id'] ?? '';
      String? roleToUpdate;
      if (!_isApproved &&
          _selectedAdminRole != null &&
          _selectedAdminRole != 'admin') {
        roleToUpdate = _selectedAdminRole;
      }

      await ref
          .read(adminOpsRepositoryProvider)
          .updateEmployeeApproval(uid, !_isApproved, role: roleToUpdate);
      if (!mounted) return;
      setState(() {
        _isApproved = !_isApproved;
        _isLoading = false;
      });
      NavHelpers.showSuccess(
        context,
        _isApproved
            ? 'Employee approved and activated!'
            : 'Employee access suspended!',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Operation failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.employee['name'] ?? 'Unknown Employee';
    final String email = widget.employee['email'] ?? 'No email';
    final String phone = widget.employee['phone'] ?? 'No phone';
    final String role = widget.employee['role'] ?? 'technician';
    final String profilePic = widget.employee['profile_pic'] ?? '';
    final String createdAt = widget.employee['created_at'] != null
        ? widget.employee['created_at'].toString().split('T')[0]
        : 'Unknown Date';

    final displayName = role.toUpperCase().replaceAll('_', ' ');

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context
              .pop(true), // returning true indicates potential refresh needed
        ),
        title: Text(
          'User Details',
          style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.1),
                    backgroundImage:
                        profilePic.isNotEmpty && profilePic.startsWith('http')
                            ? NetworkImage(profilePic)
                            : null,
                    child: profilePic.isEmpty || !profilePic.startsWith('http')
                        ? Text(name.isNotEmpty ? name[0] : '?',
                            style: const TextStyle(
                                fontSize: 32,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(name,
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.bgLightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.email_outlined, 'Email', email),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.phone_outlined, 'Phone', phone),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      Icons.calendar_today_outlined, 'Joined', createdAt),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    _isApproved
                        ? Icons.check_circle_outline
                        : Icons.pending_actions,
                    'Status',
                    _isApproved ? 'Active' : 'Pending Approval',
                    valueColor: _isApproved
                        ? AppColors.successGreen
                        : AppColors.warningAmber,
                  ),
                  if (_adminRoles.contains(_initialRole) && !_isApproved) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 16),
                        const Text('Assign Role',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAdminRole,
                              items: _adminRoles
                                  .map((r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(_formatRole(r),
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedAdminRole = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (_isLoading)
              const CircularProgressIndicator(color: AppColors.primaryBlue)
            else
              Row(
                children: [
                  if (_isApproved)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleApproval,
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Suspend Access'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleApproval,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Approve Access'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Text(label,
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
