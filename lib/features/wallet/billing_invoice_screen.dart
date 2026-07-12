import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';

class BillingInvoiceScreen extends StatelessWidget {
  const BillingInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Invoice',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => NavHelpers.showSnackAction(
                context, 'Invoice shared to clipboard!',
                icon: Icons.share_rounded),
            icon: const Icon(Iconsax.import, color: AppColors.primaryBlue),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('INVOICE',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 2)),
                      Text('#INV-2024-001',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildInfoRow('Billed To', 'Rahul Sharma'),
                  _buildInfoRow('Date', '12 Jan 2024'),
                  _buildInfoRow('Vehicle', 'Hyundai Creta (MH 02 AB 1234)'),
                  const SizedBox(height: 32),
                  const Text('Service Items',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildItemRow('General Service Package', '₹1,499.00'),
                  _buildItemRow('Engine Oil (Synthetic)', '₹850.00'),
                  _buildItemRow('Oil Filter', '₹220.00'),
                  _buildItemRow('Labor Charges', '₹350.00'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildItemRow('Subtotal', '₹2,919.00', isBold: true),
                  _buildItemRow('Discount (PROMO50)', '-₹500.00',
                      color: AppColors.successGreen),
                  _buildItemRow('Tax (GST 18%)', '₹435.42'),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                  _buildItemRow('Total Amount Paid', '₹2,854.42',
                      isBold: true, fontSize: 18),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),
            const SizedBox(height: 48),
            CustomButton(
              label: 'Download PDF',
              onPressed: () => NavHelpers.showSuccess(
                  context, 'Invoice PDF downloaded successfully!'),
              backgroundColor: AppColors.deepNavy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String value,
      {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: color ?? AppColors.textPrimary)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
