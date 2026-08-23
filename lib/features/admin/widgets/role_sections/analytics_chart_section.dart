import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';

/// Enterprise Interactive Time-Series Analytics & Performance Chart.
class AnalyticsChartSection extends StatefulWidget {
  const AnalyticsChartSection({super.key});

  @override
  State<AnalyticsChartSection> createState() => _AnalyticsChartSectionState();
}

class _AnalyticsChartSectionState extends State<AnalyticsChartSection> {
  String _selectedRange = '7D';
  int _selectedMetricIndex = 0; // 0: Revenue, 1: Rides, 2: Services

  final List<String> _ranges = ['Today', '7D', '30D', '90D'];

  // Mocked time-series values scaled according to selected range
  List<double> get _chartPoints {
    switch (_selectedRange) {
      case 'Today':
        return [0.2, 0.4, 0.35, 0.6, 0.5, 0.85, 0.9, 0.75];
      case '7D':
        return [0.3, 0.45, 0.4, 0.7, 0.65, 0.85, 0.95];
      case '30D':
        return [0.25, 0.35, 0.5, 0.45, 0.6, 0.75, 0.7, 0.85, 0.8, 0.95];
      case '90D':
        return [0.2, 0.3, 0.45, 0.6, 0.55, 0.7, 0.8, 0.75, 0.9, 1.0];
      default:
        return [0.3, 0.5, 0.4, 0.7, 0.65, 0.85, 0.95];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Range Selector
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Telemetry',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Time-series velocity & metrics',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Range Segmented Control
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _ranges.map((range) {
                    final isSelected = range == _selectedRange;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedRange = range);
                      },
                      borderRadius: BorderRadius.circular(7),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          range,
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? AppColors.brandGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metric toggles
          Row(
            children: [
              _buildMetricChip(
                  0, 'Gross GMV', Iconsax.wallet_3, const Color(0xFF059669)),
              const SizedBox(width: 8),
              _buildMetricChip(
                  1, 'Ride Volume', Iconsax.routing_2, const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              _buildMetricChip(2, 'Service Bookings', Iconsax.setting_4,
                  const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 18),
          // Interactive Custom Painted Area Chart
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _AreaChartPainter(
                points: _chartPoints,
                color: _selectedMetricIndex == 0
                    ? const Color(0xFF059669)
                    : _selectedMetricIndex == 1
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFD97706),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          // Unit Economics Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _UnitMetricItem(
                    title: 'Avg Fare', value: '₹342', trend: '+4.2%'),
                _UnitMetricItem(
                    title: 'Rev / Driver', value: '₹1,850', trend: '+8.1%'),
                _UnitMetricItem(
                    title: 'Completion', value: '94.6%', trend: '+1.4%'),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildMetricChip(int index, String label, IconData icon, Color color) {
    final isSelected = _selectedMetricIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedMetricIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isSelected ? color : AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitMetricItem extends StatelessWidget {
  final String title;
  final String value;
  final String trend;

  const _UnitMetricItem({
    required this.title,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          trend,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.brandGreen,
          ),
        ),
      ],
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _AreaChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (points.length - 1);

    path.moveTo(0, size.height * (1.0 - points[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1.0 - points[0]));

    for (int i = 1; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height * (1.0 - points[i]);

      final prevX = (i - 1) * stepX;
      final prevY = size.height * (1.0 - points[i - 1]);

      final controlX1 = prevX + (x - prevX) / 2;
      final controlX2 = prevX + (x - prevX) / 2;

      path.cubicTo(controlX1, prevY, controlX2, y, x, y);
      fillPath.cubicTo(controlX1, prevY, controlX2, y, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill with smooth gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // Draw active indicator point at end
    final lastX = size.width;
    final lastY = size.height * (1.0 - points.last);

    final outerDot = Paint()..color = color.withValues(alpha: 0.3);
    final innerDot = Paint()..color = color;
    final centerWhite = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(lastX, lastY), 7, outerDot);
    canvas.drawCircle(Offset(lastX, lastY), 4.5, innerDot);
    canvas.drawCircle(Offset(lastX, lastY), 2, centerWhite);
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
