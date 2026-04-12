import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepository(this._firestore);

  /// Get user wallet stream
  Stream<Wallet?> getWallet(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return Wallet.fromMap(snapshot.data()!);
    });
  }

  /// Atomic Wallet Top-up
  Future<void> topUpWallet(String userId, double amount, String paymentId) async {
    final walletRef = _firestore.collection('wallets').doc(userId);
    final transactionRef = _firestore.collection('wallet_transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);
      
      double currentBalance = 0.0;
      if (snapshot.exists) {
        currentBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble();
      }

      final newBalance = currentBalance + amount;

      // Update or create wallet
      transaction.set(walletRef, {
        'userId': userId,
        'balance': newBalance,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Log transaction
      transaction.set(transactionRef, {
        'walletId': userId,
        'amount': amount,
        'type': 'credit',
        'description': 'Wallet Top-up (Ref: $paymentId)',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Atomic Wallet Payment
  Future<bool> payFromWallet(String userId, double amount, String description) async {
    final walletRef = _firestore.collection('wallets').doc(userId);
    final transactionRef = _firestore.collection('wallet_transactions').doc();

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);
      
      if (!snapshot.exists) return false;

      double currentBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble();

      if (currentBalance < amount) return false; // Insufficient funds

      final newBalance = currentBalance - amount;

      // Update wallet
      transaction.update(walletRef, {
        'balance': newBalance,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Log transaction
      transaction.set(transactionRef, {
        'walletId': userId,
        'amount': amount,
        'type': 'debit',
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    });
  }

  /// Get transaction history
  Stream<List<WalletTransaction>> getTransactionHistory(String userId) {
    return _firestore
        .collection('wallet_transactions')
        .where('walletId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WalletTransaction.fromMap(doc.data(), doc.id))
            .toList());
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(FirebaseFirestore.instance);
});

final walletStreamProvider = StreamProvider.family<Wallet?, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getWallet(userId);
});
