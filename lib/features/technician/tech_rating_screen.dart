import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Post-job rating screen shown to the technician after job completion.
class TechRatingScreen extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String customerName;

  const TechRatingScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.customerName,
  });

  @override
  State<TechRatingScreen> createState() => _TechRatingScreenState();
}

class _TechRatingScreenState extends State<TechRatingScreen> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];

  static const _colors = [
    Colors.transparent,
    Color(0xFFF43F5E),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
    Color(0xFF06B6D4),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccess(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  children: [
                    _buildCompletedBadge(),
                    const SizedBox(height: 32),
                    _buildRatingStars(),
                    const SizedBox(height: 24),
                    _buildCommentField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/main/technician'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Rate This Job',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandGreen, AppColors.brandGreenMid],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGreen.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
        )
            .animate()
            .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut)
            .fadeIn(),
        const SizedBox(height: 16),
        Text(
          'Job Completed!',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          '${widget.serviceName} · ${widget.customerName}',
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Column(
      children: [
        Text(
          'How did this job go?',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            final isSelected = star <= _selectedRating;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRating = star);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isSelected
                      ? const Color(0xFFFBBF24)
                      : Colors.white.withValues(alpha: 0.2),
                  size: 44,
                ),
              ).animate(target: isSelected ? 1 : 0).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 150.ms),
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _selectedRating > 0
                ? _colors[_selectedRating]
                : Colors.transparent,
          ),
          child: Text(_selectedRating > 0 ? _labels[_selectedRating] : '-'),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildCommentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 3,
        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Any notes about this job? (optional)',
          hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedRating == 0
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    setState(() => _submitted = true);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              disabledBackgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              _selectedRating == 0 ? 'Select a rating' : 'Submit Rating',
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/main/technician'),
          child: Text('Skip for now',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white38)),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _buildSuccess(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy animation
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF59E0B),
                        Color(0xFFF97316),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 52),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 700.ms)
                    .fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'Thank you!',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  'Your feedback helps us improve\nservice quality.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 15, color: Colors.white54, height: 1.5),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/main/technician'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Dashboard',
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
