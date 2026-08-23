import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class ScheduleRideScreen extends StatefulWidget {
  final String? pickupAddress;
  final String? dropoffAddress;

  const ScheduleRideScreen({
    super.key,
    this.pickupAddress,
    this.dropoffAddress,
  });

  @override
  State<ScheduleRideScreen> createState() => _ScheduleRideScreenState();
}

class _ScheduleRideScreenState extends State<ScheduleRideScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 2));
  String? _selectedTime;
  int _step = 0; // 0 = pick date, 1 = pick time, 2 = confirm

  // Generate next 7 days
  List<DateTime> get _availableDates => List.generate(
        7,
        (i) => DateTime.now().add(Duration(days: i)),
      );

  // Time slots from 6 AM to 11 PM in 30-min intervals
  List<String> get _timeSlots {
    final slots = <String>[];
    final now = DateTime.now();
    for (int h = 6; h <= 23; h++) {
      for (int m = 0; m < 60; m += 30) {
        final slotTime = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, h, m);
        // Skip past slots for today
        if (_selectedDate.day == now.day && slotTime.isBefore(now)) continue;
        final period = h < 12 ? 'AM' : 'PM';
        final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        final min = m == 0 ? '00' : '30';
        slots.add('$hour:$min $period');
      }
    }
    return slots;
  }

  String get _fareEstimate {
    if (widget.dropoffAddress == null) return '₹150 – ₹250';
    return '₹180 – ₹320';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _step == 0
                    ? _buildDatePicker(key: const ValueKey('date'))
                    : _step == 1
                        ? _buildTimePicker(key: const ValueKey('time'))
                        : _buildConfirmation(key: const ValueKey('confirm')),
              ),
            ),
            _buildBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_step == 0) {
                context.pop();
              } else {
                setState(() => _step--);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule a Ride',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                ['Pick a date', 'Choose a time', 'Confirm booking'][_step],
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _step;
          final isDone = i < _step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive
                          ? AppColors.brandGreenLight
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDatePicker({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date',
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60)),
          const SizedBox(height: 16),
          ..._availableDates.map((date) {
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month;
            final isToday = date.day == DateTime.now().day;
            final label = isToday
                ? 'Today'
                : DateFormat('EEEE').format(date); // Monday, Tuesday...
            final dateStr = DateFormat('d MMM').format(date);

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.brandGreen,
                            AppColors.brandGreenMid
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color:
                      isSelected ? null : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.brandGreenLight.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.brandGreen.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('d').format(date),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.87),
                            ),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color:
                                  isSelected ? Colors.white70 : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimePicker({Key? key}) {
    final slots = _timeSlots;
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Slots for ${DateFormat("EEE, d MMM").format(_selectedDate)}',
            style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white60),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final isSelected = slot == _selectedTime;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTime = slot);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              AppColors.brandGreen,
                              AppColors.brandGreenMid
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandGreenLight.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildConfirmation({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Route card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _confirmRow(
                  icon: Icons.radio_button_checked_rounded,
                  iconColor: const Color(0xFF22C55E),
                  label: 'From',
                  value: widget.pickupAddress ?? 'Current Location',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Container(
                    width: 2,
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                _confirmRow(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFF43F5E),
                  label: 'To',
                  value: widget.dropoffAddress ?? 'Not set',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Date/time card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandGreen.withValues(alpha: 0.2),
                  AppColors.brandGreenMid.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.brandGreenLight.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.brandGreenLight, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.brandGreenLight, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime ?? '--:--',
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Fare estimate
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.currency_rupee_rounded,
                    color: Color(0xFF60A5FA), size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Fare',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.white54)),
                    Text(_fareEstimate,
                        style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Estimate',
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: Colors.white38)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reminder note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You'll receive a reminder 15 minutes before your scheduled ride.",
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _confirmRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
              Text(value,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.87)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA() {
    final canProceed = _step == 0
        ? true
        : _step == 1
            ? _selectedTime != null
            : true;

    final labels = ['Continue to Time', 'Review Booking', 'Confirm Schedule'];

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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canProceed
              ? () {
                  HapticFeedback.mediumImpact();
                  if (_step < 2) {
                    setState(() => _step++);
                  } else {
                    // Booking confirmed — go to ride options with scheduled flag
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ride scheduled for ${DateFormat("d MMM").format(_selectedDate)} at $_selectedTime!',
                        ),
                        backgroundColor: AppColors.brandGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    context.go('/main/home');
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canProceed ? AppColors.brandGreen : Colors.white12,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white12,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                labels[_step],
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              if (canProceed) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
