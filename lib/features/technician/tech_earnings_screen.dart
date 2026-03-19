import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class TechEarningsScreen extends StatefulWidget {
  const TechEarningsScreen({super.key});

  @override
  State<TechEarningsScreen> createState() => _TechEarningsScreenState();
}

class _TechEarningsScreenState extends State<TechEarningsScreen> {
  int _bottomNavIndex = 3; // Default to Profile (or common entry point)

  void _onBottomNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0: context.go('/tech-dashboard'); break;
      case 1: context.go('/tech-tasks'); break;
      case 2: context.go('/tech-spare-parts'); break;
      case 3: context.go('/tech-profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryIndigo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Service Earnings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top Summary (Technician Indigo Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            decoration: const BoxDecoration(
              color: primaryIndigo,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
            child: Column(
              children: [
                const Text('NET EARNINGS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                const Text('₹18,250.00', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildQuickStat(Iconsax.task_square, 'Jobs', '56'),
                    _buildDivider(),
                    _buildQuickStat(Iconsax.timer_1, 'Service Hrs', '142h'),
                    _buildDivider(),
                    _buildQuickStat(Iconsax.star, 'Rating', '4.8'),
                  ],
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/driver-bank-withdrawal'); // Generic withdrawal route
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Text('Cash Out Profits', style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ).animate().scale(delay: 400.ms),
              ],
            ),
          ).animate().slideY(begin: -0.1, end: 0, duration: 600.ms),

          // Payout History & Performance
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payout History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryIndigo, letterSpacing: -0.5)),
                    Icon(Iconsax.filter, color: primaryIndigo, size: 20),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPayoutRow('Oct 16 - Oct 22', '₹6,450', 'Settled', Colors.green),
                _buildPayoutRow('Oct 09 - Oct 15', '₹7,200', 'Settled', Colors.green),
                _buildPayoutRow('Current Week', '₹4,600', 'In Review', Colors.orange),
                
                const SizedBox(height: 40),
                const Text('Job Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryIndigo, letterSpacing: -0.5)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar('M', 0.4),
                          _buildBar('T', 0.7),
                          _buildBar('W', 0.9, isMax: true),
                          _buildBar('T', 0.6),
                          _buildBar('F', 0.8),
                          _buildBar('S', 0.3),
                          _buildBar('S', 0.2),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Wednesday was your peak performance day!', 
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F2F4))),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Iconsax.home5, 'Home', 0),
          _navItem(context, Iconsax.task_square5, 'Jobs', 1),
          _navItem(context, Iconsax.box, 'Parts', 2),
          _navItem(context, Iconsax.user, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = _bottomNavIndex == index;
    const primaryIndigo = Color(0xFF1A237E);
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8EAF6) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isActive ? primaryIndigo : Colors.grey, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? primaryIndigo : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.white12);
  }

  Widget _buildPayoutRow(String date, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), 
                child: Icon(Iconsax.money_tick, color: color, size: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                  const SizedBox(height: 2),
                  Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percent, {bool isMax = false}) {
    const primaryIndigo = Color(0xFF1A237E);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 80 * percent,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isMax 
                ? [primaryIndigo, const Color(0xFF3949AB)]
                : [primaryIndigo.withValues(alpha: 0.1), primaryIndigo.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Text(day, style: TextStyle(fontSize: 11, color: isMax ? primaryIndigo : Colors.grey, fontWeight: isMax ? FontWeight.w900 : FontWeight.w600)),
      ],
    );
  }
}
