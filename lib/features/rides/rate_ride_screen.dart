import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_text_field.dart';

class RateRideScreen extends StatefulWidget {
  const RateRideScreen({super.key});

  @override
  State<RateRideScreen> createState() => _RateRideScreenState();
}

class _RateRideScreenState extends State<RateRideScreen> {
  bool? _isPositive;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => context.go('/main/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?u=roadrobo'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rate your Roadrobo',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 32),

            // Rating Selection (Simplified Rapido Style)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRatingButton(
                    true, 'Great', Icons.thumb_up_rounded, Colors.green),
                const SizedBox(width: 32),
                _buildRatingButton(
                    false, 'Bad', Icons.thumb_down_rounded, Colors.red),
              ],
            ),

            const SizedBox(height: 40),

            if (_isPositive != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Add a note',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _reviewController,
                hint: _isPositive! ? 'What did you like?' : 'What went wrong?',
                maxLines: 4,
              ),
            ],

            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback submitted!'),
                    backgroundColor: AppColors.primaryBlue,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.go('/main/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Submit Feedback',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(
      bool positive, String label, IconData icon, Color color) {
    final isSelected = _isPositive == positive;
    return GestureDetector(
      onTap: () => setState(() => _isPositive = positive),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isSelected ? color.withValues(alpha: 0.1) : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? color : Colors.transparent, width: 2),
            ),
            child:
                Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey)),
        ],
      ),
    );
  }
}
