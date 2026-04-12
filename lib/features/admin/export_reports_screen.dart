import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';

class ExportReportsScreen extends StatefulWidget {
  const ExportReportsScreen({super.key});

  @override
  State<ExportReportsScreen> createState() => _ExportReportsScreenState();
}

class _ExportReportsScreenState extends State<ExportReportsScreen> {
  String _selectedFormat = 'PDF';
  String _selectedRange = 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Export Reports', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Report Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _buildReportTypeCard('Accounting & Billing', 'Financial statements, tax invoices', Iconsax.money_send),
            const SizedBox(height: 12),
            _buildReportTypeCard('Fleet Performance', 'Vehicle usage, maintenance logs', Iconsax.truck_fast),
            const SizedBox(height: 12),
            _buildReportTypeCard('Customer Engagement', 'New users, retention, feedback', Iconsax.user_square),
            
            const SizedBox(height: 32),
            const Text('Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildConfigRow('Date Range', _selectedRange, ['Today', 'Last 7 Days', 'Last 30 Days', 'Custom']),
            const Divider(height: 32),
            _buildConfigRow('File Format', _selectedFormat, ['PDF', 'Excel (XLSX)', 'CSV']),
            
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                NavHelpers.showSuccess(context, 'Report generation started...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('GENERATE & DOWNLOAD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.circle_outlined, color: AppColors.border, size: 24),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildConfigRow(String label, String value, List<String> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
          items: options.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: (v) {
            if (label == 'Date Range') {
              setState(() => _selectedRange = v!);
            } else {
              setState(() => _selectedFormat = v!);
            }
          },
        ),
      ],
    );
  }
}
