import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/service_booking_repository.dart';
import 'tech_rating_screen.dart';

/// Technician job completion screen — notes, photo evidence, and e-signature.
class TechJobCompletionScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String serviceName;
  final String customerName;

  const TechJobCompletionScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.customerName,
  });

  @override
  ConsumerState<TechJobCompletionScreen> createState() =>
      _TechJobCompletionScreenState();
}

class _TechJobCompletionScreenState
    extends ConsumerState<TechJobCompletionScreen> {
  final _notesController = TextEditingController();
  final _partsController = TextEditingController();

  // Simulated "uploaded" photos count
  int _photoCount = 0;
  bool _signatureAdded = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _partsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_signatureAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Please add customer signature before completing'),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await HapticFeedback.mediumImpact();

    try {
      await ref
          .read(serviceBookingRepositoryProvider)
          .updateServiceStatus(widget.bookingId, 'completed');

      if (mounted) {
        unawaited(Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TechRatingScreen(
              bookingId: widget.bookingId,
              serviceName: widget.serviceName,
              customerName: widget.customerName,
            ),
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete job: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Service Summary'),
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Completion Notes'),
                    _buildNotesField(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Parts Used (Optional)'),
                    _buildPartsField(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Photo Evidence'),
                    _buildPhotoGrid(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Customer Signature'),
                    _buildSignaturePad(),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Complete Job',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandGreen, AppColors.brandGreenMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.build_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.serviceName,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('Customer: ${widget.customerName}',
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Describe what was done, any issues found...',
          hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPartsField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _partsController,
        maxLines: 2,
        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'e.g., Engine oil (1L), Air filter...',
          hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        // Uploaded photos (simulated)
        ...List.generate(
          _photoCount,
          (i) => Container(
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.brandGreenLight.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.brandGreenLight, size: 24),
          ),
        ),
        // Add photo button
        if (_photoCount < 4)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _photoCount++);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded,
                      color: Colors.white38, size: 22),
                  SizedBox(height: 4),
                  Text('Add',
                      style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignaturePad() {
    return GestureDetector(
      onTap: () {
        // Simulate signature capture
        HapticFeedback.mediumImpact();
        setState(() => _signatureAdded = true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 100,
        decoration: BoxDecoration(
          color: _signatureAdded
              ? AppColors.brandGreen.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _signatureAdded
                ? AppColors.brandGreenLight.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.12),
            width: _signatureAdded ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _signatureAdded
                    ? Icons.check_circle_rounded
                    : Icons.draw_rounded,
                color: _signatureAdded
                    ? AppColors.brandGreenLight
                    : Colors.white38,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                _signatureAdded
                    ? 'Signature Captured ✓'
                    : 'Tap to add customer signature',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: _signatureAdded
                      ? AppColors.brandGreenLight
                      : Colors.white38,
                  fontWeight:
                      _signatureAdded ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Mark Job Complete',
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
