import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

class RideCompleteScreen extends StatefulWidget {
  const RideCompleteScreen({super.key});

  @override
  State<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends State<RideCompleteScreen> {
  late ConfettiController _confettiController;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [AppColors.primaryBlue, AppColors.primaryNavy, Colors.white],
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Success Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 100),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack, duration: 600.ms),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Arrived Safely!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 12),
                
                Text(
                  'Your trip with Sohan is complete.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 48),
                
                // Fare Column
                const Text('Fare Summary', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text(
                  '₹247.00',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                ).animate().scale(delay: 600.ms),
                
                const SizedBox(height: 40),
                
                // Rating Section
                const Text('Rate your Captain', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => _selectedRating = index + 1),
                      icon: Icon(
                        index < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.primaryBlue,
                        size: 44,
                      ),
                    );
                  }),
                ).animate().fadeIn(delay: 800.ms),
                
                const Spacer(),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CustomButton(
                        label: 'GIVE FEEDBACK',
                        onPressed: () {
                           context.push('/taxi/feedback');
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          context.go('/main/home');
                        },
                        child: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
