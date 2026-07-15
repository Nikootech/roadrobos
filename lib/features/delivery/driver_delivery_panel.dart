// lib/features/delivery/driver_delivery_panel.dart
// Driver-side widget: incoming delivery request cards + active delivery actions.
// Designed to be embedded in DriverHomeScreen as an overlay panel.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/delivery_order.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'delivery_providers.dart';

// ── Top-level exported widget ─────────────────────────────────────────────────

/// Renders driver-side delivery UI:
/// - Pending request card (if there are pending orders and driver has no active)
/// - Active delivery action card (picked up / in transit / mark delivered)
class DriverDeliveryPanel extends ConsumerWidget {
  const DriverDeliveryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDelivery = ref.watch(activeDeliveryProvider);
    final pendingAsync = ref.watch(pendingDeliveryRequestsProvider);
    final declinedIds = ref.watch(declinedOrderIdsProvider);

    // Show active delivery actions first
    if (activeDelivery != null) {
      return _ActiveDeliveryCard(order: activeDelivery);
    }

    // Otherwise show first pending request (ignoring locally declined ones)
    return pendingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (pending) {
        final visible = pending.where((o) => !declinedIds.contains(o.id)).toList();
        if (visible.isEmpty) return const SizedBox.shrink();
        return _IncomingRequestCard(order: visible.first);
      },
    );
  }
}

// ── Incoming Request Card ─────────────────────────────────────────────────────
class _IncomingRequestCard extends ConsumerStatefulWidget {
  final DeliveryOrder order;
  const _IncomingRequestCard({required this.order});

  @override
  ConsumerState<_IncomingRequestCard> createState() => _IncomingRequestCardState();
}

class _IncomingRequestCardState extends ConsumerState<_IncomingRequestCard> {
  bool _isAccepting = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final notifier = ref.read(activeDeliveryProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('NEW DELIVERY REQUEST',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6366F1),
                        letterSpacing: 0.5)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgLightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${order.weightKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Addresses
          _AddressRow(
            icon: Icons.radio_button_checked_rounded,
            color: const Color(0xFF6366F1),
            label: 'PICKUP',
            address: order.pickupAddress,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(width: 2, height: 20, color: AppColors.border),
          ),
          const SizedBox(height: 8),
          _AddressRow(
            icon: Icons.location_on_rounded,
            color: AppColors.dangerRed,
            label: 'DROPOFF',
            address: order.dropoffAddress,
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Package info + price
          Row(
            children: [
              Expanded(
                child: _StatChip(
                    icon: Iconsax.box,
                    label: 'PACKAGE',
                    value: order.packageDescription.isEmpty
                        ? 'Parcel'
                        : order.packageDescription,
                    color: const Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                    icon: Iconsax.receipt_1,
                    label: 'EARNINGS',
                    value: '₹${order.estimatedPrice.toStringAsFixed(0)}',
                    color: AppColors.verifiedGreen),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(declinedOrderIdsProvider.notifier)
                        .update((set) => {...set, order.id});
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'ACCEPT',
                  isLoading: _isAccepting,
                  backgroundColor: const Color(0xFF6366F1),
                  onPressed: _isAccepting
                      ? null
                      : () async {
                          unawaited(HapticFeedback.heavyImpact());
                          setState(() => _isAccepting = true);
                          try {
                            await notifier.acceptDelivery(order);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to accept: $e'),
                                  backgroundColor: AppColors.dangerRed,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isAccepting = false);
                            }
                          }
                        },
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(delay: 1.seconds, duration: 1.5.seconds),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .scale(
            begin: const Offset(0.9, 0.9),
            duration: 400.ms,
            curve: Curves.easeOutBack)
        .fadeIn();
  }
}

// ── Active Delivery Card ──────────────────────────────────────────────────────
class _ActiveDeliveryCard extends ConsumerStatefulWidget {
  final DeliveryOrder order;
  const _ActiveDeliveryCard({required this.order});

  @override
  ConsumerState<_ActiveDeliveryCard> createState() =>
      _ActiveDeliveryCardState();
}

class _ActiveDeliveryCardState extends ConsumerState<_ActiveDeliveryCard> {
  bool _isLoading = false;
  String? _proofUrl;

  Future<void> _markPickedUp() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(activeDeliveryProvider.notifier).markPickedUp();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markDelivered() async {
    setState(() => _isLoading = true);
    try {
      final url = await ref
          .read(activeDeliveryProvider.notifier)
          .markDeliveredWithProof();
      if (mounted && url != null) {
        setState(() => _proofUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Delivery completed & proof uploaded!'),
            backgroundColor: AppColors.verifiedGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openNavigation() async {
    // Deep link to Google Maps with pickup coordinates
    // In production, geocode from pickup_address; for now use a Maps search
    final address = Uri.encodeComponent(widget.order.pickupAddress);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (order.status) {
      case DeliveryStatus.accepted:
        statusColor = const Color(0xFF6366F1);
        statusLabel = 'Head to Pickup';
        statusIcon = Iconsax.direct_up;
        break;
      case DeliveryStatus.pickedUp:
        statusColor = AppColors.accentOrange;
        statusLabel = 'In Transit';
        statusIcon = Iconsax.truck;
        break;
      case DeliveryStatus.inTransit:
        statusColor = AppColors.accentAmber;
        statusLabel = 'Nearly There';
        statusIcon = Iconsax.routing;
        break;
      default:
        statusColor = AppColors.verifiedGreen;
        statusLabel = 'Delivered!';
        statusIcon = Iconsax.tick_circle;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(statusLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(order.status.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Route info
                _AddressRow(
                    icon: Icons.radio_button_checked_rounded,
                    color: const Color(0xFF6366F1),
                    label: 'PICKUP',
                    address: order.pickupAddress),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child:
                      Container(width: 2, height: 16, color: AppColors.border),
                ),
                const SizedBox(height: 6),
                _AddressRow(
                    icon: Icons.location_on_rounded,
                    color: AppColors.dangerRed,
                    label: 'DROPOFF',
                    address: order.dropoffAddress),

                const SizedBox(height: 16),

                // Package chip + price
                Row(
                  children: [
                    Chip(
                      avatar: const Icon(Iconsax.box, size: 14),
                      label: Text(
                          order.packageDescription.isEmpty
                              ? 'Package'
                              : order.packageDescription,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                      backgroundColor: AppColors.bgLightGrey,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Spacer(),
                    Text('₹${order.estimatedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepNavy)),
                  ],
                ),

                const SizedBox(height: 16),

                // Proof image thumbnail if uploaded
                if (_proofUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_proofUrl!,
                        height: 80, width: double.infinity, fit: BoxFit.cover),
                  ),
                if (_proofUrl != null) const SizedBox(height: 12),

                // Action buttons
                if (order.status == DeliveryStatus.accepted) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openNavigation,
                          icon: const Icon(Iconsax.direct_up, size: 16),
                          label: const Text('Navigate'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: statusColor),
                            foregroundColor: statusColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'MARK PICKED UP',
                          isLoading: _isLoading,
                          backgroundColor: statusColor,
                          onPressed: _isLoading ? null : _markPickedUp,
                        ),
                      ),
                    ],
                  ),
                ] else if (order.status == DeliveryStatus.pickedUp ||
                    order.status == DeliveryStatus.inTransit) ...[
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: '📷  MARK DELIVERED',
                      isLoading: _isLoading,
                      backgroundColor: statusColor,
                      onPressed: _isLoading ? null : _markDelivered,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.verifiedGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.tick_circle,
                            color: AppColors.verifiedGreen, size: 20),
                        SizedBox(width: 8),
                        Text('Delivery Complete!',
                            style: TextStyle(
                                color: AppColors.verifiedGreen,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05);
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────
class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;
  const _AddressRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              Text(address,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
                Text(value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
