import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';

class LiveServiceStatusScreen extends StatelessWidget {
  const LiveServiceStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/main/home'),
          child: const Center(
            child: Icon(Icons.close_rounded, size: 24, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Service Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vehicle Info Card
            _buildVehicleStatusCard(),
            const SizedBox(height: 24),
            
            // Progress Steps
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Live Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressStep('Vehicle Picked Up', 'Technician is on the way to the hub', true, true),
            _buildProgressStep('Inspection Started', 'Checking all vital components', true, true),
            _buildProgressStep('Servicing in Progress', 'Oil change and brake cleaning', true, false),
            _buildProgressStep('Quality Check', 'Final testing and verification', false, false),
            _buildProgressStep('Ready for Delivery', 'Vehicle is being cleaned', false, false),
            
            const SizedBox(height: 32),
            
            // Tech info
            _buildTechnicianInfo(context),
            
            const SizedBox(height: 32),
            CustomButton(
              label: 'Back to Home',
              onPressed: () => context.go('/main/home'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.chat_bubble_rounded),
        label: const Text('Chat with Tech'),
      ),
    );
  }

  Widget _buildVehicleStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_rounded, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hyundai Creta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('MH 02 AB 1234', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Text('₹ 1,499', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Completion', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('05:30 PM Today', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  Widget _buildProgressStep(String title, String subtitle, bool completed, bool current) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? AppColors.successGreen : (current ? AppColors.primaryBlue : AppColors.bgLightGrey),
                shape: BoxShape.circle,
                border: current ? Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 4) : null,
              ),
              child: completed 
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : (current ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)) : null),
            ),
            Container(
              width: 2,
              height: 40,
              color: completed ? AppColors.successGreen : AppColors.bgLightGrey,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: completed || current ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTechnicianInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=tech'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suresh Kumar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Senior Technician', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => NavHelpers.showSnackAction(context, 'Calling technician...', icon: Icons.call_rounded, color: AppColors.successGreen),
            icon: const Icon(Icons.call_rounded, color: AppColors.successGreen),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

