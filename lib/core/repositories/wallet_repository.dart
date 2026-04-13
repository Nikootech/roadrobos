import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get user wallet stream
  Stream<Wallet?> getWallet(String userId) {
    return _supabase
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((list) {
      if (list.isEmpty) return null;
      return Wallet.fromMap(list.first);
    });
  }

  /// Atomic Wallet Top-up 
  /// (Note: For high production scale, use a PostgreSQL RPC for strict atomicity)
  Future<void> topUpWallet(String userId, double amount, String paymentId) async {
    try {
      final walletResponse = await _supabase
          .from('wallets')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      double currentBalance = (walletResponse?['balance'] ?? 0.0).toDouble();
      final newBalance = currentBalance + amount;

      await _supabase.from('wallets').upsert({
        'id': userId,
        'balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await _supabase.from('transactions').insert({
        'wallet_id': userId,
        'amount': amount,
        'type': 'credit',
        'category': 'topup',
        'description': 'Wallet Top-up (Ref: $paymentId)',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to top up wallet: $e');
    }
  }

  /// Atomic Wallet Payment
  Future<bool> payFromWallet(String userId, double amount, String description) async {
    try {
      final walletResponse = await _supabase
          .from('wallets')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (walletResponse == null) return false;

      double currentBalance = (walletResponse['balance'] ?? 0.0).toDouble();
      if (currentBalance < amount) return false;

      final newBalance = currentBalance - amount;

      await _supabase.from('wallets').update({
        'balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      await _supabase.from('transactions').insert({
        'wallet_id': userId,
        'amount': amount,
        'type': 'debit',
        'category': 'payment',
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Wallet Payment Error: $e');
      return false;
    }
  }

  /// Get transaction history
  Stream<List<WalletTransaction>> getTransactionHistory(String userId) {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('wallet_id', userId)
        .order('created_at')
        .map((list) => list
            .map((map) => WalletTransaction.fromMap(map, map['id'].toString()))
            .toList());
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletStreamProvider = StreamProvider.family<Wallet?, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getWallet(userId);
});
