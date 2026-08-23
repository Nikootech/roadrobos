import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ServiceBookingConfirmationScreen extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String vehicleName;
  final String vehiclePlate;
  final String date;
  final String time;
  final String address;
  final double totalCost;

  const ServiceBookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.date,
    required this.time,
    required this.address,
    required this.totalCost,
  });

  @override
  State<ServiceBookingConfirmationScreen> createState() =>
      _ServiceBookingConfirmationScreenState();
}

class _ServiceBookingConfirmationScreenState
    extends State<ServiceBookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildSuccessAnimation(),
                    const SizedBox(height: 32),
                    _buildBookingCard(),
                    const SizedBox(height: 20),
                    _buildDetailsSection(),
                    const SizedBox(height: 20),
                    _buildAmountCard(),
                    const SizedBox(height: 20),
                    _buildStatusTimeline(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 120 + (_pulseController.value * 8),
              height: 120 + (_pulseController.value * 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successGreen
                    .withValues(alpha: 0.05 + _pulseController.value * 0.05),
              ),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.successGreen, AppColors.brandGreenLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.successGreen.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 52),
          ),
        ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 20),
        Text(
          'Booking Confirmed! 🎉',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          'Your service has been scheduled successfully.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildBookingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandGreen.withValues(alpha: 0.3),
            AppColors.brandGreenMid.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.brandGreenLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandGreenLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.brandGreenLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking ID',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 4),
                Text(
                  '#${widget.bookingId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.bookingId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Booking ID copied!'),
                    duration: Duration(seconds: 2)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded,
                  color: Colors.white60, size: 18),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.build_circle_rounded,
            iconColor: const Color(0xFF60A5FA),
            label: 'Service',
            value: widget.serviceName,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.two_wheeler_rounded,
            iconColor: const Color(0xFFFBBF24),
            label: 'Vehicle',
            value: '${widget.vehicleName} • ${widget.vehiclePlate}',
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFFA78BFA),
            label: 'Date',
            value: widget.date,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFF97316),
            label: 'Time Slot',
            value: widget.time,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFF43F5E),
            label: 'Address',
            value: widget.address.isEmpty ? 'Doorstep Service' : widget.address,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white38,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.87),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: Colors.white.withValues(alpha: 0.06), height: 1);

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F2040)],
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount Paid',
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: Colors.white54)),
                const SizedBox(height: 6),
                Text('₹${widget.totalCost.toInt()}',
                    style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('via RoadRobos Wallet',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppColors.brandGreenLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.successGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.successGreen, size: 16),
                const SizedBox(width: 6),
                Text('PAID',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatusTimeline() {
    final steps = [
      {'label': 'Booking Confirmed', 'done': true},
      {'label': 'Technician Assigned', 'done': false},
      {'label': 'Service In Progress', 'done': false},
      {'label': 'Service Completed', 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Progress',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 0.5)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isDone = step['done'] as bool;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.successGreen
                            : Colors.white.withValues(alpha: 0.08),
                        border: isDone
                            ? null
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isDone ? Colors.white : Colors.white24,
                        size: 16,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: isDone
                            ? AppColors.successGreen.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    step['label'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDone
                          ? Colors.white.withValues(alpha: 0.87)
                          : Colors.white30,
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.go('/live-service-status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.track_changes_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text('Track My Service',
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.go('/main/home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Back to Home',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
