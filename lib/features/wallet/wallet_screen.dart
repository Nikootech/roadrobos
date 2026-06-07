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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(walletTransactionsProvider);
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
                            loading: () => const SizedBox(height: 42, width: 100, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
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

                  // Transaction List
                  transactionsAsync.when(
                    data: (transactions) {
                      if (transactions.isEmpty) return const Center(child: Text('No transactions yet'));
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: transactions.length > 10 ? 10 : transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          return _buildTransactionCard({
                            'title': t.description,
                            'subtitle': t.type == TransactionType.credit ? 'Credit' : 'Debit',
                            'amount': '${t.type == TransactionType.credit ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                            'isDebit': t.type == TransactionType.debit,
                            'time': DateFormat('dd MMM').format(t.timestamp),
                          });
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err'),
                  ),
                  
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

  Widget _buildTransactionCard(Map<String, dynamic> data) {
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

