import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';

class TechQRScannerScreen extends ConsumerStatefulWidget {
  const TechQRScannerScreen({super.key});

  @override
  ConsumerState<TechQRScannerScreen> createState() => _TechQRScannerScreenState();
}

class _TechQRScannerScreenState extends ConsumerState<TechQRScannerScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _pendingBookings = [];
  bool _isLoading = true;
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _fetchPendingBookings();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _fetchPendingBookings() async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select()
          .not('status', 'in', '("paid", "completed", "cancelled")')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _pendingBookings = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pending bookings: $e')),
        );
      }
    }
  }

  void _simulateScan(String bookingId, String packageName, String vehicle) {
    HapticFeedback.heavyImpact();

    // Show simulated scan overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Colors.green)
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 500.ms),
            const SizedBox(height: 20),
            const Text(
              'Ticket Scanned Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$packageName - $vehicle',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );

    // Navigate to job details after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        context.pushReplacement('/tech-job-detail', extra: bookingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Scan QR Ticket',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Simulated Scanner Viewport
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.grey.shade900,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera Simulation Container
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                  ),

                  // Scanner Frame Targets
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Laser beam animation
                  AnimatedBuilder(
                    animation: _laserController,
                    builder: (context, child) {
                      final double offset = _laserController.value * 160;
                      return Positioned(
                        top: 30 + offset,
                        child: Container(
                          width: 160,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Framing corners
                  Positioned(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: const BoxDecoration(
                        // Add fancy framing corners
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instruction Text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Align QR code inside the frame to scan ticket',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 2. Active Unpaid bookings list (Scanner simulation helper)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDarkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Text(
                      'ACTIVE SERVICE TICKETS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _pendingBookings.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code_2_rounded,
                                          size: 48,
                                          color: isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade300),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No active pending bookings found',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: _pendingBookings.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                ),
                                itemBuilder: (context, index) {
                                  final b = _pendingBookings[index];
                                  final bookingId = b['id'].toString();
                                  final packageName = b['package_name'] ?? 'Service';
                                  final vehicle = b['vehicle_name'] ?? 'Vehicle';
                                  final cost = b['total_cost'] ?? 0.0;
                                  final method = (b['details'] as Map?)?['method'] ?? 'Cash';
                                  final date = b['booking_date'] ?? '';

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                                      child: const Icon(Icons.directions_car_filled_rounded,
                                          color: AppColors.primaryBlue, size: 20),
                                    ),
                                    title: Text(
                                      '$packageName ($vehicle)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Date: $date | Method: $method',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    trailing: Text(
                                      '₹${cost.toInt()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    onTap: () => _simulateScan(bookingId, packageName, vehicle),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
