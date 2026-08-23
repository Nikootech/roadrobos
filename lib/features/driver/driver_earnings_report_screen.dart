import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class DriverEarningsReportScreen extends StatefulWidget {
  const DriverEarningsReportScreen({super.key});

  @override
  State<DriverEarningsReportScreen> createState() =>
      _DriverEarningsReportScreenState();
}

class _DriverEarningsReportScreenState extends State<DriverEarningsReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data per period
  static const _dailyData = [
    {'label': 'Mon', 'amount': 820.0},
    {'label': 'Tue', 'amount': 1140.0},
    {'label': 'Wed', 'amount': 970.0},
    {'label': 'Thu', 'amount': 1380.0},
    {'label': 'Fri', 'amount': 1620.0},
    {'label': 'Sat', 'amount': 2100.0},
    {'label': 'Sun', 'amount': 1750.0},
  ];

  static const _weeklyData = [
    {'label': 'W1', 'amount': 7200.0},
    {'label': 'W2', 'amount': 8400.0},
    {'label': 'W3', 'amount': 6900.0},
    {'label': 'W4', 'amount': 9200.0},
  ];

  static const _monthlyData = [
    {'label': 'May', 'amount': 28000.0},
    {'label': 'Jun', 'amount': 31500.0},
    {'label': 'Jul', 'amount': 29800.0},
    {'label': 'Aug', 'amount': 14200.0},
  ];

  List<Map<String, Object>> get _currentData {
    switch (_tabController.index) {
      case 0:
        return _dailyData;
      case 1:
        return _weeklyData;
      case 2:
        return _monthlyData;
      default:
        return _dailyData;
    }
  }

  double get _totalEarnings =>
      _currentData.fold(0.0, (sum, d) => sum + (d['amount'] as double));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    _buildTabBar(),
                    const SizedBox(height: 20),
                    _buildTotalCard(),
                    const SizedBox(height: 20),
                    _buildBarChart(),
                    const SizedBox(height: 20),
                    _buildSummaryStats(),
                    const SizedBox(height: 20),
                    _buildIncentiveTracker(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Earnings Report',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.brandGreenLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download_rounded,
                    color: AppColors.brandGreenLight, size: 14),
                const SizedBox(width: 4),
                Text('Export',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.brandGreenLight,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.brandGreen, AppColors.brandGreenMid],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle:
            GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Daily'),
          Tab(text: 'Weekly'),
          Tab(text: 'Monthly'),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandGreen, AppColors.brandGreenMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    'This Week',
                    'This Month',
                    '3-Month Total'
                  ][_tabController.index],
                  style:
                      GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${_totalEarnings.toInt()}',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('+12% vs last period',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildBarChart() {
    final data = _currentData;
    final maxAmount =
        data.map((d) => d['amount'] as double).reduce((a, b) => a > b ? a : b);
    const chartHeight = 160.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings Breakdown',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60)),
          const SizedBox(height: 16),
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final amount = d['amount'] as double;
                final barHeight = (amount / maxAmount) * (chartHeight - 30);
                final isMax = amount == maxAmount;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Amount label on tallest bar
                        if (isMax)
                          Text(
                            '₹${(amount / 1000).toStringAsFixed(1)}k',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: AppColors.brandGreenLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 60),
                          curve: Curves.easeOutCubic,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isMax
                                  ? [
                                      AppColors.brandGreenLight,
                                      AppColors.brandGreen
                                    ]
                                  : [
                                      AppColors.brandGreen
                                          .withValues(alpha: 0.7),
                                      AppColors.brandGreenMid
                                          .withValues(alpha: 0.5),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d['label'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildSummaryStats() {
    final stats = [
      {'icon': Icons.local_taxi_rounded, 'label': 'Total Trips', 'value': '47'},
      {'icon': Icons.speed_rounded, 'label': 'Total KM', 'value': '312 km'},
      {
        'icon': Icons.currency_rupee_rounded,
        'label': 'Avg/Trip',
        'value': '₹178'
      },
      {'icon': Icons.star_rounded, 'label': 'Rating', 'value': '4.87'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final stat = entry.value;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat['icon'] as IconData,
                    color: AppColors.brandGreenLight, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(stat['value'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    Text(stat['label'] as String,
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.white38)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
            delay: Duration(milliseconds: 200 + i * 80), duration: 400.ms);
      }).toList(),
    );
  }

  Widget _buildIncentiveTracker() {
    const ridesNeeded = 5;
    const ridesCompleted = 2;
    const bonus = 500;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.15),
            const Color(0xFFF97316).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFF59E0B), size: 22),
              const SizedBox(width: 10),
              Text(
                'Incentive Tracker',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete $ridesNeeded more rides to earn ₹$bonus bonus!',
            style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ridesCompleted / (ridesCompleted + ridesNeeded),
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$ridesCompleted/${ridesCompleted + ridesNeeded}',
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$ridesNeeded rides remaining · Bonus credited by end of week',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
