import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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
  ConsumerState<RentalCheckoutScreen> createState() =>
      _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends ConsumerState<RentalCheckoutScreen> {
  bool _includeInsurance = true;
  String _paymentMethod = 'Online';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final basePriceStr = ref.watch(rentalPriceProvider);

    final basePrice =
        double.tryParse(basePriceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final breakdown =
        PricingService.calculateBill(basePrice + (_includeInsurance ? 400 : 0));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDarkDeep : AppColors.bgLightGrey;
    final cardColor = isDark ? AppColors.bgDarkSurface : Colors.white;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final textSecondaryColor =
        isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDarkDeep : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: textColor),
          onPressed: () => NavHelpers.pop(context),
        ),
        title: Text('Checkout',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 70,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bgDarkDeep : AppColors.bgLightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedVehicle['image_url']
                              .toString()
                              .startsWith('http')
                          ? Image.network(selectedVehicle['image_url'],
                              fit: BoxFit.contain)
                          : Image.asset(selectedVehicle['image_url'],
                              fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedVehicle['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                          Text('Premium Rental • Sanitized',
                              style: TextStyle(
                                  color: textSecondaryColor,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            _buildSectionHeader('Pickup & Drop-off'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildLocationRow(
                    icon: Icons.trip_origin_rounded,
                    iconColor: AppColors.successGreen,
                    label: 'Pickup',
                    value: ref.watch(rentalPickupLocationProvider)?['name']
                            as String? ??
                        'Not selected',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Row(
                      children: [
                        Container(
                            width: 1.5, height: 20, color: isDark ? AppColors.bgDarkDeep : AppColors.border),
                        const Spacer(),
                      ],
                    ),
                  ),
                  _buildLocationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.accentOrange,
                    label: 'Drop-off',
                    value: ref.watch(rentalDropoffLocationProvider)?['name']
                            as String? ??
                        'Not selected',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Rental Dates'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup',
                          style: TextStyle(
                              color: textSecondaryColor, fontSize: 11)),
                      Text('Oct 20, 10:00 AM',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    ],
                  ),
                  Icon(Icons.arrow_forward_rounded, color: isDark ? AppColors.bgDarkDeep : AppColors.border),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Drop-off',
                          style: TextStyle(
                              color: textSecondaryColor, fontSize: 11)),
                      Text('Oct 22, 10:00 AM',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
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
              title: Text('Full Insurance Cover',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              subtitle: Text('Covers accidental damage & theft',
                  style: TextStyle(fontSize: 12, color: textSecondaryColor)),
              secondary:
                  const Icon(Iconsax.shield_tick, color: AppColors.primaryBlue),
              activeColor: AppColors.primaryBlue,
              tileColor: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),

             const SizedBox(height: 32),
            _buildSectionHeader('Payment Method'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _paymentMethod = 'Cash');
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'Cash'
                            ? Colors.orange.shade50
                            : (isDark ? AppColors.bgDarkSurface : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _paymentMethod == 'Cash'
                              ? Colors.orange.shade400
                              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          width: _paymentMethod == 'Cash' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.money_rounded,
                            color: _paymentMethod == 'Cash'
                                ? Colors.orange.shade700
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pay at Pickup',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _paymentMethod == 'Cash'
                                  ? Colors.orange.shade700
                                  : textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _paymentMethod = 'Online');
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'Online'
                            ? AppColors.primaryBlue.withValues(alpha: 0.08)
                            : (isDark ? AppColors.bgDarkSurface : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _paymentMethod == 'Online'
                              ? AppColors.primaryBlue
                              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          width: _paymentMethod == 'Online' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            color: _paymentMethod == 'Online'
                                ? AppColors.primaryBlue
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pay Online',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _paymentMethod == 'Online'
                                  ? AppColors.primaryBlue
                                  : textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Price Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildPriceRow('Base Rental', '₹${basePrice.toInt()}'),
                  const SizedBox(height: 12),
                  if (_includeInsurance) ...[
                    _buildPriceRow('Insurance', '₹400'),
                    const SizedBox(height: 12),
                  ],
                  _buildPriceRow(
                      'Platform Fee', '₹${breakdown.platformFee.toInt()}'),
                  const SizedBox(height: 12),
                  _buildPriceRow('Handling Charges',
                      '₹${breakdown.handlingCharges.toInt()}'),
                  const SizedBox(height: 12),
                  _buildPriceRow(
                      'GST (18%)', '₹${breakdown.gstAmount.round()}'),
                  const Divider(height: 32),
                  _buildPriceRow(
                      'Grand Total', '₹${breakdown.totalPayable.round()}',
                      isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.push('/rental-terms'),
              child: const Center(
                child: Text('Review Terms & Conditions',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: isDark ? AppColors.bgDarkDeep : Colors.white),
        child: CustomButton(
          label: _paymentMethod == 'Online'
              ? 'PAY ₹${breakdown.totalPayable.round()}'
              : 'CONFIRM BOOKING',
          onPressed: () async {
            // ignore: unawaited_futures
            HapticFeedback.heavyImpact();

            final userData = ref.read(userProvider).user;
            final userId = userData?.id ?? 'demo';

            try {
              // 1. Start the rental state
              if (selectedVehicle != null) {
                ref.read(activeRentalProvider.notifier).startRental(
                      selectedVehicle,
                      const Duration(hours: 2), // Demo limit
                    );

                // 2. Complete payment (will trigger Razorpay if Online, or complete directly if Cash)
                await ref.read(activeRentalProvider.notifier).completePayment(
                      totalCost: breakdown.totalPayable,
                      paymentService: ref.read(paymentServiceProvider.notifier),
                      method: _paymentMethod,
                    );

                // 3. Log detailed transaction
                await ref
                    .read(transactionRepositoryProvider)
                    .logTransaction(AppTransaction(
                      id: '',
                      userId: userId,
                      razoprayPaymentId: _paymentMethod == 'Online' ? 'VERIFIED_ON_SERVER' : 'CASH_PAYMENT',
                      baseAmount: breakdown.baseAmount,
                      gstAmount: breakdown.gstAmount,
                      platformFee: breakdown.platformFee,
                      handlingCharges: breakdown.handlingCharges,
                      totalAmount: breakdown.totalPayable,
                      description: 'Vehicle Rental: ${selectedVehicle['name']}',
                      timestamp: DateTime.now(),
                    ));

                if (!context.mounted) return;
                // ignore: unawaited_futures
                context.push('/rental-confirmed');
              }
            } catch (e) {
              // Reset state on failure so UI is consistent
              ref.read(activeRentalProvider.notifier).clearRental();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: AppColors.errorRed,
              ));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    return Text(title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor));
  }

  Widget _buildPriceRow(String label, String val, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final textSecondaryColor =
        isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
                color: isTotal ? textColor : textSecondaryColor)),
        Text(val,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.bold,
                color:
                    isTotal ? AppColors.primaryBlue : textColor)),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final textSecondaryColor =
        isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: textSecondaryColor, fontSize: 11)),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
