// lib/features/delivery/create_delivery_screen.dart
// Customer screen: create a new delivery order.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'delivery_providers.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  ConsumerState<CreateDeliveryScreen> createState() =>
      _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> {
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(deliveryOrderProvider);
    final notifier = ref.read(deliveryOrderProvider.notifier);

    // Listen for errors
    ref.listen<DeliveryFormState>(deliveryOrderProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.createdOrder != null && prev?.createdOrder == null) {
        context.push(
          '/delivery/tracking/${next.createdOrder!.id}',
        );
        notifier.reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Addresses ──────────────────────────────────
                    const _SectionHeader(title: 'Addresses', icon: Iconsax.location),
                    const SizedBox(height: 12),
                    _AddressCard(
                      pickupCtrl: _pickupCtrl,
                      dropoffCtrl: _dropoffCtrl,
                      onPickupChanged: notifier.setPickup,
                      onDropoffChanged: notifier.setDropoff,
                    ),
                    const SizedBox(height: 24),

                    // ── Package Details ────────────────────────────
                    const _SectionHeader(title: 'Package Details', icon: Iconsax.box),
                    const SizedBox(height: 12),
                    _PackageDetailsCard(
                      descCtrl: _descCtrl,
                      formState: formState,
                      onDescChanged: notifier.setDescription,
                      onWeightChanged: notifier.setWeight,
                    ),
                    const SizedBox(height: 24),

                    // ── Price Estimate ─────────────────────────────
                    _PriceEstimateCard(formState: formState)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1),

                    const SizedBox(height: 32),

                    // ── Submit ─────────────────────────────────────
                    CustomButton(
                      label: 'PLACE DELIVERY ORDER',
                      isLoading: formState.isSubmitting,
                      onPressed: formState.isSubmitting
                          ? null
                          : () async {
                              unawaited(HapticFeedback.mediumImpact());
                              await notifier.submitOrder();
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.bgLightGrey,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.box, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New Delivery',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5),
                  ),
                  const Text(
                    'Fast & secure package delivery',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text(
          'New Delivery',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17),
        ),
        titlePadding:
            const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final TextEditingController pickupCtrl;
  final TextEditingController dropoffCtrl;
  final ValueChanged<String> onPickupChanged;
  final ValueChanged<String> onDropoffChanged;

  const _AddressCard({
    required this.pickupCtrl,
    required this.dropoffCtrl,
    required this.onPickupChanged,
    required this.onDropoffChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Pickup
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: Color(0xFF6366F1), shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Pickup Address',
                  hint: 'Enter pickup location',
                  controller: pickupCtrl,
                  prefixIcon: Iconsax.location,
                  onChanged: onPickupChanged,
                ),
              ),
            ],
          ),
          // Connector line
          Row(
            children: [
              const SizedBox(width: 4),
              Container(width: 2, height: 24, color: AppColors.border),
            ],
          ),
          // Dropoff
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.dangerRed, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Dropoff Address',
                  hint: 'Enter delivery location',
                  controller: dropoffCtrl,
                  prefixIcon: Iconsax.routing,
                  onChanged: onDropoffChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

class _PackageDetailsCard extends StatelessWidget {
  final TextEditingController descCtrl;
  final DeliveryFormState formState;
  final ValueChanged<String> onDescChanged;
  final ValueChanged<double> onWeightChanged;

  const _PackageDetailsCard({
    required this.descCtrl,
    required this.formState,
    required this.onDescChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Package Description',
            hint: 'e.g., Electronics, Clothing, Documents...',
            controller: descCtrl,
            prefixIcon: Iconsax.note_text,
            onChanged: onDescChanged,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Package Weight',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${formState.weightKg.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: AppColors.bgLightGrey,
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: formState.weightKg.clamp(0.5, 50.0),
              min: 0.5,
              max: 50.0,
              divisions: 99,
              onChanged: (v) => onWeightChanged(double.parse(v.toStringAsFixed(1))),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.5 kg',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
              Text('50 kg',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05);
  }
}

class _PriceEstimateCard extends StatelessWidget {
  final DeliveryFormState formState;
  const _PriceEstimateCard({required this.formState});

  @override
  Widget build(BuildContext context) {
    final price = formState.estimatedPrice;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Price',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1),
                ),
                const SizedBox(height: 4),
                Text(
                  'Base ₹50 + ₹${(5 * formState.weightKg).toStringAsFixed(0)} (weight) + ₹${(8 * formState.estimatedDistanceKm).toStringAsFixed(0)} (dist)',
                  style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.receipt_1, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
