import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/banner_offer_repository.dart';

class ManageOffersScreen extends ConsumerWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Offers & Coupons',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Offer Button
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (ctx) => Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewInsets.bottom),
                    child: const _CreateOfferForm(),
                  ),
                );
              },
              icon: const Icon(Iconsax.ticket_2, size: 20),
              label: const Text('Create New Offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),

            const SizedBox(height: 32),
            const Text('Active Campaigns',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildOfferCard('WELCOME50', '50% off on first ride',
                'Expired in 4 days', true),
            const SizedBox(height: 12),
            _buildOfferCard(
                'FESTIVE20', '20% discount on rentals', 'Active', true),
            const SizedBox(height: 12),
            _buildOfferCard(
                'ROAdROBoS10', 'Flat ₹100 off on services', 'Active', true),

            const SizedBox(height: 32),
            const Text('Drafts & Expired',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildOfferCard(
                'SUMMER40', '40% seasonal discount', 'Expired', false),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
      String code, String desc, String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isActive
                ? AppColors.primaryBlue.withValues(alpha: 0.3)
                : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: (isActive ? AppColors.primaryBlue : AppColors.textMuted)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Iconsax.ticket_discount,
                color: isActive ? AppColors.primaryBlue : AppColors.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1)),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Text(status,
                    style: TextStyle(
                        color: isActive
                            ? AppColors.successGreen
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class _CreateOfferForm extends ConsumerStatefulWidget {
  const _CreateOfferForm();

  @override
  ConsumerState<_CreateOfferForm> createState() => _CreateOfferFormState();
}

class _CreateOfferFormState extends ConsumerState<_CreateOfferForm> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _ctaController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(bannerOfferRepositoryProvider).createOffer(
            title: title,
            subtitle: _subtitleController.text.trim(),
            image: _imageController.text.trim().isEmpty
                ? 'assets/banners/b3.jpg'
                : _imageController.text.trim(),
            cta: _ctaController.text.trim().isEmpty
                ? 'Claim Now'
                : _ctaController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Offer created!'),
            backgroundColor: AppColors.successGreen));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed: $e'), backgroundColor: AppColors.dangerRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Create New Offer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(
              controller: _subtitleController,
              decoration:
                  const InputDecoration(labelText: 'Subtitle / Description')),
          const SizedBox(height: 12),
          TextField(
              controller: _ctaController,
              decoration: const InputDecoration(
                  labelText: 'Button Text (e.g. Claim Now)')),
          const SizedBox(height: 12),
          TextField(
              controller: _imageController,
              decoration:
                  const InputDecoration(labelText: 'Image URL (optional)')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Create Offer'),
          ),
        ],
      ),
    );
  }
}
