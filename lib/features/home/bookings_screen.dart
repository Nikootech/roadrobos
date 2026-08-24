import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../providers/connectivity_provider.dart';
import 'user_bookings_provider.dart';

/// Bookings Screen - World-Class React Tier-1 Booking Management
/// Matches Figma Screen [21]: "My Rides History"
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showBookingFilterSheet(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Iconsax.filter,
                color: Color(0xFF0F172A),
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
                    'Viewing offline data - Last updated 5 minutes ago',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: bookingsAsync.when(
              data: (allBookings) {
                final bookings = _filterBookings(allBookings);

                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.calendar_remove,
                            size: 32,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings found',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedFilter == 'All'
                              ? 'Your past rides and service bookings will appear here'
                              : 'No bookings match the selected "$_selectedFilter" filter',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final (gradient, icon) =
                        _getServiceStyle(booking.type, booking.title);
                    final (
                      statusTextColor,
                      statusBg,
                      statusBorder,
                      statusLabel
                    ) = _getStatusStyle(booking.status);

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (booking.type == BookingType.service) {
                          context.push('/service-booking-detail',
                              extra: booking.originalObject);
                        } else if (booking.type == BookingType.ride) {
                          context.push('/live-tracking',
                              extra: booking.originalObject);
                        } else if (booking.type == BookingType.rental) {
                          context.push('/rental-detail/${booking.id}');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.first.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 3D Squircle Icon Badge with Dual Gradient
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        gradient.first.withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Booking Title & Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    booking.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Iconsax.calendar_1,
                                        size: 11.5,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4.5),
                                      Text(
                                        booking.date,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Price and Status Chip
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(6),
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
                                      const SizedBox(width: 4.5),
                                      Text(
                                        statusLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
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
                          ],
                        ),
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 30 * index))
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF006241)),
              ),
              error: (err, stack) =>
                  Center(child: Text('Error loading bookings: $err')),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterBookings(List<dynamic> all) {
    if (_selectedFilter == 'All') return all;
    return all.where((b) {
      final s = b.status.toString().toLowerCase();
      if (_selectedFilter == 'Completed') {
        return s == 'completed' || s == 'paid';
      } else if (_selectedFilter == 'Active') {
        return s == 'active' || s == 'in_progress' || s == 'confirmed';
      } else if (_selectedFilter == 'Pending') {
        return s == 'payment_pending' || s == 'pending';
      } else if (_selectedFilter == 'Cancelled') {
        return s == 'cancelled';
      }
      return true;
    }).toList();
  }

  void _showBookingFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Bookings',
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF1F5F9),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'STATUS FILTER',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All',
                  'Completed',
                  'Active',
                  'Pending',
                  'Cancelled',
                ].map((f) {
                  final isSelected = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setSheetState(() => _selectedFilter = f);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF006241)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF006241)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filter',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (List<Color>, IconData) _getServiceStyle(BookingType type, String title) {
    final t = title.toLowerCase();
    if (t.contains('taxi') || t.contains('ride') || type == BookingType.ride) {
      return (
        const [Color(0xFF0284C7), Color(0xFF38BDF8)],
        Iconsax.car,
      );
    } else if (t.contains('rental') || type == BookingType.rental) {
      return (
        const [Color(0xFF006241), Color(0xFF10B981)],
        Iconsax.key,
      );
    } else if (t.contains('delivery') || t.contains('package')) {
      return (
        const [Color(0xFF0D9488), Color(0xFF14B8A6)],
        Iconsax.box_1,
      );
    } else {
      return (
        const [Color(0xFFD97706), Color(0xFFFBBF24)],
        Iconsax.setting_2,
      );
    }
  }

  (Color, Color, Color, String) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return (
          const Color(0xFF006241),
          const Color(0xFFF0FDF4),
          const Color(0xFF86EFAC),
          'COMPLETED',
        );
      case 'active':
      case 'in_progress':
      case 'in progress':
      case 'confirmed':
        return (
          const Color(0xFF0284C7),
          const Color(0xFFF0F9FF),
          const Color(0xFFBAE6FD),
          'CONFIRMED',
        );
      case 'payment_pending':
        return (
          const Color(0xFFD97706),
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          'PENDING',
        );
      case 'cancelled':
        return (
          const Color(0xFFE11D48),
          const Color(0xFFFFF1F2),
          const Color(0xFFFECDD3),
          'CANCELLED',
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
}
