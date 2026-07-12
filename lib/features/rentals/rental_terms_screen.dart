import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class RentalTermsScreen extends StatelessWidget {
  const RentalTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Rental Terms',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTerm('1. Driver Requirements',
                'The driver must have a valid Indian driving license (Original) and must be at least 21 years of age.'),
            _buildTerm('2. Security Deposit',
                'A security deposit of ₹2,000 (50% is refundable) will be held during the rental period.'),
            _buildTerm('3. Fuel Policy',
                'The vehicle must be returned with the same amount of fuel as provided at the start of the rental.'),
            _buildTerm('4. Late Return',
                'Late returns will attract a penalty of ₹500 per hour.'),
            _buildTerm('5. Insurance',
                'User is responsible for the first ₹5,000 of any damage if full cover is not selected.'),
            _buildTerm('6. Usage Restrictions',
                'The vehicle cannot be used for commercial purposes or racing.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTerm(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
