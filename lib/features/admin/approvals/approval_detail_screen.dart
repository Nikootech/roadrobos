import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/approval.dart';
import '../../../core/models/user_role.dart';
import '../../../core/providers/rbac_provider.dart';
import '../../../shared/widgets/kinetic_motion.dart';
import '../../../shared/widgets/sos_button.dart';
import 'approval_provider.dart';

class ApprovalDetailScreen extends ConsumerStatefulWidget {
  final ApprovalRequest request;

  const ApprovalDetailScreen({super.key, required this.request});

  @override
  ConsumerState<ApprovalDetailScreen> createState() =>
      _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends ConsumerState<ApprovalDetailScreen> {
  bool _isLoading = false;
  late ApprovalRequest _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
  }

  String get _permissionKey {
    switch (widget.request.type) {
      case ApprovalType.partnerKyc:
        return 'approve_kyc';
      case ApprovalType.refund:
        return 'approve_refunds';
      case ApprovalType.vehicleAttachment:
        return 'approve_vehicles';
      case ApprovalType.payout:
        return 'approve_withdrawals';
      default:
        return 'admin_access';
    }
  }

  bool get _hasActionPermission {
    return ref.watch(hasPermissionProvider(_permissionKey)) ||
        ref.watch(hasPermissionProvider('admin_access'));
  }

  void _handleApprove() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    await HapticFeedback.heavyImpact();

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.tick_circle,
                  color: Color(0xFF006241), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Authorize Request?',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'You are authorizing this ${widget.request.type.displayName.toLowerCase()} request. This action will be immutably recorded in the Maker-Checker governance audit trail.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ),
          ScaleOnTap(
            onTap: () => Navigator.pop(ctx, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006241), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Confirm & Approve',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(approvalProvider.notifier).approve(widget.request.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '✅ Request approved and authorized successfully!',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF006241),
          behavior: SnackBarBehavior.floating,
        ),
      );
      router.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to approve: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleReject() {
    HapticFeedback.lightImpact();
    final TextEditingController reasonController = TextEditingController();
    String? selectedPresetReason;

    final presetReasons = [
      'Invalid / expired documents',
      'Policy criteria not met',
      'Information mismatch',
      'Duplicate request submission',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.close_circle,
                        color: Color(0xFFE11D48), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Reject Approval Request',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Please select or describe the reason for rejection.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),

              // Preset Reason Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetReasons.map((reason) {
                  final isSelected = selectedPresetReason == reason;
                  return ScaleOnTap(
                    onTap: () {
                      setSheetState(() {
                        selectedPresetReason = reason;
                        reasonController.text = reason;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFF1F2)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE11D48)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        reason,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Additional rejection comments...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE11D48)),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ScaleOnTap(
                      onTap: () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please provide a rejection reason')),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);

                        Navigator.pop(sheetContext);
                        setState(() => _isLoading = true);
                        try {
                          await ref
                              .read(approvalProvider.notifier)
                              .reject(widget.request.id, reason);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Request rejected successfully',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFFE11D48),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          router.pop();
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to reject: $e',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                              backgroundColor: const Color(0xFFE11D48),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Confirm Rejection',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showZoomedImage(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(color: Colors.white);
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCorrectionSheet() {
    HapticFeedback.lightImpact();
    final request = _currentRequest;
    final payload = request.payload;

    final targetUserId = request.entityId ?? request.makerId;
    final initialName = payload['applicant_name'] ??
        payload['requester_name'] ??
        payload['user_name'] ??
        payload['name'] ??
        '';
    final initialPhone = payload['phone'] ??
        payload['mobile'] ??
        payload['phone_number'] ??
        '';
    final initialEmail = payload['email'] ?? '';
    final initialRoleStr = payload['role'] ?? payload['applicant_role'] ?? '';

    UserRole selectedRole = UserRole.values.firstWhere(
      (r) =>
          r.name.toLowerCase() == initialRoleStr.toString().toLowerCase() ||
          r.roleLabel.toLowerCase() ==
              initialRoleStr.toString().toLowerCase() ||
          r.name.toLowerCase() ==
              initialRoleStr.toString().toLowerCase().replaceAll(' ', '_'),
      orElse: () => request.type == ApprovalType.partnerKyc
          ? UserRole.driver
          : UserRole.customer,
    );

    bool isApproved = request.status == ApprovalStatus.approved;

    final nameController = TextEditingController(text: initialName);
    final phoneController = TextEditingController(text: initialPhone);
    final emailController = TextEditingController(text: initialEmail);
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.edit_2,
                          color: Color(0xFF006241), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit & Correct User Details',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Update user profile details, role, and approval status with audit trail.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),

                // Name field
                Text('Full Name',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.user, size: 16),
                    hintText: 'Enter full name',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF006241)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone & Email Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone Number',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Iconsax.call, size: 16),
                              hintText: '+91 98765 43210',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFF006241)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Address',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Iconsax.sms, size: 16),
                              hintText: 'user@roadrobos.com',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFF006241)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Role Dropdown Selector
                Text('Assigned User Role',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: selectedRole,
                      isExpanded: true,
                      icon: const Icon(Iconsax.arrow_down_1, size: 16),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(
                            role.roleLabel,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newR) {
                        if (newR != null) {
                          setSheetState(() => selectedRole = newR);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Approval Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Approval Status',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155))),
                        Text(
                            isApproved
                                ? 'User is verified and active'
                                : 'Awaiting verification / pending',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: const Color(0xFF64748B))),
                      ],
                    ),
                    Switch.adaptive(
                      value: isApproved,
                      activeTrackColor: const Color(0xFF006241),
                      onChanged: (val) {
                        setSheetState(() => isApproved = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Correction Notes
                Text('Admin Correction Notes (Optional)',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                      fontSize: 12.5, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Corrected name spelling & assigned Driver role',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF006241)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info banner about re-login enforcement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.info_circle,
                          size: 16, color: Color(0xFF006241)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saving changes will update the user profile, refresh the maker payload, dispatch an in-app role change notification, and require the user to re-login.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF006241),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save & Cancel Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        child: Text('Cancel',
                            style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ScaleOnTap(
                        onTap: () async {
                          final name = nameController.text.trim();
                          final phone = phoneController.text.trim();
                          final email = emailController.text.trim();
                          final notes = notesController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              const SnackBar(
                                  content: Text('Name cannot be empty')),
                            );
                            return;
                          }

                          Navigator.pop(sheetCtx);
                          setState(() => _isLoading = true);

                          try {
                            await ref
                                .read(approvalProvider.notifier)
                                .updateCorrection(
                                  approvalId: request.id,
                                  targetUserId: targetUserId,
                                  name: name,
                                  phone: phone,
                                  email: email.isNotEmpty ? email : null,
                                  role: selectedRole,
                                  isApproved: isApproved,
                                  currentPayload: payload,
                                  correctionNotes:
                                      notes.isNotEmpty ? notes : null,
                                );

                            // Update local state copy
                            final updatedPayload =
                                Map<String, dynamic>.from(payload);
                            updatedPayload['applicant_name'] = name;
                            updatedPayload['user_name'] = name;
                            updatedPayload['applicant_role'] =
                                selectedRole.roleLabel;
                            updatedPayload['role'] = selectedRole.name;
                            updatedPayload['phone'] = phone;
                            if (email.isNotEmpty) {
                              updatedPayload['email'] = email;
                            }
                            if (notes.isNotEmpty) {
                              updatedPayload['admin_correction_notes'] = notes;
                            }
                            updatedPayload['last_corrected_at'] =
                                DateTime.now().toIso8601String();

                            if (mounted) {
                              setState(() {
                                _currentRequest = request.copyWith(
                                  payload: updatedPayload,
                                  status: isApproved
                                      ? ApprovalStatus.approved
                                      : request.status,
                                );
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ User profile & role updated! In-app notification sent.',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  backgroundColor: const Color(0xFF006241),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update: $e'),
                                  backgroundColor: const Color(0xFFE11D48),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF006241), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF006241)
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Save & Apply Updates',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _currentRequest;
    final submittedDate =
        '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}';

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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              '${request.type.displayName} Review',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Maker-Checker Verification',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_hasActionPermission)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ScaleOnTap(
                onTap: _showEditCorrectionSheet,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: const Center(
                    child: Icon(Iconsax.edit_2,
                        size: 16, color: Color(0xFF006241)),
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Approval Request Review',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HERO REQUEST & REQUESTER CARD ───────────────────────────
                _buildHeroCard(request, submittedDate),

                const SizedBox(height: 16),

                // ── SPECIFIC DETAILS (REFUND, KYC, VEHICLE, PAYOUT) ─────────
                _buildSpecificDetails(request),

                const SizedBox(height: 16),

                // ── MAKER-CHECKER AUDIT TRAIL TIMELINE ──────────────────────
                _buildAuditTrailCard(request, submittedDate),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF006241)),
              ),
            ),
        ],
      ),
      bottomNavigationBar:
          request.status == ApprovalStatus.pending && _hasActionPermission
              ? Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ScaleOnTap(
                          onTap: _isLoading ? () {} : _handleReject,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFFECDD3), width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.close_circle,
                                    size: 18, color: Color(0xFFE11D48)),
                                const SizedBox(width: 8),
                                Text(
                                  'Reject Request',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScaleOnTap(
                          onTap: _isLoading ? () {} : _handleApprove,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF006241), Color(0xFF10B981)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF006241)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.tick_circle,
                                    size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Approve & Authorize',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
    );
  }

  Widget _buildHeroCard(ApprovalRequest request, String submittedDate) {
    final payload = request.payload;
    final requesterName = payload['applicant_name'] ??
        payload['requester_name'] ??
        payload['user_name'] ??
        payload['name'] ??
        'User (${request.makerId.length > 8 ? request.makerId.substring(0, 8) : request.makerId})';

    IconData typeIcon = Iconsax.user_tag;
    List<Color> typeGradient = [
      const Color(0xFF006241),
      const Color(0xFF10B981)
    ];

    if (request.type == ApprovalType.refund) {
      typeIcon = Iconsax.money_recive;
      typeGradient = [const Color(0xFFD97706), const Color(0xFFF59E0B)];
    } else if (request.type == ApprovalType.vehicleAttachment) {
      typeIcon = Iconsax.car;
      typeGradient = [const Color(0xFF0284C7), const Color(0xFF38BDF8)];
    } else if (request.type == ApprovalType.payout) {
      typeIcon = Iconsax.wallet_3;
      typeGradient = [const Color(0xFF0D9488), const Color(0xFF14B8A6)];
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: typeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: typeGradient.first.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(typeIcon, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Request ID: ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.id.length > 10
                                ? request.id.substring(0, 10).toUpperCase()
                                : request.id.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.type.displayName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(request.status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // Requester Info Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF2F6)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF006241).withValues(alpha: 0.1),
                  child: Text(
                    requesterName.isNotEmpty
                        ? requesterName[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF006241),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requesterName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Role: ${payload['applicant_role'] ?? payload['role'] ?? 'Partner'} • Submitted: $submittedDate',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                ScaleOnTap(
                  onTap: _showEditCorrectionSheet,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.edit_2,
                            size: 12, color: Color(0xFF006241)),
                        const SizedBox(width: 4),
                        Text(
                          'EDIT',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF006241),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (request.status == ApprovalStatus.rejected &&
              request.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle,
                      size: 16, color: Color(0xFFE11D48)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection Reason: ${request.rejectionReason}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecificDetails(ApprovalRequest request) {
    final payload = request.payload;

    switch (request.type) {
      case ApprovalType.partnerKyc:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KYC Document Reviews',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            if (payload.containsKey('document_url'))
              _buildDocumentCard(
                  'Main Identity Proof', payload['document_url']),
            if (payload.containsKey('license_front'))
              _buildDocumentCard(
                  'Driving License Front', payload['license_front']),
            if (payload.containsKey('license_back'))
              _buildDocumentCard(
                  'Driving License Back', payload['license_back']),
            if (payload.containsKey('rc_document'))
              _buildDocumentCard(
                  'Registration Certificate (RC)', payload['rc_document']),
          ],
        );

      case ApprovalType.refund:
        final refundAmount = payload['amount']?.toString() ?? '50';
        final originalPrice =
            payload['booking_amount'] ?? payload['original_amount'] ?? 'N/A';
        final bookingId = request.entityId ?? payload['booking_id'] ?? 'RID-4892A';
        final reason = payload['reason'] ?? 'Driver no-show cancellation fee reversal';

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
              Text(
                'Booking & Refund Details',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),

              // Highlighted Amount Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refund Amount',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF006241),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹$refundAmount',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF006241),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Original: ₹$originalPrice',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              _buildDetailItem(
                  'Booking Reference', bookingId, Iconsax.ticket),
              const SizedBox(height: 10),
              _buildDetailItem(
                  'Refund Reason', reason, Iconsax.message_text_1),
            ],
          ),
        );

      case ApprovalType.vehicleAttachment:
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
              Text(
                'Vehicle Details',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              _buildDetailItem('Vehicle Model',
                  payload['vehicle_model'] ?? payload['vehicle_name'] ?? 'Tata Nexon EV', Iconsax.car),
              const SizedBox(height: 10),
              _buildDetailItem('Plate Number',
                  payload['vehicle_number'] ?? payload['plate_number'] ?? 'KA 01 AB 1234', Iconsax.routing_2),
              if (payload.containsKey('document_url')) ...[
                const SizedBox(height: 14),
                _buildDocumentCard(
                    'Vehicle RC Document', payload['document_url']),
              ],
            ],
          ),
        );

      case ApprovalType.payout:
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
              Text(
                'Payout & Banking Details',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              _buildDetailItem(
                  'Withdrawal Amount', '₹${payload['amount'] ?? 'N/A'}', Iconsax.wallet_3,
                  isHighContrast: true),
              const SizedBox(height: 10),
              _buildDetailItem(
                  'Account Holder', payload['account_name'] ?? 'Partner', Iconsax.user),
              const SizedBox(height: 10),
              _buildDetailItem(
                  'Bank Name', payload['bank_name'] ?? 'HDFC Bank', Iconsax.bank),
              const SizedBox(height: 10),
              _buildDetailItem('Account Number',
                  payload['account_number'] ?? '•••• •••• 8842', Iconsax.card),
              const SizedBox(height: 10),
              _buildDetailItem(
                  'IFSC Code', payload['ifsc_code'] ?? 'HDFC0001234', Iconsax.code),
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payload Details',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                payload.toString(),
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildAuditTrailCard(ApprovalRequest request, String submittedDate) {
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
              const Icon(Iconsax.shield_security,
                  size: 18, color: Color(0xFF006241)),
              const SizedBox(width: 8),
              Text(
                'Governance & Audit Trail',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildAuditStep(
            '1. Request Submitted (Maker)',
            'Generated by Maker at $submittedDate',
            isComplete: true,
          ),
          _buildAuditStep(
            '2. System Validation',
            'Policy and security rule checks passed',
            isComplete: true,
          ),
          if (request.payload.containsKey('last_corrected_at') ||
              request.payload.containsKey('admin_correction_notes'))
            _buildAuditStep(
              '3. Admin Correction Applied',
              request.payload['admin_correction_notes'] != null &&
                      request.payload['admin_correction_notes'].toString().isNotEmpty
                  ? 'Notes: ${request.payload['admin_correction_notes']}'
                  : 'Role and profile details corrected by Administrator',
              isComplete: true,
            ),
          _buildAuditStep(
            request.payload.containsKey('last_corrected_at') ||
                    request.payload.containsKey('admin_correction_notes')
                ? '4. Checker Authorization'
                : '3. Checker Authorization',
            request.status == ApprovalStatus.pending
                ? 'Awaiting Checker dual-authorization'
                : request.status == ApprovalStatus.approved
                    ? 'Authorized and finalized'
                    : 'Rejected by Checker',
            isComplete: request.status != ApprovalStatus.pending,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAuditStep(String title, String subtitle,
      {required bool isComplete, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isComplete
                    ? const Color(0xFF006241)
                    : const Color(0xFFE2E8F0),
              ),
              child: Center(
                child: Icon(
                  isComplete ? Icons.check_rounded : Icons.circle,
                  size: 12,
                  color: isComplete ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isComplete
                    ? const Color(0xFF006241)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon,
      {bool isHighContrast = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isHighContrast ? FontWeight.w800 : FontWeight.w600,
                    color: isHighContrast
                        ? const Color(0xFF006241)
                        : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              ScaleOnTap(
                onTap: () => _showZoomedImage(imageUrl, title),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.maximize_4,
                          size: 12, color: Color(0xFF006241)),
                      const SizedBox(width: 4),
                      Text(
                        'Inspect',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF006241),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showZoomedImage(imageUrl, title),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFF006241)),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 170,
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  child: const Center(
                    child: Icon(Iconsax.image,
                        size: 40, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ApprovalStatus status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    Color dot = const Color(0xFFF59E0B);

    if (status == ApprovalStatus.approved) {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF006241);
      dot = const Color(0xFF10B981);
    } else if (status == ApprovalStatus.rejected) {
      bg = const Color(0xFFFFF1F2);
      fg = const Color(0xFFE11D48);
      dot = const Color(0xFFF43F5E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.name.toUpperCase(),
            style: GoogleFonts.inter(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
