import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/taxi_provider.dart';
import '../../core/services/payment_service.dart';
import '../../features/profile/user_provider.dart';

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
                            _buildStatItem(
                              'Distance',
                              '${taxiState.distance.toStringAsFixed(1)} km',
                              Icons.directions_rounded,
                            ),
                            _buildStatItem(
                              'ETA',
                              taxiState.eta ?? '-- mins',
                              Icons.access_time_rounded,
                            ),
                            _buildStatItem(
                              'Vehicle',
                              taxiState.selectedOption?.title ?? 'Ride',
                              Icons.electric_rickshaw,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Rating Section
                  Text(
                    'How was your trip with ${taxiState.roadroboName ?? 'your driver'}?',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontSize: 16),
                  ),
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
                  
                  const SizedBox(height: 30),
                  
                  // Tipping Section
                  const Text('Add a Tip', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryNavy, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [0.0, 20.0, 50.0, 100.0].map((tip) {
                      final isSelected = taxiState.tipAmount == tip;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(taxiProvider.notifier).setTipAmount(tip);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!),
                            ),
                            child: Text(
                              tip == 0 ? 'No Tip' : '₹${tip.toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 800.ms),
                  
                  const SizedBox(height: 40),
                  
                  CustomButton(
                    label: taxiState.paymentMethod == 'Online' ? 'PAY ₹${(fare + taxiState.tipAmount).toStringAsFixed(0)} & FINISH' : 'DONE',
                    onPressed: () async {
                      if (taxiState.paymentMethod == 'Online') {
                        final authState = ref.read(userProvider);
                        final userId = authState.user?.id ?? 'guest';
                        final userEmail = authState.user?.email ?? 'user@roadrobos.com';
                        
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          
                          try {
                            final paymentDetails = PaymentDetails(
                              bookingId: taxiState.rideId ?? 'test_ride',
                              bookingType: BookingType.ride,
                              totalCost: fare + taxiState.tipAmount,
                              userId: userId,
                              contact: '9876543210',
                              email: userEmail,
                              description: 'RoadRobos Taxi Ride',
                            );
                            
                            // The service throws on failure. Await blocks until success.
                            await ref.read(paymentServiceProvider.notifier).startPayment(paymentDetails);
                            
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
                            );
                            return; // Stop here, do not complete rating or exit
                          }
                      }
                    
                      // Submit rating to Supabase if a ride exists
                      final rideId = ref.read(taxiProvider).rideId;
                      if (rideId != null && rideId.isNotEmpty && _selectedRating > 0) {
                        try {
                          await Supabase.instance.client
                              .from('ride_bookings')
                              .update({'customer_rating': _selectedRating})
                              .eq('id', rideId);
                        } catch (e) {
                          debugPrint('Failed to submit rating: $e');
                        }
                      }
                      ref.read(taxiProvider.notifier).reset();
                      if (context.mounted) context.go('/main/home');
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
