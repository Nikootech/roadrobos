import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';
import 'rental_providers.dart';

class RentalCheckoutScreen extends ConsumerStatefulWidget {
  const RentalCheckoutScreen({super.key});

  @override
  ConsumerState<RentalCheckoutScreen> createState() => _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends ConsumerState<RentalCheckoutScreen> {
  bool _includeInsurance = true;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final basePriceStr = ref.watch(rentalPriceProvider);
    
    // Simple calculation for taxes and total
    final basePrice = int.tryParse(basePriceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final gst = (basePrice * 0.18).round();
    final insurance = _includeInsurance ? 400 : 0;
    final grandTotal = basePrice + gst + insurance;

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => NavHelpers.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Summary Card
            if (selectedVehicle != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 70,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgLightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(selectedVehicle['image'], fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedVehicle['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Premium Rental • Sanitized', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Rental Dates'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      Text('Oct 20, 10:00 AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.border),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Drop-off', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      Text('Oct 22, 10:00 AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Insurance'),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _includeInsurance,
              onChanged: (v) => setState(() => _includeInsurance = v!),
              title: const Text('Full Insurance Cover', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Covers accidental damage & theft', style: TextStyle(fontSize: 12)),
              secondary: const Icon(Iconsax.shield_tick, color: AppColors.primaryBlue),
              activeColor: AppColors.primaryBlue,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            
            const SizedBox(height: 12),
            _buildSectionHeader('Offers & Coupons'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withAlpha(128)),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.ticket_discount, color: AppColors.primaryBlue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Apply Coupon Code',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Price Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildPriceRow('Base Rental', '₹$basePrice'),
                  const SizedBox(height: 12),
                  if (_includeInsurance) ...[
                    _buildPriceRow('Insurance', '₹400'),
                    const SizedBox(height: 12),
                  ],
                  _buildPriceRow('GST (18%)', '₹$gst'),
                  const Divider(height: 32),
                  _buildPriceRow('Grand Total', '₹$grandTotal', isTotal: true),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.push('/rental-terms'),
              child: const Center(
                child: Text('Review Terms & Conditions', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white),
        child: CustomButton(
          label: 'PAY ₹$grandTotal',
          onPressed: () {
            HapticFeedback.heavyImpact();
            if (selectedVehicle != null) {
              ref.read(activeRentalProvider.notifier).startRental(
                selectedVehicle,
                const Duration(hours: 2), // Simulation duration
              );
              context.push('/rental-confirmed');
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildPriceRow(String label, String val, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal)),
        Text(val, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.bold, color: isTotal ? AppColors.primaryBlue : AppColors.textPrimary)),
      ],
    );
  }
}

