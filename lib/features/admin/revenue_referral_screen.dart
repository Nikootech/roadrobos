import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/admin_bottom_nav_bar.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

class RevenueDataPoint {
  final double x;
  final double y; // in Thousands (e.g. 19.8 = ₹19,800)
  final String label;
  final String date;
  final int orders;

  RevenueDataPoint({
    required this.x,
    required this.y,
    required this.label,
    required this.date,
    required this.orders,
  });
}

class RevenueReferralScreen extends StatefulWidget {
  const RevenueReferralScreen({super.key});

  @override
  State<RevenueReferralScreen> createState() => _RevenueReferralScreenState();
}

class _RevenueReferralScreenState extends State<RevenueReferralScreen> {
  String _selectedRange = '7D';
  int? _hoveredIndex;
  bool _showProfitCurve = false;
  double _liveFluctuation = 0.0;
  Timer? _liveTimer;

  // Datasets for Timeframes
  final Map<String, List<RevenueDataPoint>> _datasets = {
    '7D': [
      RevenueDataPoint(
          x: 0, y: 16.2, label: 'Mon', date: '10 Aug', orders: 28),
      RevenueDataPoint(
          x: 1, y: 21.5, label: 'Tue', date: '11 Aug', orders: 34),
      RevenueDataPoint(
          x: 2, y: 18.0, label: 'Wed', date: '12 Aug', orders: 31),
      RevenueDataPoint(
          x: 3, y: 25.4, label: 'Thu', date: '13 Aug', orders: 45),
      RevenueDataPoint(
          x: 4, y: 19.8, label: 'Fri', date: '14 Aug', orders: 39),
      RevenueDataPoint(
          x: 5, y: 31.0, label: 'Sat', date: '15 Aug', orders: 58),
      RevenueDataPoint(
          x: 6, y: 35.6, label: 'Sun', date: '16 Aug', orders: 64),
    ],
    '30D': [
      RevenueDataPoint(
          x: 0, y: 82.0, label: 'W1', date: '1-7 Jul', orders: 180),
      RevenueDataPoint(
          x: 1, y: 94.5, label: 'W2', date: '8-14 Jul', orders: 210),
      RevenueDataPoint(
          x: 2, y: 89.2, label: 'W3', date: '15-21 Jul', orders: 195),
      RevenueDataPoint(
          x: 3, y: 115.0, label: 'W4', date: '22-28 Jul', orders: 270),
    ],
    '90D': [
      RevenueDataPoint(
          x: 0, y: 320.0, label: 'May', date: 'May 2026', orders: 740),
      RevenueDataPoint(
          x: 1, y: 380.5, label: 'Jun', date: 'Jun 2026', orders: 860),
      RevenueDataPoint(
          x: 2, y: 442.0, label: 'Jul', date: 'Jul 2026', orders: 980),
    ],
    '1Y': [
      RevenueDataPoint(
          x: 0, y: 950.0, label: 'Q1', date: 'Q1 2026', orders: 2200),
      RevenueDataPoint(
          x: 1, y: 1240.0, label: 'Q2', date: 'Q2 2026', orders: 2950),
      RevenueDataPoint(
          x: 2, y: 1580.0, label: 'Q3', date: 'Q3 2026 (Est)', orders: 3600),
      RevenueDataPoint(
          x: 3, y: 1820.0, label: 'Q4', date: 'Q4 2026 (Proj)', orders: 4100),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Simulate subtle real-time telemetry pulsing
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _hoveredIndex == null) {
        setState(() {
          _liveFluctuation =
              (_liveFluctuation == 0.0) ? 0.35 : 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  List<RevenueDataPoint> get _currentPoints =>
      _datasets[_selectedRange] ?? _datasets['7D']!;

  @override
  Widget build(BuildContext context) {
    final points = _currentPoints;
    final activePt = (_hoveredIndex != null && _hoveredIndex! < points.length)
        ? points[_hoveredIndex!]
        : points.last;

    final activeRevenueVal =
        (activePt.y * (_showProfitCurve ? 0.38 : 1.0) * 1000);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: ScaleOnTap(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Revenue & Telemetry',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Live Financial Stream',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.radar_2, size: 14, color: Color(0xFF006241)),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF006241),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Revenue & Telemetry Console',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KPI SUMMARY GRID ───────────────────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.42,
              children: [
                _buildKpiCard('Total Revenue', '₹12.4L', '+18.4%',
                    Iconsax.wallet_3, const Color(0xFF006241), true),
                _buildKpiCard('Active Referrals', '1,284', '+12.1%',
                    Iconsax.profile_2user, const Color(0xFF0284C7), true),
                _buildKpiCard('Referral Payouts', '₹45.2K', '-4.8%',
                    Iconsax.money_send, const Color(0xFFD97706), false),
                _buildKpiCard('Avg. Order Value', '₹850', '+6.2%',
                    Iconsax.receipt_2, const Color(0xFF0D9488), true),
              ],
            ),

            const SizedBox(height: 18),

            // ── REVENUE GROWTH CHART CARD ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Revenue Growth',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            // Curve Switcher
                            ScaleOnTap(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _showProfitCurve = !_showProfitCurve;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _showProfitCurve
                                      ? const Color(0xFFF0F9FF)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _showProfitCurve
                                        ? const Color(0xFFBAE6FD)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _showProfitCurve
                                          ? Iconsax.chart_21
                                          : Iconsax.chart_2,
                                      size: 13,
                                      color: _showProfitCurve
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showProfitCurve
                                          ? 'Net Margin'
                                          : 'Gross Rev',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _showProfitCurve
                                            ? const Color(0xFF0284C7)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${activeRevenueVal.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: _showProfitCurve
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF006241),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${activePt.orders} Orders • ${activePt.date}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF006241),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hoveredIndex != null
                              ? 'Scrubbing point at ${activePt.label}'
                              : 'Touch or slide across the curve to inspect intervals',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Range Tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: ['7D', '30D', '90D', '1Y'].map((range) {
                        final isSelected = _selectedRange == range;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isSelected) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedRange = range;
                                  _hoveredIndex = null;
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  range,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interactive Chart
                  Container(
                    height: 210,
                    padding:
                        const EdgeInsets.only(right: 20, left: 6, bottom: 8),
                    child: _buildInteractiveChart(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── REFERRAL LEADERBOARD ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Referral Leaderboard',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Top Advocates',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildLeaderboardTile(index);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveChart() {
    final points = _currentPoints;
    final maxY =
        points.map((p) => p.y).reduce((a, b) => a > b ? a : b) * 1.25;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (response != null &&
                response.lineBarSpots != null &&
                response.lineBarSpots!.isNotEmpty) {
              final touchedIndex = response.lineBarSpots!.first.spotIndex;
              if (_hoveredIndex != touchedIndex) {
                HapticFeedback.selectionClick();
                setState(() {
                  _hoveredIndex = touchedIndex;
                });
              }
            }
          },
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: const Color(0xFF006241).withValues(alpha: 0.5),
                  dashArray: const [4, 4],
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: _showProfitCurve
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF006241),
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF0F172A),
            tooltipRoundedRadius: 10,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final pt = points[spot.spotIndex];
                final val = (pt.y * (_showProfitCurve ? 0.35 : 1.0) * 1000)
                    .toStringAsFixed(0);
                return LineTooltipItem(
                  '₹$val\n',
                  GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: pt.label,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).clamp(1.0, 500.0),
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFFF1F5F9),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: (maxY / 4).clamp(1.0, 500.0),
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                final text = value >= 100
                    ? '${(value).toInt()}k'
                    : '${value.toInt()}k';
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '₹$text',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                final isSelected = _hoveredIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    points[index].label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF006241)
                          : const Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            preventCurveOverShooting: true,
            color: _showProfitCurve
                ? const Color(0xFF0284C7)
                : const Color(0xFF006241),
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              checkToShowDot: (spot, barData) {
                return spot.x == (points.length - 1).toDouble() ||
                    spot.x == (_hoveredIndex?.toDouble() ?? -1);
              },
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: _showProfitCurve
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF006241),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _showProfitCurve
                    ? [
                        const Color(0xFF0284C7).withValues(alpha: 0.25),
                        const Color(0xFF0284C7).withValues(alpha: 0.0),
                      ]
                    : [
                        const Color(0xFF006241).withValues(alpha: 0.25),
                        const Color(0xFF006241).withValues(alpha: 0.0),
                      ],
              ),
            ),
            spots: List.generate(points.length, (i) {
              final p = points[i];
              final factor = _showProfitCurve ? 0.38 : 1.0;
              final val = (p.y * factor) +
                  (i == points.length - 1 && _hoveredIndex == null
                      ? _liveFluctuation
                      : 0);
              return FlSpot(p.x, val);
            }),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color accentColor,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.inter(
                    color: isPositive
                        ? const Color(0xFF006241)
                        : const Color(0xFFDC2626),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(int index) {
    final advocates = [
      {
        'name': 'Arun J.',
        'referrals': 42,
        'earned': '₹12,400',
        'badge': 'Top Influencer'
      },
      {
        'name': 'Sima K.',
        'referrals': 38,
        'earned': '₹10,800',
        'badge': 'Super Advocate'
      },
      {
        'name': 'Rahul V.',
        'referrals': 29,
        'earned': '₹8,200',
        'badge': 'Pro Referrer'
      },
      {
        'name': 'Meena P.',
        'referrals': 24,
        'earned': '₹6,900',
        'badge': 'Rising Star'
      },
    ];
    final adv = advocates[index];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: index == 0
                    ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                    : index == 1
                        ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                        : [const Color(0xFF006241), const Color(0xFF10B981)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      adv['name'] as String,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        adv['badge'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF006241),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${adv['referrals']} Successful Referrals',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            adv['earned'] as String,
            style: GoogleFonts.outfit(
              color: const Color(0xFF006241),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms * index).slideX(begin: 0.05, end: 0);
  }
}
