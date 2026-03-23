import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';
import '../technician/technician_provider.dart';

class LiveServiceStatusScreen extends ConsumerStatefulWidget {
  const LiveServiceStatusScreen({super.key});

  @override
  ConsumerState<LiveServiceStatusScreen> createState() => _LiveServiceStatusScreenState();
}

class _LiveServiceStatusScreenState extends ConsumerState<LiveServiceStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Start the mock progress simulation when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(technicianProvider.notifier).startMockProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(technicianProvider);
    
    if (job == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        title: Text(
          'Service Status: ${job.id}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vehicle Info Card
            _buildVehicleStatusCard(job),
            const SizedBox(height: 24),
            
            // Progress Steps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(job.progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Dynamically build progress steps from checklist
            ...List.generate(job.checklist.length, (index) {
              final step = job.checklist[index];
              final bool isCompleted = step.isDone;
              final bool isCurrent = !isCompleted && 
                  (index == 0 || job.checklist[index - 1].isDone);
              
              return _buildProgressStep(
                step.task, 
                step.category, 
                isCompleted, 
                isCurrent,
                isLast: index == job.checklist.length - 1,
              );
            }),
            
            const SizedBox(height: 32),
            
            // Tech info
            _buildTechnicianInfo(context),
            
            const SizedBox(height: 32),
            CustomButton(
              label: 'Back to Home',
              onPressed: () => context.go('/main/home'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(technicianProvider.notifier).resetProgress();
                ref.read(technicianProvider.notifier).startMockProgress();
              },
              child: const Text('Restart Simulation', style: TextStyle(color: AppColors.textSecondary)),
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

  Widget _buildVehicleStatusCard(TechnicianJob job) {
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
                  color: (job.vehicleModel.toLowerCase().contains('car') || job.vehicleModel.toLowerCase().contains('creta')) 
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (job.vehicleModel.toLowerCase().contains('car') || job.vehicleModel.toLowerCase().contains('creta'))
                      ? AppColors.primaryBlue.withValues(alpha: 0.2)
                      : AppColors.accentOrange.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  (job.vehicleModel.toLowerCase().contains('car') || job.vehicleModel.toLowerCase().contains('creta'))
                    ? Icons.directions_car_rounded 
                    : Icons.pedal_bike_rounded, 
                  color: (job.vehicleModel.toLowerCase().contains('car') || job.vehicleModel.toLowerCase().contains('creta'))
                    ? AppColors.primaryBlue 
                    : AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${job.serviceType} - ${job.packageName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${job.vehicleModel} (${job.vehiclePlate})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Scheduled: ${job.date} at ${job.time}', style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job.price,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Completion', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(job.estimatedCompletion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  Widget _buildProgressStep(String title, String subtitle, bool completed, bool current, {bool isLast = false}) {
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
                : (current ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)) : null),
            ),
            if (!isLast)
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
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
    ).animate().fadeIn(delay: 200.ms);
  }
}

