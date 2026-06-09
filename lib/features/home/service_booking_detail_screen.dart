import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/service_booking.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../profile/user_provider.dart';

class ServiceBookingDetailScreen extends ConsumerWidget {
  final ServiceBooking booking;

  const ServiceBookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final currentUser = userState.user;

    if (currentUser != null) {
      final isCustomer = currentUser.id == booking.customerId;
      final isTechnician = currentUser.id == booking.techId;
      final isAdmin = currentUser.role.isAdmin;

      if (!isCustomer && !isTechnician && !isAdmin) {
        return Scaffold(
          backgroundColor: AppColors.bgLightAlt,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: const Text('Access Denied'),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'You are not authorized to view this booking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }
    }

    final statusColor = _statusColor(booking.status);
    final statusLabel = booking.status.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgLightAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/main/home');
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Booking Details',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Badge ──
            _buildStatusBadge(statusLabel, statusColor),
            const SizedBox(height: 16),

            // ── Booking Summary Card ──
            _buildSummaryCard(context),
            const SizedBox(height: 16),

            // ── Status Timeline ──
            _buildStatusTimeline(booking.status),
            const SizedBox(height: 16),

            // ── Schedule Info ──
            _buildInfoCard(
              title: 'Schedule',
              icon: Icons.calendar_today_rounded,
              color: AppColors.primaryBlue,
              children: [
                _infoRow('Date', booking.date.isNotEmpty ? booking.date : '—'),
                _infoRow('Time', booking.time.isNotEmpty ? booking.time : '—'),
                if (booking.address != null && booking.address!.isNotEmpty)
                  _infoRow('Address', booking.address!),
              ],
            ),
            const SizedBox(height: 16),

            // ── Payment Info ──
            _buildInfoCard(
              title: 'Payment',
              icon: Icons.receipt_long_rounded,
              color: AppColors.accentOrange,
              children: [
                _infoRow('Package', booking.packageName),
                _infoRow('Total', '₹${booking.totalCost.toStringAsFixed(2)}'),
                _infoRow('Booking ID', '#${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}'),
              ],
            ),
            const SizedBox(height: 24),

            // ── Action Buttons ──
            if (booking.status == 'pending' || booking.status == 'confirmed')
              _buildRescheduleButton(context),
            const SizedBox(height: 12),
            _buildBackButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              booking.vehicleName.toLowerCase().contains('car')
                  ? Icons.directions_car_rounded
                  : Icons.pedal_bike_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.packageName,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.vehicleName} • ${booking.vehiclePlate}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '₹${booking.totalCost.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStatusTimeline(String status) {
    final steps = [
      _TimelineStep('Booking Placed', Icons.check_circle_rounded, true),
      _TimelineStep('Confirmed', Icons.verified_rounded,
          status == 'confirmed' || status == 'in_progress' || status == 'completed'),
      _TimelineStep('In Progress', Icons.build_circle_rounded,
          status == 'in_progress' || status == 'completed'),
      _TimelineStep('Completed', Icons.task_alt_rounded, status == 'completed'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Status', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: step.done ? AppColors.primaryBlue : AppColors.bgLightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.done ? step.icon : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: step.done ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: step.done ? AppColors.primaryBlue.withValues(alpha: 0.3) : AppColors.bgLightGrey,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: step.done ? FontWeight.w600 : FontWeight.w400,
                      color: step.done ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/schedule-appointment');
        },
        icon: const Icon(Icons.calendar_month_rounded, size: 18),
        label: const Text('Reschedule Appointment'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/main/home');
          }
        },
        icon: const Icon(Icons.home_rounded, size: 18),
        label: const Text('Back to Home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ).animate().fadeIn(delay: 450.ms);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successDark;
      case 'in_progress':
      case 'in progress':
        return AppColors.primaryBlue;
      case 'confirmed':
        return AppColors.accentIndigo;
      case 'cancelled':
        return AppColors.dangerRed;
      default:
        return AppColors.accentOrange; // pending
    }
  }
}

class _TimelineStep {
  final String label;
  final IconData icon;
  final bool done;
  _TimelineStep(this.label, this.icon, this.done);
}
