import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

// --- MOCK DATA ---
class AdminDriver {
  final String id;
  final String name;
  final String joinDate;
  final double rating;
  final int rides;
  final int docsPending;
  final double walletRequest;
  final List<DriverDocument> documents;

  AdminDriver(this.id, this.name, this.joinDate, this.rating, this.rides, this.docsPending, this.walletRequest, this.documents);
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
    await Future.delayed(const Duration(milliseconds: 600));
    state = AsyncValue.data([
      AdminDriver('D201', 'Rajesh S.', 'Oct 2023', 4.8, 142, 2, 4500, [
        DriverDocument('Driving License', 'Pending', 'Yesterday'),
        DriverDocument('Vehicle RC', 'Pending', 'Yesterday'),
        DriverDocument('Aadhar Card', 'Approved', 'Oct 15'),
      ]),
      AdminDriver('D202', 'Vikas P.', 'Nov 2023', 4.5, 89, 0, 12000, [
        DriverDocument('Driving License', 'Approved', 'Nov 12'),
      ]),
      AdminDriver('D203', 'Arun M.', 'Jan 2024', 4.9, 320, 1, 0, [
        DriverDocument('Background Check', 'Pending', '2 days ago'),
      ]),
    ]);
  }

  void approveDoc(String driverId, String docTitle) {
    if (state.value == null) return;
    final current = state.value!;
    state = AsyncValue.data(current.map((d) {
      if (d.id != driverId) return d;
      final newDocs = d.documents.map((doc) => doc.title == docTitle ? DriverDocument(doc.title, 'Approved', doc.date) : doc).toList();
      final newPending = newDocs.where((doc) => doc.status == 'Pending').length;
      return AdminDriver(d.id, d.name, d.joinDate, d.rating, d.rides, newPending, d.walletRequest, newDocs);
    }).toList());
  }

  void approveWallet(String driverId) {
    if (state.value == null) return;
    final current = state.value!;
    state = AsyncValue.data(current.map((d) {
      if (d.id != driverId) return d;
      return AdminDriver(d.id, d.name, d.joinDate, d.rating, d.rides, d.docsPending, 0, d.documents);
    }).toList());
  }
}

final adminDriversProvider = NotifierProvider<AdminDriversNotifier, AsyncValue<List<AdminDriver>>>(() => AdminDriversNotifier());
final driverSearchProvider = StateProvider<String>((ref) => '');

// --- SCREEN ---
class DriverDatabaseScreen extends ConsumerWidget {
  const DriverDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(driverSearchProvider);
    final driversAsync = ref.watch(adminDriversProvider);

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
          'Driver Database',
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
                onChanged: (val) => ref.read(driverSearchProvider.notifier).state = val,
                decoration: const InputDecoration(
                  icon: Icon(Iconsax.search_normal, size: 20, color: AppColors.textSecondary),
                  hintText: 'Search by driver name or ID...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: driversAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              error: (err, stack) => const Center(child: Text('Error loading data')),
              data: (drivers) {
                final filtered = drivers.where((d) => d.name.toLowerCase().contains(search.toLowerCase()) || d.id.toLowerCase().contains(search.toLowerCase())).toList();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildDriverCard(context, ref, filtered[index]).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, WidgetRef ref, AdminDriver d) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          iconColor: AppColors.primaryBlue,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Text('🚗', style: TextStyle(fontSize: 18))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${d.name} (${d.id})', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Joined: ${d.joinDate} • ⭐ ${d.rating}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge('🚕', '${d.rides} Rides', AppColors.primaryBlue),
                if (d.docsPending > 0) _buildBadge('🪪', '${d.docsPending} Docs Pending', AppColors.dangerRed),
                if (d.walletRequest > 0) _buildBadge('💳', '₹${d.walletRequest.toInt()} Req', AppColors.warningAmber),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),

            // Wallet Requests
            if (d.walletRequest > 0) ...[
              Text('Wallet Withdrawal Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warningAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${d.walletRequest.toInt()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.warningAmber)),
                        const Text('Requested today', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningAmber, minimumSize: const Size(80, 32), padding: const EdgeInsets.symmetric(horizontal: 16)),
                      onPressed: () {
                         ref.read(adminDriversProvider.notifier).approveWallet(d.id);
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet request approved automatically.')));
                      },
                      child: const Text('Approve', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Documents Verification
            Text('Document Verification', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (d.documents.isEmpty)
              const Text('No documents uploaded.', style: TextStyle(color: AppColors.textMuted))
            else
              ...d.documents.map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${d.name} - ${doc.title}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.bgLightGrey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Center(
                                  child: Icon(Iconsax.document_text_1, size: 48, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle), child: const Icon(Iconsax.document, color: AppColors.textSecondary, size: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                              Text('Uploaded: ${doc.date}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (doc.status == 'Pending') ...[
                          const Icon(Icons.visibility_rounded, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, minimumSize: const Size(60, 28), padding: const EdgeInsets.symmetric(horizontal: 10)),
                            onPressed: () {
                              ref.read(adminDriversProvider.notifier).approveDoc(d.id, doc.title);
                            },
                            child: const Text('Verify', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          )
                        ] else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Approved', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                          )
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
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
}
