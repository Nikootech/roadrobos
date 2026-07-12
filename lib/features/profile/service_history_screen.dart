import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import '../../core/repositories/service_booking_repository.dart';
import 'package:roadrobos/core/services/auth_service.dart';

class ServiceHistoryScreen extends ConsumerWidget {
  const ServiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authNotifierProvider).value?.id;
    final servicesAsync = userId != null
        ? ref
            .watch(serviceBookingRepositoryProvider)
            .getPagedCustomerServiceBookings(userId, limit: 50)
        : Future<List>.value([]);

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
        title: const Text('Service History',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: servicesAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      size: 80,
                      color: AppColors.textMuted.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('No service history found',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildHistoryCard(service, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(dynamic service, BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(service.createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.bgDarkCard : Colors.white;
    final textCol = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final subTextCol =
        isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;
    final borderCol = isDark ? Colors.transparent : AppColors.border;

    return GestureDetector(
      onTap: () => context.push('/service-booking-detail/${service.id}'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.packageName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textCol,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              service.vehicleName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subTextCol,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(service),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${service.totalCost}',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: subTextCol,
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextCol,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => NavHelpers.showSuccess(
                      context, 'Invoice PDF downloaded successfully!'),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Invoice'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildBadge(dynamic service) {
    final status = service.status;
    final detailsMap = service.details is Map ? service.details as Map : {};
    final method = detailsMap['method'] ?? 'Cash';
    final isPaid = status == 'paid' || status == 'completed';

    Color bg;
    Color fg;
    String label;

    if (status == 'refunded') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      label = 'Refunded';
    } else if (isPaid) {
      if (method == 'Online' || method == 'Razorpay') {
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        label = 'Online';
      } else {
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Paid';
      }
    } else {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
      label = 'Pay at Center';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
