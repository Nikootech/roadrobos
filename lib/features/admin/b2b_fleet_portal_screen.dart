import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Enterprise B2B Corporate Fleet Subscriptions & SLA Management Screen.
class B2BFleetPortalScreen extends StatefulWidget {
  const B2BFleetPortalScreen({super.key});

  @override
  State<B2BFleetPortalScreen> createState() => _B2BFleetPortalScreenState();
}

class _B2BFleetPortalScreenState extends State<B2BFleetPortalScreen> {
  final List<Map<String, dynamic>> _corporateAccounts = [
    {
      'company': 'Swiggy Quick Logistics',
      'vehicles': 420,
      'tier': 'Platinum Dedicated',
      'monthlyBilling': '₹1,26,000/mo',
      'slaBreachRate': '0.4%',
      'color': const Color(0xFFF97316),
      'activeRequests': 3,
    },
    {
      'company': 'Zomato Hyperlocal Fleet',
      'vehicles': 310,
      'tier': 'Gold 10-min SLA',
      'monthlyBilling': '₹93,000/mo',
      'slaBreachRate': '0.8%',
      'color': const Color(0xFFEF4444),
      'activeRequests': 1,
    },
    {
      'company': 'Porter City Freight Vans',
      'vehicles': 185,
      'tier': 'Gold 10-min SLA',
      'monthlyBilling': '₹74,000/mo',
      'slaBreachRate': '1.2%',
      'color': const Color(0xFF3B82F6),
      'activeRequests': 0,
    },
    {
      'company': 'Blinkit 10-Min Darkstore Fleet',
      'vehicles': 240,
      'tier': 'Platinum Dedicated',
      'monthlyBilling': '₹1,08,000/mo',
      'slaBreachRate': '0.2%',
      'color': const Color(0xFFEAB308),
      'activeRequests': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'B2B Corporate Fleet Portal',
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const Text('Enterprise SLA Subscriptions & Fleets',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Executive B2B Stats Row
            Row(
              children: [
                _buildMetricCard('Total Fleet Vehicles', '1,155', Iconsax.car,
                    const Color(0xFF0284C7)),
                const SizedBox(width: 12),
                _buildMetricCard('B2B Monthly MRR', '₹4.01L', Iconsax.wallet_3,
                    const Color(0xFF059669)),
              ],
            ),
            const SizedBox(height: 18),
            // SLA Commitment Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded,
                      color: Colors.greenAccent, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enterprise SLA Compliance: 99.4%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                        SizedBox(height: 2),
                        Text(
                            'Average Breakdown Response: 8.2 mins across 4 corporate contracts.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Corporate Accounts',
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Corporate contract onboarding modal.')),
                    );
                  },
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: AppColors.brandGreen),
                  label: const Text('+ Add Contract',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.brandGreen)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _corporateAccounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final account = _corporateAccounts[index];
                return _CorporateAccountCard(account: account);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            Text(title,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CorporateAccountCard extends StatelessWidget {
  final Map<String, dynamic> account;

  const _CorporateAccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final color = account['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Iconsax.building, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account['company'],
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    Text('${account['vehicles']} Vehicles Registered',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(account['tier'],
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contract Value',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                  Text(account['monthlyBilling'],
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SLA Breach Rate',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                  Text(account['slaBreachRate'],
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Active Roadside Calls',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                  Text('${account['activeRequests']} active',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: account['activeRequests'] > 0
                              ? const Color(0xFFDC2626)
                              : AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06, end: 0);
  }
}
