import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class TechnicianDashboardScreen extends StatelessWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wednesday, 25 Oct', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      Text('Good Morning, Rahul', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                    ],
                  ),
                  _buildProfileAvatar(),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Main Stats
              _buildMainPerformanceCard(),

              const SizedBox(height: 24),

              // 3. Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildActionCard('New Job', Iconsax.add_square, const Color(0xFF5E6AD2), () => context.push('/tech-create-job'))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionCard('Inventory', Iconsax.box, const Color(0xFFFF9F43), () => context.push('/tech-spare-parts'))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionCard('Performance', Iconsax.chart_21, const Color(0xFF28C76F), () => {})),
                ],
              ),

              const SizedBox(height: 32),

              // 4. Recent Jobs / Tasks preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                  TextButton(
                    onPressed: () => context.push('/tech-tasks'),
                    child: const Text('View All', style: TextStyle(color: Color(0xFF5E6AD2), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTaskPreviewItem('Hyundai Creta SX', 'XYZ-1234', 'In-Progress', '10 AM'),
              _buildTaskPreviewItem('Maruti Swift Dzire', 'ABC-9988', 'To-Do', '01 PM'),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E9F0),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: const Center(child: Icon(Icons.person_rounded, color: Color(0xFF1A237E))),
    );
  }

  Widget _buildMainPerformanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEEKLY PERFORMANCE', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  SizedBox(height: 4),
                  Text('12 Jobs Completed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                    SizedBox(width: 4),
                    Text('+20%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Simple Bar Chart Placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Mon', 0.4),
              _buildChartBar('Tue', 0.6),
              _buildChartBar('Wed', 0.9),
              _buildChartBar('Thu', 0.5),
              _buildChartBar('Fri', 0.7),
              _buildChartBar('Sat', 0.3),
              _buildChartBar('Sun', 0.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double percent) {
    return Column(
      children: [
        Container(
          width: 25,
          height: 80 * percent,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: percent > 0.8 ? 1.0 : 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPreviewItem(String vehicle, String plate, String status, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F2F4), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.directions_car_rounded, color: Color(0xFF1A237E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1A237E))),
                Text('$plate • $time', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'In-Progress' ? const Color(0xFFE8EAF6) : const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'In-Progress' ? const Color(0xFF1A237E) : Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

