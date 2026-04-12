import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/pricing_service.dart';
import '../../core/repositories/transaction_repository.dart';
import '../../core/models/transaction_model.dart';
import '../profile/user_provider.dart';
import 'rental_providers.dart';

class RentalCheckoutScreen extends ConsumerStatefulWidget {
  const RentalCheckoutScreen({super.key});

  @override
  ConsumerState<RentalCheckoutScreen> createState() => _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends ConsumerState<RentalCheckoutScreen> {
  bool _includeInsurance = true;
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: (PaymentSuccessResponse? response) async {
        final selectedVehicle = ref.read(selectedVehicleProvider);
        final basePriceStr = ref.read(rentalPriceProvider);
        final basePrice = double.tryParse(basePriceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final breakdown = PricingService.calculateBill(basePrice + (_includeInsurance ? 400 : 0));

        // 1. Log detailed transaction to Firestore
        final userId = ref.read(userProvider).user?.id ?? 'demo';
        await ref.read(transactionRepositoryProvider).logTransaction(AppTransaction(
          id: '',
          userId: userId,
          razoprayPaymentId: response?.paymentId ?? 'SIM_SUCCESS',
          razorpayOrderId: response?.orderId,
          razorpaySignature: response?.signature,
          baseAmount: breakdown.baseAmount,
          gstAmount: breakdown.gstAmount,
          platformFee: breakdown.platformFee,
          handlingCharges: breakdown.handlingCharges,
          totalAmount: breakdown.totalPayable,
          description: 'Vehicle Rental: ${selectedVehicle?['name']}',
          timestamp: DateTime.now(),
        ));

        // 2. Start the rental state
        if (selectedVehicle != null) {
          ref.read(activeRentalProvider.notifier).startRental(
            selectedVehicle,
            const Duration(hours: 2), // Demo limit
          );
          
          await ref.read(activeRentalProvider.notifier).completePayment(
            totalCost: breakdown.totalPayable,
            paymentId: response?.paymentId,
          );

          if (mounted) context.push('/rental-confirmed');
        }
      },
      onFailure: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
            backgroundColor: AppColors.errorRed,
          ));
        }
      },
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final basePriceStr = ref.watch(rentalPriceProvider);
    
    final basePrice = double.tryParse(basePriceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final breakdown = PricingService.calculateBill(basePrice + (_includeInsurance ? 400 : 0));

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
            
            const SizedBox(height: 32),
            _buildSectionHeader('Price Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildPriceRow('Base Rental', '₹${basePrice.toInt()}'),
                  const SizedBox(height: 12),
                  if (_includeInsurance) ...[
                    _buildPriceRow('Insurance', '₹400'),
                    const SizedBox(height: 12),
                  ],
                  _buildPriceRow('Platform Fee', '₹${breakdown.platformFee.toInt()}'),
                  const SizedBox(height: 12),
                  _buildPriceRow('Handling Charges', '₹${breakdown.handlingCharges.toInt()}'),
                  const SizedBox(height: 12),
                  _buildPriceRow('GST (18%)', '₹${breakdown.gstAmount.round()}'),
                  const Divider(height: 32),
                  _buildPriceRow('Grand Total', '₹${breakdown.totalPayable.round()}', isTotal: true),
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
          label: 'PAY ₹${breakdown.totalPayable.round()}',
          onPressed: () {
            HapticFeedback.heavyImpact();
            
            final userData = ref.read(userProvider).user;
            
            _paymentService.startPayment(
              amount: breakdown.totalPayable,
              contact: userData?.phone ?? '9876543210',
              email: userData?.email ?? 'customer@example.com',
              description: 'Vehicle Rental: ${selectedVehicle?['name']}',
            );
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

