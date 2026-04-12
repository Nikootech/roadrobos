import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  Future<void> logTransaction(AppTransaction transaction) async {
    await _firestore.collection('transactions').add(transaction.toMap());
  }

  Stream<List<AppTransaction>> watchUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppTransaction.fromMap(doc.data(), doc.id))
            .toList());
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(FirebaseFirestore.instance);
});
