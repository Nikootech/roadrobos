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

  /// Atomic Wallet Top-up using RPC
  Future<void> topUpWallet(String userId, double amount, String paymentId) async {
    try {
      await _supabase.rpc('update_wallet_balance', params: {
        'user_id': userId,
        'amount_change': amount,
        'trans_type': 'credit',
        'trans_category': 'topup',
        'trans_description': 'Wallet Top-up (Ref: $paymentId)',
      });
    } catch (e) {
      throw Exception('Failed to top up wallet: $e');
    }
  }

  /// Atomic Wallet Payment using RPC
  Future<bool> payFromWallet(String userId, double amount, String description) async {
    try {
      // We still check local balance for immediate UI feedback, 
      // but the RPC handles the final source of truth and atomic check.
      await _supabase.rpc('update_wallet_balance', params: {
        'user_id': userId,
        'amount_change': -amount,
        'trans_type': 'debit',
        'trans_category': 'payment',
        'trans_description': description,
      });
      return true;
    } catch (e) {
      debugPrint('Wallet Payment Error: $e');
      return false;
    }
  }

  Future<List<WalletTransaction>> getPagedTransactionHistory(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((map) => WalletTransaction.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  /// Transfer funds to another user
  Future<bool> transferFunds(String senderId, String recipientPhone, double amount) async {
    try {
      // 1. Find recipient by phone
      final recipientRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('phone', recipientPhone)
          .maybeSingle();
      
      if (recipientRes == null) {
        throw Exception('User with this phone number not found.');
      }
      
      final recipientId = recipientRes['id'] as String;
      
      if (recipientId == senderId) {
        throw Exception('Cannot transfer to yourself.');
      }

      // 2. Deduct from sender
      final debitSuccess = await payFromWallet(senderId, amount, 'Transfer to $recipientPhone');
      if (!debitSuccess) return false;

      // 3. Add to recipient
      await _supabase.rpc('update_wallet_balance', params: {
        'user_id': recipientId,
        'amount_change': amount,
        'trans_type': 'credit',
        'trans_category': 'transfer',
        'trans_description': 'Transfer received',
      });
      
      return true;
    } catch (e) {
      debugPrint('Transfer Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Withdraw funds to bank
  Future<bool> withdrawFunds(String userId, double amount, String bankDetails) async {
    try {
      final success = await payFromWallet(userId, amount, 'Withdrawal to $bankDetails');
      return success;
    } catch (e) {
      debugPrint('Withdrawal Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletStreamProvider = StreamProvider.family<Wallet?, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getWallet(userId);
});
