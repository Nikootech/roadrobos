import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../core/services/invoice_service.dart';
import '../profile/user_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'rental_providers.dart';

class RentalConfirmedScreen extends ConsumerWidget {
  const RentalConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final vehicleName = selectedVehicle?['name'] ?? 'Vehicle';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.successGreen.withAlpha(25), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.successGreen),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 32),
                  const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Your rental booking for $vehicleName is successful. You can track your vehicle status in "My Bookings".', 
                            textAlign: TextAlign.center, 
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                  
                  const SizedBox(height: 48),
                  CustomButton(
                    label: 'TRACK BOOKING',
                    onPressed: () {
                      // Trigger a mock rental of 30 seconds for demonstration
                      if (selectedVehicle != null) {
                        ref.read(activeRentalProvider.notifier).startRental(
                          selectedVehicle,
                          const Duration(seconds: 30),
                        );
                      }
                      context.push('/delivery-logistics');
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final userData = ref.read(userProvider);
                      final basePriceStr = ref.read(rentalPriceProvider);
                      final basePrice = double.tryParse(basePriceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                      
                      await InvoiceService.generateAndShareInvoice(
                        bookingId: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
                        customerName: userData.name,
                        vehicleName: vehicleName,
                        baseAmount: basePrice,
                        date: DateTime.now(),
                      );
                    },
                    icon: const Icon(Iconsax.document_download, size: 18),
                    label: const Text('DOWNLOAD INVOICE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/main/home'),
                    child: const Text('Back to Home', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

