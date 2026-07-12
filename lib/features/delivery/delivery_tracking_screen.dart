// lib/features/delivery/delivery_tracking_screen.dart
// Customer screen: live order tracking with map + status timeline.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/models/delivery_order.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import 'delivery_providers.dart';

class DeliveryTrackingScreen extends ConsumerWidget {
  final String orderId;
  const DeliveryTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(deliveryTrackingProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: orderAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (order) {
          if (order == null) {
            return const _ErrorView(message: 'Order not found.');
          }
          return _TrackingContent(order: order);
        },
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────
class _TrackingContent extends ConsumerWidget {
  final DeliveryOrder order;
  const _TrackingContent({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: AppColors.bgLightGrey, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.textPrimary),
            ),
          ),
          title: const Text('Track Delivery',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
          actions: [
            _StatusBadge(status: order.status),
            const SizedBox(width: 16),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Live Map ──────────────────────────────────────
                _LiveMapCard(driverId: order.driverId, order: order),
                const SizedBox(height: 24),

                // ── ETA Card ──────────────────────────────────────
                if (order.driverId != null &&
                    order.status != DeliveryStatus.delivered &&
                    order.status != DeliveryStatus.cancelled)
                  _EtaCard(order: order),
                if (order.driverId != null) const SizedBox(height: 16),

                // ── Status Timeline ───────────────────────────────
                _buildSectionTitle('Order Timeline'),
                const SizedBox(height: 12),
                _StatusTimeline(currentStatus: order.status),
                const SizedBox(height: 24),

                // ── Order Details ─────────────────────────────────
                _buildSectionTitle('Package Info'),
                const SizedBox(height: 12),
                _OrderDetailCard(order: order),

                // ── Proof Image ───────────────────────────────────
                if (order.proofImageUrl != null) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Delivery Proof'),
                  const SizedBox(height: 12),
                  _ProofImageCard(url: order.proofImageUrl!),
                ],

                const SizedBox(height: 32),

                // ── Actions ───────────────────────────────────────
                if (order.status == DeliveryStatus.delivered ||
                    order.status == DeliveryStatus.cancelled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/main/home'),
                      icon: const Icon(Iconsax.home, size: 18),
                      label: const Text('Return to Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary));
}

// ── Live Map ──────────────────────────────────────────────────────────────────
class _LiveMapCard extends StatelessWidget {
  final String? driverId;
  final DeliveryOrder order;
  const _LiveMapCard({this.driverId, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Stack(
        children: [
          LiveMapWidget(
            height: 220,
            driverId: driverId,
            isTracking: driverId != null,
            showLiveIndicator: driverId != null,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

// ── ETA Card ──────────────────────────────────────────────────────────────────
class _EtaCard extends StatelessWidget {
  final DeliveryOrder order;
  const _EtaCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF6366F1), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Arrival',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700)),
                Text(
                  _getEta(order.status),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6366F1)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  String _getEta(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.accepted:
        return 'Driver heading to pickup · ~15 min';
      case DeliveryStatus.pickedUp:
        return 'Package picked up · ~20 min';
      case DeliveryStatus.inTransit:
        return 'On the way · ~10 min';
      default:
        return 'Calculating...';
    }
  }
}

// ── Status Timeline ───────────────────────────────────────────────────────────
class _StatusTimeline extends StatelessWidget {
  final DeliveryStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  static const _steps = [
    (
      DeliveryStatus.pending,
      'Order Placed',
      'Waiting for a driver to accept',
      Iconsax.box
    ),
    (
      DeliveryStatus.accepted,
      'Driver Accepted',
      'Driver is heading to pickup',
      Iconsax.truck
    ),
    (
      DeliveryStatus.pickedUp,
      'Package Picked Up',
      'Your package is with the driver',
      Iconsax.bag_2
    ),
    (
      DeliveryStatus.inTransit,
      'In Transit',
      'Your package is on the way',
      Iconsax.routing
    ),
    (
      DeliveryStatus.delivered,
      'Delivered',
      'Package delivered successfully',
      Iconsax.tick_circle
    ),
  ];

  int get _currentIndex {
    if (currentStatus == DeliveryStatus.cancelled) return -1;
    return _steps.indexWhere((s) => s.$1 == currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == DeliveryStatus.cancelled) {
      return _CancelledBanner();
    }
    final ci = _currentIndex;
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
        children: List.generate(_steps.length, (i) {
          final step = _steps[i];
          final isDone = i <= ci;
          final isActive = i == ci;
          final isLast = i == _steps.length - 1;
          return _TimelineStep(
            icon: step.$4,
            title: step.$2,
            subtitle: step.$3,
            isDone: isDone,
            isActive: isActive,
            isLast: isLast,
          ).animate().fadeIn(delay: (i * 80).ms);
        }),
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Iconsax.close_circle, color: AppColors.dangerRed, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Cancelled',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dangerRed)),
                Text('This delivery was cancelled.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF6366F1);
    const doneColor = AppColors.verifiedGreen;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? (isActive ? activeColor : doneColor)
                    : AppColors.bgLightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone && !isActive ? Icons.check_rounded : icon,
                color: isDone ? Colors.white : AppColors.textMuted,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDone && !isActive ? doneColor : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Order Details Card ────────────────────────────────────────────────────────
class _OrderDetailCard extends StatelessWidget {
  final DeliveryOrder order;
  const _OrderDetailCard({required this.order});

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
          _DetailRow(
              icon: Iconsax.note_text,
              label: 'Package',
              value: order.packageDescription.isEmpty
                  ? '—'
                  : order.packageDescription),
          _DetailRow(
              icon: Iconsax.weight,
              label: 'Weight',
              value: '${order.weightKg.toStringAsFixed(1)} kg'),
          _DetailRow(
              icon: Iconsax.location,
              label: 'Pickup',
              value: order.pickupAddress),
          _DetailRow(
              icon: Iconsax.routing,
              label: 'Dropoff',
              value: order.dropoffAddress),
          _DetailRow(
              icon: Iconsax.receipt_1,
              label: 'Estimated',
              value: '₹${order.estimatedPrice.toStringAsFixed(0)}',
              highlight: true),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: highlight
                        ? const Color(0xFF6366F1)
                        : AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Proof Image ───────────────────────────────────────────────────────────────
class _ProofImageCard extends StatelessWidget {
  final String url;
  const _ProofImageCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Image.network(url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
                child:
                    Icon(Iconsax.image, size: 40, color: AppColors.textMuted),
              )),
    ).animate().fadeIn(delay: 200.ms);
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (status) {
      case DeliveryStatus.delivered:
        bg = AppColors.verifiedGreen.withValues(alpha: 0.12);
        text = AppColors.verifiedGreen;
        break;
      case DeliveryStatus.cancelled:
        bg = AppColors.dangerRed.withValues(alpha: 0.12);
        text = AppColors.dangerRed;
        break;
      case DeliveryStatus.inTransit:
      case DeliveryStatus.pickedUp:
        bg = AppColors.warningAmber.withValues(alpha: 0.15);
        text = AppColors.accentAmber;
        break;
      default:
        bg = const Color(0xFF6366F1).withValues(alpha: 0.1);
        text = const Color(0xFF6366F1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: text)),
    );
  }
}

// ── Loading/Error States ──────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2,
                  size: 48, color: AppColors.dangerRed),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => context.pop(), child: const Text('Go Back')),
            ],
          ),
        ),
      ),
    );
  }
}
