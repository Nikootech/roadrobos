import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/approval.dart';
import 'approval_provider.dart';

class ApprovalsListScreen extends ConsumerStatefulWidget {
  const ApprovalsListScreen({super.key});

  @override
  ConsumerState<ApprovalsListScreen> createState() => _ApprovalsListScreenState();
}

class _ApprovalsListScreenState extends ConsumerState<ApprovalsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ApprovalStatus? _statusFilter = ApprovalStatus.pending;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandGreen,
              onSurface: AppColors.textPrimary,
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

  @override
  Widget build(BuildContext context) {
    final approvalsAsync = ref.watch(approvalProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Maker-Checker Approvals',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.brandGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'KYC'),
            Tab(text: 'Refunds'),
            Tab(text: 'Vehicles'),
            Tab(text: 'Withdrawals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),

          // Tab views
          Expanded(
            child: approvalsAsync.when(
              data: (approvals) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApprovalList(approvals, ApprovalType.partnerKyc),
                    _buildApprovalList(approvals, ApprovalType.refund),
                    _buildApprovalList(approvals, ApprovalType.vehicleAttachment),
                    _buildApprovalList(approvals, ApprovalType.payout),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Status Dropdown Filter
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ApprovalStatus?>(
                  value: _statusFilter,
                  isExpanded: true,
                  hint: const Text('Status'),
                  items: [
                    const DropdownMenuItem<ApprovalStatus?>(
                      child: Text('All Statuses'),
                    ),
                    ...ApprovalStatus.values.map((status) {
                      return DropdownMenuItem<ApprovalStatus?>(
                        value: status,
                        child: Text(
                          status.name.substring(0, 1).toUpperCase() + status.name.substring(1),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _statusFilter = val;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Date Range Picker
          IconButton(
            onPressed: _selectDateRange,
            icon: Icon(
              Icons.date_range_rounded,
              color: _dateRange != null ? AppColors.brandGreen : AppColors.textSecondary,
            ),
          ),
          if (_dateRange != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _dateRange = null;
                });
              },
              icon: const Icon(Icons.clear_rounded, color: AppColors.dangerRed),
            ),
        ],
      ),
    );
  }

  Widget _buildApprovalList(List<ApprovalRequest> approvals, ApprovalType type) {
    // Filter list
    final filtered = approvals.where((req) {
      if (req.type != type) return false;
      if (_statusFilter != null && req.status != _statusFilter) return false;
      if (_dateRange != null) {
        if (req.createdAt.isBefore(_dateRange!.start) ||
            req.createdAt.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
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
            Icon(Icons.inbox_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No matching requests found',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ).animate().fadeIn().scale(),
      );
    }

    return ListView.builder(
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/admin-approval-detail', extra: request),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      requesterName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                details,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: $submittedDate',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildStatusBadge(ApprovalStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case ApprovalStatus.approved:
        bg = AppColors.successGreen.withValues(alpha: 0.15);
        fg = AppColors.successDark;
        break;
      case ApprovalStatus.rejected:
        bg = AppColors.dangerRed.withValues(alpha: 0.15);
        fg = AppColors.dangerRed;
        break;
      case ApprovalStatus.pending:
        bg = AppColors.warningAmber.withValues(alpha: 0.15);
        fg = AppColors.accentAmber;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
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
        final name = payload['vehicle_name'] ?? payload['vehicle_model'] ?? 'Vehicle';
        final plate = payload['vehicle_number'] ?? payload['plate_number'] ?? '';
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
