import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/taxi_provider.dart';

class RideCompleteScreen extends ConsumerStatefulWidget {
  const RideCompleteScreen({super.key});

  @override
  ConsumerState<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends ConsumerState<RideCompleteScreen> {
  late ConfettiController _confettiController;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);
    final fare = taxiState.selectedOption?.price ?? 247;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
                ),
              ),
            ),
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.primaryBlue, AppColors.primaryNavy, Colors.orange, Colors.green],
              numberOfParticles: 20,
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Success Badge with Glow
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 10),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms).shimmer(delay: 800.ms),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Ride Completed!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primaryNavy, letterSpacing: -1),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'You reached your destination safely.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Fare Card (Glassmorphism style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        const Text('TOTAL FARE', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 12, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(
                          '₹${fare.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: AppColors.primaryNavy, letterSpacing: -2),
                        ).animate().scale(delay: 400.ms, curve: Curves.elasticOut, duration: 800.ms),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Distance', '4.2 km', Icons.directions_rounded),
                            _buildStatItem('Time', '18 mins', Icons.access_time_rounded),
                            _buildStatItem('Co2 Saved', '1.2 kg', Icons.eco_rounded),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Rating Section
                  const Text('How was your trip with Sohan?', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontSize: 16)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = index + 1),
                        child: Icon(
                          index < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: index < _selectedRating ? Colors.orange : Colors.grey[300],
                          size: 50,
                        ).animate(target: index < _selectedRating ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2)).shake(),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  CustomButton(
                    label: 'DONE',
                    onPressed: () {
                      ref.read(taxiProvider.notifier).reset();
                      context.go('/main/home');
                    },
                  ).animate().fadeIn(delay: 1.seconds),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryNavy)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
