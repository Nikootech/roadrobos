import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> logTransaction(AppTransaction transaction) async {
    await _supabase.from('transactions').insert(transaction.toMap());
  }

  Stream<List<AppTransaction>> watchUserTransactions(String userId) {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((list) => list
            .map((map) => AppTransaction.fromMap(map, map['id'].toString()))
            .toList());
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});
