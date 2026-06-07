import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallet_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/wallet_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/notification_service.dart';

/// Wallet & Transactions Screen matching Figma Screen [7]
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  List<double> _computeRunningBalances(List<WalletTransaction> transactions, double currentBalance) {
    final List<double> balances = List.filled(transactions.length, 0.0);
    if (transactions.isEmpty) return balances;

    double temp = currentBalance;
    for (int i = 0; i < transactions.length; i++) {
      balances[i] = temp;
      final t = transactions[i];
      if (t.type == TransactionType.credit) {
        temp -= t.amount;
      } else {
        temp += t.amount;
      }
    }
    return balances;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final transactionsState = ref.watch(walletTransactionsProvider);
    final currentBalance = walletAsync.value?.balance ?? 0.0;
    
    final runningBalances = _computeRunningBalances(transactionsState.transactions, currentBalance);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          await ref.read(walletTransactionsProvider.notifier).loadInitial();
        },
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          slivers: [
            // Premium Header with Mesh-style Gradient
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              backgroundColor: AppColors.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Background Pattern/Blur for "Mesh" effect
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 120, // Leave space for Verified badge
                      bottom: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Available Balance',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: walletAsync.when(
                              data: (wallet) => Text(
                                NumberFormat.simpleCurrency(name: 'INR').format(wallet?.balance ?? 0.0),
                                style: GoogleFonts.outfit(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              loading: () => const SizedBox(
                                height: 42,
                                width: 100,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              error: (_, __) => const Text('₹--'),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                    Positioned(
                      right: 20,
                      bottom: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Verified',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Primary Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionTile(
                            context,
                            'Top Up',
                            Iconsax.add,
                            AppColors.primaryBlue,
                            '/wallet/topup',
                            ref,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionTile(
                            context,
                            'Transfer',
                            Iconsax.send_2,
                            AppColors.successGreen,
                            '/wallet/transfer',
                            ref,
                            requiresBiometric: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionTile(
                            context,
                            'Withdraw',
                            Iconsax.money_send,
                            AppColors.accentOrange,
                            '/wallet/withdraw',
                            ref,
                            requiresBiometric: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Iconsax.setting_4, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                    
                    const SizedBox(height: 16),

                    // Transaction List, Paginated and Stateful
                    if (transactionsState.isInitialLoading)
                      _buildShimmerSkeleton()
                    else if (currentBalance == 0.0 && transactionsState.transactions.isEmpty)
                      _buildEmptyState(context)
                    else if (transactionsState.transactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No transactions yet',
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: transactionsState.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final t = transactionsState.transactions[index];
                          final runningBal = runningBalances[index];
                          return _buildTransactionCard({
                            'title': t.description,
                            'subtitle': t.type == TransactionType.credit ? 'Credit' : 'Debit',
                            'amount': '${t.type == TransactionType.credit ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                            'isDebit': t.type == TransactionType.debit,
                            'time': DateFormat('dd MMM').format(t.timestamp),
                          }, runningBal);
                        },
                      ),
                      
                      // Pagination Load More Button
                      if (transactionsState.hasMore) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: transactionsState.isLoadingMore
                                ? null
                                : () => ref.read(walletTransactionsProvider.notifier).loadMore(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: transactionsState.isLoadingMore
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                                  )
                                : Text(
                                    'Load More',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ],
                    ],
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 76,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 55,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 30,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 1200.ms, color: Colors.grey.shade100);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
              child: const Icon(
                Iconsax.wallet_3,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Wallet is Empty',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add money to your wallet to start booking rides and services instantly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/wallet/topup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add money to get started',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionTile(BuildContext context, String label, IconData icon, Color color, String? route, WidgetRef ref, {bool requiresBiometric = false}) {
    return GestureDetector(
      onTap: () async {
        // ignore: unawaited_futures
        HapticFeedback.lightImpact();
        
        if (requiresBiometric) {
          final bioService = ref.read(biometricServiceProvider);
          final isAvailable = await bioService.isAvailable();
          
          if (isAvailable) {
            final authenticated = await bioService.authenticate(
              localizedReason: 'Please authenticate to perform $label',
            );
            
            if (!authenticated) {
              ref.read(notificationServiceProvider).showError(
                'Authentication Failed',
                message: 'Could not verify your identity. Action cancelled.',
              );
              return;
            }
          }
        }

        if (!context.mounted) return;

        if (route != null) {
          // ignore: unawaited_futures
          context.push(route);
        } else {
          // Placeholder for non-routed actions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label feature coming soon!')),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data, double runningBalance) {
    final bool isDebit = data['isDebit'] as bool;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDebit ? AppColors.dangerRed.withValues(alpha: 0.1) : AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDebit ? Iconsax.arrow_down : Iconsax.arrow_up_3,
              color: isDebit ? AppColors.dangerRed : AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['subtitle'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data['amount'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDebit ? AppColors.textPrimary : AppColors.successGreen,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bal: ₹${runningBalance.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data['time'] as String,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
