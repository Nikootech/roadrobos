import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';

// --- MOCK DATA ---
class AdminCustomer {
  final String id;
  final String name;
  final String joinDate;
  final double ltv;
  final int rides;
  final int rentals;
  final int services;
  final List<CustomerActivity> activities;

  AdminCustomer(this.id, this.name, this.joinDate, this.ltv, this.rides, this.rentals, this.services, this.activities);
}

class CustomerActivity {
  final String type; // 'Ride', 'Rental', 'Service'
  final String title;
  final String status;
  final String date;

  CustomerActivity(this.type, this.title, this.status, this.date);
}

final adminCustomersProvider = StreamProvider<List<AdminCustomer>>((ref) async* {
  final repo = ref.read(adminOpsRepositoryProvider);
  
  // For a production app, we would use a real-time stream if needed, 
  // but for a database view, a Future converted to a Stream is often enough 
  // or we can use a polling mechanism.
  final customers = await repo.getAllCustomers();
  
  yield customers.map((map) {
    final id = map['id']?.toString().substring(0, 4).toUpperCase() ?? 'NEW';
    final name = map['name'] ?? 'Unknown User';
    final createdAt = map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : DateTime.now();
    
    // Format date as "Oct 2023"
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[createdAt.month - 1]} ${createdAt.year}';

    return AdminCustomer(
      id,
      name,
      dateStr,
      (map['ltv'] ?? 0).toDouble(),
      map['total_rides'] ?? 0,
      map['total_rentals'] ?? 0,
      map['total_services'] ?? 0,
      [], // Activities could be fetched separately if needed
    );
  }).toList();
});

final customerSearchProvider = StateProvider<String>((ref) => '');

// --- SCREEN ---
class CustomerDatabaseScreen extends ConsumerWidget {
  const CustomerDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(customerSearchProvider);
    final customersAsync = ref.watch(adminCustomersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Customer Database',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                onChanged: (val) => ref.read(customerSearchProvider.notifier).state = val,
                decoration: const InputDecoration(
                  icon: Icon(Iconsax.search_normal, size: 20, color: AppColors.textSecondary),
                  hintText: 'Search by customer name or ID...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              error: (err, stack) => const Center(child: Text('Error loading data')),
              data: (customers) {
                final filtered = customers.where((c) => c.name.toLowerCase().contains(search.toLowerCase()) || c.id.toLowerCase().contains(search.toLowerCase())).toList();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildCustomerCard(filtered[index]).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(AdminCustomer c) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          iconColor: AppColors.primaryBlue,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.name} (${c.id})', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Joined: ${c.joinDate} • LTV: ₹${c.ltv.toInt()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                _buildBadge('🚕', '${c.rides} Rides', AppColors.primaryBlue),
                const SizedBox(width: 8),
                _buildBadge('🚗', '${c.rentals} Rentals', AppColors.successGreen),
                const SizedBox(width: 8),
                _buildBadge('🔧', '${c.services} Services', AppColors.warningAmber),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Text('Recent Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (c.activities.isEmpty)
              const Text('No recent activity.', style: TextStyle(color: AppColors.textMuted))
            else
              ...c.activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getTypeIcon(a.type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                          Text(a.date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _getStatusBg(a.status), borderRadius: BorderRadius.circular(6)),
                      child: Text(a.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusText(a.status))),
                    )
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'Ride': icon = Icons.local_taxi_rounded; color = AppColors.primaryBlue; break;
      case 'Rental': icon = Iconsax.car; color = AppColors.successGreen; break;
      case 'Service': icon = Icons.build_rounded; color = AppColors.warningAmber; break;
      default: icon = Icons.history; color = AppColors.textSecondary;
    }
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16));
  }

  Color _getStatusBg(String status) {
    if (status.contains('Ongoing') || status.contains('Progress')) return AppColors.primaryBlue.withValues(alpha: 0.1);
    if (status.contains('Completed')) return AppColors.successGreen.withValues(alpha: 0.1);
    if (status.contains('Scheduled')) return AppColors.warningAmber.withValues(alpha: 0.1);
    return AppColors.bgLightGrey;
  }

  Color _getStatusText(String status) {
    if (status.contains('Ongoing') || status.contains('Progress')) return AppColors.primaryBlue;
    if (status.contains('Completed')) return AppColors.successGreen;
    if (status.contains('Scheduled')) return AppColors.warningAmber;
    return AppColors.textSecondary;
  }
}

