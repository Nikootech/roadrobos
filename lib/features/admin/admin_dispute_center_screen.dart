import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class DisputeClaim {
  final String id;
  final String customerName;
  final String customerPhone;
  final String bookingId;
  final String type; // 'Ride' or 'Service'
  final String issueCategory;
  final String description;
  final double amount;
  final String timestamp;
  String status; // 'pending', 'refunded', 'rejected'

  DisputeClaim({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.bookingId,
    required this.type,
    required this.issueCategory,
    required this.description,
    required this.amount,
    required this.timestamp,
    this.status = 'pending',
  });
}

class AdminDisputeCenterScreen extends ConsumerStatefulWidget {
  const AdminDisputeCenterScreen({super.key});

  @override
  ConsumerState<AdminDisputeCenterScreen> createState() =>
      _AdminDisputeCenterScreenState();
}

class _AdminDisputeCenterScreenState
    extends ConsumerState<AdminDisputeCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<DisputeClaim> _claims = [
    DisputeClaim(
      id: 'DISP-8921',
      customerName: 'Rahul Verma',
      customerPhone: '+91 98450 23145',
      bookingId: 'RID-4892A',
      type: 'Ride',
      issueCategory: 'Driver No-Show / Cancelled',
      description:
          'Driver was waiting 2 km away and never arrived at pickup location, but ₹50 cancellation fee was deducted.',
      amount: 50.0,
      timestamp: 'Today, 10:24 AM',
    ),
    DisputeClaim(
      id: 'DISP-8922',
      customerName: 'Priya Sharma',
      customerPhone: '+91 97412 88901',
      bookingId: 'SRV-1029F',
      type: 'Service',
      issueCategory: 'Technician Late by 2 Hours',
      description:
          'Booked doorstep brake service for 9 AM. Tech arrived at 11:30 AM without prior call. Requesting partial labor refund.',
      amount: 250.0,
      timestamp: 'Today, 08:45 AM',
    ),
    DisputeClaim(
      id: 'DISP-8923',
      customerName: 'Anil Kumar',
      customerPhone: '+91 99012 44321',
      bookingId: 'RID-9901C',
      type: 'Ride',
      issueCategory: 'Incorrect Surcharge Charged',
      description:
          'Fare estimated ₹180, but final wallet deduction was ₹320 due to incorrect GPS detour recorded.',
      amount: 140.0,
      timestamp: 'Yesterday, 06:12 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _claims.where((c) => c.status == 'pending').toList();
    final refunded = _claims.where((c) => c.status == 'refunded').toList();
    final rejected = _claims.where((c) => c.status == 'rejected').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispute & Refund Center',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Customer Claims & Chargeback Approvals',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Summary Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryBox('Pending Claims', pending.length.toString(),
                    AppColors.dangerRed, Iconsax.danger),
                const SizedBox(width: 10),
                _buildSummaryBox('Total Refunded', '₹${refunded.fold<double>(0, (s, c) => s + c.amount).toInt()}',
                    AppColors.successGreen, Iconsax.empty_wallet_tick),
                const SizedBox(width: 10),
                _buildSummaryBox('Resolved', '${refunded.length + rejected.length}',
                    AppColors.primaryBlue, Iconsax.verify),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle:
                  GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Pending (${pending.length})'),
                Tab(text: 'Refunded (${refunded.length})'),
                Tab(text: 'Rejected (${rejected.length})'),
              ],
            ),
          ),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClaimsList(pending, isPending: true),
                _buildClaimsList(refunded),
                _buildClaimsList(rejected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimsList(List<DisputeClaim> claims, {bool isPending = false}) {
    if (claims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.shield_tick,
                size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No claims in this category',
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: claims.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final claim = claims[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: claim.type == 'Ride'
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : AppColors.brandGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      claim.type == 'Ride'
                          ? Icons.local_taxi_rounded
                          : Icons.build_rounded,
                      size: 16,
                      color: claim.type == 'Ride'
                          ? AppColors.primaryBlue
                          : AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.issueCategory,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${claim.customerName} (${claim.customerPhone}) · Ref: ${claim.bookingId}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${claim.amount.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dangerRed,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        claim.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    claim.timestamp,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (isPending) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectClaim(claim),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dangerRed,
                          side: const BorderSide(color: AppColors.dangerRed),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Reject Claim'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveRefund(claim),
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 16),
                        label: Text('Refund ₹${claim.amount.toInt()}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 300.ms);
      },
    );
  }

  void _approveRefund(DisputeClaim claim) async {
    await HapticFeedback.heavyImpact();
    if (!mounted) return;
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.successGreen)),
    ));

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.pop(context); // Close loader
      setState(() {
        claim.status = 'refunded';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Refund of ₹${claim.amount.toInt()} credited to ${claim.customerName}\'s wallet!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  void _rejectClaim(DisputeClaim claim) async {
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() {
      claim.status = 'rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claim ${claim.id} marked as Rejected.'),
        backgroundColor: AppColors.dangerRed,
      ),
    );
  }
}
