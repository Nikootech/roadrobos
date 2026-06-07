import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../core/repositories/transaction_repository.dart';
import '../../core/models/service_booking.dart';
import '../../core/models/transaction_model.dart';
import '../profile/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/pricing_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/technician/technician_provider.dart';

class ScheduleAppointmentScreen extends ConsumerStatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  ConsumerState<ScheduleAppointmentScreen> createState() => _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends ConsumerState<ScheduleAppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Schedule Appointment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  const SizedBox(height: 32),
                  const Text('Select Time Slot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = time),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 64) / 3,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue : AppColors.bgLightGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.transparent),
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: CustomButton(
              label: 'Book Appointment',
              onPressed: _selectedTime.isEmpty ? null : () async {
                final booking = ref.read(bookingProvider);
                final basePrice = double.tryParse(booking.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                final breakdown = PricingService.calculateBill(basePrice);
                final userData = ref.read(userProvider).user;
                final userId = userData?.id ?? 'demo';
                
                try {
                  await ref.read(paymentServiceProvider.notifier).startPayment(
                    PaymentDetails(
                      contact: userData?.phone ?? '9876543210',
                      email: userData?.email ?? 'customer@example.com',
                      description: 'Service Booking: ${booking.packageName}',
                      bookingId: '00000000-0000-0000-0000-000000000000',
                      userId: userId,
                      bookingType: BookingType.service,
                      totalCost: breakdown.totalPayable,
                    )
                  );

                  // On success
                  final dateStr = DateFormat('d MMMM yyyy').format(_selectedDate);
                  ref.read(bookingProvider.notifier).setSchedule(dateStr, _selectedTime);
                  
                  await ref.read(transactionRepositoryProvider).logTransaction(AppTransaction(
                    id: '',
                    userId: userId,
                    razoprayPaymentId: 'VERIFIED_ON_SERVER',
                    baseAmount: breakdown.baseAmount,
                    gstAmount: breakdown.gstAmount,
                    platformFee: breakdown.platformFee,
                    handlingCharges: breakdown.handlingCharges,
                    totalAmount: breakdown.totalPayable,
                    description: 'Service Booking: ${booking.packageName}',
                    timestamp: DateTime.now(),
                  ));

                  ref.read(technicianProvider.notifier).createJobFromBooking(booking);
                  
                  await ref.read(serviceBookingRepositoryProvider).createServiceBooking(ServiceBooking(
                    id: '',
                    customerId: userId,
                    vehicleName: booking.vehicleModel,
                    vehiclePlate: booking.vehiclePlate,
                    packageName: booking.packageName,
                    date: booking.date.isEmpty ? dateStr : booking.date,
                    time: booking.time.isEmpty ? _selectedTime : booking.time,
                    totalCost: breakdown.totalPayable,
                    details: {'method': 'Razorpay'},
                    status: 'paid',
                    createdAt: DateTime.now(),
                  ));

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Booking Confirmed!'),
                    backgroundColor: Colors.green,
                  ));
                  context.pop();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.errorRed,
                  ));
                }
              },
              backgroundColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSkyLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Row(
                children: [
                  Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  SizedBox(width: 16),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = _selectedDate.day == date.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(date)[0],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle('1', true),
          _stepLine(true),
          _stepCircle('2', true),
          _stepLine(false),
          _stepCircle('3', false),
        ],
      ),
    );
  }

  Widget _stepCircle(String label, bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : AppColors.bgLightGrey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: active ? AppColors.primaryBlue : AppColors.bgLightGrey,
    );
  }
}

