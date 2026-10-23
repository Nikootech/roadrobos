import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../providers/connectivity_provider.dart';
import '../profile/user_provider.dart';
import 'user_bookings_provider.dart';
import 'package:intl/intl.dart';

/// Rapido-Style Bookings Screen
/// Features Rapido category segment pills, signature Route Stepper visualizer,
/// instant "Book Again" rebook CTA, and Rapido zero-state experience.
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  // Category tabs: 'All', 'Rides', 'Rentals', 'Services'
  String _selectedCategory = 'All';
  // Status filter: 'All', 'Completed', 'Active', 'Cancelled'
  String _selectedStatus = 'All';
  // Tracks whether the cleanup snackbar has already been shown this session
  bool _cleanupNotified = false;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    // Watch cleanup provider — auto-cancels stale pending rentals & unassigned rides
    final cleanupAsync = ref.watch(expiredPendingCleanupProvider);
    cleanupAsync.whenData((result) {
      if (!_cleanupNotified && result.hasActivity && mounted) {
        _cleanupNotified = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showExpiredCancelledBanner(context, result);
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'My Bookings',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Cancelled & Expired',
            onPressed: () => _confirmClearCancelled(context),
            icon: const Icon(
              Iconsax.trash,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(userBookingsProvider);
            },
            icon: const Icon(
              Iconsax.refresh,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (ref.watch(connectivityProvider).value == true)
            Container(
              width: double.infinity,
              color: const Color(0xFFFEF3C7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Iconsax.wifi_square,
                      size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Text(
                    'Viewing offline data',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // Rapido Category Segment Selector
          _buildCategoryPills(),

          // Status Filter Strip (Compact)
          _buildStatusChips(),

          // Bookings List or Rapido Empty State
          Expanded(
            child: bookingsAsync.when(
              data: (allBookings) {
                final bookings = _filterBookings(allBookings);

                if (bookings.isEmpty) {
                  return _buildRapidoEmptyState(context);
                }

                return RefreshIndicator(
                  color: const Color(0xFF006241),
                  onRefresh: () async {
                    ref.invalidate(userBookingsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _buildRapidoRideCard(booking, index);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF006241)),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.warning_2,
                          size: 40, color: Color(0xFFEF4444)),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load bookings',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(userBookingsProvider),
                        icon: const Icon(Iconsax.refresh, size: 16),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rapido Category Segment Pill Bar
  Widget _buildCategoryPills() {
    final categories = [
      {'label': 'All', 'icon': Iconsax.category},
      {'label': 'Rides', 'icon': Iconsax.car},
      {'label': 'Rentals', 'icon': Iconsax.key},
      {'label': 'Services', 'icon': Iconsax.setting_2},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['label'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedCategory = cat['label'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 14,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Status Filter Chips
  Widget _buildStatusChips() {
    final statuses = ['All', 'Completed', 'Active', 'Cancelled'];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: statuses.map((status) {
            final isSelected = _selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedStatus = status);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    status == 'All' ? 'All Status' : status,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Rapido-Style Ride Card with Route Stepper, Price & Quick Rebook Action
  Widget _buildRapidoRideCard(UnifiedBookingItem booking, int index) {
    final (
      statusTextColor,
      statusBg,
      statusBorder,
      statusLabel,
    ) = _getStatusStyle(booking.status);

    final pickup = booking.pickupAddress?.isNotEmpty == true
        ? booking.pickupAddress!
        : 'Pickup Location';
    final dropoff = booking.destinationAddress?.isNotEmpty == true
        ? booking.destinationAddress!
        : 'Drop-off Location';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (booking.type == BookingType.service) {
          context.push('/service-booking-detail', extra: booking.originalObject);
        } else if (booking.type == BookingType.ride) {
          context.push('/live-tracking', extra: booking.originalObject);
        } else if (booking.type == BookingType.rental) {
          context.push('/rental-detail/${booking.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Vehicle Type, Date & Status Chip
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  _buildVehicleBadge(booking),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.date,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusTextColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: statusTextColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Rapido Signature Route Visualizer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stepper Dots & Line
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      children: [
                        // Green Pickup Dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Dotted Line
                        Container(
                          width: 1.5,
                          height: 28,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: const Color(0xFFCBD5E1),
                        ),
                        // Red Drop-off Square
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Route Addresses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dropoff,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Bottom Action Strip: Fare, Payment & "Book Again" Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  // Fare & Payment Mode
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.price,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        booking.paymentMethod?.isNotEmpty == true
                            ? booking.paymentMethod!
                            : 'Paid',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Delete / Dismiss Icon Button
                  IconButton(
                    onPressed: () =>
                        _confirmDeleteSingleBooking(context, booking),
                    tooltip: 'Remove from history',
                    icon: const Icon(
                      Iconsax.trash,
                      size: 17,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Rapido "Book Again" Action CTA
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/taxi');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006241),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 15),
                    label: Text(
                      'Book Again',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 25 * index))
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.04, end: 0);
  }

  /// Vehicle type badge
  Widget _buildVehicleBadge(UnifiedBookingItem booking) {
    IconData icon;
    Color color;

    if (booking.type == BookingType.ride) {
      final v = (booking.vehicleType ?? '').toLowerCase();
      if (v.contains('bike') || v.contains('moto')) {
        icon = Icons.two_wheeler_rounded;
        color = const Color(0xFFF59E0B);
      } else if (v.contains('auto')) {
        icon = Icons.electric_rickshaw_rounded;
        color = const Color(0xFFEAB308);
      } else {
        icon = Iconsax.car;
        color = const Color(0xFF0284C7);
      }
    } else if (booking.type == BookingType.rental) {
      icon = Iconsax.key;
      color = const Color(0xFF10B981);
    } else {
      icon = Iconsax.setting_2;
      color = const Color(0xFF8B5CF6);
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  /// Rapido-Style Empty State
  Widget _buildRapidoEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Icon(
                  Iconsax.car,
                  size: 44,
                  color: Color(0xFF006241),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Rides Yet',
              style: GoogleFonts.inter(
                color: const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ready to move? Book a quick, affordable ride anywhere in the city.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/taxi');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006241),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Iconsax.car, size: 18),
                label: Text(
                  'Book a Ride Now',
                  style: GoogleFonts.inter(
                    fontSize: 14,
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

  /// Filters bookings according to selected category & status
  List<UnifiedBookingItem> _filterBookings(List<UnifiedBookingItem> all) {
    return all.where((b) {
      // 1. Category Filter
      if (_selectedCategory == 'Rides' && b.type != BookingType.ride) {
        return false;
      }
      if (_selectedCategory == 'Rentals' && b.type != BookingType.rental) {
        return false;
      }
      if (_selectedCategory == 'Services' && b.type != BookingType.service) {
        return false;
      }

      // 2. Status Filter
      if (_selectedStatus != 'All') {
        final s = b.status.toLowerCase();
        if (_selectedStatus == 'Completed') {
          if (s != 'completed' && s != 'paid') return false;
        } else if (_selectedStatus == 'Active') {
          if (s != 'active' &&
              s != 'in_progress' &&
              s != 'in progress' &&
              s != 'confirmed') {
            return false;
          }
        } else if (_selectedStatus == 'Cancelled') {
          if (s != 'cancelled' && s != 'cancelled_expired') return false;
        }
      }

      return true;
    }).toList();
  }

  (Color, Color, Color, String) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return (
          const Color(0xFF047857),
          const Color(0xFFECFDF5),
          const Color(0xFFA7F3D0),
          'COMPLETED',
        );
      case 'active':
      case 'in_progress':
      case 'in progress':
      case 'confirmed':
        return (
          const Color(0xFF0369A1),
          const Color(0xFFF0F9FF),
          const Color(0xFFBAE6FD),
          'CONFIRMED',
        );
      case 'payment_pending':
      case 'pending':
        return (
          const Color(0xFFB45309),
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          'PENDING',
        );
      case 'cancelled':
        return (
          const Color(0xFFB91C1C),
          const Color(0xFFFEF2F2),
          const Color(0xFFFECDD3),
          'CANCELLED',
        );
      case 'cancelled_expired':
        return (
          const Color(0xFFDC2626),
          const Color(0xFFFFF1F2),
          const Color(0xFFFCA5A5),
          'EXPIRED',
        );
      default:
        return (
          const Color(0xFF475569),
          const Color(0xFFF8FAFC),
          const Color(0xFFE2E8F0),
          status.toUpperCase(),
        );
    }
  }

  void _confirmDeleteSingleBooking(
      BuildContext context, UnifiedBookingItem booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Booking',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          'Remove this booking from your history?',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await deleteBookingItem(ref, booking);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking removed from history'),
                    backgroundColor: Color(0xFF006241),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCancelled(BuildContext context) {
    final userId = ref.read(userProvider).user?.id;
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Cancelled Bookings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          'Permanently remove all cancelled and expired bookings from your history?',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await clearAllCancelledBookings(ref, userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cancelled bookings cleared from history'),
                    backgroundColor: Color(0xFF006241),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showExpiredCancelledBanner(
      BuildContext context, ExpiredRentalCleanupResult result) {
    final hasRefund = result.hasRefund;
    final amountStr = NumberFormat.currency(
            locale: 'en_IN', symbol: '\u20b9', decimalDigits: 0)
        .format(result.refundedAmount);

    final content = hasRefund
        ? 'Your ${result.cancelledCount} pending rental(s) expired and were cancelled. '
            '$amountStr has been refunded to your wallet.'
        : 'Your ${result.cancelledCount} pending rental(s) expired and were automatically cancelled.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasRefund
                ? const Color(0xFF064E3B)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasRefund
                      ? const Color(0xFF059669).withValues(alpha: 0.25)
                      : const Color(0xFFE11D48).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasRefund ? Iconsax.wallet_check : Iconsax.calendar_remove,
                  color: hasRefund
                      ? const Color(0xFF34D399)
                      : const Color(0xFFFB7185),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasRefund
                          ? 'Booking Expired • Refund Initiated'
                          : 'Booking Expired • Auto-Cancelled',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
