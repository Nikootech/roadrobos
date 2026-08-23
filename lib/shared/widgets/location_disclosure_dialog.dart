import 'package:flutter/material.dart';

/// A prominent disclosure dialog required by Google Play Console policies
/// for apps accessing foreground and background location data.
///
/// Google Policy Requirements:
/// 1. Must be prominent and displayed prior to requesting runtime permissions.
/// 2. Must explicitly state what data is collected (Location data).
/// 3. Must explain usage (Driver dispatch, ride tracking, delivery monitoring, emergency SOS).
/// 4. Must state if used in the background ("even when the app is closed or not in use").
/// 5. Must require an affirmative user action (Separate Accept / Decline buttons).
class LocationDisclosureDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback? onDecline;
  final bool isBackgroundRequired;

  const LocationDisclosureDialog({
    super.key,
    required this.onAccept,
    this.onDecline,
    this.isBackgroundRequired = true,
  });

  /// Displays the prominent disclosure dialog.
  /// Returns `true` if the user consented, `false` otherwise.
  static Future<bool> show(
    BuildContext context, {
    bool isBackgroundRequired = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LocationDisclosureDialog(
        isBackgroundRequired: isBackgroundRequired,
        onAccept: () => Navigator.of(ctx).pop(true),
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF2E7D32); // RoadRobos Brand Green

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Location Access & Tracking',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Main Explanation
                Text(
                  'RoAd RoBo\'s collects location data to enable core mobility features:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Feature Bullet Points
                _buildFeatureRow(
                  icon: Icons.local_taxi_rounded,
                  title: 'Ride Booking & Navigation',
                  subtitle:
                      'Calculates pickup points, accurate fares, and real-time turn-by-turn navigation.',
                ),
                const SizedBox(height: 10),
                _buildFeatureRow(
                  icon: Icons.local_shipping_rounded,
                  title: 'Package Delivery Tracking',
                  subtitle:
                      'Tracks real-time dispatch routes and ETA for senders and recipients.',
                ),
                const SizedBox(height: 10),
                _buildFeatureRow(
                  icon: Icons.emergency_rounded,
                  title: 'Emergency Assistance (SOS)',
                  subtitle:
                      'Pinpoints your exact location for rapid response teams during roadside emergencies.',
                ),
                const SizedBox(height: 10),

                if (isBackgroundRequired) ...[
                  _buildFeatureRow(
                    icon: Icons.sync_rounded,
                    title: 'Background Location Updates',
                    subtitle:
                        'Location data is accessed even when the app is closed or not in use during active rides, driver shifts, or delivery tracking to provide continuous live safety monitoring.',
                    isHighlight: true,
                  ),
                  const SizedBox(height: 12),
                ],

                // Privacy Commitment Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 20, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your location data is encrypted in transit and is never sold to third parties or used for advertisements.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          'Not Now',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Agree & Continue',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHighlight = false,
  }) {
    final color =
        isHighlight ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHighlight
                ? color.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? color : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
