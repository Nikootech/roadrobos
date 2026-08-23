import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/admin_bottom_nav_bar.dart';

// --- DRIVER MODEL ---
class AdminDriver {
  final String id;
  final String name;
  final String phone;
  final String joinDate;
  final double rating;
  final int rides;
  final int docsPending;
  final double walletRequest;
  final List<DriverDocument> documents;

  AdminDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinDate,
    required this.rating,
    required this.rides,
    required this.docsPending,
    required this.walletRequest,
    required this.documents,
  });
}

class DriverDocument {
  final String title;
  final String status;
  final String date;
  DriverDocument(this.title, this.status, this.date);
}

class AdminDriversNotifier extends Notifier<AsyncValue<List<AdminDriver>>> {
  @override
  AsyncValue<List<AdminDriver>> build() {
    _init();
    return const AsyncValue.loading();
  }

  void _init() async {
    try {
      final repo = ref.read(adminOpsRepositoryProvider);
      final drivers = await repo.getAllDrivers();

      state = AsyncValue.data(drivers.map((map) {
        final rawId = map['id']?.toString() ?? '';
        final id = rawId.length > 8 ? rawId.substring(0, 8).toUpperCase() : (rawId.isNotEmpty ? rawId.toUpperCase() : 'DRV-NEW');
        final name = map['name'] ?? map['full_name'] ?? 'RoadRobos Partner Driver';
        final phone = map['phone'] ?? '+91 98700 11223';
        final createdAt = map['created_at'] != null
            ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
            : DateTime.now();

        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final dateStr = '${months[createdAt.month - 1]} ${createdAt.year}';

        final docs = (map['kyc_documents'] as List?)?.map((d) {
              return DriverDocument(
                d['title'] ?? 'Document',
                d['status'] ?? 'Pending',
                d['uploaded_at']?.toString().split('T')[0] ?? 'Recently',
              );
            }).toList() ??
            [];

        return AdminDriver(
          id: id,
          name: name,
          phone: phone,
          joinDate: dateStr,
          rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
          rides: (map['total_rides'] as int?) ?? 45,
          docsPending: docs.where((d) => d.status.toLowerCase() == 'pending').length,
          walletRequest: (map['wallet_request'] as num?)?.toDouble() ?? 0.0,
          documents: docs,
        );
      }).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> approveDoc(String driverId, String docTitle) async {
    try {
      await ref
          .read(adminOpsRepositoryProvider)
          .updateDriverKycStatus(driverId, docTitle, 'Approved');
      _init(); // Refresh data
    } catch (e) {
      debugPrint('Error approving doc: $e');
    }
  }

  Future<void> approveWallet(String driverId) async {
    try {
      await ref
          .read(adminOpsRepositoryProvider)
          .approveWalletWithdrawal(driverId);
      _init(); // Refresh data
    } catch (e) {
      debugPrint('Error approving wallet: $e');
    }
  }
}

final adminDriversProvider =
    NotifierProvider<AdminDriversNotifier, AsyncValue<List<AdminDriver>>>(
        () => AdminDriversNotifier());
final driverSearchProvider = StateProvider<String>((ref) => '');
final driverFilterProvider = StateProvider<String>((ref) => 'All');

// --- SCREEN ---
class DriverDatabaseScreen extends ConsumerWidget {
  const DriverDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(driverSearchProvider);
    final activeFilter = ref.watch(driverFilterProvider);
    final driversAsync = ref.watch(adminDriversProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 65,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Database & KYC',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Fleet partners, document audits & withdrawals',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandGreenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.refresh,
                  size: 18, color: AppColors.brandGreen),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(adminDriversProvider);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                // Modern Search Field
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Iconsax.search_normal_1,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) =>
                              ref.read(driverSearchProvider.notifier).state = val,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by driver name, phone, or ID...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withValues(alpha: 0.9),
                            ),
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        GestureDetector(
                          onTap: () =>
                              ref.read(driverSearchProvider.notifier).state = '',
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textMuted),
                          ),
                        )
                      else
                        const SizedBox(width: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Tabs Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(ref, 'All', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Pending KYC', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Wallet Requests', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Top Rated (⭐4.8+)', activeFilter),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: driversAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandGreen),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.warning_2, size: 40, color: AppColors.dangerRed),
                    const SizedBox(height: 12),
                    Text('Failed to load driver database',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandGreen),
                      onPressed: () => ref.invalidate(adminDriversProvider),
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
              data: (drivers) {
                final filtered = drivers.where((d) {
                  final matchesSearch = d.name.toLowerCase().contains(search.toLowerCase()) ||
                      d.id.toLowerCase().contains(search.toLowerCase()) ||
                      d.phone.toLowerCase().contains(search.toLowerCase());
                  if (!matchesSearch) return false;

                  if (activeFilter == 'Pending KYC') return d.docsPending > 0;
                  if (activeFilter == 'Wallet Requests') return d.walletRequest > 0;
                  if (activeFilter == 'Top Rated (⭐4.8+)') return d.rating >= 4.8;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.car, size: 48, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            search.isNotEmpty ? 'No drivers matching "$search"' : 'No drivers in this filter',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            search.isNotEmpty ? 'Try searching with another name or ID.' : 'Try changing your filter.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(driverSearchProvider.notifier).state = '';
                              ref.read(driverFilterProvider.notifier).state = 'All';
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 16),
                            label: const Text('Reset Search & Filters'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandGreen,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final totalPending = drivers.fold<int>(0, (sum, d) => sum + d.docsPending);
                      final totalWithdrawals = drivers.fold<double>(0.0, (sum, d) => sum + d.walletRequest);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Total Partners', '${drivers.length}', Colors.white),
                              Container(width: 1, height: 28, color: Colors.white24),
                              _buildSummaryItem('Pending KYC', '$totalPending', const Color(0xFFFBBF24)),
                              Container(width: 1, height: 28, color: Colors.white24),
                              _buildSummaryItem('Withdrawal Req', '₹${totalWithdrawals.toInt()}', const Color(0xFF34D399)),
                            ],
                          ),
                        ),
                      );
                    }

                    final driver = filtered[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDriverCard(context, ref, driver)
                          .animate()
                          .fadeIn(delay: (index * 40).ms)
                          .slideY(begin: 0.08, end: 0),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String current) {
    final isSelected = label == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(driverFilterProvider.notifier).state = label;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.brandGreen : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, WidgetRef ref, AdminDriver d) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          iconColor: AppColors.brandGreen,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandGreenBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Iconsax.car, color: AppColors.brandGreen, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            d.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${d.id}',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.phone} • Joined: ${d.joinDate}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(
                    d.rating.toStringAsFixed(1),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBadge('🚕', '${d.rides} Completed Rides', const Color(0xFF0284C7)),
                if (d.docsPending > 0)
                  _buildBadge('🪪', '${d.docsPending} Docs Pending', const Color(0xFFDC2626)),
                if (d.walletRequest > 0)
                  _buildBadge('💳', '₹${d.walletRequest.toInt()} Req', const Color(0xFFD97706)),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 6),

            // Wallet Requests Section
            if (d.walletRequest > 0) ...[
              Text('Pending Wallet Withdrawal', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${d.walletRequest.toInt()}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: const Color(0xFFD97706))),
                        const Text('Immediate Bank Payout Requested', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        ref.read(adminDriversProvider.notifier).approveWallet(d.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payout approved & initiated!'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: const Text('Approve Payout', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Document Verification Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KYC Verification Documents', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                Text('${d.documents.length} Docs', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            if (d.documents.isEmpty)
              const Text('No KYC documents submitted yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 12))
            else
              ...d.documents.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Iconsax.document, size: 16, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
                                Text('Uploaded: ${doc.date}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          if (doc.status.toLowerCase() == 'pending')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandGreen,
                                elevation: 0,
                                minimumSize: const Size(60, 28),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                ref.read(adminDriversProvider.notifier).approveDoc(d.id, doc.title);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${doc.title} verified for ${d.name}'), behavior: SnackBarBehavior.floating),
                                );
                              },
                              child: const Text('Verify', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                              child: const Text('VERIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.brandGreen)),
                            )
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
