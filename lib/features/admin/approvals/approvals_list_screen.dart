import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/approval.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import 'approval_provider.dart';
import '../../../shared/widgets/kinetic_motion.dart';
import '../../../shared/widgets/sos_button.dart';

class ApprovalsListScreen extends ConsumerStatefulWidget {
  const ApprovalsListScreen({super.key});

  @override
  ConsumerState<ApprovalsListScreen> createState() =>
      _ApprovalsListScreenState();
}

class _ApprovalsListScreenState extends ConsumerState<ApprovalsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ApprovalStatus? _statusFilter = ApprovalStatus.pending;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006241),
              secondary: Color(0xFF006241),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              titleTextStyle: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showStatusBottomSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
            Text(
              'Filter by Approval Status',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            _buildStatusFilterOption(null, 'All Statuses', Iconsax.category),
            _buildStatusFilterOption(ApprovalStatus.pending, 'Pending', Iconsax.clock,
                dotColor: const Color(0xFFF59E0B)),
            _buildStatusFilterOption(ApprovalStatus.approved, 'Approved', Iconsax.tick_circle,
                dotColor: const Color(0xFF10B981)),
            _buildStatusFilterOption(ApprovalStatus.rejected, 'Rejected', Iconsax.close_circle,
                dotColor: const Color(0xFFF43F5E)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterOption(ApprovalStatus? status, String label, IconData icon,
      {Color? dotColor}) {
    final isSelected = _statusFilter == status;
    return ScaleOnTap(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _statusFilter = status);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF006241) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
            ] else ...[
              Icon(icon, size: 16, color: isSelected ? const Color(0xFF006241) : const Color(0xFF64748B)),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF006241) : const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 18, color: Color(0xFF006241)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approvalsAsync = ref.watch(approvalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 2),
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
              'Maker-Checker Approvals',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Governance & Verification Hub',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Admin Approvals Console',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── SEGMENTED REACT TAB BAR ──────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTabPill(0, 'KYC', Iconsax.user_tag),
                  _buildTabPill(1, 'Refunds', Iconsax.money_recive),
                  _buildTabPill(2, 'Vehicles', Iconsax.car),
                  _buildTabPill(3, 'Payouts', Iconsax.wallet_3),
                ],
              ),
            ),
          ),

          // ── FILTER BAR ──────────────────────────────────────────────────
          _buildFilterBar(),

          // ── TAB VIEWS ───────────────────────────────────────────────────
          Expanded(
            child: approvalsAsync.when(
              data: (approvals) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApprovalList(approvals, ApprovalType.partnerKyc),
                    _buildApprovalList(approvals, ApprovalType.refund),
                    _buildApprovalList(
                        approvals, ApprovalType.vehicleAttachment),
                    _buildApprovalList(approvals, ApprovalType.payout),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF006241)),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(int index, String label, IconData icon) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _tabController.animateTo(index);
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? const Color(0xFF006241)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF006241)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final statusText = _statusFilter == null
        ? 'All Statuses'
        : _statusFilter!.name.substring(0, 1).toUpperCase() +
            _statusFilter!.name.substring(1);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          // Status Trigger Button (Sleek React Modal Sheet)
          Expanded(
            child: ScaleOnTap(
              onTap: _showStatusBottomSheet,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    if (_statusFilter != null) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusFilter == ApprovalStatus.approved
                              ? const Color(0xFF10B981)
                              : _statusFilter == ApprovalStatus.rejected
                                  ? const Color(0xFFF43F5E)
                                  : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Icon(Iconsax.arrow_down_1,
                        size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Date Range Picker
          ScaleOnTap(
            onTap: _selectDateRange,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _dateRange != null
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _dateRange != null
                      ? const Color(0xFF006241)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calendar_1,
                    size: 15,
                    color: _dateRange != null
                        ? const Color(0xFF006241)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _dateRange != null ? 'Filtered' : 'Date',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _dateRange != null
                          ? const Color(0xFF006241)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_dateRange != null) ...[
            const SizedBox(width: 6),
            ScaleOnTap(
              onTap: () => setState(() => _dateRange = null),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Color(0xFFE11D48)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovalList(
      List<ApprovalRequest> approvals, ApprovalType type) {
    final filtered = approvals.where((req) {
      if (req.type != type) return false;
      if (_statusFilter != null && req.status != _statusFilter) return false;
      if (_dateRange != null) {
        if (req.createdAt.isBefore(_dateRange!.start) ||
            req.createdAt
                .isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Iconsax.task,
                  size: 28, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14),
            Text(
              'No requests found',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All items in this queue have been verified.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final request = filtered[index];
        return _buildApprovalCard(request);
      },
    );
  }

  Widget _buildApprovalCard(ApprovalRequest request) {
    final requesterName = _getRequesterName(request);
    final details = _getDetails(request);
    final submittedDate = _formatDate(request.createdAt);

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScaleOnTap(
        onTap: () => context.push('/admin-approval-detail', extra: request),
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
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: typeGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(typeIcon, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requesterName,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          details,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.clock,
                          size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted: $submittedDate',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Review',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF006241),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF006241),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.04, end: 0);
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

  String _getRequesterName(ApprovalRequest request) {
    final payload = request.payload;
    return payload['applicant_name'] ??
        payload['requester_name'] ??
        payload['user_name'] ??
        payload['name'] ??
        'User (${request.makerId.length > 8 ? request.makerId.substring(0, 8) : request.makerId})';
  }

  String _getDetails(ApprovalRequest request) {
    final payload = request.payload;
    switch (request.type) {
      case ApprovalType.partnerKyc:
        return 'KYC Details: ${payload['applicant_role'] ?? 'Partner'}';
      case ApprovalType.refund:
        final amount = payload['amount'] ?? 'N/A';
        final reason = payload['reason'] ?? 'None specified';
        return 'Refund of ₹$amount for $reason';
      case ApprovalType.vehicleAttachment:
        final name =
            payload['vehicle_name'] ?? payload['vehicle_model'] ?? 'Vehicle';
        final plate =
            payload['vehicle_number'] ?? payload['plate_number'] ?? '';
        return 'Vehicle: $name ($plate)';
      case ApprovalType.payout:
        final amount = payload['amount'] ?? 'N/A';
        return 'Withdrawal: ₹$amount';
      default:
        return 'Details: ${payload.toString()}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
