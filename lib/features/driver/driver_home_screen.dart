import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Driver App - Home Screen matching Figma Screen [8]
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, Rajesh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.warningAmber, size: 14),
                    SizedBox(width: 4),
                    Text('4.8 Rating', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: AppColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card (350x218)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isOnline ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.textMuted.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isOnline ? AppColors.successGreen : AppColors.textMuted,
                          shape: BoxShape.circle,
                          boxShadow: _isOnline ? [BoxShadow(color: AppColors.successGreen.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 4)] : [],
                        ),
                        child: Icon(_isOnline ? Icons.wifi_tethering : Icons.wifi_tethering_off, color: Colors.white),
                      )
                      .animate(target: _isOnline ? 1 : 0)
                      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut)
                      .then(delay: 0.ms).scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 1.seconds, curve: Curves.easeInOut),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_isOnline ? 'You\'re Online' : 'You\'re Offline', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(_isOnline ? 'Searching for nearby rides...' : 'Go online to start receiving rides', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => setState(() => _isOnline = !_isOnline),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isOnline ? AppColors.dangerRed : AppColors.successGreen,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (_isOnline ? AppColors.dangerRed : AppColors.successGreen).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isOnline ? Icons.power_settings_new_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isOnline ? 'GO OFFLINE' : 'GO ONLINE', 
                            style: GoogleFonts.outfit(
                              fontSize: 15, 
                              fontWeight: FontWeight.w800, 
                              color: Colors.white, 
                              letterSpacing: 1.2
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Earnings Card (350x193)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.deepNavy, AppColors.primaryBlue]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Today\'s Earnings', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      GestureDetector(
                        onTap: () => context.push('/driver-earnings'),
                        child: const Row(
                          children: [
                            Text('Details', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10)
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text('₹1,250', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Text('+₹120 Bonus', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Time Online', '4h 30m'),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildStatColumn('Total Rides', '8'),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildStatColumn('Acceptance', '95%'),
                    ],
                  )
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                TextButton(
                  onPressed: () { if(_isOnline) context.push('/driver-ride-request'); },
                  child: const Text('Simulate Ride Request'), 
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!_isOnline)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.directions_car_filled_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('Go online to see ride requests', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
               // Teaser for an incoming ride
               GestureDetector(
                onTap: () => context.push('/driver-ride-request'),
                child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                       child: const Icon(Icons.person, color: AppColors.primaryBlue),
                     ),
                     const SizedBox(width: 16),
                     const Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('New Ride Request!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                           SizedBox(height: 4),
                           Text('2 mins away • 4.5km Drop', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                         ],
                       ),
                     ),
                     const Text('₹180', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.successGreen)),
                   ],
                 ),
                ),
               ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

