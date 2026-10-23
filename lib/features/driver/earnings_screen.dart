import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/repositories/ride_booking_repository.dart';
import '../../core/models/ride_booking.dart';
import '../../features/profile/user_provider.dart';
import 'providers/driver_state_provider.dart';
import 'driver_earnings_report_screen.dart';

/// Driver Earnings Screen — connected to real Supabase driver stream data.
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  List<RideBooking> _rides = [];
  bool _isLoadingRides = true;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    try {
      final user = ref.read(userProvider);
      final driverId = user.user?.id ?? 'demo';
      final rides = await ref
          .read(rideBookingRepositoryProvider)
          .getPagedDriverRides(driverId);
      if (mounted) {
        setState(() {
          _rides = rides.where((r) => r.status == 'completed').toList();
          _isLoadingRides = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRides = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(earningsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Earnings Overview',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DriverEarningsReportScreen()),
            ),
            icon: const Icon(Icons.bar_chart_rounded,
                color: AppColors.brandGreenLight, size: 18),
            label: const Text(
              'Report',
              style: TextStyle(
                  color: AppColors.brandGreenLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              _fetchRides();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top Summary — real data from earningsProvider stream
          earningsAsync.when(
            loading: () => const LinearProgressIndicator(
                color: AppColors.brandGreen, minHeight: 3),
            error: (_, __) => const SizedBox.shrink(),
            data: (earnings) => Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepNavy,
                    Color(0xFF004D32),
                    AppColors.brandGreen
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const Text('TOTAL EARNINGS TODAY',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text(
                    NumberFormat.simpleCurrency(name: 'INR')
                        .format(earnings.todayEarnings),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 32),
                  // Glassmorphism stats row — real values
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        _buildQuickStat(
                            Iconsax.car, 'Rides', '${earnings.totalRides}'),
                        _buildDivider(),
                        _buildQuickStat(
                            Iconsax.clock, 'Online', earnings.onlineTime),
                        _buildDivider(),
                        _buildQuickStat(
                            Iconsax.chart_1, 'Accept', earnings.acceptanceRate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/driver-bank-withdrawal');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: const Text('Cash Out to Bank',
                          style: TextStyle(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ).animate().scale(delay: 400.ms),
                ],
              ),
            ).animate().slideY(begin: -0.1, end: 0, duration: 600.ms),
          ),

          // Payout History — real completed rides from Supabase
          Expanded(
            child: _isLoadingRides
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primaryBlue))
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    children: [
                      _buildDailyIncentiveCard(_rides.length),
                      const SizedBox(height: 28),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Completed Rides',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5)),
                          Icon(Iconsax.filter,
                              color: AppColors.textPrimary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_rides.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text('No completed rides yet.',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600)),
                          ),
                        )
                      else
                        ..._rides.map((ride) {
                          final dateStr = DateFormat('MMM dd, yyyy')
                              .format(ride.createdAt.toLocal());
                          return _buildPremiumPayoutRow(
                            dateStr,
                            NumberFormat.simpleCurrency(name: 'INR')
                                .format(ride.fare),
                            'Completed',
                            AppColors.successGreen,
                          );
                        }),

                      const SizedBox(height: 48),
                      // Weekly earnings summary
                      earningsAsync.maybeWhen(
                        data: (earnings) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Weekly Overview',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColors.border
                                        .withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10))
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildWeeklyStat(
                                    'Weekly Rides',
                                    '${earnings.weeklyRides}',
                                    Iconsax.car,
                                    AppColors.primaryBlue,
                                  ),
                                  Container(
                                      width: 1,
                                      height: 48,
                                      color: AppColors.border),
                                  _buildWeeklyStat(
                                    'Weekly Earnings',
                                    NumberFormat.compactSimpleCurrency(
                                            name: 'INR', decimalDigits: 0)
                                        .format(earnings.weeklyEarnings),
                                    Iconsax.wallet,
                                    AppColors.successGreen,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.white12);
  }

  Widget _buildWeeklyStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPremiumPayoutRow(
      String date, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => HapticFeedback.selectionClick(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(Iconsax.empty_wallet_tick,
                            color: color, size: 20)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(status,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(amount,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepNavy)),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildDailyIncentiveCard(int completedCount) {
    const targetCount = 5;
    final progress = (completedCount / targetCount).clamp(0.0, 1.0);
    final isUnlocked = completedCount >= targetCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? AppColors.brandGreenMid.withValues(alpha: 0.4)
              : AppColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
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
                  color: isUnlocked
                      ? AppColors.brandGreenBg
                      : AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isUnlocked
                      ? Icons.emoji_events_rounded
                      : Icons.military_tech_rounded,
                  color: isUnlocked
                      ? AppColors.brandGreenMid
                      : AppColors.accentOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked
                          ? '🎉 Daily Incentive Unlocked!'
                          : 'Daily Quest: Earn ₹150 Bonus',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUnlocked
                          ? '₹150 bonus credited to your wallet'
                          : 'Complete 5 trips today to unlock ₹150 bonus',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.brandGreenMid
                      : AppColors.bgLightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUnlocked ? 'EARNED' : '₹150',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isUnlocked ? Colors.white : AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgLightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? AppColors.brandGreenMid : AppColors.accentOrange,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount of $targetCount trips completed',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
