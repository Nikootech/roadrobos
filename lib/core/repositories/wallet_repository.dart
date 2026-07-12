import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final SupabaseClient _supabase;

  WalletRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

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
  Future<void> topUpWallet(
      String userId, double amount, String paymentId) async {
    try {
      await _supabase.rpc('update_wallet_balance', params: {
        'wallet_id': userId,
        'amount': amount,
        'transaction_type': 'credit',
      });
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      throw Exception('Failed to top up wallet: $e');
    }
  }

  /// Atomic Wallet Payment using RPC
  Future<bool> payFromWallet(
      String userId, double amount, String description) async {
    try {
      // We still check local balance for immediate UI feedback,
      // but the RPC handles the final source of truth and atomic check.
      await _supabase.rpc('update_wallet_balance', params: {
        'wallet_id': userId,
        'amount': amount,
        'transaction_type': 'debit',
      });
      return true;
    } on PostgrestException catch (e, st) {
      if (e.code != 'P0001') {
        unawaited(Sentry.captureException(e, stackTrace: st));
      }
      if (e.code == 'P0001') {
        throw InsufficientBalanceException();
      }
      debugPrint('Postgres Wallet Payment Error: $e');
      rethrow;
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      debugPrint('Wallet Payment Error: $e');
      rethrow;
    }
  }

  Future<List<WalletTransaction>> getPagedTransactionHistory(String userId,
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((map) => WalletTransaction.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  /// SECURE RPC user lookup by phone
  Future<Map<String, dynamic>?> lookupUserByPhone(String phone) async {
    try {
      final List<dynamic> response =
          await _supabase.rpc('lookup_user_by_phone', params: {
        'phone_param': phone,
      });
      if (response.isEmpty) return null;
      return Map<String, dynamic>.from(response.first);
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      debugPrint('Lookup User Error: $e');
      throw Exception('Failed to lookup recipient: $e');
    }
  }

  /// Transfer funds to another user atomically via a single Supabase RPC.
  ///
  /// Uses the `transfer_funds` PostgreSQL function (migration
  /// 038_transfer_funds_atomic.sql) which wraps both the debit and
  /// credit in a single transaction — no funds can disappear if the app
  /// crashes or the network drops between two separate calls.
  Future<bool> transferFunds(
      String senderId, String recipientPhone, double amount) async {
    try {
      // 1. Find recipient by phone using secure RPC
      final recipientRes = await lookupUserByPhone(recipientPhone);

      if (recipientRes == null) {
        throw Exception('User with this phone number not found.');
      }

      final recipientId = recipientRes['id'] as String;

      if (recipientId == senderId) {
        throw Exception('Cannot transfer to yourself.');
      }

      // 2. Single atomic RPC — replaces the old 2-step debit + credit pattern.
      //    The DB function uses SELECT FOR UPDATE locking to prevent race conditions.
      final result = await _supabase.rpc('transfer_funds', params: {
        'sender_id': senderId,
        'receiver_id': recipientId,
        'amount': amount,
        'description':
            'Transfer to ${recipientRes['full_name'] ?? recipientPhone}',
      });

      final success = result?['success'] == true;
      if (!success) {
        throw Exception('Transfer failed. Please try again.');
      }

      return true;
    } on PostgrestException catch (e, st) {
      // Map named PostgreSQL exceptions to user-friendly messages.
      final msg = e.message;
      if (msg.contains('insufficient_funds')) {
        throw Exception('Insufficient wallet balance.');
      } else if (msg.contains('receiver_not_found')) {
        throw Exception(
            'Recipient wallet not found. They may need to add funds first.');
      } else if (msg.contains('sender_not_found')) {
        throw Exception('Your wallet was not found. Please contact support.');
      } else if (msg.contains('invalid_amount')) {
        throw Exception(
            'Invalid transfer amount. Amount must be greater than zero.');
      } else if (msg.contains('same_account')) {
        throw Exception('Cannot transfer funds to yourself.');
      }
      unawaited(Sentry.captureException(e, stackTrace: st));
      debugPrint('Transfer PostgrestException: $e');
      throw Exception('Transfer failed: ${e.message}');
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      debugPrint('Transfer Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Withdraw funds to bank
  Future<bool> withdrawFunds(
      String userId, double amount, String bankDetails) async {
    try {
      await _supabase.rpc('create_payout_request', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_bank_details': bankDetails,
      });
      return true;
    } on PostgrestException catch (e, st) {
      if (e.code == 'P0001') {
        throw InsufficientBalanceException();
      }
      unawaited(Sentry.captureException(e, stackTrace: st));
      debugPrint('Withdrawal Error: $e');
      rethrow;
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      debugPrint('Withdrawal Error: $e');
      rethrow;
    }
  }

  Future<void> syncTransaction(
      String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'create_transaction':
        await _supabase.from('wallet_transactions').upsert(payload);
        break;
      case 'update_transaction_status':
        await _supabase
            .from('wallet_transactions')
            .update({'status': payload['status']}).eq('id', payload['id']);
        break;
      default:
        throw Exception('Unknown wallet_transaction action: $action');
    }
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletStreamProvider =
    StreamProvider.family<Wallet?, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getWallet(userId);
});

class InsufficientBalanceException implements Exception {
  final String message;
  InsufficientBalanceException([this.message = 'insufficient_balance']);

  @override
  String toString() => message;
}
