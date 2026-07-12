import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/service_booking.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../profile/user_provider.dart';

class ServiceBookingDetailScreen extends ConsumerWidget {
  final ServiceBooking? booking;
  final String? bookingId;

  const ServiceBookingDetailScreen({
    super.key,
    this.booking,
    this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final currentUser = userState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveId = booking?.id ?? bookingId ?? '';

    return StreamBuilder<ServiceBooking>(
      stream: ref.watch(serviceBookingRepositoryProvider).streamBookingStatus(effectiveId),
      initialData: booking,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Booking details not found')),
          );
        }
        final b = snapshot.data!;

        if (currentUser != null) {
          final isCustomer = currentUser.id == b.customerId;
          final isTechnician = currentUser.id == b.techId;
          final isAdmin = currentUser.role.isAdmin;

          if (!isCustomer && !isTechnician && !isAdmin) {
            return Scaffold(
              backgroundColor: AppColors.bgLightAlt,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: AppColors.textPrimary),
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
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }
        }

        final statusColor = _statusColor(b.status);
        final statusLabel = b.status.toUpperCase();

        final method = b.details['method'] ?? 'Cash';
        final isCashPending = method == 'Cash' && b.status != 'paid' && b.status != 'completed';

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
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppColors.textPrimary),
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
                _buildSummaryCard(context, b),
                const SizedBox(height: 16),

                // ── Status Timeline ──
                _buildStatusTimeline(b.status),
                const SizedBox(height: 16),

                // ── Schedule Info ──
                _buildInfoCard(
                  title: 'Schedule',
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.primaryBlue,
                  children: [
                    _infoRow('Date', b.date.isNotEmpty ? b.date : '—'),
                    _infoRow('Time', b.time.isNotEmpty ? b.time : '—'),
                    if (b.address != null && b.address!.isNotEmpty)
                      _infoRow('Address', b.address!),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Payment Info ──
                _buildInfoCard(
                  title: 'Payment',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.accentOrange,
                  children: [
                    _infoRow('Package', b.packageName),
                    _infoRow('Method', method),
                    _infoRow('Total', '₹${b.totalCost.toStringAsFixed(2)}'),
                    _infoRow('Booking ID',
                        '#${b.id.length > 8 ? b.id.substring(0, 8).toUpperCase() : b.id.toUpperCase()}'),
                  ],
                ),

                if (isCashPending) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded, color: AppColors.primaryBlue, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Payment Ticket QR',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CustomPaint(
                            size: const Size(140, 140),
                            painter: QRPainter(isDark: isDark),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Present this QR code to the service center employee to pay cash and check in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // ── Action Buttons ──
                if (b.status == 'pending' || b.status == 'confirmed')
                  _buildRescheduleButton(context),
                const SizedBox(height: 12),
                _buildBackButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
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
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSummaryCard(BuildContext context, ServiceBooking b) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8)),
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
              b.vehicleName.toLowerCase().contains('car')
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
                  b.packageName,
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${b.vehicleName} • ${b.vehiclePlate}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '₹${b.totalCost.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStatusTimeline(String status) {
    final steps = [
      _TimelineStep('Booking Placed', Icons.check_circle_rounded, true),
      _TimelineStep(
          'Confirmed',
          Icons.verified_rounded,
          status == 'confirmed' ||
              status == 'in_progress' ||
              status == 'completed'),
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Status',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
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
                        color: step.done
                            ? AppColors.primaryBlue
                            : AppColors.bgLightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.done
                            ? step.icon
                            : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: step.done ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: step.done
                            ? AppColors.primaryBlue.withValues(alpha: 0.3)
                            : AppColors.bgLightGrey,
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
                      color: step.done
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle:
              GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
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
      case 'refunded':
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

class QRPainter extends CustomPainter {
  final bool isDark;

  QRPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;

    // Outer framing corners
    const double frameWidth = 35;
    const double strokeWidth = 5;
    final framePaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Top-Left Frame
    canvas.drawRect(Rect.fromLTWH(0, 0, frameWidth, frameWidth), framePaint);
    canvas.drawRect(Rect.fromLTWH(frameWidth/4, frameWidth/4, frameWidth/2, frameWidth/2), paint);

    // Top-Right Frame
    canvas.drawRect(Rect.fromLTWH(size.width - frameWidth, 0, frameWidth, frameWidth), framePaint);
    canvas.drawRect(Rect.fromLTWH(size.width - frameWidth + frameWidth/4, frameWidth/4, frameWidth/2, frameWidth/2), paint);

    // Bottom-Left Frame
    canvas.drawRect(Rect.fromLTWH(0, size.height - frameWidth, frameWidth, frameWidth), framePaint);
    canvas.drawRect(Rect.fromLTWH(frameWidth/4, size.height - frameWidth + frameWidth/4, frameWidth/2, frameWidth/2), paint);

    // Drawing some mock pixels
    final mockPixels = [
      // row 1
      Offset(size.width * 0.4, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.1),
      // row 2
      Offset(size.width * 0.45, size.height * 0.2),
      Offset(size.width * 0.55, size.height * 0.2),
      // row 3
      Offset(size.width * 0.1, size.height * 0.4),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.4),
      // row 4
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.5),
      // row 5
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.6),
      Offset(size.width * 0.9, size.height * 0.6),
      // row 6
      Offset(size.width * 0.45, size.height * 0.7),
      Offset(size.width * 0.55, size.height * 0.7),
      Offset(size.width * 0.65, size.height * 0.7),
      // row 7
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.85, size.height * 0.9),
    ];

    for (var offset in mockPixels) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: offset, width: 10, height: 10),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
